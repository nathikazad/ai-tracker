#include <ArduinoBLE.h>

BLEService dataService("19B10000-E8F2-537E-4F6C-D104768A1214");
BLECharacteristic dataCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, 516);
BLEUnsignedLongCharacteristic delayCharacteristic("19B10002-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);
BLEUnsignedLongCharacteristic burstTimeCharacteristic("19B10003-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify);

const int packetCount = 100;
const unsigned long sendInterval = 10000; // 10 seconds in milliseconds
unsigned long lastSendTime = 0;
uint32_t packetNumber = 0;
unsigned long packetDelay = 20; // Default delay between packets (in milliseconds)

void setup() {
  Serial.begin(9600);
  while (!Serial);

  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy module failed!");
    while (1);
  }

  BLE.setConnectionInterval(0x0006, 0x0010); // Set connection interval (7.5ms - 20ms)
  // BLE.setTxPower(4); // Set to maximum power (4 dBm)

  BLE.setLocalName("Random Data Sender");
  BLE.setAdvertisedService(dataService);

  dataService.addCharacteristic(dataCharacteristic);
  dataService.addCharacteristic(delayCharacteristic);
  dataService.addCharacteristic(burstTimeCharacteristic);

  delayCharacteristic.writeValue(packetDelay);

  BLE.addService(dataService);
  BLE.advertise();

  Serial.println("BLE Random Data Sender Ready");
}

void loop() {
  BLE.poll(); // Handle BLE events

  BLEDevice central = BLE.central();
  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());

    while (central.connected()) {
      BLE.poll(); // Keep handling BLE events

      if (delayCharacteristic.written()) {
        packetDelay = delayCharacteristic.value();
        Serial.print("New packet delay set: ");
        Serial.println(packetDelay);
      }

      unsigned long currentTime = millis();
      if (currentTime - lastSendTime >= sendInterval) {
        sendRandomData(central);
        lastSendTime = currentTime;
      }
    }

    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}

void sendRandomData(BLEDevice &central) {
  packetNumber = 0;
  unsigned long startTime = millis();

  for (int i = 0; i < packetCount; i++) {
    uint8_t packet[516];
    packet[0] = (packetNumber >> 24) & 0xFF;
    packet[1] = (packetNumber >> 16) & 0xFF;
    packet[2] = (packetNumber >> 8) & 0xFF;
    packet[3] = packetNumber & 0xFF;

    for (int j = 4; j < 516; j++) {
      packet[j] = random(256);
    }

    dataCharacteristic.writeValue(packet, 516);
    delay(packetDelay);
    Serial.print("Sent packet ");
    Serial.println(packetNumber);
    packetNumber++;
    BLE.poll(); // Handle BLE events between packets
  }

  unsigned long endTime = millis();
  unsigned long burstTime = endTime - startTime;
  burstTimeCharacteristic.writeValue(burstTime);

  Serial.print("Finished sending 100 packets. Total time: ");
  Serial.print(burstTime);
  Serial.println(" ms");
}