import serial
import cv2
import numpy as np
import time

# Configure the serial port
ser = serial.Serial('/dev/cu.usbmodem11101', 921600, timeout=1.5)  # 1.5 second timeout

def read_frame():
    # Wait for start marker
    start_time = time.time()
    while True:
        if ser.read(2) == b'\xFF\xAA':
            print("Start marker received")
            break
        if time.time() - start_time > 2:  # 2 second timeout for start marker
            print("Timeout waiting for start marker")
            return None

    # Read frame data with byte counting
    expected_bytes = 160 * 120
    frame_data = ser.read(expected_bytes)
    actual_bytes = len(frame_data)
    
    if actual_bytes < expected_bytes:
        print(f"Timeout: Received only {actual_bytes} bytes out of {expected_bytes} expected")
        return None

    # Wait for end marker
    start_time = time.time()
    while True:
        if ser.read(2) == b'\xFF\xBB':
            print("End marker received")
            break
        if time.time() - start_time > 2:  # 2 second timeout for end marker
            print("Timeout waiting for end marker")
            return None

    try:
        return np.frombuffer(frame_data, dtype=np.uint8).reshape((120, 160))
    except ValueError as e:
        print(f"Error reshaping frame data: {e}")
        return None

# Main loop
while True:
    frame = read_frame()
    
    if frame is not None:
        # Display the frame
        cv2.imshow('Camera Stream', frame)
    else:
        print("Failed to read valid frame")
        # Optional: small delay to prevent tight loop on errors
        time.sleep(0.1)

    # Break the loop if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Clean up
cv2.destroyAllWindows()
ser.close()