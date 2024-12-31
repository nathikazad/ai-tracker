import asyncio
from bleak import BleakClient, BleakScanner
import struct
import time
import os

# BLE device name (should match the name set in the ESP32 code)
DEVICE_NAME = "XIAOESP32S3_BLE"

# UUID of the characteristic to notify (should match the one in the ESP32 code)
NOTIFY_CHARACTERISTIC_UUID = "00002a59-0000-1000-8000-00805f9b34fb"

# Constants for packet handling
PACKET_SIZE = 512
HEADER_SIZE = 3  # 3 bytes for packet number
OUTPUT_DIR = "received_images"

class ImageReceiver:
    def __init__(self):
        self.reset()
        
        # Create output directory if it doesn't exist
        if not os.path.exists(OUTPUT_DIR):
            os.makedirs(OUTPUT_DIR)

    def reset(self):
        self.image_data = bytearray()
        self.file_size = None
        self.total_packets = None
        self.receiving = False
        self.start_time = None
        self.received_bytes = 0
        self.received_packets = set()
        self.max_packet_number = 0

    def get_packet_number(self, data):
        # Extract packet number from first 3 bytes
        return (data[0] << 16) | (data[1] << 8) | data[2]

    def process_packet(self, data):
        # Check for reset packet
        if len(data) > 0 and data[0] == 0xFF:
            print("\nReceived reset packet, starting new image reception")
            self.reset()
            # Read file size (4 bytes)
            self.file_size = (data[1] << 24) | (data[2] << 16) | (data[3] << 8) | data[4]
            
            # Read total packets (4 bytes)
            self.total_packets = (data[5] << 24) | (data[6] << 16) | (data[7] << 8) | data[8]
            self.receiving = True
            self.start_time = time.time()
            print(f"Starting to receive image of size: {self.file_size} bytes")
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
            self.save_image()
            return True
        return False

    def save_image(self):
        duration = time.time() - self.start_time
        throughput = self.file_size / duration / 1024  # KB/s

        # Generate unique filename
        timestamp = time.strftime("%Y%m%d-%H%M%S")
        filename = os.path.join(OUTPUT_DIR, f"received_image_{timestamp}.jpg")
        
        # Save the image
        with open(filename, 'wb') as f:
            f.write(self.image_data[:self.file_size])
        
        print(f"\nImage saved as: {filename}")
        print(f"Transfer duration: {duration:.2f} seconds")
        print(f"Average throughput: {throughput:.2f} KB/s")
        print(f"Total packets received: {len(self.received_packets)}")
        
        self.reset()

async def run_ble_client():
    receiver = ImageReceiver()
    
    def notification_handler(sender, data):
        if receiver.process_packet(data):
            print("\nImage reception complete")
    
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
                
                # Subscribe to notifications
                await client.start_notify(NOTIFY_CHARACTERISTIC_UUID, notification_handler)
                
                # Keep the connection alive
                while True:
                    await asyncio.sleep(0.1)
                    
        except Exception as e:
            print(f"Error: {str(e)}")
            print("Retrying in 5 seconds...")
            await asyncio.sleep(5)
            receiver.reset()

if __name__ == "__main__":
    try:
        asyncio.run(run_ble_client())
    except KeyboardInterrupt:
        print("\nProgram terminated by user")