import os
import struct
from collections import defaultdict

def is_valid_header(header):
    sync = (header & 0xFFE00000) >> 21
    return sync == 0x7FF

def parse_header(header):
    try:
        version = (header & 0x180000) >> 19
        layer = (header & 0x60000) >> 17
        bitrate_index = (header & 0xF000) >> 12
        sample_rate_index = (header & 0xC00) >> 10
        padding = (header & 0x200) >> 9
        
        if version == 3:  # MPEG Version 1
            bitrates = [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320]
            sample_rates = [44100, 48000, 32000]
        else:  # MPEG Version 2 or 2.5
            bitrates = [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160]
            sample_rates = [22050, 24000, 16000]
        
        if bitrate_index == 0 or bitrate_index >= len(bitrates):
            return 0  # Invalid bitrate index
        if sample_rate_index >= len(sample_rates):
            return 0  # Invalid sample rate index
        
        bitrate = bitrates[bitrate_index] * 1000
        sample_rate = sample_rates[sample_rate_index]
        
        if layer == 3:  # Layer I
            frame_size = (12 * bitrate // sample_rate + padding) * 4
        else:  # Layer II & III
            frame_size = 144 * bitrate // sample_rate + padding
        
        return frame_size
    except Exception as e:
        print(f"Error parsing header: {e}")
        return 0

def analyze_mp3(file_path):
    if not os.path.exists(file_path):
        print(f"File {file_path} not found!")
        return

    total_size = os.path.getsize(file_path)
    frame_sizes = defaultdict(int)
    total_frames = 0
    current_pos = 0

    with open(file_path, 'rb') as f:
        while current_pos < total_size:
            f.seek(current_pos)
            header_bytes = f.read(4)
            if len(header_bytes) < 4:
                break

            header = struct.unpack('>I', header_bytes)[0]
            if is_valid_header(header):
                frame_size = parse_header(header)
                if frame_size > 0:
                    frame_sizes[frame_size] += 1
                    total_frames += 1
                    current_pos += frame_size
                else:
                    current_pos += 1
            else:
                current_pos += 1

    # Print results
    print(f"File: {file_path}")
    print(f"Total file size: {total_size} bytes")
    print(f"Number of frames: {total_frames}")
    if total_frames > 0:
        print(f"Average frame size: {sum(size * count for size, count in frame_sizes.items()) / total_frames:.2f} bytes")
    print("\nFrame size distribution:")
    for size, count in sorted(frame_sizes.items()):
        percentage = (count / total_frames) * 100 if total_frames > 0 else 0
        print(f"  {size} bytes: {count} frames ({percentage:.2f}%)")

    # Verify if we've accounted for all bytes
    analyzed_bytes = sum(size * count for size, count in frame_sizes.items())
    if analyzed_bytes != total_size:
        print(f"\nWarning: Analyzed {analyzed_bytes} bytes, but file size is {total_size} bytes.")
        print("The difference might be due to ID3 tags or other metadata.")

if __name__ == "__main__":
    file_path = input("Enter the path to the MP3 file: ")
    analyze_mp3(file_path)