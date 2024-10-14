import asyncio
from bleak import BleakClient, BleakScanner
import struct
import wave
import time
import os
from openai import OpenAI
# BLE device name (should match the name set in the ESP32 code)
DEVICE_NAME = "ESP32_Audio_System"
# UUID of the characteristic to notify (should match the one in the ESP32 code)
NOTIFY_CHARACTERISTIC_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

audio_data = bytearray()
expected_packets = 0
received_packets = 0
file_counter = 0

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
    global file_counter
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

# def transcribe_audio(filename):
#     global model
#     result = model.transcribe(filename, fp16=False)
#     return result["text"]

def transcribe_audio(file_path):
    # Set the API key
    client = OpenAI(
        api_key=os.environ.get("OPENAI_API_KEY")
    )

    # Check if file exists
    if not os.path.isfile(file_path):
        return "Error: File not found."

    try:
        # Open the audio file
        with open(file_path, "rb") as audio_file:
            # Transcribe the audio file
            transcript = client.audio.transcriptions.create(
                model="whisper-1", 
                file=audio_file
                )
            print(transcript)

        # Return the transcribed text
        return transcript.text
    except Exception as e:
        return f"An error occurred during transcription: {str(e)}"

async def run_ble_client():
    global audio_data, expected_packets, received_packets, start_time
    start_time = 0

    def notification_handler(sender, data):
        global audio_data, expected_packets, received_packets, start_time

        if data[:5] == b'START':
            audio_data.clear()
            start_time = time.time()
            expected_packets = struct.unpack('>I', b'\x00' + data[5:])[0]
            received_packets = 0
            print(f"Starting to receive {expected_packets} packets")
        elif data[:2] == b'\xFF\xFF':
            chunk_index = struct.unpack('>H', data[2:4])[0]
            audio_data.extend(data[4:])
            received_packets += 1
            print(f"Received packet {received_packets}/{expected_packets}", end='\r')
        elif data[:3] == b'END':
            end_time = time.time()
            duration = (end_time - start_time) * 1000  # Convert to milliseconds
            print(f"\nAudio data received successfully. Total time: {duration:.2f} ms")
            audio_file = save_wav_file()
            start_time = time.time()
            transcription = transcribe_audio(audio_file)
            end_time = time.time()
            print("Transcription:", transcription)
            duration = (end_time - start_time) * 1000  # Convert to milliseconds
            print(f"\nAudio data received successfully. Total time: {duration:.2f} ms")
        else:
            print(f"Received unexpected data: {data}")

    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return

    async with BleakClient(device) as client:
        global model
        print(f"Connected to {device.name}")
        # model = whisper.load_model("tiny")
        await client.start_notify(NOTIFY_CHARACTERISTIC_UUID, notification_handler)
        print("Waiting for audio data...")
        
        while True:
            await asyncio.sleep(1)

if __name__ == "__main__":
    asyncio.run(run_ble_client())