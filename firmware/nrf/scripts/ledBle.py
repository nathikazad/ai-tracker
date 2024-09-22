import asyncio
from bleak import BleakClient, BleakScanner
import keyboard

# Replace with your Arduino's advertised name
DEVICE_NAME = "LED Control"
LED_CHARACTERISTIC_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"

# Global variable to store the BLE client
ble_client = None

# Global flag to control the main loop
running = True

async def send_led_command(value):
    if ble_client and ble_client.is_connected:
        await ble_client.write_gatt_char(LED_CHARACTERISTIC_UUID, bytearray([value]))

value = True

def on_key_press(key):
    global value
    if value:
        value = False
    else:
        value = True
    # print("Key pressed: ", key.name)
    # global running
    # if key.name == 'o':
    #     print("Turning LED on")
    #     asyncio.create_task(send_led_command(0x01))
    # elif key.name == 'f':
    #     print("Turning LED off")
    #     asyncio.create_task(send_led_command(0x00))
    # elif key.name == 'q':
    #     print("Quitting...")
    #     running = False

async def run_ble_client():
    global ble_client, running
    
    print(f"Scanning for device with name '{DEVICE_NAME}'...")
    device = await BleakScanner.find_device_by_name(DEVICE_NAME)
    
    if device is None:
        print(f"Could not find device with name '{DEVICE_NAME}'")
        return

    async with BleakClient(device) as client:
        ble_client = client
        print(f"Connected to {device.name}")

        keyboard.on_press(on_key_press)

        print("Press 'o' to turn the LED on, 'f' to turn it off, and 'q' to quit.")
        global value
        while running:
            await asyncio.sleep(0.1)
            if value:
                asyncio.create_task(send_led_command(0x01))
            else:
                asyncio.create_task(send_led_command(0x00))

        keyboard.unhook_all()

if __name__ == "__main__":
    asyncio.run(run_ble_client())