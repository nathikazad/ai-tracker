from bleak import BleakClient, BleakScanner
import asyncio
import cv2
import numpy as np
import struct
import time
import sys
import sys
from slic_decoder import SlicDecoder
from PIL import Image

# BLE UUIDs from the Arduino code
SERIAL_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
SERIAL_TX_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"  # Notifications come from this characteristic

def fletcher32(data):
    """
    Python implementation of Fletcher-32 checksum algorithm.
    Exact port of the C implementation accounting for all numeric operations.
    
    Args:
        data: bytearray or bytes object containing the data
        
    Returns:
        32-bit Fletcher checksum as an integer
    """
    sum1 = 0xffff
    sum2 = 0xffff
    length = len(data)
    index = 0
    
    # Process pairs of bytes as 16-bit words
    while length > 1:
        # Calculate block size (max 718 bytes)
        blocks = min(718, length)
        length -= blocks
        blocks //= 2  # Process two bytes at a time
        
        while blocks:
            # Combine two bytes into a 16-bit word
            word = (data[index] << 8) | data[index + 1]
            sum1 = (sum1 + word) & 0xffffffff
            sum2 = (sum2 + sum1) & 0xffffffff
            index += 2
            blocks -= 1
            
        # First reduction step
        sum1 = (sum1 & 0xffff) + (sum1 >> 16)
        sum2 = (sum2 & 0xffff) + (sum2 >> 16)
    
    # Handle last byte if length is odd
    if length:
        word = data[index] << 8
        sum1 = (sum1 + word) & 0xffffffff
        sum2 = (sum2 + sum1) & 0xffffffff
        sum1 = (sum1 & 0xffff) + (sum1 >> 16)
        sum2 = (sum2 & 0xffff) + (sum2 >> 16)
    
    # Second reduction step to reduce sums to 16 bits
    sum1 = (sum1 & 0xffff) + (sum1 >> 16)
    sum2 = (sum2 & 0xffff) + (sum2 >> 16)
    
    # Combine the two 16-bit sums into one 32-bit value
    return (sum2 << 16) | sum1

def print_hex(data, length):
    for i in range(length):
        # Print leading zero if needed
        if data[i] < 0x10:
            print('0', end='')
        print(f'{data[i]:X}', end=' ')
    print()  # New line at end


class BLEFrameReceiver:
    def __init__(self):
        self.frame_width = None
        self.frame_height = None
        self.total_bytes = None
        self.num_packets = None
        self.packet_data_size = 242  # 240 - 2 bytes for packet number
        
        self.frame_buffer = None
        self.packets_received = set()
        self.frame_ready = asyncio.Event()
        self.current_frame = None
        
    def notification_handler(self, sender, data):
        """Handle incoming notifications from BLE device"""
        # Check if this is a handshake packet
        if data[0] == 0xFF and data[1] == 0xAA:
            print("Handshake packet received")
            self.handle_handshake(data)
            return

        # Handle regular data packet
        if len(data) >= 2:  # Ensure we have at least the packet number
            packet_num = struct.unpack('<H', data[0:2])[0]
            payload = data[2:]
            
            if self.frame_buffer is not None:
                offset = packet_num * self.packet_data_size
                remaining_bytes = self.total_bytes - offset
                expected_size = min(remaining_bytes, self.packet_data_size)
                
                # if len(payload) == expected_size:
                self.frame_buffer[offset:offset + expected_size] = payload[0:expected_size]
                self.packets_received.add(packet_num)
  
                # print(f"Packet {packet_num} stored. {len(payload)}:{expected_size}  {len(self.packets_received)}/{self.num_packets} packets received.")
                
                # # Check if we have all packets
                # if len(self.packets_received) > self.num_packets-3:
                #     print_hex(payload, expected_size)
                # checksum = fletcher32(payload[:expected_size])
                # print(f"Fletcher-32 checksum: {packet_num} {expected_size} 0x{checksum:08X}")
                
                if len(self.packets_received) == self.num_packets:
                    # print_hex(self.frame_buffer[offset:offset + expected_size], expected_size)
                    print(f"All packets received, processing frame...{len(self.packets_received)}/{self.num_packets} packets received.")
                    print(f"Bytes received: {len(self.frame_buffer)}/{self.total_bytes}")
                    checksum = fletcher32(self.frame_buffer)
                    print(f"Fletcher-32 checksum: 0x{checksum:08X}")
                    self.process_complete_frame()
                    # decoder = SlicDecoder()
    
                    # # Decode the image
                    # img = decoder.decode_array(self.frame_buffer)
                    
                    # # Save the image using PIL
                    # Image.fromarray(img).save('decompressed.png')
                    # print(f"Image decoded successfully: {img.shape}")

    def handle_handshake(self, data):
        """Process handshake packet"""
        try:
            if data[0:2] == b'\xFF\xAA' and data[12:14] == b'\xFF\xBB':
                self.total_bytes = struct.unpack('<I', data[2:6])[0]
                self.num_packets = struct.unpack('<H', data[6:8])[0]
                self.frame_width = struct.unpack('<H', data[8:10])[0]
                self.frame_height = struct.unpack('<H', data[10:12])[0]
                
                print(f"Handshake received: {self.frame_width}x{self.frame_height}, "
                      f"{self.total_bytes} bytes in {self.num_packets} packets")
                
                # Initialize new frame buffer
                self.frame_buffer = bytearray(self.total_bytes)
                self.packets_received.clear()
        except struct.error as e:
            print(f"Error processing handshake: {e}")

    def process_complete_frame(self):
        """Process completed frame"""
        try:
            frame = np.frombuffer(self.frame_buffer, dtype=np.uint8).reshape(
                (self.frame_height, self.frame_width))
            self.current_frame = frame
            self.frame_ready.set()
        except ValueError as e:
            print(f"Error reshaping frame data: {e}")

async def find_camera_device():
    """Find the camera device by name"""
    print("Scanning for CameraRelay device...")
    devices = await BleakScanner.discover()
    for device in devices:
        if device.name and "CameraRelay" in device.name:
            return device.address
    return None

def handle_disconnect(client):
    print("Device disconnected")
    sys.exit(0)

async def main():
    # Find camera device
    device_address = await find_camera_device()
    if not device_address:
        print("Camera device not found!")
        return

    receiver = BLEFrameReceiver()
    
    async with BleakClient(device_address, disconnected_callback=handle_disconnect) as client:
        print(f"Connected to {client.address}")
        
        # Start notifications
        await client.start_notify(
            SERIAL_TX_UUID,
            receiver.notification_handler
        )
        
        while True:
            # Wait for frame with timeout
            try:
                await asyncio.wait_for(receiver.frame_ready.wait(), timeout=20.0)
                receiver.frame_ready.clear()
                
                if receiver.current_frame is not None:
                    cv2.imshow('Camera Stream', receiver.current_frame)
                    
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
                    
            except asyncio.TimeoutError:
                print("Timeout waiting for frame")
                continue
            
        # Clean up
        await client.stop_notify(SERIAL_TX_UUID)
        cv2.destroyAllWindows()

if __name__ == "__main__":
    asyncio.run(main())