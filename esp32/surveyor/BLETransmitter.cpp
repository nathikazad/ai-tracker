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
    // xTaskCreatePinnedToCore(
    //     this->transmitTask,
    //     "TransmitTask",
    //     10000,
    //     this,
    //     1,
    //     &transmitTaskHandle,
    //     0
    // );
}

void BLETransmitter::transmitTask(void *pvParameters) {
    BLETransmitter* transmitter = static_cast<BLETransmitter*>(pvParameters);
    for (;;) {
        Serial.println("Checking for files to transmit...");
        transmitter->transmitFiles();
        vTaskDelay(pdMS_TO_TICKS(5000));
    }
}

void BLETransmitter::transmitFiles() {
    if (fileSent) {
        return;
    }
    // if (!deviceConnected) {
    //     Serial.println("Device not connected, skipping file transmission.");
    //     return;
    // }

    String filename;
    if (sdCard.acquireNextFile(filename)) {
        Serial.printf("Acquired file: %s\n", filename.c_str());
        vTaskDelay(pdMS_TO_TICKS(100)); 
    } else {
        Serial.println("No files to transmit.");
    }
    // String filename = "arduino_rec_0.wav";
    filename = "/image0.jpg";
    size_t fileSize = sdCard.getFileSize(filename);
    if (fileSize == 0) {
        Serial.println("File size is 0, skipping file transmission.");
        vTaskDelay(pdMS_TO_TICKS(100)); 
        return;
    }
    // Send packet 0 with filename and number of frames
    uint16_t numFrames = (fileSize + MAX_FRAME_SIZE - 1) / MAX_FRAME_SIZE;
    Serial.printf("Transmitting file: %s, size: %d, frames: %d\n", filename.c_str(), fileSize, numFrames);
    sendPacket(0, reinterpret_cast<const uint8_t*>(filename.c_str()), filename.length() + 1, numFrames);


    uint8_t frameBuffer[MAX_FRAME_SIZE];
    size_t bytesRead;
    uint16_t frameIndex = 1;

    if (sdCard.readFile(filename, frameBuffer, MAX_FRAME_SIZE, bytesRead)) {
        Serial.printf("Reading frame %d, bytesRead: %d\n", frameIndex, bytesRead);
        while (bytesRead > 0) {
            sendPacket(frameIndex++, frameBuffer, bytesRead);
            bytesRead = 0;
            if (sdCard.readFile(filename, frameBuffer, MAX_FRAME_SIZE, bytesRead)) {
                // Continue reading and sending packets
            } else {
                Serial.printf("Error reading file: %s\n", filename.c_str());
                break;
            }
        }
    } else {
        Serial.printf("Error opening file: %s\n", filename.c_str());
    }

    // Send last packet with closing signature
    static const uint8_t signature[] = "END";
    sendPacket(frameIndex, signature, sizeof(signature));

    sdCard.removeFile(filename);
    Serial.println("File transmission complete.");
    fileSent = true;
}

void BLETransmitter::sendPacket(uint16_t packetIndex, const uint8_t* data, size_t length, uint16_t numFrames) {
    uint8_t packet[MAX_PACKET_SIZE];
    size_t packetSize = 0;

    packet[packetSize++] = packetIndex >> 8;
    packet[packetSize++] = packetIndex & 0xFF;

    if (packetIndex == 0) {
        packet[packetSize++] = numFrames >> 8;
        packet[packetSize++] = numFrames & 0xFF;

        // Add current millis time to the starting packet
        uint32_t currentMillis = millis();
        packet[packetSize++] = (currentMillis >> 24) & 0xFF;
        packet[packetSize++] = (currentMillis >> 16) & 0xFF;
        packet[packetSize++] = (currentMillis >> 8) & 0xFF;
        packet[packetSize++] = currentMillis & 0xFF;
    }

    memcpy(packet + packetSize, data, length);
    packetSize += length;
    fileDataCharacteristic->setValue(packet, packetSize);
    fileDataCharacteristic->notify();
    Serial.printf("Sent packet %d\n", packetIndex);

}