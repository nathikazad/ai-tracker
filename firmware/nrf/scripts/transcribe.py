import asyncio
from bleak import BleakClient, BleakScanner
import struct
import wave
import numpy as np
from openai import OpenAI
import os
from typing import AsyncGenerator, Optional, Callable
from typing import AsyncGenerator, Optional, Callable, Coroutine, Any
import tempfile

class BLEAudioTranscriber:
    def __init__(self, device_name: str = "Audio Sender", 
                 data_characteristic_uuid: str = "19B10001-E8F2-537E-4F6C-D104768A1214"):
        self.device_name = device_name
        self.data_characteristic_uuid = data_characteristic_uuid
        self.audio_data = bytearray()
        self.expected_packets = 0
        self.received_packets = 0
        self.client: Optional[BleakClient] = None
        self._transcription_callback: Optional[Callable[[str], Coroutine[Any, Any, None]]] = None
        
        # ADPCM tables
        self.step_table = [
            7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
            50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230,
            253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963,
            1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327,
            3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442,
            11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794,
            32767
        ]
        self.index_table = [-1, -1, -1, -1, 2, 4, 6, 8]

    def set_transcription_callback(self, callback: Callable[[str], Coroutine[Any, Any, None]]):
        """Set a callback function to receive transcribed text."""
        self._transcription_callback = callback

    async def start(self):
        """Start listening for BLE audio data."""
        device = await BleakScanner.find_device_by_name(self.device_name)
        if device is None:
            raise RuntimeError(f"Could not find device with name '{self.device_name}'")

        self.client = BleakClient(device)
        await self.client.connect()
        await self.client.start_notify(self.data_characteristic_uuid, self._notification_handler)

    async def stop(self):
        """Stop listening and disconnect."""
        if self.client:
            await self.client.stop_notify(self.data_characteristic_uuid)
            await self.client.disconnect()

    def _notification_handler(self, _sender, data):
        """Handle incoming BLE notifications."""
        if data.startswith(b'START'):
            self.audio_data.clear()
            self.expected_packets = data[7] if len(data) >= 8 else 0
            self.received_packets = 0
            
        elif data[:2] == b'\xFF\xFF':
            self.audio_data.extend(data[4:])
            self.received_packets += 1
            
        elif data.startswith(b'END'):
            asyncio.create_task(self._process_audio())

    async def _process_audio(self):
        """Process received audio data and get transcription."""
        try:
            # Decode ADPCM and create WAV file (same as before)
            decoded_data = self._adpcm_decode_block(self.audio_data, channels=1)
            decoded_bytes = decoded_data.tobytes()
            
            with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as temp_wav:
                wav_header = self._generate_wav_header(
                    sample_rate=4000,
                    bits_per_sample=16,
                    channels=1,
                    data_size=len(decoded_bytes)
                )
                with wave.open(temp_wav.name, "wb") as wav_file:
                    wav_file.setnchannels(1)
                    wav_file.setsampwidth(2)
                    wav_file.setframerate(4000)
                    wav_file.writeframes(wav_header + decoded_bytes)

                # Transcribe
                transcript = await self._transcribe_wav(temp_wav.name)
                
                # Call callback with transcribed text
                if self._transcription_callback and transcript:
                    await self._transcription_callback(transcript)
                
        except Exception as e:
            print(f"Error processing audio: {e}")
        finally:
            try:
                os.unlink(temp_wav.name)
            except:
                pass

    async def _transcribe_wav(self, file_path: str) -> str:
        """Transcribe WAV file using OpenAI Whisper API."""
        client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
        
        try:
            with open(file_path, "rb") as audio_file:
                transcript = await asyncio.get_event_loop().run_in_executor(
                    None,
                    lambda: client.audio.transcriptions.create(
                        model="whisper-1",
                        file=audio_file
                    )
                )
                return transcript.text
        except Exception as e:
            print(f"Transcription error: {e}")
            return ""

    def _adpcm_decode_block(self, inbuf, channels):
        """Decode ADPCM data."""
        inbuf = np.frombuffer(inbuf, dtype=np.uint8)
        if len(inbuf) < channels * 4:
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

        for _ in range(chunks):
            for ch in range(channels):
                for i in range(4):
                    step = self.step_table[index[ch]]
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

                    index[ch] += self.index_table[inbuf[0] & 0x7]
                    index[ch] = max(0, min(index[ch], 88))
                    pcmdata[ch] = max(-32768, min(pcmdata[ch], 32767))
                    outbuf.append(pcmdata[ch])

                    # Process high nibble
                    step = self.step_table[index[ch]]
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

                    index[ch] += self.index_table[(inbuf[0] >> 4) & 0x7]
                    index[ch] = max(0, min(index[ch], 88))
                    pcmdata[ch] = max(-32768, min(pcmdata[ch], 32767))
                    outbuf.append(pcmdata[ch])

                    inbuf = inbuf[1:]

        return np.array(outbuf, dtype=np.int16)

    def _generate_wav_header(self, sample_rate, bits_per_sample, channels, data_size):
        """Generate WAV header."""
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