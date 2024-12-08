from bleak import BleakClient, BleakScanner
import asyncio
import cv2
import numpy as np
import struct
import time
import sys

SERIAL_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
SERIAL_TX_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

class BLEFrameReceiver:
    def __init__(self):
        self.frame_width = None
        self.frame_height = None
        self.total_bytes = None
        self.num_packets = None
        self.packet_data_size = 238  # 244 - 6 bytes header
        self.expected_frame_checksum = None
        
        self.frame_buffer = None
        self.packets_received = set()
        self.frame_ready = asyncio.Event()
        self.current_frame = None

    def calculate_fletcher32(self, data):
        sum1 = 0xffff
        sum2 = 0xffff
        length = len(data)
        index = 0
        
        while length > 0:
            tlen = min(length, 359)
            length -= tlen
            
            for _ in range(tlen):
                sum1 += data[index]
                sum2 += sum1
                index += 1
                
            sum1 = (sum1 & 0xffff) + (sum1 >> 16)
            sum2 = (sum2 & 0xffff) + (sum2 >> 16)
        
        sum1 = (sum1 & 0xffff) + (sum1 >> 16)
        sum2 = (sum2 & 0xffff) + (sum2 >> 16)
        
        return (sum2 << 16) | sum1

    def notification_handler(self, sender, data):
        """Handle incoming notifications from BLE device"""
        # Check if this is a handshake packet
        if len(data) >= 2 and data[0] == 0xFF and data[1] == 0xAA:
            print("Handshake packet received")
            self.handle_handshake(data)
            return

        # Handle regular data packet
        if len(data) >= 6:  # Ensure we have packet number + checksum
            # Extract packet number (first 2 bytes)
            packet_num = struct.unpack('<H', data[0:2])[0]
            
            # Extract checksum (next 4 bytes)
            received_checksum = struct.unpack('<I', data[2:6])[0]
            
            # Data portion starts at byte 6
            payload = data[6:]
            
            # Calculate checksum on received data
            calculated_checksum = self.calculate_fletcher32(payload)
            
            if calculated_checksum != received_checksum:
                print(f"Checksum mismatch for packet {packet_num}! Discarding packet.")
                print(f"Received: {received_checksum}, Calculated: {calculated_checksum}")
                return
            
            if self.frame_buffer is not None:
                offset = packet_num * self.packet_data_size
                remaining_bytes = self.total_bytes - offset
                data_to_copy = min(remaining_bytes, self.packet_data_size)
                
                self.frame_buffer[offset:offset + data_to_copy] = payload[:data_to_copy]
                self.packets_received.add(packet_num)
                print(f"Packet {packet_num} verified and stored. {len(self.packets_received)}/{self.num_packets} packets received.")
                
                if len(self.packets_received) == self.num_packets:
                    self.verify_and_process_frame()

    def handle_handshake(self, data):
        """Process handshake packet"""
        try:
            if len(data) >= 18 and data[0:2] == b'\xFF\xAA' and data[16:18] == b'\xFF\xBB':
                self.total_bytes = struct.unpack('<I', data[2:6])[0]
                self.num_packets = struct.unpack('<H', data[6:8])[0]
                self.frame_width = struct.unpack('<H', data[8:10])[0]
                self.frame_height = struct.unpack('<H', data[10:12])[0]
                self.expected_frame_checksum = struct.unpack('<I', data[12:16])[0]
                
                print(f"Handshake received: {self.frame_width}x{self.frame_height}, "
                      f"{self.total_bytes} bytes in {self.num_packets} packets")
                print(f"Expected frame checksum: {self.expected_frame_checksum}")
                
                self.frame_buffer = bytearray(self.total_bytes)
                self.packets_received.clear()
        except struct.error as e:
            print(f"Error processing handshake: {e}")

    def verify_and_process_frame(self):
        """Verify complete frame checksum and process if valid"""
        calculated_frame_checksum = self.calculate_fletcher32(self.frame_buffer)
        
        if calculated_frame_checksum != self.expected_frame_checksum:
            print("Frame checksum mismatch! Discarding frame.")
            print(f"Expected: {self.expected_frame_checksum}, Calculated: {calculated_frame_checksum}")
            self.packets_received.clear()
            return
            
        try:
            frame = np.frombuffer(self.frame_buffer, dtype=np.uint8).reshape(
                (self.frame_height, self.frame_width))
            self.current_frame = frame
            self.frame_ready.set()
            print("Frame verified and processed successfully!")
        except ValueError as e:
            print(f"Error reshaping frame data: {e}")

async def find_camera_device():
    """Find the camera device by name"""
    print("Scanning for CameraRelay device...")
    devices = await BleakScanner.discover()
    for device in devices:
        if device.name and "CameraRelay" in device.name:
            print(f"Found CameraRelay device: {device.address}")
            return device.address
    return None

def handle_disconnect(client):
    print("Device disconnected")
    sys.exit(0)

async def main():
    while True:
        device_address = await find_camera_device()
        if not device_address:
            print("Camera device not found! Retrying in 5 seconds...")
            await asyncio.sleep(5)
            continue

        receiver = BLEFrameReceiver()
        try:
            async with BleakClient(device_address, disconnected_callback=handle_disconnect) as client:
                print(f"Connected to {client.address}")
                
                await client.start_notify(
                    SERIAL_TX_UUID,
                    receiver.notification_handler
                )
                
                while True:
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
                    
                await client.stop_notify(SERIAL_TX_UUID)
                cv2.destroyAllWindows()
                break
                
        except Exception as e:
            print(f"Connection error: {e}")
            print("Retrying in 5 seconds...")
            await asyncio.sleep(5)
            continue

if __name__ == "__main__":
    asyncio.run(main())