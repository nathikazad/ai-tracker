import serial
import time
import os

# Configure the serial port
ser = serial.Serial('/dev/cu.usbmodem1101', 921600, timeout=1)  # Adjust port name as needed

def send_command(cmd):
    ser.write(cmd.encode())
    time.sleep(0.1)  # Give some time for Arduino to process
    response = ser.readline().decode().strip()
    print(f"Arduino response: {response}")

def send_file(filename):
    if not os.path.exists(filename):
        print(f"File {filename} not found!")
        return

    file_size = os.path.getsize(filename)
    print(f"Sending file: {filename} ({file_size} bytes)")

    send_command('r')  # Send receive command to Arduino
    time.sleep(1)  # Wait for Arduino to prepare

    with open(filename, 'rb') as file:
        bytes_sent = 0
        while True:
            chunk = file.read(1024)  # Read 1KB at a time
            if not chunk:
                break
            ser.write(chunk)
            bytes_sent += len(chunk)
            print(f"Progress: {bytes_sent}/{file_size} bytes sent", end='\r')
            time.sleep(0.01)  # Small delay to prevent overwhelming the Arduino

    ser.write(b'EOF')  # Send end-of-file marker
    print("\nFile sent successfully")
    time.sleep(1)  # Wait for Arduino to finish processing

# Main loop
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