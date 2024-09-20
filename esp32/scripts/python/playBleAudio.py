import asyncio
from bleak import BleakClient, BleakScanner
import numpy as np
import wave
import time

# BLE UUIDs
SERVICE_UUID = "19B10000-E8F2-537E-4F6C-D104768A1214"
AUDIO_DATA_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"

# Audio settings
SAMPLE_RATE = 16000  # Adjust if different
CHANNELS = 1
DTYPE = 'int16'

# Global variables
audio_buffer = []
start_time = None

def save_wav_file(buffer, filename):
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(2)  # 2 bytes for 'int16'
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(np.array(buffer, dtype=DTYPE).tobytes())
    print(f"Saved audio to {filename}")

def notification_handler(sender, data):
    global audio_buffer, start_time
    
    # Convert the raw bytes directly to audio samples
    audio_data = np.frombuffer(data, dtype=DTYPE)
    audio_buffer.extend(audio_data)
    
    # If this is the first packet, set the start time
    if start_time is None:
        start_time = time.time()
    
    # Check if 10 seconds have passed
    if time.time() - start_time >= 10:
        # Save the accumulated audio as a WAV file
        timestamp = time.strftime("%Y%m%d-%H%M%S")
        filename = f"audio_{timestamp}.wav"
        save_wav_file(audio_buffer, filename)
        
        # Reset the buffer and start time
        audio_buffer = []
        start_time = None

async def main():
    print("Scanning for OpenGlass device...")
    device = await BleakScanner.find_device_by_filter(
        lambda d, ad: d.name and d.name.lower() == "openglass"
    )
    
    if not device:
        print("OpenGlass device not found. Make sure it's turned on and in range.")
        return
    
    print(f"Found OpenGlass device: {device.name} ({device.address})")
    
    async with BleakClient(device.address) as client:
        print(f"Connected to {device.address}")
        
        # Subscribe to audio notifications
        await client.start_notify(AUDIO_DATA_UUID, notification_handler)
        print("Receiving audio. Saving every 10 seconds. Press Ctrl+C to stop.")
        
        try:
            while True:
                await asyncio.sleep(1)
        except asyncio.CancelledError:
            print("Stopping...")
        finally:
            await client.stop_notify(AUDIO_DATA_UUID)

if __name__ == "__main__":
    asyncio.run(main())