import asyncio
from bleak import BleakClient, BleakScanner
import numpy as np
import wave
import time

# BLE UUIDs
SERVICE_UUID = "181A"  # Environmental Sensing service
AUDIO_DATA_UUID = "2A59"  # Analog Output characteristic

# Audio settings
SAMPLE_RATE = 16000
CHANNELS = 1
DTYPE = np.int16
MAX_RECORD_TIME = 4  # Maximum recording time in seconds

# Global variables
audio_buffer = []
start_time = None
current_packet = None
recording = False

def save_wav_file(buffer, filename):
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(2)  # 2 bytes for 'int16'
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(buffer.tobytes())
    print(f"Saved audio to {filename}")

def notification_handler(sender, data):
    global audio_buffer, start_time, current_packet, recording

    packet_number = data[0]
    
    # Calculate how many complete samples we have
    samples_count = (len(data) - 1) // 2  # Subtract 1 for the packet number, divide by 2 for int16
    
    # Only process complete samples
    audio_data = np.frombuffer(data[1:1+samples_count*2], dtype=DTYPE)

    if packet_number == 0:
        if recording:
            # Save the previous recording if we were recording
            save_wav_file(np.array(audio_buffer, dtype=DTYPE), f"audio_{time.strftime('%Y%m%d-%H%M%S')}.wav")
        
        # Start a new recording
        audio_buffer = []
        start_time = time.time()
        recording = True
        print("Starting new recording...")

    if recording:
        audio_buffer.extend(audio_data)

        if time.time() - start_time >= MAX_RECORD_TIME:
            save_wav_file(np.array(audio_buffer, dtype=DTYPE), f"audio_{time.strftime('%Y%m%d-%H%M%S')}.wav")
            audio_buffer = []
            recording = False
            print("Finished recording. Waiting for next burst...")

    current_packet = packet_number
    print(f"Received packet {packet_number}, length: {len(audio_data)}")

async def main():
    print("Scanning for XIAOESP32S3_BLE device...")
    device = await BleakScanner.find_device_by_filter(
        lambda d, ad: d.name and d.name == "XIAOESP32S3_BLE"
    )

    if not device:
        print("XIAOESP32S3_BLE device not found. Make sure it's turned on and in range.")
        return

    print(f"Found XIAOESP32S3_BLE device: {device.name} ({device.address})")

    async with BleakClient(device.address) as client:
        print(f"Connected to {device.address}")

        # Subscribe to audio notifications
        await client.start_notify(AUDIO_DATA_UUID, notification_handler)
        print("Receiving audio. Recording for max 4 seconds per burst. Press Ctrl+C to stop.")

        try:
            while True:
                await asyncio.sleep(1)
        except asyncio.CancelledError:
            print("Stopping...")
        finally:
            await client.stop_notify(AUDIO_DATA_UUID)

if __name__ == "__main__":
    asyncio.run(main())