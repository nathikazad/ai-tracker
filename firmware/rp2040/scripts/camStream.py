import serial
import cv2
import numpy as np

# Configure the serial port
ser = serial.Serial('/dev/cu.usbmodem1101', 921600)  # Adjust port name as needed

def read_frame():
    # Wait for start marker
    while ser.read(2) != b'\xFF\xAA':
        pass
    
    # Read frame data
    frame_data = ser.read(320 * 320)
    
    # Wait for end marker
    while ser.read(2) != b'\xFF\xBB':
        pass
    
    return np.frombuffer(frame_data, dtype=np.uint8).reshape((320, 320))

# Main loop
while True:
    frame = read_frame()
    
    # Display the frame
    cv2.imshow('Camera Stream', frame)
    
    # Break the loop if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Clean up
cv2.destroyAllWindows()
ser.close()