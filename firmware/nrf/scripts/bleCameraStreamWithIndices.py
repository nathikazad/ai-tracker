from bleak import BleakClient, BleakScanner
import asyncio
import cv2
import numpy as np
import struct
import time
import sys

# BLE UUIDs from the Arduino code
SERIAL_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
SERIAL_TX_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"  # Notifications come from this characteristic

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
                self.frame_buffer[offset:offset + expected_size] = payload[:expected_size]
                self.packets_received.add(packet_num)
                # print(f"Packet {packet_num} stored. {len(payload)}:{expected_size}  {len(self.packets_received)}/{self.num_packets} packets received.")
                
                # Check if we have all packets
                if len(self.packets_received) == self.num_packets:
                    print(f"All packets received, processing frame...{len(self.packets_received)}/{self.num_packets} packets received.")
                    print(f"Bytes received: {len(self.frame_buffer)}/{self.total_bytes}")
                    # self.process_complete_frame()

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