import asyncio
from bleak import BleakClient, BleakScanner
import time
import struct
import wave
import numpy as np

# Replace with your Arduino's advertised name
DEVICE_NAME = "Random Data Sender"
DATA_CHARACTERISTIC_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"

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

import numpy as np

# Step table
step_table = [
    7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
    50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230,
    253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963,
    1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327,
    3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442,
    11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794,
    32767
]

# Index table
index_table = [-1, -1, -1, -1, 2, 4, 6, 8]

def adpcm_decode_block(inbuf, channels):
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
    samples = 1 + chunks * 8

    for _ in range(chunks):
        for ch in range(channels):
            for i in range(4):
                step = step_table[index[ch]]
                delta = step >> 3

                if inbuf[0] & 1:
                    delta += step >> 2
                if inbuf[0] & 2:
                    delta += step >> 1
                if inbuf[0] & 4:
                    delta += step

                if inbuf[0] & 8:
                    pcmdata[ch] -= delta
                else:
                    pcmdata[ch] += delta

                index[ch] += index_table[inbuf[0] & 0x7]
                index[ch] = max(0, min(index[ch], 88))
                pcmdata[ch] = max(-32768, min(pcmdata[ch], 32767))
                outbuf.append(pcmdata[ch])

                step = step_table[index[ch]]
                delta = step >> 3

                if inbuf[0] & 0x10:
                    delta += step >> 2
                if inbuf[0] & 0x20:
                    delta += step >> 1
                if inbuf[0] & 0x40:
                    delta += step

                if inbuf[0] & 0x80:
                    pcmdata[ch] -= delta
                else:
                    pcmdata[ch] += delta

                index[ch] += index_table[(inbuf[0] >> 4) & 0x7]
                index[ch] = max(0, min(index[ch], 88))
                pcmdata[ch] = max(-32768, min(pcmdata[ch], 32767))
                outbuf.append(pcmdata[ch])

                inbuf = inbuf[1:]

    return np.array(outbuf, dtype=np.int16)

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
    global file_number, audio_data
    sample_rate = 4000
    bits_per_sample = 16
    channels = 1

    # Decode ADPCM data
    decoded_data = adpcm_decode_block(audio_data, channels)
    
    # Convert numpy array to bytes
    decoded_bytes = decoded_data.tobytes()

    wav_header = generate_wav_header(sample_rate, bits_per_sample, channels, len(decoded_bytes))
    with wave.open(f"recorded_audio_{file_number}.wav", "wb") as wav_file:
        wav_file.setnchannels(channels)
        wav_file.setsampwidth(bits_per_sample // 8)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(wav_header + decoded_bytes)
    print(f"Decoded audio saved as 'recorded_audio_{file_number}.wav'")
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
    global audio_data, expected_packets, received_packets, start_time
    start_time = 0
    
    print(f"Scanning for device with name '{DEVICE_NAME}'...")
    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return
    
    async with BleakClient(device) as client:
        ble_client = client
        print(f"Connected to {device.name}")
        
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