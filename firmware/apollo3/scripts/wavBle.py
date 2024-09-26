import asyncio
from bleak import BleakClient, BleakScanner
import time
import struct
import wave

# Replace with your Arduino's advertised name
DEVICE_NAME = "Random Data Sender"
DATA_CHARACTERISTIC_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"
DELAY_CHARACTERISTIC_UUID = "19B10002-E8F2-537E-4F6C-D104768A1214"

# Global variables
ble_client = None
running = True
packet_count = 0
last_packet_time = 0
first_packet_time = None
last_packet_number = None

audio_data = bytearray()
expected_packets = 0
received_packets = 0

file_number = 0

def generate_wav_header(sample_rate, bits_per_sample, channels, data_size):
    print(f"Generating WAV header for {data_size} bytes")
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
    global file_number
    sample_rate = 5859
    bits_per_sample = 16
    channels = 1

    wav_header = generate_wav_header(sample_rate, bits_per_sample, channels, len(audio_data))
    with wave.open(f"recorded_audio_{file_number}.wav", "wb") as wav_file:
        wav_file.setnchannels(channels)
        wav_file.setsampwidth(bits_per_sample // 8)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(wav_header + audio_data)
    print(f"Audio saved as 'recorded_audio_{file_number}.wav'")
    file_number += 1

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
        print(f"Received packet {chunk_index}/{received_packets}/{expected_packets} {len(data[4:])} {len(audio_data)} bytes", end='\r')
    elif data[:3] == b'END':
        end_time = time.time()
        duration = (end_time - start_time) * 1000  # Convert to milliseconds
        print(f"Audio data received successfully. Total time: {duration:.2f} ms, received {received_packets} packets")
        # print("\nReceived all packets")
        save_wav_file()
    else:
        print(f"Received unexpected data: {data}")

async def run_ble_client():
    global ble_client, running, packet_count, last_packet_time, first_packet_time, last_packet_number
    
    print(f"Scanning for device with name '{DEVICE_NAME}'...")
    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return
    
    async with BleakClient(device) as client:
        ble_client = client
        print(f"Connected to {device.name}")
        
        # Set delay time to 20ms
        # await client.write_gatt_char(DELAY_CHARACTERISTIC_UUID, struct.pack('<I', 15))
        # print("Set delay time to 20ms")
        
        await client.start_notify(DATA_CHARACTERISTIC_UUID, notification_handler)
        print("Listening for packets...")
        
        while running:
            await asyncio.sleep(0.1)
            current_time = time.time()
            
            if packet_count > 0 and (current_time - last_packet_time) >= 1:
                total_time = last_packet_time - first_packet_time
                print(f"No new packets for 1 second. Total packets received: {packet_count}")
                print(f"Time taken to receive packets: {total_time:.2f} seconds")
                print(f"Last packet number received: {last_packet_number}")
                
                packet_count = 0
                first_packet_time = None
                last_packet_number = None
        
        await client.stop_notify(DATA_CHARACTERISTIC_UUID)

if __name__ == "__main__":
    asyncio.run(run_ble_client())