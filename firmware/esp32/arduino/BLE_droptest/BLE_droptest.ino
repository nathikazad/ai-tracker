// droptest.ino

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLEServer.h>
#include <Arduino.h>

// BLE Server name
#define bleServerName "XIAOESP32S3_BLE"

BLECharacteristic *pCharacteristic;
bool deviceConnected = false;

// Packet size and count
#define PACKET_SIZE 512
#define PACKET_COUNT 100

class MyServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
  };
  
  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
  }
};

void setup() {
  Serial.begin(115200);
  
  BLEDevice::init(bleServerName);
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  
  BLEService *pService = pServer->createService(BLEUUID((uint16_t)0x181A)); // Environmental Sensing
  pCharacteristic = pService->createCharacteristic(
    BLEUUID((uint16_t)0x2A59), // Analog Output
    BLECharacteristic::PROPERTY_NOTIFY
  );
  pCharacteristic->addDescriptor(new BLE2902());
  
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(pService->getUUID());
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x0);
  pAdvertising->setMinPreferred(0x1F);
  BLEDevice::startAdvertising();

  // Initialize random seed
  randomSeed(analogRead(0));
}

void loop() {
  if (deviceConnected) {
    Serial.println("Sending burst...");
    
    // Create a buffer for the packet
    uint8_t packet[PACKET_SIZE];
    
    // Send 100 packets
    for (int i = 0; i < PACKET_COUNT; i++) {
      // Set the first byte as the packet number
      packet[0] = i;
      
      // Fill the rest with random data
      for (int j = 1; j < PACKET_SIZE; j++) {
        packet[j] = random(256);
      }
      
      // Send the packet
      pCharacteristic->setValue(packet, PACKET_SIZE);
      pCharacteristic->notify();
      
      // Print progress to serial
      // Serial.printf("Sent packet: %d/%d\n", i + 1, PACKET_COUNT);
      
      // Small delay to avoid congestion
      // delay(10);
    }
    
    Serial.println("Burst complete. Waiting for next burst...");
    
    // Wait for 10 seconds before the next burst
    delay(10000);
  }
}