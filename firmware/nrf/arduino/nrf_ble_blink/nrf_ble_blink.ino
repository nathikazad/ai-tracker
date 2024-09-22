
#include <ArduinoBLE.h>
BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214"); // Bluetooth® Low Energy LED Service
BLEByteCharacteristic ledCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);
const int ledPin = LED_BUILTIN; // pin to use for the LED
void setup()
{
  Serial.begin(9600);
  while (!Serial)
    ;
  pinMode(ledPin, OUTPUT);
  if (!BLE.begin())
  {
    Serial.println("starting Bluetooth® Low Energy module failed!");
    while (1)
      ;
  }
  BLE.setLocalName("LED Control");
  BLE.setAdvertisedService(ledService);
  ledService.addCharacteristic(ledCharacteristic);
  BLE.addService(ledService);
  ledCharacteristic.writeValue(0);
  BLE.advertise();
  Serial.println("BLE LED Control Ready");
}
void loop()
{
  BLEDevice central = BLE.central();
  if (central)
  {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
    while (central.connected())
    {
      if (ledCharacteristic.written())
      {
        if (ledCharacteristic.value())
        {
          Serial.println("LED on");
          digitalWrite(ledPin, HIGH);
        }
        else
        {
          Serial.println("LED off");
          digitalWrite(ledPin, LOW);
        }
      }
    }
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}