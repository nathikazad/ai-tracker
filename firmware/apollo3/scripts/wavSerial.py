import serial
import wave
import time
import struct

# Serial port configuration
SERIAL_PORT = '/dev/cu.usbserial-110'  # Change this to match your serial port
BAUD_RATE = 500000
SAMPLE_RATE = 3906  # As mentioned in the Arduino sketch

# WAV file configuration
CHANNELS = 1
SAMPLE_WIDTH = 2  # 16-bit audio

def main():
    # Open serial port
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    
    # Clear any existing data in the buffer
    ser.reset_input_buffer()

    print("Starting to read data...")
    
    # Read data for 10 seconds
    start_time = time.time()
    buffer = bytearray()
    
    while time.time() - start_time < 10:
        if ser.in_waiting > 0:
            data = ser.read(ser.in_waiting)
            buffer.extend(data)
        time.sleep(0.01)  # Small delay to prevent CPU overuse
    
    # Close serial port
    ser.close()
    
    print(f"Total bytes received: {len(buffer)}")

    # Ensure buffer length is even
    if len(buffer) % 2 != 0:
        buffer = buffer[:-1]
        print(f"Truncated buffer to {len(buffer)} bytes to ensure even length")

    # Write buffer to WAV file
    with wave.open('output.wav', 'wb') as wav_file:
        wav_file.setnchannels(CHANNELS)
        wav_file.setsampwidth(SAMPLE_WIDTH)
        wav_file.setframerate(SAMPLE_RATE)
        
        # Convert buffer to 16-bit integers
        int_data = struct.unpack('<' + 'h'*(len(buffer)//2), buffer)
        
        # Write to WAV file
        wav_file.writeframes(struct.pack('<' + 'h'*len(int_data), *int_data))

    print("Recording complete. Data saved to 'output.wav'")

if __name__ == "__main__":
    main()