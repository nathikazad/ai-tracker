import asyncio
from bleak import BleakClient, BleakScanner
import time
import struct
import wave

# Replace with your Arduino's advertised name
DEVICE_NAME = "PDM Data Sender"
DATA_CHARACTERISTIC_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"

# WAV file configuration
SAMPLE_RATE = 3906  # As mentioned in the Arduino sketch
CHANNELS = 1
SAMPLE_WIDTH = 2  # 16-bit audio

# Global variables
buffer = bytearray()

def notification_handler(sender, data):
    global buffer
    buffer.extend(data)
    print(f"Received chunk of {len(data)} bytes. Total bytes: {len(buffer)}")

async def run_ble_client():
    global buffer
    
    print(f"Scanning for device with name '{DEVICE_NAME}'...")
    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return
    
    async with BleakClient(device) as client:
        print(f"Connected to {device.name}")
        
        await client.start_notify(DATA_CHARACTERISTIC_UUID, notification_handler)
        print("Listening for packets...")
        
        # Listen for 10 seconds
        start_time = time.time()
        while time.time() - start_time < 10:
            await asyncio.sleep(0.1)
        
        await client.stop_notify(DATA_CHARACTERISTIC_UUID)
        
        total_time = time.time() - start_time
        print(f"Finished receiving data. Total bytes received: {len(buffer)}")
        print(f"Time taken to receive data: {total_time:.2f} seconds")
        
        # Ensure buffer length is even
        if len(buffer) % 2 != 0:
            buffer = buffer[:-1]
        print(f"Adjusted buffer size: {len(buffer)} bytes")
        
        # Write buffer to WAV file
        with wave.open('output.wav', 'wb') as wav_file:
            wav_file.setnchannels(CHANNELS)
            wav_file.setsampwidth(SAMPLE_WIDTH)
            wav_file.setframerate(SAMPLE_RATE)
            
            # Convert buffer to 16-bit integers
            int_data = struct.unpack('<' + 'h'*(len(buffer)//2), buffer)
            
            # Write to WAV file
            wav_file.writeframes(struct.pack('<' + 'h'*len(int_data), *int_data))
        
        print("Recording complete. Data saved to 'output.wav'")

if __name__ == "__main__":
    asyncio.run(run_ble_client())