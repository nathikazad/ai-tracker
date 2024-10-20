import serial
import cv2
import numpy as np
import time

# Configure the serial port
ser = serial.Serial('/dev/cu.usbmodem1101', 921600, timeout=10)  # Adjust port name as needed

def capture_image():
    # Send capture command
    ser.write(b'c')
    
    # Wait for start marker
    start_marker = ser.read(2)
    if start_marker != b'\xFF\xAA':
        print("Error: Start marker not found")
        return None
    
    # Read frame data
    frame_data = ser.read(320 * 320)
    
    # Wait for end marker
    end_marker = ser.read(2)
    if end_marker != b'\xFF\xBB':
        print("Error: End marker not found")
        return None
    
    return np.frombuffer(frame_data, dtype=np.uint8).reshape((320, 320))

def save_image(frame, filename):
    cv2.imwrite(filename, frame)
    print(f"Image saved as {filename}")

# Main loop
while True:
    user_input = input("Press 'c' to capture an image or 'q' to quit: ")
    
    if user_input.lower() == 'c':
        frame = capture_image()
        if frame is not None:
            timestamp = time.strftime("%Y%m%d-%H%M%S")
            filename = f"capture_{timestamp}.png"
            save_image(frame, filename)
    elif user_input.lower() == 'q':
        break

# Clean up
ser.close()
print("Program ended")