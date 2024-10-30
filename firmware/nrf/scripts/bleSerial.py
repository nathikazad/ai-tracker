import asyncio
from bleak import BleakClient, BleakScanner
import time

# Replace with your Arduino's advertised name
DEVICE_NAME = "Audio Sender"

# Nordic UART Service UUIDs
SERIAL_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
SERIAL_RX_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"  # Write characteristic
SERIAL_TX_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"  # Notify characteristic

# Global variables
running = True

def notification_handler(sender, data):
    # Print received data as string
    try:
        message = data.decode('utf-8')
        print(f"Received: {message}")
    except UnicodeDecodeError:
        print(f"Received (hex): {data.hex()}")

async def send_periodic_message(client):
    counter = 0
    while running:
        message = f"Test message {counter}\n"
        print(f"Sending: {message.strip()}")
        
        # Convert string to bytes and send
        await client.write_gatt_char(SERIAL_RX_UUID, message.encode('utf-8'))
        counter += 1
        
        # Wait 5 seconds before sending next message
        await asyncio.sleep(5)

async def run_ble_client():
    global running
    
    print(f"Scanning for device with name '{DEVICE_NAME}'...")
    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return

    print(f"Found device {device.name} [{device.address}]")
    
    async with BleakClient(device) as client:
        print(f"Connected to {device.name}")

        # Start notification listener
        await client.start_notify(SERIAL_TX_UUID, notification_handler)
        print("Listening for incoming messages...")

        # Start periodic message sender
        send_task = asyncio.create_task(send_periodic_message(client))
        
        try:
            # Keep running until Ctrl+C
            while True:
                await asyncio.sleep(0.1)
        except KeyboardInterrupt:
            print("\nStopping...")
            running = False
            await send_task
            await client.stop_notify(SERIAL_TX_UUID)

if __name__ == "__main__":
    asyncio.run(run_ble_client())