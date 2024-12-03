import cv2
import numpy as np
import asyncio
from bleak import BleakClient, BleakScanner
from typing import Optional, List
import time

class CameraFrameReceiver:
    def __init__(self, device_name: str = "CameraRelay"):
        self.device_name = device_name
        self.client: Optional[BleakClient] = None
        self.connected = False
        
        # UUIDs for BLE service
        self.tx_uuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
        
        # Frame buffer and state
        self.frame_buffer = bytearray()
        self.frame_started = False
        self.expected_size = 160 * 120
        self.current_frame = None
        self.frame_ready = asyncio.Event()

    def notification_handler(self, sender: int, data: bytes):
        """Handle incoming BLE notifications."""
        if not self.frame_started:
            # Look for start marker
            if len(data) >= 2 and data[0] == 0xFF and data[1] == 0xAA:
                print("Start marker received")
                self.frame_buffer = bytearray()
                self.frame_started = True
                # Remove start marker from data
                data = data[2:]
            else:
                return

        self.frame_buffer.extend(data)

        # Check for end marker in the latest data
        if len(self.frame_buffer) >= self.expected_size:
            self.frame_started = False
            try:
                # Convert buffer to numpy array and reshape
                frame_data = np.frombuffer(self.frame_buffer[:self.expected_size], dtype=np.uint8)
                self.current_frame = frame_data.reshape((120, 160))
                self.frame_ready.set()
                print(f"Frame complete: {len(self.frame_buffer)} bytes")
            except ValueError as e:
                print(f"Error processing frame: {e}")
            self.frame_buffer = bytearray()

    async def connect(self):
        """Connect to BLE device."""
        print(f"Scanning for device with name '{self.device_name}'...")
        device = await BleakScanner.find_device_by_name(self.device_name)
        if device is None:
            raise RuntimeError(f"Could not find device with name '{self.device_name}'")
        
        print(f"Found device {device.name} [{device.address}]")
        self.client = BleakClient(device)
        await self.client.connect()
        print(f"Connected to {device.name}")
        
        # Start notifications
        await self.client.start_notify(self.tx_uuid, self.notification_handler)
        self.connected = True

    async def disconnect(self):
        """Disconnect from BLE device."""
        if self.client and self.client.is_connected:
            await self.client.stop_notify(self.tx_uuid)
            await self.client.disconnect()
            self.connected = False

    async def run_display(self):
        """Main display loop."""
        try:
            await self.connect()
            
            while True:
                # Wait for a frame to be ready
                await self.frame_ready.wait()
                self.frame_ready.clear()
                
                if self.current_frame is not None:
                    # Display the frame
                    cv2.imshow('Camera Stream', self.current_frame)
                    
                    # Break the loop if 'q' is pressed
                    if cv2.waitKey(1) & 0xFF == ord('q'):
                        break
                
        except Exception as e:
            print(f"Error: {e}")
        finally:
            await self.disconnect()
            cv2.destroyAllWindows()

async def main():
    receiver = CameraFrameReceiver()
    await receiver.run_display()

if __name__ == "__main__":
    asyncio.run(main())