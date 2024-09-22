import asyncio
from bleak import BleakClient, BleakScanner
import time
import struct

# Replace with your Arduino's advertised name
DEVICE_NAME = "Random Data Sender"
DATA_CHARACTERISTIC_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"

# Global variables
ble_client = None
running = True
packet_count = 0
last_packet_time = 0

def notification_handler(sender, data):
    global packet_count, last_packet_time
    packet_count += 1
    last_packet_time = time.time()
    
    # Extract packet number from the first 4 bytes
    packet_number = struct.unpack('>I', data[:4])[0]
    
    print(f"Received packet {packet_count}, Frame Header: {packet_number}")

async def run_ble_client():
    global ble_client, running, packet_count, last_packet_time

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
                print(f"No new packets for 1 second. Total packets received: {packet_count}")
                packet_count = 0
                last_packet_time = current_time

        await client.stop_notify(DATA_CHARACTERISTIC_UUID)

if __name__ == "__main__":
    asyncio.run(run_ble_client())