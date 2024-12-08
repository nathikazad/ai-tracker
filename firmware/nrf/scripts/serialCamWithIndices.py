import serial
import cv2
import numpy as np
import time
import struct
from datetime import datetime
import os

class FrameReceiver:
    def __init__(self, port='/dev/cu.usbmodem11101', baudrate=921600, save_dir='saved_frames'):
        self.ser = serial.Serial(port, baudrate, timeout=1.5)
        self.frame_width = None
        self.frame_height = None
        self.total_bytes = None
        self.num_packets = None
        self.packet_data_size = 238  # 240 - 2 bytes for packet number
        
        # Create directory for saved frames if it doesn't exist
        self.save_dir = save_dir
        os.makedirs(self.save_dir, exist_ok=True)

    def read_handshake(self):
        # Wait for start marker
        while True:
            if self.ser.read(2) == b'\xFF\xAA':
                break
                
        # Read handshake data
        try:
            self.total_bytes = struct.unpack('<I', self.ser.read(4))[0]  # 32-bit unsigned int
            self.num_packets = struct.unpack('<H', self.ser.read(2))[0]  # 16-bit unsigned int
            self.frame_width = struct.unpack('<H', self.ser.read(2))[0]  # 16-bit unsigned int
            self.frame_height = struct.unpack('<H', self.ser.read(2))[0]  # 16-bit unsigned int
            
            # Wait for end marker
            if self.ser.read(2) != b'\xFF\xBB':
                print("Invalid handshake end marker")
                return False
                
            print(f"Handshake received: {self.frame_width}x{self.frame_height}, "
                  f"{self.total_bytes} bytes in {self.num_packets} packets")
            return True
        except struct.error:
            print("Error reading handshake data")
            return False

    def save_frame(self, frame):
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        filename = f"frame_{timestamp}.png"
        filepath = os.path.join(self.save_dir, filename)
        
        # Save the frame
        success = cv2.imwrite(filepath, frame)
        if success:
            print(f"Frame saved: {filename}")
        else:
            print(f"Failed to save frame: {filename}")
        
        return success

    def read_frame(self):
        if not self.read_handshake():
            return None
            
        # Initialize frame buffer
        frame_buffer = bytearray(self.total_bytes)
        packets_received = set()
        
        # Read all packets
        timeout = time.time() + 2.0  # 2 second timeout
        while len(packets_received) < self.num_packets:
            if time.time() > timeout:
                print("Timeout waiting for packets")
                return None
                
            # Read packet number (2 bytes)
            packet_num_bytes = self.ser.read(2)
            if len(packet_num_bytes) != 2:
                continue
                
            packet_num = struct.unpack('<H', packet_num_bytes)[0]
            
            # Calculate expected data size for this packet
            offset = packet_num * self.packet_data_size
            remaining_bytes = self.total_bytes - offset
            expected_size = min(remaining_bytes, self.packet_data_size)
            
            # Read packet data
            packet_data = self.ser.read(expected_size)
            if len(packet_data) != expected_size:
                print(f"Incomplete packet {packet_num}")
                continue
                
            # Store packet data in frame buffer
            frame_buffer[offset:offset + expected_size] = packet_data
            packets_received.add(packet_num)
            
        try:
            # Reshape the complete frame buffer into a numpy array
            frame = np.frombuffer(frame_buffer, dtype=np.uint8).reshape(
                (self.frame_height, self.frame_width))
            return frame
        except ValueError as e:
            print(f"Error reshaping frame data: {e}")
            return None

def main():
    receiver = FrameReceiver()
    
    while True:
        frame = receiver.read_frame()
        if frame is not None:
            # Display the frame
            cv2.imshow('Camera Stream', frame)
            
            # Save the frame
            receiver.save_frame(frame)
        else:
            print("Failed to read valid frame")
            time.sleep(0.1)
            
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cv2.destroyAllWindows()
    receiver.ser.close()

if __name__ == "__main__":
    main()