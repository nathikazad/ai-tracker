import asyncio
from bleak import BleakClient, BleakScanner
import time
import struct
import wave
import numpy as np
from openai import OpenAI
import os
import tempfile
from pathlib import Path
from rp2040.scripts.cmdmp3Transfer import send_file, send_command

# BLE Configuration
DEVICE_NAME = "Audio Sender"
DATA_CHARACTERISTIC_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"



# Global variables for BLE
ble_client = None
running = True
audio_data = bytearray()
expected_packets = 0
received_packets = 0
file_number = 0
full_text = ""

# OpenAI client
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

# Step and index tables for ADPCM decoding
step_table = [
    7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
    50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230,
    253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963,
    1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327,
    3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442,
    11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794,
    32767
]

index_table = [-1, -1, -1, -1, 2, 4, 6, 8]

class AudioProcessor:
    def __init__(self):
        self.temp_dir = tempfile.mkdtemp()
        print(f"Using temporary directory: {self.temp_dir}")

    def adpcm_decode_block(self, inbuf, channels):
        inbuf = np.frombuffer(inbuf, dtype=np.uint8)
        inbufsize = len(inbuf)
        
        if inbufsize < channels * 4:
            return np.array([], dtype=np.int16)

        pcmdata = np.zeros(channels, dtype=np.int32)
        index = np.zeros(channels, dtype=np.int8)
        outbuf = []

        for ch in range(channels):
            pcmdata[ch] = np.int16(inbuf[ch*4] | (inbuf[ch*4 + 1] << 8))
            index[ch] = inbuf[ch*4 + 2]
            
            if index[ch] < 0 or index[ch] > 88 or inbuf[ch*4 + 3] != 0:
                return np.array([], dtype=np.int16)
            
            outbuf.append(pcmdata[ch])

        inbuf = inbuf[channels*4:]
        chunks = len(inbuf) // (channels * 4)
        
        for _ in range(chunks):
            for ch in range(channels):
                for i in range(4):
                    for nibble in [(inbuf[0] & 0x0F), (inbuf[0] >> 4)]:
                        step = step_table[index[ch]]
                        delta = step >> 3

                        if nibble & 1:
                            delta += step >> 2
                        if nibble & 2:
                            delta += step >> 1
                        if nibble & 4:
                            delta += step

                        if nibble & 8:
                            pcmdata[ch] -= delta
                        else:
                            pcmdata[ch] += delta

                        index[ch] += index_table[nibble & 0x7]
                        index[ch] = max(0, min(index[ch], 88))
                        pcmdata[ch] = max(-32768, min(pcmdata[ch], 32767))
                        outbuf.append(pcmdata[ch])

                    inbuf = inbuf[1:]

        return np.array(outbuf, dtype=np.int16)

    def generate_wav_header(self, sample_rate, bits_per_sample, channels, data_size):
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

    def save_wav_file(self, audio_data):
        sample_rate = 4000
        bits_per_sample = 16
        channels = 1

        decoded_data = self.adpcm_decode_block(audio_data, channels)
        decoded_bytes = decoded_data.tobytes()
        
        wav_path = Path(self.temp_dir) / f"recorded_audio_{int(time.time())}.wav"
        wav_header = self.generate_wav_header(sample_rate, bits_per_sample, channels, len(decoded_bytes))
        
        with wave.open(str(wav_path), "wb") as wav_file:
            wav_file.setnchannels(channels)
            wav_file.setsampwidth(bits_per_sample // 8)
            wav_file.setframerate(sample_rate)
            wav_file.writeframes(wav_header + decoded_bytes)
        
        return wav_path

    def transcribe_audio(self, wav_path):
        with open(wav_path, "rb") as audio_file:
            transcript = client.audio.transcriptions.create(
                model="whisper-1", 
                file=audio_file
            )
        return transcript.text

    def text_to_speech(self, text):
        print(f"Text to speech: {text}")
        response = client.audio.speech.create(
            model="tts-1",
            voice="alloy",
            input=text
        )
        
        mp3_path = f"response_{int(time.time())}.mp3"
        response.stream_to_file(str(mp3_path))
        return mp3_path


    def cleanup(self):
        for file in Path(self.temp_dir).glob("*"):
            file.unlink()
        Path(self.temp_dir).rmdir()

async def notification_handler(processor, data):
    global audio_data, expected_packets, received_packets, full_text
    
    if data.startswith(b'START'):
        audio_data.clear()
        try:
            if len(data) >= 8:
                expected_packets = data[7]
            else:
                expected_packets = 0
            received_packets = 0
            # print(f"Starting to receive {expected_packets} packets")
        except struct.error:
            print(f"Warning: Could not extract packet count")
            expected_packets = 0
            received_packets = 0
    
    elif data[:2] == b'\xFF\xFF':
        audio_data.extend(data[4:])
        received_packets += 1
        print(f"Received packet {received_packets}/{expected_packets}", end='\r')
    
    elif data.startswith(b'END'):
        # print("\nProcessing audio...")
        
        # Process the received audio
        wav_path = processor.save_wav_file(audio_data)
        # print("Audio saved as WAV")
        
        # Transcribe to text
        text = processor.transcribe_audio(wav_path)
        print(f"Transcribed text: {text} {len(text)}")

        if len(text) < 4:
            print("Nothing received...")
            if len(full_text) > 0:
                print("Sending to rp")
                mp3_path = processor.text_to_speech(full_text)
                
                send_file(mp3_path)
            full_text = ""
        else:
            full_text = full_text + " " + text
        
        # Convert text back to speech
        

async def run_ble_client(processor):
    global running
    
    while running:
        try:
            print(f"Scanning for device with name '{DEVICE_NAME}'...")
            device = await BleakScanner.find_device_by_name(DEVICE_NAME)
            
            if device is None:
                print(f"Could not find device '{DEVICE_NAME}'. Retrying in 5 seconds...")
                await asyncio.sleep(5)
                continue
            
            async with BleakClient(device) as client:
                print(f"Connected to {device.name}")
                
                # Create partial function with processor
                handler = lambda sender, data: asyncio.create_task(
                    notification_handler(processor, data)
                )
                
                await client.start_notify(DATA_CHARACTERISTIC_UUID, handler)
                print("Listening for audio...")
                
                while running:
                    await asyncio.sleep(0.1)
                
                await client.stop_notify(DATA_CHARACTERISTIC_UUID)
                
        except Exception as e:
            print(f"Error: {e}")
            print("Reconnecting in 5 seconds...")
            await asyncio.sleep(5)

async def main():
    processor = AudioProcessor()
    try:
        await run_ble_client(processor)
            
    finally:
        processor.cleanup()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nShutting down...")
        running = False