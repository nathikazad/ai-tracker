import asyncio
from bleak import BleakClient, BleakScanner
import time
import struct

# Nordic UART Service UUIDs
DEVICE_NAME = "Audio Sender"
SERIAL_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
SERIAL_RX_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"  # Write characteristic
SERIAL_TX_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"  # Notify characteristic

class BLEStreamError(Exception):
    pass

class BLEMP3Streamer:
    def __init__(self):
        self.client = None
        self.ack_received = asyncio.Event()
        self.connected = False
        
    async def connect(self):
        print(f"Scanning for device with name '{DEVICE_NAME}'...")
        device = await BleakScanner.find_device_by_name(DEVICE_NAME)
        
        if device is None:
            raise BLEStreamError(f"Could not find device with name '{DEVICE_NAME}'")

        print(f"Found device {device.name} [{device.address}]")
        self.client = BleakClient(device)
        await self.client.connect()
        print(f"Connected to {device.name}")
        
        # Setup notification handler for acknowledgments
        await self.client.start_notify(SERIAL_TX_UUID, self._notification_handler)
        self.connected = True
        
    def _notification_handler(self, sender, data):
        if data == b'A':
            self.ack_received.set()
        else:
            print(f"Received unexpected data: {data}")

    async def stream_frames(self, mp3_data, frames_per_batch=100):
        if not self.connected:
            raise BLEStreamError("Not connected to BLE device")

        # Find MP3 frame boundaries
        frame_starts = []
        i = 0
        while i < len(mp3_data) - 1:
            if mp3_data[i] == 0xFF and (mp3_data[i+1] == 0xFB or mp3_data[i+1] == 0xF3):
                frame_starts.append(i)
            i += 1
        
        print(f"Found {len(frame_starts)} frames in {len(mp3_data)}")

        # Stream frames in batches
        for i in range(0, len(frame_starts), frames_per_batch):
            print(f"Sending batch {i//frames_per_batch + 1}")
            start = time.time()
            batch_start = frame_starts[i]
            # Calculate batch end
            if i + frames_per_batch < len(frame_starts):
                batch_end = frame_starts[i + frames_per_batch]
            else:
                batch_end = len(mp3_data)
            
            batch_data = mp3_data[batch_start:batch_end]
            
            # Clear previous acknowledgment
            self.ack_received.clear()
            
            # Send batch size first (as 2 bytes)
            size_bytes = struct.pack('>H', len(batch_data))
            await self.client.write_gatt_char(SERIAL_RX_UUID, size_bytes)
            await asyncio.sleep(0.01)  # Small delay between size and data
            
            # Send batch data in chunks (BLE has limited packet size)
            CHUNK_SIZE = 240  # Maximum BLE packet size
            for j in range(0, len(batch_data), CHUNK_SIZE):
                chunk = batch_data[j:j + CHUNK_SIZE]
                await self.client.write_gatt_char(SERIAL_RX_UUID, chunk)
                # await asyncio.sleep(0.001)  # Small delay between chunks

            end = time.time()
            print(f"Sent batch {i//frames_per_batch + 1} in {end - start} seconds")
            
            # Wait for acknowledgment with timeout
            try:
                await asyncio.wait_for(self.ack_received.wait(), timeout=2.0)
            except asyncio.TimeoutError:
                raise BLEStreamError("Timeout waiting for acknowledgment")

    async def close(self):
        if self.client and self.client.is_connected:
            await self.client.stop_notify(SERIAL_TX_UUID)
            await self.client.disconnect()
            self.connected = False

async def playFile(filename):
    with open(filename, 'rb') as f:
        mp3_data = f.read()

    print(f"Size of {filename}: {len(mp3_data)} bytes")
    streamer = BLEMP3Streamer()
    try:
        await streamer.connect()
        await streamer.stream_frames(mp3_data)
    finally:
        await streamer.close()

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python script.py <mp3_file>")
        sys.exit(1)
        
    asyncio.run(playFile(sys.argv[1]))