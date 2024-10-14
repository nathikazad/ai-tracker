import asyncio
from bleak import BleakClient, BleakScanner
import struct
import wave
import time
import os
import numpy as np
from openai import OpenAI

# BLE device name (should match the name set in the ESP32 code)
DEVICE_NAME = "ESP32_Audio_System"
# UUID of the characteristic to notify (should match the one in the ESP32 code)
NOTIFY_CHARACTERISTIC_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
# UUID of the characteristic to write (should match the one in the ESP32 code)
WRITE_CHARACTERISTIC_UUID = "6E400004-B5A3-F393-E0A9-E50E24DCCA9E"

START_MARKER = 0xFFFF
STOP_MARKER = 0xFFFE
CHUNK_SIZE = 512  # Adjust based on your BLE MTU size

audio_data = bytearray()
expected_packets = 0
received_packets = 0
file_counter = 0
audio_received = asyncio.Event()

def generate_wav_header(sample_rate, bits_per_sample, channels, data_size):
    header = bytearray(44)
    header[0:4] = b'RIFF'
    struct.pack_into('<I', header, 4, data_size + 36)
    header[8:12] = b'WAVE'
    header[12:16] = b'fmt '
    struct.pack_into('<I', header, 16, 16)
    struct.pack_into('<H', header, 20, 1)
    struct.pack_into('<H', header, 22, channels)
    struct.pack_into('<I', header, 24, sample_rate)
    struct.pack_into('<I', header, 28, sample_rate * channels * (bits_per_sample // 8))
    struct.pack_into('<H', header, 32, channels * (bits_per_sample // 8))
    struct.pack_into('<H', header, 34, bits_per_sample)
    header[36:40] = b'data'
    struct.pack_into('<I', header, 40, data_size)
    return header

def save_wav_file():
    global file_counter, audio_data
    sample_rate = 4000
    bits_per_sample = 16
    channels = 1
    wav_header = generate_wav_header(sample_rate, bits_per_sample, channels, len(audio_data))
    
    filename = f"audio_recordings/recorded_audio_{file_counter}.wav"
    with wave.open(filename, "wb") as wav_file:
        wav_file.setnchannels(channels)
        wav_file.setsampwidth(bits_per_sample // 8)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(wav_header + audio_data)
    
    print(f"Audio saved as '{filename}'")
    file_counter += 1
    return filename

def transcribe_audio(file_path):
    client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

    if not os.path.isfile(file_path):
        return "Error: File not found."

    try:
        with open(file_path, "rb") as audio_file:
            transcript = client.audio.transcriptions.create(
                model="whisper-1", 
                file=audio_file
            )
        return transcript.text
    except Exception as e:
        return f"An error occurred during transcription: {str(e)}"

async def send_audio_data(client, data):
    send_start_time = time.time()
    print("Number of packets to send: ", len(data) // CHUNK_SIZE)
    for i in range(0, len(data), CHUNK_SIZE):
        chunk = data[i:i+CHUNK_SIZE]
        await client.write_gatt_char(WRITE_CHARACTERISTIC_UUID, chunk)
    duration = time.time() - send_start_time
    print(f"Time taken to send audio data: {duration:.2f} seconds")
    print("Audio data sent successfully")

def notification_handler(sender, data):
    global audio_data, expected_packets, received_packets, audio_received

    if data[:5] == b'START':
        audio_data.clear()
        expected_packets = struct.unpack('>I', b'\x00' + data[5:])[0]
        received_packets = 0
        print(f"Starting to receive {expected_packets} packets")
    elif data[:2] == b'\xFF\xFF':
        print("Received packet number: ",data[2], data[3])
        audio_data.extend(data[4:])
        received_packets += 1
        print(f"Received packet {received_packets}/{expected_packets}", end='\r')
    elif data[:3] == b'END':
        print("\nAudio data received successfully.")
        audio_received.set()
    else:
        print(f"Received unexpected data: {data}")

async def run_ble_client():
    global audio_received

    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return

    async with BleakClient(device) as client:
        print(f"Connected to {device.name}")
        await client.start_notify(NOTIFY_CHARACTERISTIC_UUID, notification_handler)
        
        while True:
            print("Waiting for audio data...")
            audio_received.clear()
            await audio_received.wait()
            
            audio_file = save_wav_file()
            print("Transcribing audio...")
            transcription = transcribe_audio(audio_file)
            print("Transcription:", transcription)
            
            print("Sending audio file back to the device...")
            with wave.open('input.wav', 'rb') as wav_file:
                assert wav_file.getnchannels() == 1, "File is not mono"
                assert wav_file.getsampwidth() == 2, "File is not 16-bit"
                assert wav_file.getframerate() == 48000, "File is not 48kHz"
                
                n_frames = min(wav_file.getnframes(), 8 * 48000)
                audio_data = np.frombuffer(wav_file.readframes(n_frames), dtype=np.int16)
                
                # Downsample to 8kHz
                audio_data = audio_data[::12]
                
                # Normalize data
                normalized_data = ((audio_data - np.min(audio_data)) / (np.max(audio_data) - np.min(audio_data)) * 65533).astype(np.uint16)
                
                # Send start marker
                await client.write_gatt_char(WRITE_CHARACTERISTIC_UUID, struct.pack('>H', START_MARKER))
                
                # Send audio data
                await send_audio_data(client, normalized_data.tobytes())
                
                # Send stop marker
                await client.write_gatt_char(WRITE_CHARACTERISTIC_UUID, struct.pack('>H', STOP_MARKER))
            
            print("Audio file sent. Waiting for next transmission...")

if __name__ == "__main__":
    asyncio.run(run_ble_client())