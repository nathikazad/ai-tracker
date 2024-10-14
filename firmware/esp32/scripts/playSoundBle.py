import asyncio
from bleak import BleakClient
import wave
import numpy as np
import struct
import time

# BLE device name (should match the name set in the ESP32 code)
DEVICE_NAME = "ESP32_Audio_System"
# UUID of the characteristic to write (should match the one in the ESP32 code)
WRITE_CHARACTERISTIC_UUID = "6E400004-B5A3-F393-E0A9-E50E24DCCA9E"

START_MARKER = 0xFFFF
STOP_MARKER = 0xFFFE
CHUNK_SIZE = 512  # Adjust based on your BLE MTU size

async def send_audio_data(client, data):
    send_start_time = time.time()
    print("Number of packets to send: ", len(data) / CHUNK_SIZE)
    for i in range(0, len(data), CHUNK_SIZE):
        chunk = data[i:i+CHUNK_SIZE]
        start_time = time.time()
        await client.write_gatt_char(WRITE_CHARACTERISTIC_UUID, chunk)
        duration = time.time() - start_time
        # await asyncio.sleep(0.002)  # Small delay to prevent flooding
    duration = time.time() - send_start_time
    print("Time taken to send audio data: ", duration)
    print("Audio data sent successfully")

async def run_ble_client():
    # Open the WAV file
    with wave.open('input.wav', 'rb') as wav_file:
        # Ensure the file matches our expectations
        assert wav_file.getnchannels() == 1, "File is not mono"
        assert wav_file.getsampwidth() == 2, "File is not 16-bit"
        assert wav_file.getframerate() == 48000, "File is not 48kHz"

        # Read the first 8 seconds of audio data
        n_frames = min(wav_file.getnframes(), 8 * 48000)
        audio_data = np.frombuffer(wav_file.readframes(n_frames), dtype=np.int16)
        total_frames = wav_file.getnframes()
        total_duration_ms = (total_frames / wav_file.getframerate()) * 1000

        print(f"Total file duration: {total_duration_ms:.2f} milliseconds")


    # Downsample to 8kHz
    audio_data = audio_data[::12]
    print("Audio data shape: ", audio_data.shape)
    
    # Normalize data
    normalized_data = ((audio_data - np.min(audio_data)) / (np.max(audio_data) - np.min(audio_data)) * 65533).astype(np.uint16)

    # Find ESP32 device
    from bleak import BleakScanner
    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return

    async with BleakClient(device) as client:
        print(f"Connected to {device.name}")

        # Send start marker
        start_time = time.time()
        await client.write_gatt_char(WRITE_CHARACTERISTIC_UUID, struct.pack('>H', START_MARKER))

        # Send audio data
        await send_audio_data(client, normalized_data.tobytes())
        # Send stop marker
        await client.write_gatt_char(WRITE_CHARACTERISTIC_UUID, struct.pack('>H', STOP_MARKER))

if __name__ == "__main__":
    asyncio.run(run_ble_client())