import serial
import cv2
import numpy as np
from pathlib import Path

class SimpleSender:
    def __init__(self, port='/dev/cu.usbmodem1101', baudrate=921600):
        self.ser = serial.Serial(port, baudrate)
        
    def send_image(self, image_path):
        # Read the image in grayscale
        frame = cv2.imread(str(image_path), cv2.IMREAD_GRAYSCALE)
        if frame is None:
            print(f"Failed to read image: {image_path}")
            return False
        
        try:
            # Send start bytes
            self.ser.write(b'\xFF\xAA')
            
            # Send the entire image as bytes
            self.ser.write(frame.tobytes())
            
            # Send end bytes
            self.ser.write(b'\xFF\xBB')
            
            # Ensure all data is sent
            self.ser.flush()
            
            print(f"Sent image: {image_path}")
            print(f"Image size: {frame.shape[0]}x{frame.shape[1]} pixels")
            print(f"Bytes sent: {len(frame.tobytes())}")
            return True
            
        except Exception as e:
            print(f"Error sending image: {e}")
            return False
            
    def close(self):
        self.ser.close()

def main():
    sender = SimpleSender()
    try:
        image_path = 'saved_frames/frame_20241207_135158_115755.png'  # Replace with your image path
        sender.send_image(image_path)
    finally:
        sender.close()

if __name__ == "__main__":
    main()

    