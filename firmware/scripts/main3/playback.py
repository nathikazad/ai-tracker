from pydub import AudioSegment
import struct
import asyncio
import tempfile
from pathlib import Path
from util import log

class AudioPlayer:
    def __init__(self, ble_manager):
        self.ble_manager = ble_manager
        self.ack_received = asyncio.Event()

    def _notification_handler(self, sender, data):
        if data == b'A':
            self.ack_received.set()
        else:
            print(f"Received unexpected data: {data}")

    def _compress_mp3(self, input_file: str, output_file: str):
        """Compress MP3 to roughly 20% of original size"""
        audio = AudioSegment.from_mp3(input_file)
        # Export with reduced bitrate (typically achieves ~20% size)
        audio.export(output_file, format="mp3", bitrate="32k")

    async def play_audio(self, audio_response, frames_per_batch=100):
        try:
            # Create temporary files
            temp_dir = Path(tempfile.gettempdir()) / "tts_responses"
            temp_dir.mkdir(exist_ok=True)
            original_file = temp_dir / "response.mp3"
            compressed_file = temp_dir / "compressed.mp3"
            # Save original audio
            with open(original_file, 'wb') as f:
                for chunk in audio_response.iter_bytes():
                    f.write(chunk)
            log(f"Compressing")
            # Compress audio
            self._compress_mp3(str(original_file), str(compressed_file))

            # Setup acknowledgment handler
            await self.ble_manager.start_notify(
                self.ble_manager.tx_uuid,
                self._notification_handler
            )

            # Stream the compressed file
            await self._stream_file(str(compressed_file), frames_per_batch)

        finally:
            # Clean up
            await self.ble_manager.stop_notify(self.ble_manager.tx_uuid)
            if original_file.exists():
                original_file.unlink()
            if compressed_file.exists():
                compressed_file.unlink()

    async def _stream_file(self, filename: str, frames_per_batch: int):
        """Stream audio file in batches."""
        log("Starting to stream")
        with open(filename, 'rb') as f:
            mp3_data = f.read()

        frame_starts = []
        i = 0
        while i < len(mp3_data) - 1:
            if mp3_data[i] == 0xFF and (mp3_data[i+1] == 0xFB or mp3_data[i+1] == 0xF3):
                frame_starts.append(i)
            i += 1
        log(f"Found {len(frame_starts)} frame starts")
        for i in range(0, len(frame_starts), frames_per_batch):
            log(f"Sending batch {i} of {len(frame_starts)}")
            batch_start = frame_starts[i]
            batch_end = frame_starts[i + frames_per_batch] if i + frames_per_batch < len(frame_starts) else len(mp3_data)
            batch_data = mp3_data[batch_start:batch_end]
            
            self.ack_received.clear()
            size_bytes = struct.pack('>H', len(batch_data))
            await self.ble_manager.write_gatt_char(self.ble_manager.rx_uuid, size_bytes)
            await asyncio.sleep(0.01)

            CHUNK_SIZE = 240
            for j in range(0, len(batch_data), CHUNK_SIZE):
                chunk = batch_data[j:j + CHUNK_SIZE]
                await self.ble_manager.write_gatt_char(self.ble_manager.rx_uuid, chunk)

            try:
                await asyncio.wait_for(self.ack_received.wait(), timeout=2.0)
            except asyncio.TimeoutError:
                raise RuntimeError("Timeout waiting for acknowledgment")