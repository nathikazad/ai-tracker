#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLEServer.h>
#include <Arduino.h>
#include <I2S.h>
#include "FS.h"
#include "SD.h"
#include "SPI.h"

// BLE Server name
#define bleServerName "XIAOESP32S3_BLE"

// Audio recording settings
#define RECORD_TIME 5 // seconds
#define SAMPLE_RATE 16000U
#define SAMPLE_BITS 16
#define WAV_HEADER_SIZE 44
#define VOLUME_GAIN 2

// BLE characteristics
BLECharacteristic *pCharacteristic;
bool deviceConnected = false;
bool oldDeviceConnected = false;

// Buffer for audio data
uint8_t *audioBuffer = NULL;
size_t bufferSize = (SAMPLE_RATE * SAMPLE_BITS / 8) * RECORD_TIME;

// BLE packet settings
const size_t PACKET_SIZE = 512;
const size_t HEADER_SIZE = 1; // 1 byte for packet number (0-255)
const size_t PAYLOAD_SIZE = PACKET_SIZE - HEADER_SIZE;

class MyServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
    }
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
    }
};

void setup() {
    Serial.begin(115200);
    while (!Serial);

    // Initialize I2S
    I2S.setAllPins(-1, 42, 41, -1, -1);
    if (!I2S.begin(PDM_MONO_MODE, SAMPLE_RATE, SAMPLE_BITS)) {
        Serial.println("Failed to initialize I2S!");
        while (1);
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

    // Allocate buffer for audio data
    audioBuffer = (uint8_t *)ps_malloc(bufferSize);
    if (audioBuffer == NULL) {
        Serial.println("Failed to allocate memory for audio buffer!");
        while (1);
    }
}

void loop() {
    // Disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // Give the bluetooth stack the chance to get things ready
        BLEDevice::startAdvertising(); // Restart advertising
        Serial.println("Start advertising");
        oldDeviceConnected = deviceConnected;
    }
    // Connecting
    if (deviceConnected && !oldDeviceConnected) {
        // Do stuff here on connecting
        oldDeviceConnected = deviceConnected;
    }

    if (deviceConnected) {
        // Record audio
        Serial.println("Recording audio...");
        size_t bytesRead;
        esp_i2s::i2s_read(esp_i2s::I2S_NUM_0, audioBuffer, bufferSize, &bytesRead, portMAX_DELAY);

        // Apply volume gain
        for (size_t i = 0; i < bytesRead; i += SAMPLE_BITS/8) {
            (*(int16_t *)(audioBuffer + i)) <<= VOLUME_GAIN;
        }

        // Send audio data over BLE
        Serial.println("Sending audio data over BLE...");
        uint8_t packetNumber = 0;
        uint8_t packet[PACKET_SIZE];

        for (size_t i = 0; i < bytesRead; i += PAYLOAD_SIZE) {
            // Prepare packet header (packet number)
            packet[0] = packetNumber;

            // Prepare packet payload
            size_t chunkSize = min(PAYLOAD_SIZE, bytesRead - i);
            memcpy(packet + HEADER_SIZE, audioBuffer + i, chunkSize);

            // Pad the rest of the packet with zeros if needed
            if (chunkSize < PAYLOAD_SIZE) {
                memset(packet + HEADER_SIZE + chunkSize, 0, PAYLOAD_SIZE - chunkSize);
            }

            // Send the packet
            pCharacteristic->setValue(packet, PACKET_SIZE);
            pCharacteristic->notify();

            packetNumber++;
            if (packetNumber == 0) {  // Overflow, we've sent 256 packets
                Serial.println("Warning: Packet number overflow. Starting from 0 again.");
            }
            delay(10); // Small delay to avoid congestion
        }

        Serial.printf("Audio transmission complete. Sent %u packets.\n", packetNumber);
        delay(1000); // Wait for 1 second before the next recording
    } else {
        Serial.println("Device disconnected. Waiting for connection...");
        delay(2000);
    }
}