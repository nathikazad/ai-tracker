import asyncio
from bleak import BleakClient, BleakScanner
import struct
import time
import os

DEVICE_NAME = "XIAOESP32S3_BLE"
# BLE characteristics UUIDs
TRANSFER_CHARACTERISTIC_UUID = "00002a59-0000-1000-8000-00805f9b34fb"
ACK_CHARACTERISTIC_UUID = "00002a58-0000-1000-8000-00805f9b34fb"
TIME_CHARACTERISTIC_UUID = "00002a57-0000-1000-8000-00805f9b34fb"

# Constants for packet handling
PACKET_SIZE = 512
HEADER_SIZE = 3
OUTPUT_DIR = "received_images"

class ImageReceiver:
    def __init__(self):
        self.reset()
        self.client = None  # Store BLE client reference
        
        # Create output directory if it doesn't exist
        if not os.path.exists(OUTPUT_DIR):
            os.makedirs(OUTPUT_DIR)

    def reset(self):
        self.image_data = bytearray()
        self.file_size = None
        self.total_packets = None
        self.filename = None
        self.receiving = False
        self.start_time = None
        self.received_bytes = 0
        self.received_packets = set()
        self.max_packet_number = 0

    def get_packet_number(self, data):
        return (data[0] << 16) | (data[1] << 8) | data[2]

    async def send_time_sync(self):
        if self.client and self.client.is_connected:
            try:
                # Get current timestamp as uint64_t
                current_time = int(time.time())
                time_bytes = current_time.to_bytes(8, byteorder='little')
                
                await self.client.write_gatt_char(TIME_CHARACTERISTIC_UUID, time_bytes)
                print(f"Sent time sync: {current_time}")
                return True
            except Exception as e:
                print(f"Failed to send time sync: {str(e)}")
                return False
        return False

    async def process_packet(self, data):
        # Check for reset packet with 8-byte identifier
        IDENTIFIER = bytes([0xFF, 0xA5, 0x5A, 0xC3, 0x3C, 0x69, 0x96, 0xF0])
        if len(data) >= 8 and data[:8] == IDENTIFIER:
            print("\nReceived reset packet, starting new image reception")
            self.reset()
            
            # Read file size (4 bytes) - starting at byte 8
            self.file_size = (data[8] << 24) | (data[9] << 16) | (data[10] << 8) | data[11]
            
            # Read total packets (4 bytes) - starting at byte 12
            self.total_packets = (data[12] << 24) | (data[13] << 16) | (data[14] << 8) | data[15]
            
            # Read filename length (1 byte) - at byte 16
            filename_length = data[16]
            
            # Read filename - starting at byte 17
            self.filename = data[17:17+filename_length].decode('utf-8')
            
            self.receiving = True
            self.start_time = time.time()
            print(f"Starting to receive image: {self.filename}")
            print(f"File size: {self.file_size} bytes")
            print(f"Expected number of packets: {self.total_packets}")
            return False

        if not self.receiving:
            return False

        # Get packet number from header
        packet_number = self.get_packet_number(data)
        self.received_packets.add(packet_number)
        self.max_packet_number = max(self.max_packet_number, packet_number)

        # Add data (excluding header) to image buffer
        data_portion = data[HEADER_SIZE:]
        write_position = packet_number * (PACKET_SIZE - HEADER_SIZE)
        
        # Extend image_data if needed
        if write_position + len(data_portion) > len(self.image_data):
            self.image_data.extend(bytearray(write_position + len(data_portion) - len(self.image_data)))
        
        # Write data at correct position
        self.image_data[write_position:write_position + len(data_portion)] = data_portion
        self.received_bytes += len(data_portion)

        # Print progress
        progress = (self.received_bytes / self.file_size) * 100
        print(f"Progress: {progress:.1f}% | Packets received: {len(self.received_packets)}/{self.total_packets} | "
              f"Max packet number: {self.max_packet_number}", end='\r')

        # Check if we've received all packets
        if len(self.received_packets) >= self.total_packets:
            await self.save_image()
            return True
        return False

    async def save_image(self):
        duration = time.time() - self.start_time
        throughput = self.file_size / duration / 1024  # KB/s

        # Use the original filename
        filename = os.path.join(OUTPUT_DIR, self.filename)
        
        # Save the image
        with open(filename, 'wb') as f:
            f.write(self.image_data[:self.file_size])
        
        print(f"\nImage saved as: {filename}")
        print(f"Transfer duration: {duration:.2f} seconds")
        print(f"Average throughput: {throughput:.2f} KB/s")
        print(f"Total packets received: {len(self.received_packets)}")
        
        # Send ACK
        print("Sending ACK...")
        if await self.send_ack():
            print("ACK sent successfully")
        else:
            print("Failed to send ACK")
        
        self.reset()

async def run_ble_client():
    receiver = ImageReceiver()
    
    async def notification_handler(sender, data):
        await receiver.process_packet(data)
    
    while True:
        try:
            print(f"Scanning for device: {DEVICE_NAME}")
            device = await BleakScanner.find_device_by_name(DEVICE_NAME)
            
            if device is None:
                print(f"Could not find device with name '{DEVICE_NAME}'")
                await asyncio.sleep(1)
                continue

            print(f"Connecting to {device.name}")
            async with BleakClient(device) as client:
                print(f"Connected to {device.name}")
                receiver.client = client  # Store client reference
                
                # First, synchronize time
                print("Synchronizing time...")
                if await receiver.send_time_sync():
                    print("Time synchronization successful")
                else:
                    print("Time synchronization failed")
                    return
                
                # Subscribe to notifications
                await client.start_notify(TRANSFER_CHARACTERISTIC_UUID, notification_handler)
                
                # Keep the connection alive
                while True:
                    await asyncio.sleep(0.1)
                    
        except Exception as e:
            print(f"Error: {str(e)}")
            print("Retrying in 5 seconds...")
            await asyncio.sleep(5)
            receiver.reset()
            receiver.client = None

if __name__ == "__main__":
    try:
        asyncio.run(run_ble_client())
    except KeyboardInterrupt:
        print("\nProgram terminated by user")