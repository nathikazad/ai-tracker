// BLE functionality for OpenGlass project
// Handles BLE setup, connections, and data transmission

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include "ble.h"

// BLE service and characteristic UUIDs
static BLEUUID serviceUUID("19B10000-E8F2-537E-4F6C-D104768A1214");
static BLEUUID audioDataUUID("19B10001-E8F2-537E-4F6C-D104768A1214");
static BLEUUID audioCodecUUID("19B10002-E8F2-537E-4F6C-D104768A1214");
static BLEUUID photoDataUUID("19B10005-E8F2-537E-4F6C-D104768A1214");
static BLEUUID photoControlUUID("19B10006-E8F2-537E-4F6C-D104768A1214");

// Global BLE-related variables
BLECharacteristic *audioDataCharacteristic;
BLECharacteristic *photoDataCharacteristic;
BLECharacteristic *batteryLevelCharacteristic;
bool connected = false;

// BLE server callbacks
class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    connected = true;
  }
  void onDisconnect(BLEServer* pServer) {
    connected = false;
    BLEDevice::startAdvertising();
  }
};

void configure_ble() {
  BLEDevice::init("OpenGlass");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  BLEService *pService = pServer->createService(serviceUUID);

  // Set up audio characteristics
  audioDataCharacteristic = pService->createCharacteristic(
    audioDataUUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  audioDataCharacteristic->addDescriptor(new BLE2902());

  // Set up photo characteristics
  photoDataCharacteristic = pService->createCharacteristic(
    photoDataUUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  photoDataCharacteristic->addDescriptor(new BLE2902());

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(serviceUUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMaxPreferred(0x12);
  BLEDevice::startAdvertising();
}

bool is_ble_connected() {
  return connected;
}

void send_audio_data(uint8_t* data, size_t length) {
  if (connected) {
    audioDataCharacteristic->setValue(data, length);
    audioDataCharacteristic->notify();
  }
}

void send_photo_data(uint8_t* data, size_t length) {
  if (connected) {
    photoDataCharacteristic->setValue(data, length);
    photoDataCharacteristic->notify();
  }
}

void updateBatteryLevel(uint8_t level) {
  if (connected) {
    batteryLevelCharacteristic->setValue(&level, 1);
    batteryLevelCharacteristic->notify();
  }
}