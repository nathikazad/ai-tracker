// wav_ble.ino

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLEServer.h>
#include <I2S.h>
#include "FS.h"
#include "SD.h"
#include "SPI.h"

// BLE Server name
#define bleServerName "XIAO_ESP32S3_Audio"

#define RECORD_TIME 5 // seconds
#define SAMPLE_RATE 4000U
#define SAMPLE_BITS 16
#define VOLUME_GAIN 2
#define CHUNK_SIZE 512

BLECharacteristic *pCharacteristic;
uint8_t *audioBuffer = NULL;
uint32_t audioBufferSize = 0;
bool deviceConnected = false;

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

    // Initialize I2S
    I2S.setAllPins(-1, 42, 41, -1, -1);
    if (!I2S.begin(PDM_MONO_MODE, SAMPLE_RATE, SAMPLE_BITS)) {
        Serial.println("Failed to initialize I2S!");
        while (1) ;
    }

    // Initialize BLE
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

    Serial.println("BLE Audio Recorder is ready!");
}

void loop() {
  if (deviceConnected) {
    recordAndSendAudio();
    delay(5000);  // Wait for 5 seconds before next recording
  }
}

void recordAndSendAudio() {
  uint32_t recordSize = (SAMPLE_RATE * SAMPLE_BITS / 8) * RECORD_TIME;
  
  // Allocate buffer for audio data
  if (audioBuffer == NULL) {
    audioBuffer = (uint8_t *)ps_malloc(recordSize);
    if (audioBuffer == NULL) {
      Serial.println("Failed to allocate memory for audio buffer!");
      return;
    }
  }
  
  // Record audio
  Serial.println("Recording audio...");
  esp_i2s::i2s_read(esp_i2s::I2S_NUM_0, audioBuffer, recordSize, &audioBufferSize, portMAX_DELAY);
  
  if (audioBufferSize == 0) {
    Serial.println("Failed to record audio!");
    return;
  }
  
  Serial.printf("Recorded %d bytes\n", audioBufferSize);
  
  // Increase volume
  for (uint32_t i = 0; i < audioBufferSize; i += SAMPLE_BITS/8) {
    (*(uint16_t *)(audioBuffer+i)) <<= VOLUME_GAIN;
  }
  // Start timing the BLE transmission
  unsigned long startTime = millis();
  // Send start packet
  uint32_t numPackets = (audioBufferSize + CHUNK_SIZE - 1) / CHUNK_SIZE;
  uint8_t startPacket[8] = {'S', 'T', 'A', 'R', 'T', 0, 0, 0};
  startPacket[5] = (numPackets >> 16) & 0xFF;
  startPacket[6] = (numPackets >> 8) & 0xFF;
  startPacket[7] = numPackets & 0xFF;
  pCharacteristic->setValue(startPacket, 8);
  pCharacteristic->notify();
  delay(20);  // Give the client some time to process
  
  // Send audio data in chunks
  for (uint32_t i = 0; i < audioBufferSize; i += CHUNK_SIZE) {
    uint32_t chunkSize = (CHUNK_SIZE < audioBufferSize - i) ? CHUNK_SIZE : (audioBufferSize - i);
    uint8_t header[4] = {0xFF, 0xFF, (i >> 8) & 0xFF, i & 0xFF};
    uint8_t chunk[CHUNK_SIZE + 4];
    memcpy(chunk, header, 4);
    memcpy(chunk + 4, audioBuffer + i, chunkSize);
    pCharacteristic->setValue(chunk, chunkSize + 4);
    pCharacteristic->notify();
    delay(20);  // Give the client some time to process
  }
  
  // Send end packet
  uint8_t endPacket[4] = {'E', 'N', 'D', 0};
  pCharacteristic->setValue(endPacket, 4);
  pCharacteristic->notify();
  
  unsigned long endTime = millis();
  unsigned long duration = endTime - startTime;
  Serial.printf("Audio data sent successfully. Total time: %lu ms\n", duration);

}