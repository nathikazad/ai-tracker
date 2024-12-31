#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLEServer.h>
#include <Arduino.h>
#include "FS.h"
#include "SD.h"
#include "SPI.h"

// BLE Server name and characteristics
#define bleServerName "XIAOESP32S3_BLE"
#define PACKET_SIZE 512
#define HEADER_SIZE 3
#define ACK_TIMEOUT 10000  // 10 seconds in milliseconds

// Service and characteristics UUIDs
#define SERVICE_UUID        "181A"
#define CHAR_UUID_TRANSFER  "2A59"  // For image transfer
#define CHAR_UUID_ACK      "2A58"   // For acknowledgment
#define CHAR_UUID_TIME     "2A57"   // For time synchronization

BLECharacteristic *pTransferCharacteristic;
BLECharacteristic *pAckCharacteristic;
BLECharacteristic *pTimeCharacteristic;
bool deviceConnected = false;
bool ackReceived = false;
bool timeSync = false;  // Flag to track if time has been synced

// Structure to handle time characteristic callbacks
class TimeCharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String value = pCharacteristic->getValue();
        if (value.length() == 8) {  // Expecting 8 bytes for uint64_t timestamp
            uint64_t timestamp = 0;
            memcpy(&timestamp, value.c_str(), 8);
            
            // Set the ESP32's internal time
            struct timeval tv;
            tv.tv_sec = timestamp;
            tv.tv_usec = 0;
            settimeofday(&tv, NULL);
            
            timeSync = true;
            Serial.printf("Time synchronized to: %llu\n", timestamp);
        } else {
          Serial.printf("Received: %s on time char\n", value);
        }
    }
};

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
    };
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
    }
};

class AckCharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String value = pCharacteristic->getValue();
        if (value == "ACK") {
            ackReceived = true;
        }
    }
};

bool moveFile(const char* sourcePath, const char* destPath) {
    // Create sent directory if it doesn't exist
    if (!SD.exists("/sent")) {
        SD.mkdir("/sent");
    }
    
    // Copy file
    File sourceFile = SD.open(sourcePath, FILE_READ);
    File destFile = SD.open(destPath, FILE_WRITE);
    
    if (!sourceFile || !destFile) {
        if (sourceFile) sourceFile.close();
        if (destFile) destFile.close();
        return false;
    }
    
    while (sourceFile.available()) {
        destFile.write(sourceFile.read());
    }
    
    sourceFile.close();
    destFile.close();
    
    // Delete original file
    return SD.remove(sourcePath);
}

bool sendImageOverBLE(const char* imagePath) {
    if (!deviceConnected) {
        Serial.println("No BLE device connected");
        return false;
    }

    File imageFile = SD.open(imagePath);
    if (!imageFile) {
        Serial.println("Failed to open image file");
        return false;
    }

    size_t fileSize = imageFile.size();
    Serial.printf("File size: %d bytes\n", fileSize);

    uint32_t totalPackets = (fileSize + (PACKET_SIZE - HEADER_SIZE) - 1) / (PACKET_SIZE - HEADER_SIZE);
    Serial.printf("Total packets to send: %d\n", totalPackets);
    
    uint8_t packet[PACKET_SIZE];
    
    // Get just the filename after "pix/"
    const char* filename = strrchr(imagePath, '/');
    if (!filename) {
        Serial.println("Invalid path format");
        return false;
    }
    filename++; // Skip the '/'
    size_t filenameLength = strlen(filename);
    
    // Send initial packet with metadata - 8 byte identifier
    const uint8_t identifier[] = {0xFF, 0xA5, 0x5A, 0xC3, 0x3C, 0x69, 0x96, 0xF0};
    memcpy(packet, identifier, 8);  // 8-byte unique identifier
    // File size (4 bytes)
    packet[8] = (fileSize >> 24) & 0xFF;
    packet[9] = (fileSize >> 16) & 0xFF;
    packet[10] = (fileSize >> 8) & 0xFF;
    packet[11] = fileSize & 0xFF;
    // Total packets (4 bytes)
    packet[12] = (totalPackets >> 24) & 0xFF;
    packet[13] = (totalPackets >> 16) & 0xFF;
    packet[14] = (totalPackets >> 8) & 0xFF;
    packet[15] = totalPackets & 0xFF;
    // Filename length (1 byte)
    packet[16] = filenameLength;
    // Filename
    memcpy(&packet[17], filename, filenameLength);
    
    pTransferCharacteristic->setValue(packet, PACKET_SIZE);
    pTransferCharacteristic->notify();
    delay(20);

    uint32_t packetIndex = 0;
    size_t bytesRemaining = fileSize;

    while (bytesRemaining > 0) {
        packet[0] = (packetIndex >> 16) & 0xFF;
        packet[1] = (packetIndex >> 8) & 0xFF;
        packet[2] = packetIndex & 0xFF;

        size_t bytesToRead = min(PACKET_SIZE - HEADER_SIZE, (int)bytesRemaining);
        size_t bytesRead = imageFile.read(&packet[HEADER_SIZE], bytesToRead);
        
        if (bytesRead > 0) {
            pTransferCharacteristic->setValue(packet, bytesRead + HEADER_SIZE);
            pTransferCharacteristic->notify();
            
            packetIndex++;
            bytesRemaining -= bytesRead;
            
            Serial.printf("Sent packet %d of %d\n", packetIndex, totalPackets);
            delay(20);
        }
    }

    imageFile.close();
    Serial.println("Image transfer complete, waiting for ACK...");

    // Wait for ACK with timeout
    ackReceived = false;
    unsigned long startTime = millis();
    while (!ackReceived && (millis() - startTime < ACK_TIMEOUT)) {
        delay(100);
    }

    if (ackReceived) {
        Serial.println("ACK received, moving file to sent folder");
        // Create destination path
        char destPath[64];
        const char* fileName = strrchr(imagePath, '/');
        if (fileName) {
            fileName++; // Skip the '/'
            sprintf(destPath, "/sent/%s", fileName);
            if (moveFile(imagePath, destPath)) {
                Serial.printf("File moved to %s\n", destPath);
                return true;
            } else {
                Serial.println("Failed to move file");
            }
        }
    } else {
        Serial.println("ACK timeout, will retry transfer");
    }
    
    return false;
}

void setup() {
    Serial.begin(115200);
    while(!Serial);

    if(!SD.begin(21)) {
        Serial.println("Card Mount Failed");
        return;
    }

    BLEDevice::init(bleServerName);
    BLEServer *pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    BLEService *pService = pServer->createService(BLEUUID((uint16_t)0x181A));

    // Create transfer characteristic
    pTransferCharacteristic = pService->createCharacteristic(
        BLEUUID((uint16_t)0x2A59),
        BLECharacteristic::PROPERTY_NOTIFY
    );
    pTransferCharacteristic->addDescriptor(new BLE2902());

    // Create time characteristic
    pTimeCharacteristic = pService->createCharacteristic(
        BLEUUID((uint16_t)0x2A57),
        BLECharacteristic::PROPERTY_WRITE
    );
    pTimeCharacteristic->setCallbacks(new TimeCharacteristicCallbacks());
    pAckCharacteristic = pService->createCharacteristic(
        BLEUUID((uint16_t)0x2A58),
        BLECharacteristic::PROPERTY_WRITE
    );
    pAckCharacteristic->setCallbacks(new AckCharacteristicCallbacks());

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
        // Wait for time sync before starting file transfer
        if (!timeSync) {
            Serial.println("Waiting for time synchronization...");
            delay(1000);
            return;
        }

        File root = SD.open("/pix");
        if (!root) {
            Serial.println("Failed to open /pix directory");
            delay(1000);
            return;
        }
        
        if (!root.isDirectory()) {
            Serial.println("/pix is not a directory");
            root.close();
            delay(1000);
            return;
        }

        File file = root.openNextFile();
        bool filesFound = false;
        
        while (file) {
            if (!file.isDirectory()) {
                filesFound = true;
                String fileName = file.name();
                String fullPath = String("/pix/") + fileName;
                file.close();
                
                Serial.printf("Starting transfer of %s\n", fullPath.c_str());
                
                if (!sendImageOverBLE(fullPath.c_str())) {
                    Serial.printf("Transfer failed for %s, will retry in 10 seconds\n", fullPath.c_str());
                    delay(10000);
                    break;  // Exit the loop to retry this file
                }
                
                // Successfully transferred, continue to next file
                file = root.openNextFile();
            } else {
                file = root.openNextFile();
            }
        }
        
        root.close();
        
        if (!filesFound) {
            Serial.println("No files found in /pix directory");
            delay(5000);  // Wait before checking again
        }
    }
    delay(1000);
}