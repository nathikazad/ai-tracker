#include <ArduinoBLE.h>

BLEService dataService("19B10000-E8F2-537E-4F6C-D104768A1214"); // Bluetooth® Low Energy Data Service
BLECharacteristic dataCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, 516); // 4 bytes for header + 512 for data

const int packetCount = 100;
const unsigned long sendInterval = 10000; // 10 seconds in milliseconds
unsigned long lastSendTime = 0;
uint32_t packetNumber = 0;

void setup() {
  Serial.begin(9600);
  while (!Serial);

  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy module failed!");
    while (1);
  }

  BLE.setLocalName("Random Data Sender");
  BLE.setAdvertisedService(dataService);
  dataService.addCharacteristic(dataCharacteristic);
  BLE.addService(dataService);

  BLE.advertise();
  Serial.println("BLE Random Data Sender Ready");
}

void loop() {
  BLEDevice central = BLE.central();

  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());

    while (central.connected()) {
      unsigned long currentTime = millis();
      if (currentTime - lastSendTime >= sendInterval) {
        sendRandomData();
        lastSendTime = currentTime;
      }
    }

    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}

void sendRandomData() {
  packetNumber = 0;
  for (int i = 0; i < packetCount; i++) {
    uint8_t packet[516]; // 4 bytes for header + 512 for data
    
    // Add packet number as header
    packet[0] = (packetNumber >> 24) & 0xFF;
    packet[1] = (packetNumber >> 16) & 0xFF;
    packet[2] = (packetNumber >> 8) & 0xFF;
    packet[3] = packetNumber & 0xFF;
    
    // Generate random data
    for (int j = 4; j < 516; j++) {
      packet[j] = random(256);
    }
    
    dataCharacteristic.writeValue(packet, 516);
    delay(10);
    Serial.print("Sent packet ");
    Serial.println(packetNumber);
    
    packetNumber++;
  }
  Serial.println("Finished sending 100 packets");
}