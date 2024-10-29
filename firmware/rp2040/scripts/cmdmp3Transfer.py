import serial
import time
import os

# Configure the serial port
ser = serial.Serial('/dev/cu.usbmodem11101', 921600, timeout=1)  # Adjust port name as needed

def send_command(cmd):
    ser.write(cmd.encode())
    time.sleep(0.1)  # Give some time for Arduino to process
    # response = ser.readline().decode().strip()
    # print(f"Arduino response: {response}")

def wait_for_response(ser, expected_response, send_data=None):
    """
    Wait for an expected response from Arduino. Optionally send data first.
    Returns True if expected response received, False if timeout or different response.
    """
    if send_data is not None:
        if isinstance(send_data, str):
            ser.write(send_data.encode())
        else:
            ser.write(send_data)
        
    while True:
        line = ser.readline().decode().strip()
        print(f"Arduino reply: {line}")
        if line == expected_response:
            return True
        time.sleep(0.1)  # Small delay to prevent busy waiting

def send_file(filename):
    if not os.path.exists(filename):
        print(f"File {filename} not found!")
        return

    file_size = os.path.getsize(filename)
    print(f"Sending file: {filename} ({file_size} bytes)")
    
    # Wait for Arduino to be ready
    wait_for_response(ser, "Ready to receive file", send_data='r')
    
    # Send file data
    with open(filename, 'rb') as file:
        bytes_sent = 0
        while True:
            chunk = file.read(1024)
            if not chunk:
                break
            ser.write(chunk)
            bytes_sent += len(chunk)
            print(f"Progress: {bytes_sent}/{file_size} bytes sent", end='\r')
            time.sleep(0.01)
    print(f"\nProgress: {bytes_sent}/{file_size} bytes sent")
    
    # Wait for file received confirmation
    wait_for_response(ser, "File received", send_data=b'EOF')
    
    # Send play command and wait for completion
    wait_for_response(ser, "Playback stopped", send_data='p')
    
    # print("\nFile sent successfully")
    # time.sleep(1)  # Wait for Arduino to finish processing

# Main loop
if __name__ == "__main__":
    while True:
        user_input = input("Enter command (s: send file, p: play, t: stop, q: quit): ").lower()
        
        if user_input == 's':
            filename = input("Enter the path to the MP3 file: ")
            send_file(filename)
        elif user_input == 'p':
            send_command('p')
        elif user_input == 't':
            send_command('s')
        elif user_input == 'q':
            print("Quitting program")
            break
        else:
            print("Invalid command. Use 's' to send a file, 'p' to play, 't' to stop, or 'q' to quit.")

        

    # Clean up
    ser.close()
    print("Program ended")