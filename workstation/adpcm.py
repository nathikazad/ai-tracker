import time
import struct
import wave
import numpy as np
import os

step_table = [
    7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
    50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230,
    253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963,
    1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327,
    3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442,
    11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794,
    32767
]

# Index table
index_table = [-1, -1, -1, -1, 2, 4, 6, 8]

def adpcm_decode_block(inbuf, channels):
    inbuf = np.frombuffer(inbuf, dtype=np.uint8)
    inbufsize = len(inbuf)
    
    if inbufsize < channels * 4:
        return np.array([], dtype=np.int16)

    pcmdata = np.zeros(channels, dtype=np.int32)
    index = np.zeros(channels, dtype=np.int8)
    outbuf = []

    for ch in range(channels):
        pcmdata[ch] = np.int16(inbuf[ch*4] | (inbuf[ch*4 + 1] << 8))
        index[ch] = inbuf[ch*4 + 2]
        
        if index[ch] < 0 or index[ch] > 88 or inbuf[ch*4 + 3] != 0:
            return np.array([], dtype=np.int16)
        
        outbuf.append(pcmdata[ch])

    inbuf = inbuf[channels*4:]
    chunks = len(inbuf) // (channels * 4)
    samples = 1 + chunks * 8

    for _ in range(chunks):
        for ch in range(channels):
            for i in range(4):
                step = step_table[index[ch]]
                delta = step >> 3

                if inbuf[0] & 1:
                    delta += step >> 2
                if inbuf[0] & 2:
                    delta += step >> 1
                if inbuf[0] & 4:
                    delta += step

                if inbuf[0] & 8:
                    pcmdata[ch] -= delta
                else:
                    pcmdata[ch] += delta

                index[ch] += index_table[inbuf[0] & 0x7]
                index[ch] = max(0, min(index[ch], 88))
                pcmdata[ch] = max(-32768, min(pcmdata[ch], 32767))
                outbuf.append(pcmdata[ch])

                step = step_table[index[ch]]
                delta = step >> 3

                if inbuf[0] & 0x10:
                    delta += step >> 2
                if inbuf[0] & 0x20:
                    delta += step >> 1
                if inbuf[0] & 0x40:
                    delta += step

                if inbuf[0] & 0x80:
                    pcmdata[ch] -= delta
                else:
                    pcmdata[ch] += delta

                index[ch] += index_table[(inbuf[0] >> 4) & 0x7]
                index[ch] = max(0, min(index[ch], 88))
                pcmdata[ch] = max(-32768, min(pcmdata[ch], 32767))
                outbuf.append(pcmdata[ch])

                inbuf = inbuf[1:]

    return np.array(outbuf, dtype=np.int16)

def generate_wav_header(sample_rate, bits_per_sample, channels, data_size):
    print(f"Generating WAV header for {data_size} bytes")
    header = bytearray(44)
    header[0:4] = b'RIFF'
    struct.pack_into('<I', header, 4, data_size + 36)
    header[8:12] = b'WAVE'
    header[12:16] = b'fmt '
    struct.pack_into('<I', header, 16, 16)
    struct.pack_into('<H', header, 20, 1)
    struct.pack_into('<H', header, 22, channels)
    struct.pack_into('<I', header, 24, sample_rate)
    struct.pack_into('<I', header, 28, sample_rate * channels * (bits_per_sample // 8))
    struct.pack_into('<H', header, 32, channels * (bits_per_sample // 8))
    struct.pack_into('<H', header, 34, bits_per_sample)
    header[36:40] = b'data'
    struct.pack_into('<I', header, 40, data_size)
    return header

def save_wav_file(full_path, audio_data):
    sample_rate = 16000
    bits_per_sample = 16
    channels = 1

    # Decode ADPCM data
    decoded_data = adpcm_decode_block(audio_data, channels)
    
    # Convert numpy array to bytes
    decoded_bytes = decoded_data.tobytes()
    

    wav_header = generate_wav_header(sample_rate, bits_per_sample, channels, len(decoded_bytes))
    with wave.open(full_path, "wb") as wav_file:
        wav_file.setnchannels(channels)
        wav_file.setsampwidth(bits_per_sample // 8)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(wav_header + decoded_bytes)
    print(f"Decoded audio saved at '{full_path}.wav'")


