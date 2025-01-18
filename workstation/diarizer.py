import zmq
import torch
import numpy as np
import pandas as pd
from datetime import timedelta
from pyannote.audio import Pipeline, Model, Inference
from pyannote.core import Segment
import whisperx
from pydub import AudioSegment
from collections import defaultdict

def format_timedelta(seconds):
    """Convert seconds to HH:MM:SS.mmm format"""
    td = timedelta(seconds=seconds)
    hours = td.seconds//3600
    minutes = (td.seconds//60)%60
    seconds = td.seconds%60
    milliseconds = td.microseconds//1000
    return f"{hours:02d}:{minutes:02d}:{seconds:02d}.{milliseconds:03d}"

# def abbreviate_speaker(filename, speaker):
#     """Convert SPEAKER_XX to chunk_index_XX format"""
#     speaker_num = speaker.split('_')[-1]
#     return f"{filename}_{speaker_num.zfill(2)}"

class AudioProcessor:
    def __init__(self, hf_token):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"Using device: {self.device}")
        
        # Initialize models
        self.pipeline = Pipeline.from_pretrained(
            "pyannote/speaker-diarization-3.1",
            use_auth_token=hf_token,
        ).to(torch.device(self.device))
        
        self.embedding_model = Model.from_pretrained(
            "pyannote/embedding",
            use_auth_token=hf_token
        )
        self.inference = Inference(self.embedding_model, window="whole")
        
        self.whisperx_model = whisperx.load_model("base", self.device, compute_type="float32")
        
        # Storage for speaker embeddings
        self.speaker_embeddings = defaultdict(list)
        self.transcript = []
        
    def process_file(self, audio_path, max_speakers=2):
        """Process a single audio chunk"""
        # Prepare audio for diarization
        # waveform = torch.from_numpy(audio_data[np.newaxis, :])
        
        # Perform diarization
        diarization = self.pipeline(audio_path)
        
        chunk_transcript = []
        audio = AudioSegment.from_file(audio_path)
        self.speaker_embeddings = defaultdict(list)
        # Process each segment
        for segment, track, speaker in diarization.itertracks(yield_label=True):
            # Adjust segment times to account for chunk position in original audio
            absolute_start = segment.start
            absolute_end = segment.end
            
            try:
                # Get speaker embedding for the segment
                segment_obj = Segment(segment.start, segment.end)
                embedding = self.inference.crop(audio_path, segment_obj)
                self.speaker_embeddings[speaker].append(embedding.squeeze())
                
                        # Extract and transcribe audio segment
                start_time = segment.start * 1000
                end_time = segment.end * 1000
                segment_audio = audio[start_time:end_time]
                
                samples = np.array(segment_audio.get_array_of_samples())
                if segment_audio.channels > 1:
                    samples = samples.reshape((-1, segment_audio.channels)).mean(axis=1)
                samples = samples.astype(np.float32) / 32768.0
                
                result = self.whisperx_model.transcribe(samples, language="en")
                
                # Transcribe segment
                
                if result["segments"]:
                    # abbreviated_speaker = abbreviate_speaker(timestamp, speaker)
                    chunk_transcript.append({
                        'speaker': speaker,
                        'start': format_timedelta(absolute_start),
                        'end': format_timedelta(absolute_end),
                        'text': result["segments"][0]["text"].strip()
                    })
                
            except Exception as e:
                print(f"Error processing segment {absolute_start:.2f}-{absolute_end:.2f}: {str(e)}")
                continue
        
        return chunk_transcript

def receive_and_process_audio(zmq_port=5555, hf_token=None):
    if not hf_token:
        raise ValueError("HuggingFace token is required")
    
    # Initialize ZMQ
    context = zmq.Context()
    socket = context.socket(zmq.REP)
    socket.bind(f"tcp://*:{zmq_port}")
    
    # Initialize processor
    processor = AudioProcessor(hf_token)
    
    print("Waiting for audio chunks...")
    
    
    try:
        # Clear transcript file at start
        while True:
            # Receive message
            message = socket.recv_pyobj()
            filename = message['file_name']
            base_epoch = int(filename.split('/')[-2]) 
            print(f"Processing file {filename} {base_epoch}")
            
            # Process the chunk
            transcript = processor.process_file(
                filename,
            )
            dir_path = os.path.splitext(filename)[0] + os.sep
            os.makedirs(dir_path, exist_ok=True)
            # Append to transcript file
            # Convert and write transcript in new format
            with open(f'{dir_path}/transcript.txt', 'w', encoding='utf-8') as f:
                for seg in transcript:
                    # Convert timestamp to seconds and add to base epoch
                    time_parts = seg['start'].split(':')
                    seconds = (int(time_parts[0]) * 3600 + 
                             int(time_parts[1]) * 60 + 
                             float(time_parts[2]))
                    epoch_time = base_epoch + int(seconds)
                    
                    # Write in new format
                    transcript_line = f"{seg['speaker']}:{epoch_time}:{seg['text']}\n"
                    f.write(transcript_line)
            
            average_embeddings = {}
            for speaker, embeddings in processor.speaker_embeddings.items():
                average_embeddings[speaker] = np.mean(embeddings, axis=0)
            
            embedding_df = pd.DataFrame([
                {'speaker': speaker, **{f'dim_{i}': val for i, val in enumerate(emb)}}
                for speaker, emb in average_embeddings.items()
            ])
            
            # Write with header only if it's the first chunk, append for subsequent chunks
            embedding_df.to_csv(f'{dir_path}/speaker_embeddings.csv', index=False)
            
            # Send acknowledgment back to sender
            socket.send_string(f"Processed file {filename}")
            
    
    finally:
        socket.close()
        context.term()

if __name__ == "__main__":
    import os
    hf_token = os.getenv("HUGGINGFACE_TOKEN")
    if not hf_token:
        print("Please set HUGGINGFACE_TOKEN environment variable")
        exit(1)
    
    receive_and_process_audio(hf_token=hf_token)