from pyannote.audio import Pipeline, Model
from pyannote.audio import Inference
from pyannote.core import Segment
import torch
torch.backends.cuda.matmul.allow_tf32 = True
torch.backends.cudnn.allow_tf32 = True
import whisper
from pydub import AudioSegment
import numpy as np
from datetime import timedelta
import pandas as pd
from collections import defaultdict
from sklearn.metrics.pairwise import cosine_similarity

def cosine_similarity_matrix(csv_file):
    # Read the speaker embeddings from the CSV file
    df = pd.read_csv(csv_file)
    
    # Extract the speaker names and embeddings
    speakers = df['speaker'].unique()
    embeddings = df.iloc[:, 1:].values
    
    # Calculate the cosine similarity matrix
    similarity_matrix = cosine_similarity(embeddings)
    
    # Create a DataFrame with speaker names as row and column labels
    similarity_df = pd.DataFrame(similarity_matrix, index=speakers, columns=speakers)
    
    return similarity_df

def format_timedelta(seconds):
    """Convert seconds to HH:MM:SS.mmm format"""
    td = timedelta(seconds=seconds)
    hours = td.seconds//3600
    minutes = (td.seconds//60)%60
    seconds = td.seconds%60
    milliseconds = td.microseconds//1000
    return f"{hours:02d}:{minutes:02d}:{seconds:02d}.{milliseconds:03d}"

def process_audio(audio_path, pipeline_token=None):
    # Initialize the diarization pipeline
    pipeline = Pipeline.from_pretrained(
        "pyannote/speaker-diarization-3.0",
        use_auth_token=pipeline_token
    )
    
    # Initialize embedding model and inference
    embedding_model = Model.from_pretrained(
        "pyannote/embedding",
        use_auth_token=pipeline_token
    )
    inference = Inference(embedding_model, window="whole")
    
    # Move pipeline to GPU if available
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    pipeline.to(device)
    
    # Initialize Whisper model
    whisper_model = whisper.load_model("medium", device=device)
    
    # Perform diarization
    diarization = pipeline(audio_path)
    
    # Load audio file for transcription
    audio = AudioSegment.from_file(audio_path)
    
    # Store results and embeddings
    results = []
    speaker_embeddings = defaultdict(list)
    
    # Process each speech segment
    for segment, track, speaker in diarization.itertracks(yield_label=True):
        # Create Segment object for embedding extraction
        segment_duration = segment.end - segment.start
        if segment_duration < 0.5:
            print(f"Skipping segment {segment.start:.2f}-{segment.end:.2f} (duration: {segment_duration:.2f}s) - too short")
            continue
            
        try:
            # Create Segment object for embedding extraction
            segment_obj = Segment(segment.start, segment.end)
            
            # Get speaker embedding for this segment
            embedding = inference.crop(audio_path, segment_obj)
            speaker_embeddings[speaker].append(embedding.squeeze())  # Remove batch dimension
            print(f"Processed segment {segment.start:.2f}-{segment.end:.2f} (duration: {segment_duration:.2f}s)")
        except Exception as e:
            print(f"Error processing segment {segment.start:.2f}-{segment.end:.2f}: {str(e)}")
            continue
        
        # Extract the speech segment for transcription
        start_time = segment.start * 1000  # Convert to milliseconds
        end_time = segment.end * 1000
        segment_audio = audio[start_time:end_time]
        
        # Convert segment to numpy array
        samples = np.array(segment_audio.get_array_of_samples())
        if segment_audio.channels > 1:
            samples = samples.reshape((-1, segment_audio.channels)).mean(axis=1)
        samples = samples.astype(np.float32) / 32768.0  # Normalize
        
        # Transcribe the segment
        result = whisper_model.transcribe(samples, language="en")
        
        # Store results
        results.append({
            'speaker': speaker,
            'start': format_timedelta(segment.start),
            'end': format_timedelta(segment.end),
            'text': result['text'].strip()
        })
    
    # Calculate average embeddings per speaker
    average_embeddings = {}
    for speaker, embeddings in speaker_embeddings.items():
        average_embeddings[speaker] = np.mean(embeddings, axis=0)
    
    # Save speaker embeddings to CSV
    embedding_df = pd.DataFrame([
        {'speaker': speaker, **{f'dim_{i}': val for i, val in enumerate(emb)}}
        for speaker, emb in average_embeddings.items()
    ])
    embedding_df.to_csv('speaker_embeddings.csv', index=False)
    
    return results, average_embeddings

def main():
    # Replace with your audio file path
    audio_path = "Files/1737003186/combined_output.wav"
    # Replace with your HuggingFace token
    hf_token = os.getenv("HUGGINGFACE_TOKEN")
    if not hf_token:
        print("Please set HUGGINGFACE_TOKEN environment variable")
        exit(1)
    
    # Process the audio
    results, embeddings = process_audio(audio_path, hf_token)
    
    # Print results
    for segment in results:
        print(f"[{segment['start']} -> {segment['end']}] {segment['speaker']}: {segment['text']}")
    
    print("\nSpeaker embeddings have been saved to 'speaker_embeddings.csv'")
    similarity_matrix = cosine_similarity_matrix('speaker_embeddings.csv')
    print(similarity_matrix)

if __name__ == "__main__":
    main()