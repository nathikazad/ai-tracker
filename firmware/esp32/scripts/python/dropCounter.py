# dropCounter.py
# used to test the drop rate of the BLE packets
import asyncio
from bleak import BleakClient, BleakScanner
import struct
import time

# BLE device name (should match the name set in the ESP32 code)
DEVICE_NAME = "XIAOESP32S3_BLE"

# UUID of the characteristic to notify (should match the one in the ESP32 code)
NOTIFY_CHARACTERISTIC_UUID = "00002a59-0000-1000-8000-00805f9b34fb"

# Constants for packet analysis
PACKET_SIZE = 512
EXPECTED_PACKETS = 100
BURST_TIMEOUT = 5  # seconds

class PacketAnalyzer:
    def __init__(self):
        self.reset()

    def reset(self):
        self.received_packets = set()
        self.start_time = None
        self.end_time = None
        self.burst_started = False
        self.last_packet_time = None

    def add_packet(self, packet_number):
        if packet_number == 0:
            self.burst_started = True
            self.start_time = time.time()
        
        if self.burst_started:
            self.received_packets.add(packet_number)
            self.end_time = time.time()
        self.last_packet_time = time.time()

    def calculate_drop_rate(self):
        received_count = len(self.received_packets)
        drop_rate = (EXPECTED_PACKETS - received_count) / EXPECTED_PACKETS * 100
        duration = self.end_time - self.start_time if self.end_time and self.start_time else 0
        return received_count, drop_rate, duration

async def run_ble_client():
    analyzer = PacketAnalyzer()

    def notification_handler(sender, data):
        if len(data) == PACKET_SIZE:
            packet_number = data[0]
            analyzer.add_packet(packet_number)
            # if analyzer.burst_started:
            #     print(f"Received packet: {packet_number}")

    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return

    async with BleakClient(device) as client:
        print(f"Connected to {device.name}")

        await client.start_notify(NOTIFY_CHARACTERISTIC_UUID, notification_handler)

        while True:
            print("Waiting for burst...")
            analyzer.reset()
            burst_start_time = time.time()

            while analyzer.last_packet_time == None or time.time() - analyzer.last_packet_time < 1:
                await asyncio.sleep(0.1)
                if len(analyzer.received_packets) == EXPECTED_PACKETS:
                    break

            if len(analyzer.received_packets) > 0:
                received_count, drop_rate, duration = analyzer.calculate_drop_rate()
                print(f"\nBurst Summary:")
                print(f"Received packets: {received_count}/{EXPECTED_PACKETS}")
                print(f"Drop rate: {drop_rate:.2f}%")
                if duration > 0:
                    throughput = (received_count * PACKET_SIZE / duration / 1024)
                    print(f"Duration: {duration:.6f} seconds")
                    print(f"Throughput: {throughput:.2f} KB/s")
                else:
                    print(f"Duration: {duration:.6f} seconds (extremely fast)")
                    print("Throughput: Unable to calculate (duration too short)")
                print("\n" + "="*40 + "\n")

asyncio.run(run_ble_client())