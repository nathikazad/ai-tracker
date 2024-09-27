import asyncio
from bleak import BleakClient, BleakScanner
import time
import struct
import wave
import os
import numpy as np

# Replace with your Arduino's advertised name
DEVICE_NAME = "PDM Data Sender"
DATA_CHARACTERISTIC_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"

# WAV file configuration
SAMPLE_RATE = 3906  # As mentioned in the Arduino sketch
CHANNELS = 1
SAMPLE_WIDTH = 2  # 16-bit audio

# Global variables
buffer = bytearray()
last_packet_time = 0
file_counter = 0
gain = 200.0
first_packet_time = None

def notification_handler(sender, data):
    global buffer, last_packet_time, first_packet_time
    if first_packet_time is None:
        first_packet_time = time.time()
    buffer.extend(data)
    last_packet_time = time.time()
    # print(f"Received chunk of {len(data)} bytes. Total bytes: {len(buffer)}")

def apply_gain(audio_data, gain_factor):
    # Convert bytes to numpy array of 16-bit integers
    samples = np.frombuffer(audio_data, dtype=np.int16)
    
    # Apply gain
    samples = samples * gain_factor
    
    # Clip to prevent overflow
    samples = np.clip(samples, -32768, 32767)
    
    # Convert back to 16-bit integers
    return samples.astype(np.int16)

def save_buffer_to_file():
    global buffer, file_counter, gain
    
    if len(buffer) == 0:
        print("No data to save.")
        return

    # Ensure buffer length is even
    if len(buffer) % 2 != 0:
        buffer = buffer[:-1]
    
    filename = f'output_{file_counter:03d}.wav'
    with wave.open(filename, 'wb') as wav_file:
        wav_file.setnchannels(CHANNELS)
        wav_file.setsampwidth(SAMPLE_WIDTH)
        wav_file.setframerate(SAMPLE_RATE)
        
        # Apply gain and convert to 16-bit integers
        gained_data = apply_gain(buffer, gain)
        
        # Write to WAV file
        wav_file.writeframes(gained_data.tobytes())
    
    print(f"Recording saved to '{filename}'. {len(buffer)} bytes written with gain {gain}.")
    file_counter += 1
    buffer.clear()

async def run_ble_client():
    global buffer, last_packet_time, first_packet_time

    print(f"Scanning for device with name '{DEVICE_NAME}'...")
    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return

    async with BleakClient(device) as client:
        print(f"Connected to {device.name}")
        await client.start_notify(DATA_CHARACTERISTIC_UUID, notification_handler)
        print("Listening for packets...")

        while True:
            await asyncio.sleep(0.1)
            current_time = time.time()
            
            if len(buffer) > 0 and (current_time - last_packet_time > 1 or current_time - first_packet_time > 5):
                save_buffer_to_file()
                print(f"Total time: {last_packet_time - first_packet_time}")
                first_packet_time = current_time
                last_packet_time = current_time

            # Check if user wants to exit
            # if input("Press 'q' and Enter to quit: ").lower() == 'q':
            #     break

        await client.stop_notify(DATA_CHARACTERISTIC_UUID)
        print("Stopped listening for packets.")

        # Save any remaining data
        if len(buffer) > 0:
            save_buffer_to_file()

if __name__ == "__main__":
    asyncio.run(run_ble_client())