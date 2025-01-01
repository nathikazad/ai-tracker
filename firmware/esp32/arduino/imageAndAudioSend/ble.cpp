#include "config.h"

BLECharacteristic *pTransferCharacteristic;
BLECharacteristic *pAckCharacteristic;
BLECharacteristic *pTimeCharacteristic;
bool ackReceived = false;

// BLE Callbacks
class TimeCharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String value = pCharacteristic->getValue();
        if (value.length() == 8) {
            uint64_t timestamp = 0;
            memcpy(&timestamp, value.c_str(), 8);
            struct timeval tv;
            tv.tv_sec = timestamp;
            tv.tv_usec = 0;
            settimeofday(&tv, NULL);
            timeSync = true;
            Serial.printf("Time synchronized to: %llu\n", timestamp);
        }
    }
};

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) { deviceConnected = true; }
    void onDisconnect(BLEServer* pServer) { deviceConnected = false; }
};

class AckCharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String value = pCharacteristic->getValue();
        if (value == "ACK") { 
          ackReceived = true; 
          Serial.println("Ack Received");
        }
    }
};

void setup_ble() {
    BLEDevice::init(bleServerName);
    BLEServer *pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    BLEService *pService = pServer->createService(BLEUUID((uint16_t)0x181A));

    pTransferCharacteristic = pService->createCharacteristic(
        BLEUUID((uint16_t)0x2A59),
        BLECharacteristic::PROPERTY_NOTIFY
    );
    pTransferCharacteristic->addDescriptor(new BLE2902());

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

    Serial.println("BLE server initialized and advertising");
}

bool send_file_over_ble(const char* imagePath) {
    if (!deviceConnected) return false;

    if (xSemaphoreTake(sdMutex, portMAX_DELAY)) {
        File imageFile = SD.open(imagePath);
        if (!imageFile) {
            xSemaphoreGive(sdMutex);
            return false;
        }

        size_t fileSize = imageFile.size();
        uint32_t totalPackets = (fileSize + (PACKET_SIZE - HEADER_SIZE) - 1) / (PACKET_SIZE - HEADER_SIZE);
        uint8_t packet[PACKET_SIZE];
        
        // Send metadata packet
        const uint8_t identifier[] = {0xFF, 0xA5, 0x5A, 0xC3, 0x3C, 0x69, 0x96, 0xF0};
        memcpy(packet, identifier, 8);
        packet[8] = (fileSize >> 24) & 0xFF;
        packet[9] = (fileSize >> 16) & 0xFF;
        packet[10] = (fileSize >> 8) & 0xFF;
        packet[11] = fileSize & 0xFF;
        packet[12] = (totalPackets >> 24) & 0xFF;
        packet[13] = (totalPackets >> 16) & 0xFF;
        packet[14] = (totalPackets >> 8) & 0xFF;
        packet[15] = totalPackets & 0xFF;
        
        const char* filename = strrchr(imagePath, '/') + 1;
        size_t filenameLength = strlen(filename);
        packet[16] = filenameLength;
        memcpy(&packet[17], filename, filenameLength);
        
        pTransferCharacteristic->setValue(packet, PACKET_SIZE);
        pTransferCharacteristic->notify();
        delay(20);

        uint32_t packetIndex = 0;
        size_t bytesRemaining = fileSize;

        bool success = true;
        while (bytesRemaining > 0 && success) {
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
                // Serial.printf("Sent packet %d of %d\n", packetIndex, totalPackets);
                delay(20);
            } else {
                success = false;
            }
        }
        Serial.printf("Sent all packets \n");

        imageFile.close();
        xSemaphoreGive(sdMutex);

        if (success) {
            ackReceived = false;
            Serial.println("Waiting for ack");
            unsigned long startTime = millis();
            while (!ackReceived && (millis() - startTime < ACK_TIMEOUT)) {
                delay(100);
            }

            if (ackReceived) {
                char destPath[64];
                sprintf(destPath, "/sent/%s", filename);
                if (move_file(imagePath, destPath)) {
                    Serial.printf("File successfully transferred and moved to: %s\n", destPath);
                    return true;
                }
            }
        }
        return false;
    }
    return false;
}

bool check_directory(const char* dir_name) {
    if (xSemaphoreTake(sdMutex, portMAX_DELAY)) {
        String dirPath = String("/") + dir_name;
        File root = SD.open(dirPath);
        if (root && root.isDirectory()) {
            // Create a vector to store file information
            std::vector<std::pair<String, time_t>> files;
            
            // Collect all files and their timestamps
            File file = root.openNextFile();
            while (file) {
                if (!file.isDirectory()) {
                    String fileName = file.name();
                    // Parse timestamp from filename (format: YYMMDDHHMMSS)
                    struct tm tm = {};
                    int year, month, day, hour, minute, second;
                    sscanf(fileName.c_str(), "%2d%2d%2d%2d%2d%2d", 
                           &year, &month, &day, &hour, &minute, &second);
                    tm.tm_year = year + 100; // Years since 1900
                    tm.tm_mon = month - 1;   // 0-11
                    tm.tm_mday = day;
                    tm.tm_hour = hour;
                    tm.tm_min = minute;
                    tm.tm_sec = second;
                    time_t timestamp = mktime(&tm);
                    
                    files.push_back({fileName, timestamp});
                }
                file.close();
                file = root.openNextFile();
            }
            root.close();
            
            // Sort files by timestamp, newest first
            std::sort(files.begin(), files.end(),
                     [](const auto& a, const auto& b) {
                         return a.second > b.second;
                     });
            
            // Process files if any exist
            if (!files.empty()) {
                String fullPath = dirPath + "/" + files[0].first;
                Serial.printf("Sending %s over BLE\n", fullPath.c_str());
                xSemaphoreGive(sdMutex);
                
                bool success = send_file_over_ble(fullPath.c_str());
                
                if (!success) {
                    Serial.printf("Transfer failed for %s, will retry in 5 seconds\n", fullPath.c_str());
                    delay(5000);
                }
                return true;
            } else {
                xSemaphoreGive(sdMutex);
                delay(5000); // No files to process
            }
        } else {
            if (root) root.close();
            xSemaphoreGive(sdMutex);
            delay(5000);
        }
    }
    return false;
}

void ble_loop(void * parameter) {
    while(true) {
        if (deviceConnected && timeSync) {
            check_directory("pix");
            check_directory("audio");
        } else {
            if (!deviceConnected) {
                Serial.println("Waiting for BLE connection...");
            } else if (!timeSync) {
                Serial.println("Waiting for time synchronization...");
            }
            delay(5000);
        }
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
}