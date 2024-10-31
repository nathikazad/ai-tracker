# ble.py
from bleak import BleakClient, BleakScanner
import asyncio
from typing import Optional, Callable, Any

class BLEManager:
    def __init__(self, device_name: str = "Audio Sender"):
        self.device_name = device_name
        self.client: Optional[BleakClient] = None
        self.connected = False
        
        # UUIDs for different characteristics
        self.tx_uuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
        self.rx_uuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
        self.audio_uuid = "19B10001-E8F2-537E-4F6C-D104768A1214"

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
        self.connected = True

    async def disconnect(self):
        """Disconnect from BLE device."""
        if self.client and self.client.is_connected:
            await self.client.disconnect()
            self.connected = False

    async def start_notify(self, characteristic_uuid: str, callback: Callable[[Any, bytes], None]):
        """Start notifications for a characteristic."""
        if self.client and self.connected:
            await self.client.start_notify(characteristic_uuid, callback)

    async def stop_notify(self, characteristic_uuid: str):
        """Stop notifications for a characteristic."""
        if self.client and self.connected:
            await self.client.stop_notify(characteristic_uuid)

    async def write_gatt_char(self, characteristic_uuid: str, data: bytes):
        """Write data to a characteristic."""
        if self.client and self.connected:
            await self.client.write_gatt_char(characteristic_uuid, data)