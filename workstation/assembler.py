import os
import wave
import numpy as np
from dataclasses import dataclass
from typing import List, Optional
import soundfile as sf
import whisper
import torch
import faster_whisper
import os
import soundfile as sf


@dataclass
class AudioSegment:
    start_time: float      # Unix timestamp from filename
    duration: float        # Duration in seconds
    file_path: str        # Full path to the file
    sample_rate: int      # Sample rate of the audio
    n_channels: int       # Number of channels
    end_time: float       # Calculated end time (start_time + duration)

def get_wav_duration(file_path: str) -> tuple[float, int, int]:
    """Get duration, sample rate, and number of channels from a WAV file."""
    with wave.open(file_path, 'rb') as wav:
        frames = wav.getnframes()
        rate = wav.getframerate()
        channels = wav.getnchannels()
        duration = frames / float(rate)
        return duration, rate, channels

def analyze_wav_files(directory_path: str) -> List[AudioSegment]:
    """
    Analyze all WAV files in directory and create AudioSegment objects.
    Returns list of segments sorted by start time.
    """
    segments = []
    
    for file in os.listdir(directory_path):
        if not file.endswith('.wav'):
            continue
            
        file_path = os.path.join(directory_path, file)
        try: 
            start_time = float(file.replace('.wav', ''))
        except:
            continue
        duration, rate, channels = get_wav_duration(file_path)
        
        segment = AudioSegment(
            start_time=start_time,
            duration=duration,
            file_path=file_path,
            sample_rate=rate,
            n_channels=channels,
            end_time=start_time + duration
        )
        segments.append(segment)
    
    return sorted(segments, key=lambda x: x.start_time)

def combine_wav_files(directory_path: str, out_file: str) -> None:
    """
    Combines WAV files from directory, automatically calculating and inserting gaps.
    """
    # Step 1: Analyze all files and create segments
    segments = analyze_wav_files(directory_path)
    
    if not segments:
        raise ValueError("No WAV files found in directory")
    
    # Step 2: Verify all files have same audio parameters
    first_segment = segments[0]
    if not all(seg.sample_rate == first_segment.sample_rate and 
               seg.n_channels == first_segment.n_channels for seg in segments):
        raise ValueError("All WAV files must have the same sample rate and number of channels")
    
    # Step 3: Create output file
    output_path = os.path.join(directory_path, out_file)
    with wave.open(output_path, 'wb') as output_wav:
        output_wav.setnchannels(first_segment.n_channels)
        output_wav.setsampwidth(2)  # Assuming 16-bit audio
        output_wav.setframerate(first_segment.sample_rate)
        
        # Step 4: Process each segment and add gaps where needed
        for i, current_seg in enumerate(segments):
            if i > 0:
                prev_seg = segments[i-1]
                time_gap = current_seg.start_time - prev_seg.end_time
                
                if time_gap > 0.001:  # Small tolerance for floating point comparison
                    # Calculate gap frames
                    gap_frames = int(time_gap * first_segment.sample_rate)
                    gap_samples = np.zeros(gap_frames * first_segment.n_channels, 
                                         dtype=np.int16)
                    output_wav.writeframes(gap_samples.tobytes())
            
                # Write current segment
            with wave.open(current_seg.file_path, 'rb') as wav:
                # Read frames as bytes
                frames = wav.readframes(wav.getnframes())
                # Convert bytes to numpy array
                audio_data = np.frombuffer(frames, dtype=np.int16)
                # Double the volume, but clip to prevent overflow
                audio_data = np.clip(audio_data * 2, -32768, 32767).astype(np.int16)
                # Write the amplified audio
                output_wav.writeframes(audio_data.tobytes())
    
    # Print summary
    total_duration = segments[-1].end_time - segments[0].start_time
    print(f"Created combined WAV file: {output_path}")
    print(f"Total segments: {len(segments)}")
    print(f"Total duration: {total_duration:.2f} seconds")
    print(f"Time range: {segments[0].start_time} to {segments[-1].end_time}")
    return output_path

def transcribe_audio(audio_path: str, output_dir: str = None) -> None:
    """Transcribe audio file using Whisper and save transcripts."""

    
    if output_dir is None:
        output_dir = os.path.dirname(audio_path)
    
    print("\nValidating input audio file...")
    info = sf.info(audio_path)
    print(f"Duration: {info.duration:.2f}s")
    print(f"Channels: {info.channels}")
    print(f"Sample rate: {info.samplerate}Hz")
    
    device = "cuda" if torch.cuda.is_available() else "cpu"
    
    print("\nLoading Whisper model...")
    model = faster_whisper.WhisperModel(
        "medium.en",
        device=device,
        compute_type="float32",
        cpu_threads=4,
        num_workers=2
    )
    
    print("\nStarting transcription with debug info...")
    try:
        # First attempt with basic VAD settings
        segments_result, info = model.transcribe(
            audio_path,
            beam_size=5,
            vad_filter=True,
            vad_parameters=dict(
                min_silence_duration_ms=500,
                speech_pad_ms=400
            ),
            language="en",
            condition_on_previous_text=True
        )
        
        # Convert generator to list and check if empty
        segments_list = list(segments_result)
        if not segments_list:
            print("WARNING: No segments were transcribed with VAD!")
            print("Trying without VAD filter...")
            segments_result, info = model.transcribe(
                audio_path,
                beam_size=5,
                vad_filter=False,
                language="en"
            )
            segments_list = list(segments_result)
    
        print(f"\nTranscription info: {info}")
        print(f"Number of segments: {len(segments_list)}")
        
        # Generate output paths
        base_name = os.path.splitext(os.path.basename(audio_path))[0]
        transcript_path = os.path.join(output_dir, f'{base_name}_transcript.txt')
        srt_path = os.path.join(output_dir, f'{base_name}_transcript.srt')
        
        # Save plain text transcript
        with open(transcript_path, 'w', encoding='utf-8') as f:
            for segment in segments_list:
                f.write(f"[{segment.start:.2f}s -> {segment.end:.2f}s] {segment.text}\n")
        
        # Save SRT format
        with open(srt_path, 'w', encoding='utf-8') as f:
            for i, segment in enumerate(segments_list, start=1):
                start = '{0:02d}:{1:02d}:{2:02d},{3:03d}'.format(
                    int(segment.start // 3600),
                    int((segment.start % 3600) // 60),
                    int(segment.start % 60),
                    int((segment.start % 1) * 1000)
                )
                end = '{0:02d}:{1:02d}:{2:02d},{3:03d}'.format(
                    int(segment.end // 3600),
                    int((segment.end % 3600) // 60),
                    int(segment.end % 60),
                    int((segment.end % 1) * 1000)
                )
                
                f.write(f"{i}\n")
                f.write(f"{start} --> {end}\n")
                f.write(f"{segment.text.strip()}\n\n")
        
        print(f"Transcription completed!")
        print(f"Text transcript saved to: {transcript_path}")
        print(f"SRT subtitle file saved to: {srt_path}")
        print("\nFirst few segments of transcription:")
        for segment in segments_list[:3]:
            print(f"[{segment.start:.2f}s -> {segment.end:.2f}s] {segment.text}")
            
    except Exception as e:
        print(f"Transcription error: {e}")
        raise
    
    finally:
        del model
        if torch.cuda.is_available():
            torch.cuda.empty_cache()


def resample_wav(input_path, output_path, original_sr=4000, target_sr=16000):
    """
    Resample a WAV file from 4kHz to 16kHz.
    
    Args:
        input_path (str): Path to input WAV file
        output_path (str): Path to save resampled WAV file
        original_sr (int): Original sampling rate (default: 4000)
        target_sr (int): Target sampling rate (default: 16000)
    """
    import librosa
    try:
        # Load the audio file
        # res_type='kaiser_best' provides the highest quality resampling
        audio, _ = librosa.load(input_path, sr=original_sr)
        
        # Resample the audio
        resampled_audio = librosa.resample(
            y=audio,
            orig_sr=original_sr,
            target_sr=target_sr,
            res_type='kaiser_best'
        )
        
        # Save the resampled audio
        sf.write(output_path, resampled_audio, target_sr, subtype='PCM_16')
        
        print(f"Successfully resampled {input_path} to {output_path}")
        print(f"Original duration: {len(audio)/original_sr:.2f} seconds")
        print(f"Resampled duration: {len(resampled_audio)/target_sr:.2f} seconds")
        
    except Exception as e:
        print(f"Error processing file: {str(e)}")

if __name__ == "__main__":
    output_path = combine_wav_files("Files/1737003186", 'out.wav')