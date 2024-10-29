import serial
import time
import struct

class MP3Streamer:
    def __init__(self, port='/dev/cu.usbmodem11101', baudrate=921600):
        self.serial = serial.Serial(port, baudrate)
        time.sleep(2)  # Wait for Arduino to reset
        
    def stream_frames(self, mp3_data, frames_per_batch=100):
        # MP3 frame sync word is 0xFF 0xFB or 0xFF 0xF3
        frame_starts = []
        i = 0
        while i < len(mp3_data) - 1:
            if mp3_data[i] == 0xFF and (mp3_data[i+1] == 0xFB or mp3_data[i+1] == 0xF3):
                frame_starts.append(i)
            i += 1
        
        print(f"Found {len(frame_starts)} frames")
        # Stream frames in batches
        for i in range(0, len(frame_starts), frames_per_batch):
            batch_start = frame_starts[i]
            
            # Calculate batch end
            if i + frames_per_batch < len(frame_starts):
                batch_end = frame_starts[i + frames_per_batch]
            else:
                batch_end = len(mp3_data)
                
            batch_data = mp3_data[batch_start:batch_end]
            
            # Send batch size first
            self.serial.write(struct.pack('>H', len(batch_data)))
            
            # Send batch data
            self.serial.write(batch_data)
            print(f"Sent batch {i//frames_per_batch + 1}")
            
            # Wait for acknowledgment
            while True:
                if self.serial.in_waiting:
                    ack = self.serial.read()
                    if ack == b'A':
                        break
            
            time.sleep(0.01)  # Give Arduino time to process
            
    def close(self):
        self.serial.close()


def playFile(filename):
    with open(filename, 'rb') as f:
        mp3_data = f.read()
    
    streamer = MP3Streamer()  # Change to your port
    # try:
    #     while True:
    streamer.stream_frames(mp3_data)
            # time.sleep(2)
    # except KeyboardInterrupt:
    streamer.close()

if __name__ == "__main__":
    playFile("/var/folders/kn/0df0rckn6qs4d34jch67_zf00000gn/T/tts_responses/response.mp3")