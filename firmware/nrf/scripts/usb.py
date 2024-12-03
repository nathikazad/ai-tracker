import serial.tools.list_ports
import serial
import sys
import time

def find_aspire_device():
    ports = serial.tools.list_ports.comports()
    
    for port in ports:
        if port.manufacturer == "Aspire":
            print(f"\nFound Aspire device:")
            print(f"Port: {port.device}")
            print(f"Product: {port.product}")
            print(f"VID:PID: {port.vid:04x}:{port.pid:04x}")
            return port.device
    return None

def read_serial_data():
    port = find_aspire_device()
    if not port:
        print("No Aspire device found")
        return

    try:
        ser = serial.Serial(port, baudrate=115200, timeout=1)
        print("\nConnection opened. Reading data...")
        
        while True:
            try:
                if ser.in_waiting:
                    line = ser.readline().decode('utf-8').strip()
                    if line:
                        print(f"Received: {line}")
                time.sleep(0.1)  # Small delay to prevent CPU hogging
                
            except KeyboardInterrupt:
                print("\nStopping...")
                break
            
    except serial.SerialException as e:
        print(f"Error opening port: {e}")
    finally:
        if 'ser' in locals():
            ser.close()
            print("Port closed")

if __name__ == "__main__":
    read_serial_data()