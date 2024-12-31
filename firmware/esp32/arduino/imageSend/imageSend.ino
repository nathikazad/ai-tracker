#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLEServer.h>
#include <Arduino.h>
#include "FS.h"
#include "SD.h"
#include "SPI.h"

// BLE Server name
#define bleServerName "XIAOESP32S3_BLE"
#define PACKET_SIZE 512
#define HEADER_SIZE 3  // 3 bytes for packet number

BLECharacteristic *pCharacteristic;
bool deviceConnected = false;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
    };
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
    }
};

void sendImageOverBLE() {
    if (!deviceConnected) {
        Serial.println("No BLE device connected");
        return;
    }

    // Open the image file
    File imageFile = SD.open("/pix/image1.jpg");
    if (!imageFile) {
        Serial.println("Failed to open image file");
        return;
    }

    // Get file size
    size_t fileSize = imageFile.size();
    Serial.printf("File size: %d bytes\n", fileSize);

    // Calculate number of packets needed
    uint32_t totalPackets = (fileSize + (PACKET_SIZE - HEADER_SIZE) - 1) / (PACKET_SIZE - HEADER_SIZE);
    Serial.printf("Total packets to send: %d\n", totalPackets);
    
    // Create buffer for packets
    uint8_t packet[PACKET_SIZE];
    
    // First packet contains file size and total packet count information
    packet[0] = 0xFF;  // Special packet identifier
    
    // Write file size (4 bytes)
    packet[1] = (fileSize >> 24) & 0xFF;
    packet[2] = (fileSize >> 16) & 0xFF;
    packet[3] = (fileSize >> 8) & 0xFF;
    packet[4] = fileSize & 0xFF;
    
    // Write total packets (4 bytes)
    packet[5] = (totalPackets >> 24) & 0xFF;
    packet[6] = (totalPackets >> 16) & 0xFF;
    packet[7] = (totalPackets >> 8) & 0xFF;
    packet[8] = totalPackets & 0xFF;
    pCharacteristic->setValue(packet, PACKET_SIZE);
    pCharacteristic->notify();
    delay(20);  // Small delay to ensure packet is sent

    // Send file contents
    uint32_t packetIndex = 0;
    size_t bytesRemaining = fileSize;

    while (bytesRemaining > 0) {
        // Write packet number to first 3 bytes
        packet[0] = (packetIndex >> 16) & 0xFF;  // MSB
        packet[1] = (packetIndex >> 8) & 0xFF;   // Middle byte
        packet[2] = packetIndex & 0xFF;          // LSB

        // Calculate how many bytes to read for this packet
        size_t bytesToRead = min(PACKET_SIZE - HEADER_SIZE, (int)bytesRemaining);
        
        // Read data after header
        size_t bytesRead = imageFile.read(&packet[HEADER_SIZE], bytesToRead);
        
        if (bytesRead > 0) {
            pCharacteristic->setValue(packet, bytesRead + HEADER_SIZE);
            pCharacteristic->notify();
            
            packetIndex++;
            bytesRemaining -= bytesRead;
            
            Serial.printf("Sent packet %d of %d\n", packetIndex, totalPackets);
            
            delay(20);  // Small delay between packets
        }
    }

    imageFile.close();
    Serial.println("Image transfer complete");
}

void setup() {
    Serial.begin(115200);
    while(!Serial);

    // Initialize SD card
    if(!SD.begin(21)) {
        Serial.println("Card Mount Failed");
        return;
    }

    // Initialize BLE
    BLEDevice::init(bleServerName);
    BLEServer *pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    BLEService *pService = pServer->createService(BLEUUID((uint16_t)0x181A));
    pCharacteristic = pService->createCharacteristic(
        BLEUUID((uint16_t)0x2A59),
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

    Serial.println("BLE server ready");
}

void loop() {
    if (deviceConnected) {
        Serial.println("Starting image transfer...");
        sendImageOverBLE();
        delay(10000);  // Wait 10 seconds before next transfer
    }
}