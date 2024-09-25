#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLEServer.h>
#include <I2S.h>

// BLE Server name
#define bleServerName "XIAO_ESP32S3_Audio"

#define SAMPLE_RATE 4000U
#define SAMPLE_BITS 16
#define VOLUME_GAIN 2
#define CHUNK_SIZE 512
#define SEND_INTERVAL 5000 // 5 seconds in milliseconds
#define BUFFER_SIZE (SAMPLE_RATE * SAMPLE_BITS / 8 * SEND_INTERVAL / 1000 * 10) // Double the size for circular buffer

BLECharacteristic *pCharacteristic;
uint8_t *audioBuffer = NULL;
bool deviceConnected = false;

volatile uint32_t writeIndex = 0;
volatile uint32_t readIndex = 0;
volatile bool bufferFull = false;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
    };
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
    }
};

void recordTask(void * parameter) {
    for(;;) {
        // Record audio
        uint32_t bytesToRead = 1024; // Read in smaller chunks
        uint32_t bytesRead = 0;
        esp_i2s::i2s_read(esp_i2s::I2S_NUM_0, audioBuffer + writeIndex, bytesToRead, &bytesRead, 0);

        writeIndex = (writeIndex + bytesRead) % BUFFER_SIZE;
        if (writeIndex == readIndex) {
            Serial.println("Buffer full!");
            bufferFull = true;
        }

        // Small delay to prevent this task from starving others
        delay(1);
    }
}

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

    // Allocate buffer for audio data
    audioBuffer = (uint8_t *)ps_malloc(BUFFER_SIZE);
    if (audioBuffer == NULL) {
        Serial.println("Failed to allocate memory for audio buffer!");
        while (1) ;
    }

    // Create recording task on core 0
    xTaskCreatePinnedToCore(
        recordTask,   /* Task function. */
        "RecordTask", /* name of task. */
        10000,        /* Stack size of task */
        NULL,         /* parameter of the task */
        1,            /* priority of the task */
        NULL,         /* Task handle to keep track of created task */
        0);           /* pin task to core 0 */

    Serial.println("BLE Audio Recorder is ready!");
}

void loop() {
    static unsigned long lastSendTime = 0;
    uint32_t sendSize = SAMPLE_RATE * SAMPLE_BITS / 8 * SEND_INTERVAL / 1000;

    // Check if it's time to send data and enough data is available
    if (deviceConnected && (millis() - lastSendTime >= SEND_INTERVAL)) {
        uint32_t availableData = (writeIndex - readIndex + BUFFER_SIZE) % BUFFER_SIZE;
        if (bufferFull || availableData >= sendSize) {
            sendAudioData(sendSize);
            lastSendTime = millis();
        }
    }

    // Small delay to prevent this task from starving others
    delay(1);
}

void sendAudioData(uint32_t size) {
    Serial.println("Sending audio data...");

    // Start timing the BLE transmission
    unsigned long startTime = millis();

    // Send start packet
    uint32_t numPackets = (size + CHUNK_SIZE - 1) / CHUNK_SIZE;
    uint8_t startPacket[8] = {'S', 'T', 'A', 'R', 'T', 0, 0, 0};
    startPacket[5] = (numPackets >> 16) & 0xFF;
    startPacket[6] = (numPackets >> 8) & 0xFF;
    startPacket[7] = numPackets & 0xFF;
    pCharacteristic->setValue(startPacket, 8);
    pCharacteristic->notify();
    delay(20);  // Give the client some time to process

    // Send audio data in chunks
    for (uint32_t i = 0; i < size; i += CHUNK_SIZE) {
        uint32_t chunkSize = (CHUNK_SIZE < size - i) ? CHUNK_SIZE : (size - i);
        uint8_t header[4] = {0xFF, 0xFF, (i >> 8) & 0xFF, i & 0xFF};
        uint8_t chunk[CHUNK_SIZE + 4];
        memcpy(chunk, header, 4);

        // Copy data from circular buffer to chunk
        for (uint32_t j = 0; j < chunkSize; j++) {
            chunk[j + 4] = audioBuffer[(readIndex + i + j) % BUFFER_SIZE];
            // Apply volume gain
            if (j % 2 == 1) { // Assuming 16-bit samples
                uint16_t sample = *((uint16_t*)&chunk[j + 3]);
                sample <<= VOLUME_GAIN;
                *((uint16_t*)&chunk[j + 3]) = sample;
            }
        }

        pCharacteristic->setValue(chunk, chunkSize + 4);
        pCharacteristic->notify();
        delay(20);  // Give the client some time to process
    }

    // Update read index
    readIndex = (readIndex + size) % BUFFER_SIZE;
    bufferFull = false;

    // Send end packet
    uint8_t endPacket[4] = {'E', 'N', 'D', 0};
    pCharacteristic->setValue(endPacket, 4);
    pCharacteristic->notify();

    unsigned long endTime = millis();
    unsigned long duration = endTime - startTime;
    Serial.printf("Audio data sent successfully. Total time: %lu ms\n", duration);
}