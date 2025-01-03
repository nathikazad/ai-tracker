// #include "esp_gap_ble_api.h"
#include "config.h"

BLECharacteristic *pTransferCharacteristic;
BLECharacteristic *pAckCharacteristic;
BLECharacteristic *pTimeCharacteristic;
bool ackReceived = false;

#define MAX_PACKETS 1000
uint8_t packetBitmap[MAX_PACKETS/8 + 1];  // Each bit represents a packet
size_t currentFileSize = 0;
uint32_t totalPackets = 0;

void clear_bitmap() {
    memset(packetBitmap, 0, sizeof(packetBitmap));
}

void update_bitmap_from_ack(const uint8_t* ackBitmap, size_t length) {
    // Update our bitmap and check for missing packets
    Serial.print("Missing packets: ");
    for(size_t i = 0; i < length && i < sizeof(packetBitmap); i++) {
        // Check each bit in this byte
        for(int bit = 0; bit < 8; bit++) {
            // Calculate actual packet number
            size_t packet_num = i * 8 + bit;
            if(packet_num >= totalPackets) break;  // Don't go beyond total packets
            
            // Check if this bit is 0 in the received bitmap (packet not received)
            if(!(ackBitmap[i] & (1 << (7 - bit)))) {
                Serial.printf("%d ", packet_num);
            }
        }
        packetBitmap[i] |= ackBitmap[i];  // Update bitmap as before
    }
    Serial.println();  // New line after printing all missing packets
}

bool all_packets_sent() {
    uint8_t fullByte = 0xFF;
    size_t fullByteCount = totalPackets / 8;
    size_t remainingBits = totalPackets % 8;
    
    // Check all complete bytes
    for(size_t i = 0; i < fullByteCount; i++) {
        if(packetBitmap[i] != fullByte) {
            Serial.println("Not all packets received - full byte check failed");
            return false;
        }
    }
    
    // Check remaining bits in last byte if any
    if(remainingBits > 0) {
        uint8_t lastByteMask = ((1 << remainingBits) - 1) << (8 - remainingBits);  // MSB-first
        if((packetBitmap[fullByteCount] & lastByteMask) != lastByteMask) {
            Serial.println("Not all packets received - remaining bits check failed");
            return false;
        }
    }
    
    Serial.println("All packets received successfully");
    return true;
}

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
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
        Serial.println("Device Connected");
        
        // Store the BLE address of the connected device
        // esp_bd_addr_t remote_bda;
        // uint16_t connId = pServer->getConnId();
        
        // // Get connection parameters
        // esp_gap_conn_params_t curr_conn_params;
        // esp_err_t err = esp_ble_get_current_conn_params(remote_bda, &curr_conn_params);
        // if (err == ESP_OK) {
        //     Serial.printf("Current Connection Parameters:\n");
        //     Serial.printf("Interval: %d\n", curr_conn_params.interval);
        //     Serial.printf("Latency: %d\n", curr_conn_params.latency);
        //     Serial.printf("Timeout: %d\n", curr_conn_params.timeout);
        // }
        
        // // Configure preferred connection parameters
        // esp_ble_conn_update_params_t conn_params = {
        //     .min_int = 0x06,    // min_int = 0x06*1.25ms = 7.5ms
        //     .max_int = 0x0C,    // max_int = 0x0C*1.25ms = 15ms
        //     .latency = 0,       // Number of skipped connection events
        //     .timeout = 400      // Supervision timeout = 400*10ms = 4000ms
        // };
        // memcpy(conn_params.bda, remote_bda, sizeof(esp_bd_addr_t));
        
        // // Update connection parameters
        // esp_ble_gap_update_conn_params(&conn_params);
        
        // // Set MTU size if needed
        // if (connId != 0xFFFF) {
        //     pServer->updatePeerMTU(connId, 512);
        // }

        // // Set preferred PHY for better range/throughput
        // esp_ble_gap_set_preferred_default_phy(ESP_BLE_GAP_PHY_2M_PREF_MASK, ESP_BLE_GAP_PHY_2M_PREF_MASK);
    }
    
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        Serial.println("Device Disconnected");
        
        // Start advertising again after a short delay
        delay(500);
        BLEDevice::startAdvertising();
        Serial.println("Started advertising again");
    }
};

class AckCharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        Serial.printf("Ack received %s\n", pCharacteristic->getValue());
        if(pCharacteristic->getValue() == "ACK") {
            // Final ACK received - set all bits to 1 in bitmap
            memset(packetBitmap, 0xFF, sizeof(packetBitmap));
            ackReceived = true;
            Serial.println("Final ACK Received");
        } else {
            const uint8_t* rawData = pCharacteristic->getData();
            size_t length = pCharacteristic->getLength();
            update_bitmap_from_ack(rawData, length);
            ackReceived = true;
            Serial.println("Partial ACK received");
        }
    }
};

void setup_ble() {
    BLEDevice::init(bleServerName);

    // esp_ble_tx_power_set(ESP_BLE_PWR_TYPE_DEFAULT, ESP_PWR_LVL_P9);
    // esp_ble_gap_set_preferred_default_phy(ESP_BLE_GAP_PHY_2M_PREF_MASK, ESP_BLE_GAP_PHY_2M_PREF_MASK);

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

bool send_all_packets(File& file, size_t fileSize) {
    uint8_t packet[PACKET_SIZE];
    Serial.printf("Sending %d packets\n", totalPackets);
    for(uint32_t packetIndex = 0; packetIndex < totalPackets; packetIndex++) {
        // Check if packet needs to be sent
        uint8_t byteIndex = packetIndex / 8;
        uint8_t bitIndex = 7 - (packetIndex % 8);  // Changed to MSB-first
        if(packetBitmap[byteIndex] & (1 << bitIndex)) {  // Changed bit mask to match
            continue;  // Packet already received, skip it
        }
        // Prepare and send packet
        packet[0] = (packetIndex >> 16) & 0xFF;
        packet[1] = (packetIndex >> 8) & 0xFF;
        packet[2] = packetIndex & 0xFF;

        size_t filePosition = packetIndex * (PACKET_SIZE - HEADER_SIZE);
        size_t bytesToRead = min(PACKET_SIZE - HEADER_SIZE, (int)(fileSize - filePosition));
        
        file.seek(filePosition);
        size_t bytesRead = file.read(&packet[HEADER_SIZE], bytesToRead);
        
        if(bytesRead > 0) {
            pTransferCharacteristic->setValue(packet, bytesRead + HEADER_SIZE);
            pTransferCharacteristic->notify();
            delay(20);  // Small delay to prevent flooding
        } else {
            return false;
        }
    }
    return true;
}

bool send_file_over_ble(const char* imagePath) {
    if (!deviceConnected) return false;

    if (xSemaphoreTake(sdMutex, portMAX_DELAY)) {
        File imageFile = SD.open(imagePath);
        if (!imageFile) {
            xSemaphoreGive(sdMutex);
            return false;
        }

        // Initialize transfer
        currentFileSize = imageFile.size();
        totalPackets = (currentFileSize + (PACKET_SIZE - HEADER_SIZE) - 1) / (PACKET_SIZE - HEADER_SIZE);
        
        if(totalPackets > MAX_PACKETS) {
            Serial.println("File too large, too many packets required");
            imageFile.close();
            xSemaphoreGive(sdMutex);
            return false;
        }
        
        // Clear bitmap for fresh transfer
        clear_bitmap();
        
        // Send metadata packet first
        uint8_t packet[PACKET_SIZE];
        const uint8_t identifier[] = {0xFF, 0xA5, 0x5A, 0xC3, 0x3C, 0x69, 0x96, 0xF0};
        memcpy(packet, identifier, 8);
        packet[8] = (currentFileSize >> 24) & 0xFF;
        packet[9] = (currentFileSize >> 16) & 0xFF;
        packet[10] = (currentFileSize >> 8) & 0xFF;
        packet[11] = currentFileSize & 0xFF;
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
        
        // Main transfer loop
        while(!all_packets_sent()) {
            // Send all unsent packets
            if(!send_all_packets(imageFile, currentFileSize)) {
                imageFile.close();
                xSemaphoreGive(sdMutex);
                return false;
            }

            Serial.println("Waiting for Ack");
            
            // Wait for ACK (either partial or complete)
            ackReceived = false;
            unsigned long startTime = millis();
            while(!ackReceived && (millis() - startTime < ACK_TIMEOUT)) {
                delay(100);
            }
            
            if(!ackReceived) {
                Serial.println("ACK timeout");
                imageFile.close();
                xSemaphoreGive(sdMutex);
                return false;
            }
        }

        // Transfer complete, move file to sent directory
        imageFile.close();
        char destPath[64];
        sprintf(destPath, "/sent/%s", filename);
        xSemaphoreGive(sdMutex);
        if(move_file(imagePath, destPath)) {
            Serial.printf("File successfully transferred and moved to: %s\n", destPath);
            return true;
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