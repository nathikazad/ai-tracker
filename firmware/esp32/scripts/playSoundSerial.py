import wave
import numpy as np
import serial
import time
import struct

# Constants for start and stop markers
START_MARKER = 0xFFFF
STOP_MARKER = 0xFFFE

# Open the WAV file
with wave.open('input.wav', 'rb') as wav_file:
    # Ensure the file matches our expectations
    assert wav_file.getnchannels() == 1, "File is not mono"
    assert wav_file.getsampwidth() == 2, "File is not 16-bit"
    assert wav_file.getframerate() == 48000, "File is not 48kHz"
    
    # Read the first 8 seconds of audio data
    n_frames = min(wav_file.getnframes(), 8 * 48000)
    audio_data = np.frombuffer(wav_file.readframes(n_frames), dtype=np.int16)

print("length of audio data: ", len(audio_data))
audio_data = audio_data[::6]
print("length of audio data: ", len(audio_data))
# Downsample to 4 Hz
# target_rate = 4
# downsampling_factor = 48000 // target_rate
# downsampled_data = audio_data[::downsampling_factor]

# # Ensure the data is in the range of 0 to 65535 for 16-bit DAC
normalized_data = ((audio_data - np.min(audio_data)) / (np.max(audio_data) - np.min(audio_data)) * 65533).astype(np.uint16)
# Note: We use 65533 instead of 65535 to avoid conflict with START_MARKER and STOP_MARKER
print("length of normalized data: ", len(normalized_data))
# # Set up serial connection (adjust port as needed)
ser = serial.Serial('/dev/cu.usbmodem1101', 115200)

# Send start marker
ser.write(struct.pack('>H', START_MARKER))

# Send data over serial with delay
delay = 1 / 12000
# print("delay: ", delay)
start_time = time.time()

sample_count = 0
for sample in normalized_data:
    if struct.pack('>H', sample) != struct.pack('>H', START_MARKER):
        ser.write(struct.pack('>H', sample))
    time.sleep(delay)

time.sleep(1)
# Send stop marker
ser.write(struct.pack('>H', STOP_MARKER))

end_time = time.time()

# Calculate timing information
total_time = end_time - start_time
average_sample_rate = len(normalized_data) / total_time

# Print timing information
# print(f"Time taken to send all samples: {total_time:.2f} seconds")
# print(f"Number of samples sent: {len(normalized_data)}")
# print(f"Average sample rate: {average_sample_rate:.2f} Hz")

# Wait for timing information from ESP32
print("Waiting for timing information from ESP32...")
while True:
    if ser.in_waiting:
        print(ser.readline().decode().strip())
    # if "Average sample rate:" in ser.readline().decode().strip():
    #     break

# ser.close()