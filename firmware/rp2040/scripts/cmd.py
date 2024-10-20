import serial
import time

# Configure the serial port
ser = serial.Serial('/dev/cu.usbmodem1101', 115200, timeout=1)  # Adjust port name as needed

def send_command(cmd):
    ser.write(cmd.encode())
    time.sleep(0.1)  # Give some time for Arduino to process
    response = ser.readline().decode().strip()
    print(f"Arduino response: {response}")

# Main loop
while True:
    user_input = input("Enter command (p: play, s: stop, q: quit): ").lower()
    
    if user_input == 'p':
        send_command('p')
    elif user_input == 's':
        send_command('s')
    elif user_input == 'q':
        print("Quitting program")
        break
    else:
        print("Invalid command. Use 'p' for play, 's' for stop, or 'q' to quit.")

# Clean up
ser.close()
print("Program ended")