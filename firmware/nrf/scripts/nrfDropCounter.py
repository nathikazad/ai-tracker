import asyncio
from bleak import BleakClient, BleakScanner
import time
import struct

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

def notification_handler(sender, data):
    global packet_count, last_packet_time, first_packet_time, last_packet_number
    current_time = time.time()
    
    if first_packet_time is None:
        first_packet_time = current_time
    
    packet_count += 1
    last_packet_time = current_time
    
    # Extract packet number from the first 4 bytes
    packet_number = struct.unpack('>I', data[:4])[0]
    last_packet_number = packet_number
    
    print(f"Received packet {packet_count}, Frame Header: {packet_number}")

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
        await client.write_gatt_char(DELAY_CHARACTERISTIC_UUID, struct.pack('<I', 15))
        print("Set delay time to 20ms")
        
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