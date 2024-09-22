#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include <Arduino.h>
#include <I2S.h>

#define RECORD_TIME   20  // seconds, The maximum value is 240
#define WAV_FILE_NAME "arduino_rec"

// do not change for best
#define SAMPLE_RATE 16000U
#define SAMPLE_BITS 16
#define WAV_HEADER_SIZE 44
#define VOLUME_GAIN 2

// Buffer sizes
uint32_t record_size = (SAMPLE_RATE * SAMPLE_BITS / 8) * RECORD_TIME;
uint8_t *rec_buffer = NULL;

// BLE service and characteristic UUIDs
static BLEUUID serviceUUID("19B10000-E8F2-537E-4F6C-D104768A1214");
static BLEUUID audioDataUUID("19B10001-E8F2-537E-4F6C-D104768A1214");
// Global BLE-related variables
BLECharacteristic *audioDataCharacteristic;
bool connected = false;

// BLE server callbacks
class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    Serial.println("BLE connected");
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
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(serviceUUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMaxPreferred(0x12);
  BLEDevice::startAdvertising();
}

void configure_microphone() {
    // Configure I2S for the microphone
    I2S.setAllPins(-1, 42, 41, -1, -1);
    if (!I2S.begin(PDM_MONO_MODE, SAMPLE_RATE, SAMPLE_BITS)) {
        Serial.println("Failed to initialize I2S!");
        while (1); // do nothing
    }
    uint32_t record_size = (SAMPLE_RATE * SAMPLE_BITS / 8) * RECORD_TIME;
    rec_buffer = (uint8_t *)ps_malloc(record_size);
}


void setup() {
    Serial.begin(921600);
    configure_ble();
    Serial.println("BLE configured");
    configure_microphone();
    Serial.println("Microphone configured");
}

void loop() {
    
    
    if (connected) {
      uint32_t sample_size = 0;
      esp_i2s::i2s_read(esp_i2s::I2S_NUM_0, rec_buffer, record_size, &sample_size, portMAX_DELAY);
      if (sample_size == 0) {
        Serial.printf("Record Failed!\n");
      } else {
        Serial.printf("Record %d bytes\n", sample_size);
      }

      // Increase volume
      for (uint32_t i = 0; i < sample_size; i += SAMPLE_BITS/8) {
        (*(uint16_t *)(rec_buffer+i)) <<= VOLUME_GAIN;
      }
      const size_t packet_size = 512;
      for (size_t i = 0; i < sample_size; i += packet_size) {
        size_t chunk_size = min(packet_size, sample_size - i);
        audioDataCharacteristic->setValue(rec_buffer + i, chunk_size);
        audioDataCharacteristic->notify();
        
        // Add a small delay to avoid overwhelming the BLE stack
        delay(10);
      }
    }    
    delay(100);
}


