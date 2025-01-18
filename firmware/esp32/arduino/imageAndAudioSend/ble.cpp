#include <sys/_stdint.h>
// #include "esp_gap_ble_api.h"
#include "config.h"

BLECharacteristic* pTransferCharacteristic;
BLECharacteristic* pAckCharacteristic;
BLECharacteristic* pTimeCharacteristic;
BLECharacteristic* pCommandCharacteristic;
BLECharacteristic* pFilesRemainingCharacteristic;
bool ackReceived = false;

#define MAX_PACKETS 1000
uint8_t packetBitmap[MAX_PACKETS / 8 + 1];  // Each bit represents a packet
size_t currentFileSize = 0;
uint32_t totalPackets = 0;

void notify_of_files_remaining(uint8_t rem) {
  Serial.println("Notifiying of remaining files");
  uint8_t stateValue[] = {rem};  // Use curly braces instead of square brackets
  pFilesRemainingCharacteristic->setValue(stateValue, 1);
  pFilesRemainingCharacteristic->notify();
}
void clear_bitmap() {
  memset(packetBitmap, 0, sizeof(packetBitmap));
}

void update_bitmap_from_ack(const uint8_t* ackBitmap, size_t length) {
  // Update our bitmap and check for missing packets
  Serial.print("Missing packets: ");
  for (size_t i = 0; i < length && i < sizeof(packetBitmap); i++) {
    // Check each bit in this byte
    for (int bit = 0; bit < 8; bit++) {
      // Calculate actual packet number
      size_t packet_num = i * 8 + bit;
      if (packet_num >= totalPackets) break;  // Don't go beyond total packets

      // Check if this bit is 0 in the received bitmap (packet not received)
      if (!(ackBitmap[i] & (1 << (7 - bit)))) {
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
  for (size_t i = 0; i < fullByteCount; i++) {
    if (packetBitmap[i] != fullByte) {
      Serial.println("Not all packets received - full byte check failed");
      return false;
    }
  }

  // Check remaining bits in last byte if any
  if (remainingBits > 0) {
    uint8_t lastByteMask = ((1 << remainingBits) - 1) << (8 - remainingBits);  // MSB-first
    if ((packetBitmap[fullByteCount] & lastByteMask) != lastByteMask) {
      Serial.println("Not all packets received - remaining bits check failed");
      return false;
    }
  }

  Serial.println("All packets received successfully");
  return true;
}

// BLE Callbacks
class TimeCharacteristicCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
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

class CommandCharacteristicCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    String value = pCharacteristic->getValue();
    Serial.printf("Received Command %s %d\n", value, value[0]);
    if (value.length() > 0) {
      if (value[0] >= 0 && value[0] <= 2) {
        mainState = (MainState)value[0];
        new_audio_available = false;
      }
    }
  }
};

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("Device Connected");
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

class AckCharacteristicCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    Serial.printf("Ack received %s\n", pCharacteristic->getValue());
    if (pCharacteristic->getValue() == "ACK") {
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

  BLEServer* pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService* pService = pServer->createService(BLEUUID((uint16_t)0x181A));

  pTransferCharacteristic = pService->createCharacteristic(
    BLEUUID((uint16_t)0x2A59),
    BLECharacteristic::PROPERTY_NOTIFY);
  pTransferCharacteristic->addDescriptor(new BLE2902());

  pTimeCharacteristic = pService->createCharacteristic(
    BLEUUID((uint16_t)0x2A57),
    BLECharacteristic::PROPERTY_WRITE);
  pTimeCharacteristic->setCallbacks(new TimeCharacteristicCallbacks());

  pAckCharacteristic = pService->createCharacteristic(
    BLEUUID((uint16_t)0x2A58),
    BLECharacteristic::PROPERTY_WRITE);
  pAckCharacteristic->setCallbacks(new AckCharacteristicCallbacks());

  pCommandCharacteristic = pService->createCharacteristic(
    BLEUUID((uint16_t)0x2A56),
    BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ);
  pCommandCharacteristic->addDescriptor(new BLE2902());
  pCommandCharacteristic->setCallbacks(new CommandCharacteristicCallbacks());
  uint8_t stateValue = static_cast<uint8_t>(mainState);
  pCommandCharacteristic->setValue(&stateValue, 1);

  pFilesRemainingCharacteristic = pService->createCharacteristic(
  BLEUUID((uint16_t)0x2A60),
  BLECharacteristic::PROPERTY_NOTIFY);
  pFilesRemainingCharacteristic->addDescriptor(new BLE2902());

  pService->start();

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(pService->getUUID());
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x0);
  pAdvertising->setMinPreferred(0x1F);
  BLEDevice::startAdvertising();

  Serial.println("BLE server initialized and advertising");
}

bool send_all_packets(const uint8_t* data, int dataLength) {
  uint8_t packet[PACKET_SIZE];
  Serial.printf("Sending %d packets\n", totalPackets);

  for (uint32_t packetIndex = 0; packetIndex < totalPackets; packetIndex++) {
    // Check if packet needs to be sent
    uint8_t byteIndex = packetIndex / 8;
    uint8_t bitIndex = 7 - (packetIndex % 8);  // MSB-first
    if (packetBitmap[byteIndex] & (1 << bitIndex)) {
      continue;  // Packet already received, skip it
    }

    // Prepare and send packet
    packet[0] = (packetIndex >> 16) & 0xFF;
    packet[1] = (packetIndex >> 8) & 0xFF;
    packet[2] = packetIndex & 0xFF;

    size_t dataPosition = packetIndex * (PACKET_SIZE - HEADER_SIZE);
    size_t bytesToSend = min(PACKET_SIZE - HEADER_SIZE, (int)(dataLength - dataPosition));

    memcpy(&packet[HEADER_SIZE], &data[dataPosition], bytesToSend);

    pTransferCharacteristic->setValue(packet, bytesToSend + HEADER_SIZE);
    pTransferCharacteristic->notify();
    delay(20);  // Small delay to prevent flooding
  }
  return true;
}

bool send_data_over_ble(const uint8_t* data, int dataLength, const char* filename) {
  if (!deviceConnected) return false;

  // Initialize transfer
  currentFileSize = dataLength;
  totalPackets = (currentFileSize + (PACKET_SIZE - HEADER_SIZE) - 1) / (PACKET_SIZE - HEADER_SIZE);

  if (totalPackets > MAX_PACKETS) {
    Serial.println("Data too large, too many packets required");
    return false;
  }

  // Clear bitmap for fresh transfer
  clear_bitmap();

  // Send metadata packet first
  uint8_t packet[PACKET_SIZE];
  const uint8_t identifier[] = { 0xFF, 0xA5, 0x5A, 0xC3, 0x3C, 0x69, 0x96, 0xF0 };
  memcpy(packet, identifier, 8);
  packet[8] = (currentFileSize >> 24) & 0xFF;
  packet[9] = (currentFileSize >> 16) & 0xFF;
  packet[10] = (currentFileSize >> 8) & 0xFF;
  packet[11] = currentFileSize & 0xFF;
  packet[12] = (totalPackets >> 24) & 0xFF;
  packet[13] = (totalPackets >> 16) & 0xFF;
  packet[14] = (totalPackets >> 8) & 0xFF;
  packet[15] = totalPackets & 0xFF;

  // No filename for raw data transfer
  if (filename == nullptr) {
    packet[16] = 0;  // filename length = 0
  } else {
    size_t filenameLength = strlen(filename);
    packet[16] = filenameLength;
    memcpy(&packet[17], filename, filenameLength);
  }


  pTransferCharacteristic->setValue(packet, PACKET_SIZE);
  pTransferCharacteristic->notify();
  delay(20);
  int attempts = 0;
  // Main transfer loop
  while (!all_packets_sent()) {
    // Send all unsent packets

    // check for the volatile flag
    // if yes send cancel packet and exit
    if (mainState == LISTENING &&  new_audio_available) {
    //   uint8_t cancel_packet[PACKET_SIZE] = { 0xAF, 0xBF, 0xCF, 0xDF, 0xEF, 0xFF };
    //   pTransferCharacteristic->setValue(cancel_packet, PACKET_SIZE);
    //   pTransferCharacteristic->notify();
      return false;  // Exit current transfer
    }

    if (!send_all_packets(data, dataLength)) {
      return false;
    }

    Serial.println("Waiting for Ack");

    // Wait for ACK (either partial or complete)
    ackReceived = false;
    unsigned long startTime = millis();
    while (!ackReceived && (millis() - startTime < ACK_TIMEOUT)) {
      delay(100);
      if (mainState == LISTENING && new_audio_available == true) {  // new audio became available, drop this and send the next
        break;
      }
    }

    Serial.println("Ack Recv. From data send");

    if (!ackReceived) {
      Serial.println("ACK timeout");
      return false;
    }

    attempts++;
    if(attempts >= 5) {
      Serial.println("Too many tries for ble send, getting out");
      return false;
    }
    // release semaphore
  }
  Serial.println("All packets sent");
  return true;
}

bool send_file_over_ble(const char* imagePath) {
  if (!deviceConnected) return false;

  if (xSemaphoreTake(sdMutex, portMAX_DELAY)) {
    File file = SD.open(imagePath);
    if (!file) {
      Serial.println("File send: Unable to open file");
      xSemaphoreGive(sdMutex);
      return false;
    } 

    // Read entire file into buffer
    size_t fileSize = file.size();
    if(fileSize == 0) {
      file.close();
      SD.remove(imagePath);
      xSemaphoreGive(sdMutex);
      return true;
    }

    uint8_t* buffer = (uint8_t*)malloc(fileSize);
    if (!buffer) {
      file.close();
      xSemaphoreGive(sdMutex);
      return false;
    }

    file.read(buffer, fileSize);
    file.close();
    xSemaphoreGive(sdMutex);
    const char* filename = strrchr(imagePath, '/') + 1;
    // Send the data
    bool success = send_data_over_ble(buffer, fileSize, filename);
    // Clean up
    free(buffer);

    if (success) {
      // Move file to sent directory
      const char* filename = strrchr(imagePath, '/') + 1;
      char destPath[64];
      sprintf(destPath, "/sent/%s", filename);
      if (move_file(imagePath, destPath)) {
        Serial.printf("File successfully transferred and moved to: %s\n", destPath);
        return true;
      } else {
        Serial.println("File send: Unable to move file");
      }
    } else {
      Serial.println("File send: Unable to send data");
    }
  } else {
    Serial.println("File send: Semaphore unavailable");
  }
  return false;
}

bool check_for_files_to_send() {
  // File root = SD.open("/toSend");
  // if (root) {
  //   Serial.println("Opened toSend");
  //   root.close();
  // } else {
  //   Serial.println("Unable to open toSend");
  // }
  String fullPath = get_latest_file(String("/toSend"));
  if(fullPath.length() == 0) {
    // Serial.println("Error: Unable to retrieve any file to send");
    return false;
  }
  Serial.printf("Sending %s over BLE\n", fullPath.c_str());
  bool success = send_file_over_ble(fullPath.c_str());
  if (success) {
    noOfFilesRemaining--;
    notify_of_files_remaining(noOfFilesRemaining);
  } else {
    Serial.println("Unable to send file");
  }

  return success;
}

void ble_loop(void* parameter) {
  while (true) {
    if (deviceConnected && timeSync) {
      // Serial.println(mainState);
      if (mainState == LISTENING) {
        if (new_audio_available) {
          Serial.println("New audio available");
          new_audio_available = false;
          if (xSemaphoreTake(audioBufferToSendMutex, portMAX_DELAY)) {
            Serial.println("Sending buffer over bluetooth");
            send_data_over_ble(compressedBuffer, compressedBufferSize, nullptr);
            Serial.println("Sent");
            xSemaphoreGive(audioBufferToSendMutex);
          } else {
            Serial.println("Did not get audioBufferToSend mutex");
          }
        }
      } else {  //if idle or recording
        check_for_files_to_send();
      }
    } else {
      if (!deviceConnected) {
        Serial.println("Waiting for BLE connection...");
      }
      if (!timeSync) {
        Serial.println("Waiting for time synchronization...");
      }
      delay(5000);
    }
    vTaskDelay(100 / portTICK_PERIOD_MS);
  }
}