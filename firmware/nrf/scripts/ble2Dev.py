import asyncio
from bleak import BleakClient, BleakScanner
import time
import struct
from bleak.backends.characteristic import BleakGATTCharacteristic

DEVICE_NAME = "BLE Timer Test"
RX_CHAR_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"
TX_CHAR_UUID = "19B10002-E8F2-537E-4F6C-D104768A1214"
TIME_CHAR_UUID = "19B10003-E8F2-537E-4F6C-D104768A1214"

DATA_SIZE = 244
PACKET_COUNT = 100

async def get_connection_params(client):
    # Get MTU size
    mtu = client.mtu_size
    print(f"MTU Size: {mtu}")
    
    # On macOS/CoreBluetooth
    if hasattr(client._backend, 'get_connection_interval'):
        interval = await client._backend.get_connection_interval()
        print(f"Connection Interval: {interval}ms")
        
    # On Windows/BlueZ
    if hasattr(client._backend, 'get_phy'):
        phy = await client._backend.get_phy()
        print(f"PHY: {phy}")

async def notification_handler(sender: BleakGATTCharacteristic, data: bytearray):
    if sender.uuid == TIME_CHAR_UUID:
        time_ms = struct.unpack('<I', data)[0]
        print(f"Test completed - Time taken: {time_ms} ms")
        print(f"Average throughput: {(DATA_SIZE * PACKET_COUNT * 8 / time_ms)} kbps")

async def run_test():
    print(f"Scanning for {DEVICE_NAME}...")
    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    
    if not device:
        print("Device not found")
        return
        
    async with BleakClient(device) as client:
        print("Connected")
        await get_connection_params(client)
        
        await client.start_notify(TIME_CHAR_UUID, notification_handler)
        test_data = bytearray([i % 256 for i in range(DATA_SIZE)])
        
        print(f"Sending {PACKET_COUNT} packets...")
        start_time = time.time()
        
        for i in range(PACKET_COUNT):
            await client.write_gatt_char(RX_CHAR_UUID, test_data)
            # await asyncio.sleep(0.001)
            
        print(f"Local send time: {(time.time() - start_time)*1000:.2f} ms")
        await asyncio.sleep(2)

if __name__ == "__main__":
    asyncio.run(run_test())