import asyncio
from bleak import BleakClient, BleakScanner
import struct
import time
import os
# from random import Random

DEVICE_NAME = "XIAOESP32S3_BLE"
# BLE characteristics UUIDs
TRANSFER_CHARACTERISTIC_UUID = "00002a59-0000-1000-8000-00805f9b34fb"
ACK_CHARACTERISTIC_UUID = "00002a58-0000-1000-8000-00805f9b34fb"
TIME_CHARACTERISTIC_UUID = "00002a57-0000-1000-8000-00805f9b34fb"

# Constants for packet handling
PACKET_SIZE = 512
HEADER_SIZE = 3
OUTPUT_DIR = "received_images"
PACKET_TIMEOUT = 1  # 100ms timeout for packet reception

class ImageReceiver:
    def __init__(self):
        self.reset()
        self.client = None
        
        # Create output directory if it doesn't exist
        if not os.path.exists(OUTPUT_DIR):
            os.makedirs(OUTPUT_DIR)
            
        # For simulating packet loss
        # self.random = Random()

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
        self.last_packet_time = None
        self.transfer_complete = False
        self.dropped_packets = []

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

    async def send_bitmap_ack(self):
        if not self.client or not self.client.is_connected or not self.total_packets:
            return False
        try:
            # Calculate bitmap size in bytes (rounded up)
            bitmap_size = (self.total_packets + 7) // 8
            bitmap = bytearray(bitmap_size)
            
            # Fill the bitmap - MSB first
            for packet_num in self.received_packets:
                if packet_num < self.total_packets:  # Safety check
                    byte_index = packet_num // 8
                    bit_index = packet_num % 8
                    bitmap[byte_index] |= (1 << (7 - bit_index))
            
            # Calculate missing packets
            missing_packets = []
            for i in range(self.total_packets):
                if i not in self.received_packets:
                    missing_packets.append(i)
            
            # Send the bitmap
            await self.client.write_gatt_char(ACK_CHARACTERISTIC_UUID, bitmap)
            print(f"\nSent bitmap ACK: {len(self.received_packets)}/{self.total_packets} packets received")
            print(f"Missing packets: {missing_packets}")
            return True
        except Exception as e:
            print(f"Failed to send bitmap ACK: {str(e)}")
            return False

    async def send_final_ack(self):
        if self.client and self.client.is_connected:
            try:
                await self.client.write_gatt_char(ACK_CHARACTERISTIC_UUID, b"ACK")
                print("Final ACK sent successfully")
                return True
            except Exception as e:
                print(f"Failed to send final ACK: {str(e)}")
                return False
        return False

    async def check_timeout(self):
        if not self.receiving or not self.last_packet_time or self.transfer_complete:
            return
        
        current_time = time.time()
        if current_time - self.last_packet_time > PACKET_TIMEOUT:
            print(f"\n {current_time%1000:.2f} {self.last_packet_time%1000:.2f} {(current_time - self.last_packet_time)%1000:.2f} {PACKET_TIMEOUT} \n")
            # print(f"\nTimed out, packets lost {self.dropped_packets}")
            # if len(self.received_packets) > 0:
            await self.send_bitmap_ack()
            self.last_packet_time = current_time + 5

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
            self.last_packet_time = time.time()
            print(f"Starting to receive image: {self.filename}")
            print(f"File size: {self.file_size} bytes")
            print(f"Expected number of packets: {self.total_packets}")
            return False

        if not self.receiving:
            return False

        # Update last packet time
        self.last_packet_time = time.time()

        # Get packet number from header
        packet_number = self.get_packet_number(data)
        
        # Skip if we've already received this packet
        if packet_number in self.received_packets:
            return False
            
        # # Simulate random packet loss (5% chance)
        # if self.random.randint(0, 100) > 95:
        #     self.dropped_packets.append(packet_number)
        #     return False
            
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
        progress = (len(self.received_packets) / self.total_packets) * 100
        print(f"Progress: {progress:.1f}% | Packets received: {len(self.received_packets)}/{self.total_packets} | "
              f"Last Time: {self.last_packet_time%1000:.2f}", end='\r')

        # Check if we've received all packets
        if len(self.received_packets) >= self.total_packets:
            self.transfer_complete = True
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
        
        # Send final ACK
        print("Sending final ACK...")
        if await self.send_final_ack():
            print("Final ACK sent successfully")
        else:
            print("Failed to send final ACK")
        
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
                receiver.client = client
                
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
                    await receiver.check_timeout()
                    await asyncio.sleep(1)
                    
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