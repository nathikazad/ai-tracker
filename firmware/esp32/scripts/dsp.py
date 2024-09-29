import serial
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import numpy as np

# Configure the serial port
SERIAL_PORT = '/dev/cu.usbmodem1101'
BAUD_RATE = 115200

# Configure the graph
WINDOW_SIZE = 20  # 20-second window
SAMPLE_RATE = 16000  # Assuming 16kHz sample rate
MAX_POINTS = WINDOW_SIZE * SAMPLE_RATE

# Set up the plots
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))
line1, = ax1.plot([], [])
line2, = ax2.plot([], [])

ax1.set_xlim(0, WINDOW_SIZE)
ax1.set_ylim(500, 2100)
ax1.set_xlabel('Time (s)')
ax1.set_ylabel('Amplitude')
ax1.set_title('Original Audio Data (Last 20 Seconds)')
ax1.grid(True, linestyle='--', alpha=0.7)

ax2.set_xlim(0, WINDOW_SIZE)
ax2.set_ylim(-32000, 32000)
ax2.set_xlabel('Time (s)')
ax2.set_ylabel('Amplitude')
ax2.set_title('Processed Audio Data (Last 20 Seconds)')
ax2.grid(True, linestyle='--', alpha=0.7)

# Initialize serial connection
ser = serial.Serial(SERIAL_PORT, BAUD_RATE)

# Initialize buffers
raw_buffer = np.zeros(MAX_POINTS)
processed_buffer = np.zeros(MAX_POINTS)
buffer_index = 0

def moving_average(data, window_size=5):
    return np.convolve(data, np.ones(window_size), 'same') / window_size

def normalize(data, old_min, old_max, new_min, new_max):
    old_range = old_max - old_min
    new_range = new_max - new_min
    return (((data - old_min) * new_range) / old_range) + new_min

def process_data(data):
    # Apply moving average filter
    # filtered_data = moving_average(data, window_size=1000)
    
    # Normalize to [-32000, 32000]
    normalized_data = normalize(data, 500, 2100, -32000, 32000)
    
    return normalized_data

def update(frame):
    global buffer_index
    new_data = []
    while ser.in_waiting:
        try:
            sample = int(ser.readline().decode().strip())
            new_data.append(sample)
        except ValueError:
            continue
    
    if new_data:
        # Add new data to the buffer
        new_data = np.array(new_data)
        n = len(new_data)
        if buffer_index + n > MAX_POINTS:
            overflow = buffer_index + n - MAX_POINTS
            raw_buffer[:overflow] = new_data[-overflow:]
            raw_buffer[buffer_index:] = new_data[:-overflow]
        else:
            raw_buffer[buffer_index:buffer_index+n] = new_data
        
        buffer_index = (buffer_index + n) % MAX_POINTS
        
        # Process the entire buffer
        processed_buffer[:] = process_data(raw_buffer)

    # Create x-axis values
    x = np.linspace(0, WINDOW_SIZE, MAX_POINTS)

    # Update the plots
    line1.set_data(x, raw_buffer)
    line2.set_data(x, processed_buffer)

    return line1, line2

# Create the animation
anim = FuncAnimation(fig, update, interval=50, blit=True, cache_frame_data=False)

# Show the plot
plt.tight_layout()
plt.show()

# Close the serial connection when done
ser.close()