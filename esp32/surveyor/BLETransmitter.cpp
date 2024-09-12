#include "BLETransmitter.h"
#include "SDCard.h"
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// BLE service and characteristic UUIDs
static BLEUUID serviceUUID("19B10000-E8F2-537E-4F6C-D104768A1214");
static BLEUUID fileDataUUID("19B10001-E8F2-537E-4F6C-D104768A1214");

BLECharacteristic *fileDataCharacteristic;
bool deviceConnected = false;
bool fileSent = false;

class ServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
    }
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
    }
};

BLETransmitter::BLETransmitter(SDCard& sd) : sdCard(sd) {}

TaskHandle_t transmitTaskHandle = NULL;

void BLETransmitter::begin() {
    BLEDevice::init("OpenSurveyor");
    BLEServer *pServer = BLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks());

    BLEService *pService = pServer->createService(serviceUUID);

    fileDataCharacteristic = pService->createCharacteristic(
        fileDataUUID,
        BLECharacteristic::PROPERTY_READ |
        BLECharacteristic::PROPERTY_NOTIFY
    );
    fileDataCharacteristic->addDescriptor(new BLE2902());

    pService->start();

    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(serviceUUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);
    pAdvertising->setMaxPreferred(0x12);
    BLEDevice::startAdvertising();
    Serial.println("BLE started.");
    xTaskCreatePinnedToCore(
        this->transmitTask,
        "TransmitTask",
        10000,
        this,
        1,
        &transmitTaskHandle,
        0
    );
}

void BLETransmitter::transmitTask(void *pvParameters) {
    BLETransmitter* transmitter = static_cast<BLETransmitter*>(pvParameters);
    for (;;) {
        Serial.println("Checking for files to transmit...");
        transmitter->transmitFiles();
        vTaskDelay(pdMS_TO_TICKS(1000)); // Adjust delay as needed
    }
}

void BLETransmitter::transmitFiles() {
//     if(fileSent) {
//         return;
//     }
//     if (!deviceConnected) {
//         Serial.println("Device not connected, skipping file transmission.");
//         return;
//     }
//     String filename = "image0.jpg";
//     // String filename;
//     // if (sdCard.acquireNextFile(filename)) {
//         Serial.printf("Transmitting file: %s\n", filename.c_str());
//         size_t fileSize = sdCard.getFileSize(filename);

//         // Send packet 0 with filename and number of frames
//         uint16_t numFrames = (fileSize + MAX_FRAME_SIZE - 1) / MAX_FRAME_SIZE;
//         sendPacket(0, filename.c_str(), filename.length() + 1, numFrames);

//         uint8_t frameBuffer[MAX_FRAME_SIZE];
//         uint16_t frameIndex = 1;
//         while (file.available()) {
//             size_t bytesRead = file.read(frameBuffer, MAX_FRAME_SIZE);
//             sendPacket(frameIndex++, frameBuffer, bytesRead);
//         }

//         // Send last packet with closing signature
//         static const uint8_t signature[] = "END";
//         sendPacket(frameIndex, signature, sizeof(signature));

//         sdCard.removeFile(filename);
//         sdCard.releaseLock();
//         Serial.println("File transmission complete.");
//         fileSent = true;
//     // } else {
//     //     Serial.println("No files to transmit.");
//     // }
}

// void BLETransmitter::sendPacket(uint16_t packetIndex, const uint8_t* data, size_t length, uint16_t numFrames) {
//     uint8_t packet[MAX_PACKET_SIZE];
//     size_t packetSize = 0;

//     packet[packetSize++] = packetIndex >> 8;
//     packet[packetSize++] = packetIndex & 0xFF;

//     if (packetIndex == 0) {
//         packet[packetSize++] = numFrames >> 8;
//         packet[packetSize++] = numFrames & 0xFF;

//         // Add current millis time to the starting packet
//         uint32_t currentMillis = millis();
//         packet[packetSize++] = (currentMillis >> 24) & 0xFF;
//         packet[packetSize++] = (currentMillis >> 16) & 0xFF;
//         packet[packetSize++] = (currentMillis >> 8) & 0xFF;
//         packet[packetSize++] = currentMillis & 0xFF;
//     }

//     memcpy(packet + packetSize, data, length);
//     packetSize += length;

//     if (fileDataCharacteristic->setValue(packet, packetSize)) {
//         fileDataCharacteristic->notify();
//         Serial.printf("Sent packet %d\n", packetIndex);
//     } else {
//         Serial.printf("Failed to send packet %d\n", packetIndex);
//     }
// }