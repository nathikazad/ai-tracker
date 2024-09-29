import serial
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import time
import numpy as np

# Configure the serial port
SERIAL_PORT = '/dev/cu.usbmodem1101'
BAUD_RATE = 115200

# Configure the graph
WINDOW_SIZE = 20  # 5-second window
SAMPLE_RATE = 16000  # Assuming 16kHz sample rate
MAX_POINTS = WINDOW_SIZE * SAMPLE_RATE

# Set up the plot
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
line, = ax1.plot([], [])
ax1.set_xlim(0, WINDOW_SIZE)
ax1.set_ylim(500, 2100)  # Fixed y-axis for 16-bit audio range
ax1.set_xlabel('Time (s)')
ax1.set_ylabel('Amplitude')
ax1.set_title('Real-time Audio Data (Last 5 Seconds)')

# Add grid to the main plot
ax1.grid(True, linestyle='--', alpha=0.7)

# Text annotations for stats
zero_point_text = ax2.text(0.1, 0.8, '', transform=ax2.transAxes)
min_value_text = ax2.text(0.1, 0.5, '', transform=ax2.transAxes)
max_value_text = ax2.text(0.1, 0.2, '', transform=ax2.transAxes)
ax2.axis('off')

# Initialize serial connection
ser = serial.Serial(SERIAL_PORT, BAUD_RATE)

# Initialize an empty buffer for the window
window_buffer = np.zeros(MAX_POINTS)
buffer_index = 0

# Animation update function
def update(frame):
    global buffer_index
    
    while ser.in_waiting:
        try:
            sample = int(ser.readline().decode().strip())
            window_buffer[buffer_index] = sample
            buffer_index = (buffer_index + 1) % MAX_POINTS
        except ValueError:
            continue

    # Rearrange the buffer so that it's in chronological order
    ordered_buffer = np.concatenate((window_buffer[buffer_index:], window_buffer[:buffer_index]))

    # Create x-axis values
    x = np.linspace(0, WINDOW_SIZE, MAX_POINTS)

    # Update the plot
    line.set_data(x, ordered_buffer)

    # Calculate statistics
    zero_point = np.mean(ordered_buffer)
    min_value = np.min(ordered_buffer)
    max_value = np.max(ordered_buffer)

    # Update text annotations
    zero_point_text.set_text(f'Zero Point: {zero_point:.2f}')
    min_value_text.set_text(f'Min Value: {min_value:.2f}')
    max_value_text.set_text(f'Max Value: {max_value:.2f}')

    return line, zero_point_text, min_value_text, max_value_text

# Create the animation
anim = FuncAnimation(fig, update, interval=50, blit=True)

# Show the plot
plt.show()

# Close the serial connection when done
ser.close()