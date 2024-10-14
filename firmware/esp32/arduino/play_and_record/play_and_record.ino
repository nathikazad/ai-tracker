#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLEServer.h>
#include <I2S.h>
#include "Adafruit_AD569x.h"
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>

// BLE Server name
#define bleServerName "ESP32_Audio_System"

// Service UUIDs
#define RECORDING_SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define PLAYBACK_SERVICE_UUID  "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

// Characteristic UUIDs
#define RECORDING_CHARACTERISTIC_UUID "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
#define PLAYBACK_CHARACTERISTIC_UUID  "6E400004-B5A3-F393-E0A9-E50E24DCCA9E"

// Audio settings
#define SAMPLE_RATE 4000U
#define SAMPLE_BITS 16
#define VOLUME_GAIN 2
#define CHUNK_SIZE 512
#define SEND_INTERVAL 5000 // 5 seconds in milliseconds
#define BUFFER_SIZE (SAMPLE_RATE * SAMPLE_BITS / 8 * SEND_INTERVAL / 1000 * 2) // Reduced buffer size

// Global variables
Adafruit_AD569x ad5693;
BLECharacteristic *pRecordingCharacteristic;
uint8_t *recordingBuffer = NULL;
uint16_t *playbackBuffer = NULL;
bool deviceConnected = false;
bool playingAudio = false;
bool receivingAudio = false;

// Separate indices for recording and playback
volatile uint32_t recordWriteIndex = 0;
volatile uint32_t recordReadIndex = 0;
volatile uint32_t playbackWriteIndex = 0;
volatile uint32_t playbackReadIndex = 0;

volatile bool recordBufferFull = false;
volatile bool playbackBufferFull = false;

SemaphoreHandle_t recordBufferMutex;
SemaphoreHandle_t playbackBufferMutex;
unsigned long startTime = 0;
unsigned long lastPacketIndex = 0;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
    };
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        BLEDevice::startAdvertising();
    }
};

class PlaybackCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        if (value.length() == 2) {
            uint16_t sample = (uint8_t)value[0] << 8 | (uint8_t)value[1];
            if (sample == 65535) { // start marker
                Serial.println("Playback started");
                receivingAudio = true;
                startTime = millis();
                playbackWriteIndex = 0;
                playbackReadIndex = 0;
            } else if (sample == 65534) { //end marker
                lastPacketIndex = playbackWriteIndex;
                receivingAudio = false;
            }
        }
        if (value.length() > 0) {
            size_t dataSize = value.length();
            const uint8_t* data = reinterpret_cast<const uint8_t*>(value.data());
            
            xSemaphoreTake(playbackBufferMutex, portMAX_DELAY);
            
            size_t samplesToWrite = dataSize / 2;
            size_t spaceAvailable = (playbackReadIndex > playbackWriteIndex) ? 
                (playbackReadIndex - playbackWriteIndex) : 
                (BUFFER_SIZE - playbackWriteIndex + playbackReadIndex);
            
            if (samplesToWrite > spaceAvailable) {
                samplesToWrite = spaceAvailable;
                playbackBufferFull = true;
            }
            
            size_t bytesToCopy = samplesToWrite * 2;
            if (playbackWriteIndex + samplesToWrite <= BUFFER_SIZE) {
                memcpy(&playbackBuffer[playbackWriteIndex], data, bytesToCopy);
            } else {
                size_t firstCopySize = (BUFFER_SIZE - playbackWriteIndex) * 2;
                memcpy(&playbackBuffer[playbackWriteIndex], data, firstCopySize);
                memcpy(playbackBuffer, data + firstCopySize, bytesToCopy - firstCopySize);
            }
            
            playbackWriteIndex = (playbackWriteIndex + samplesToWrite) % BUFFER_SIZE;
            
            xSemaphoreGive(playbackBufferMutex);
        }
    }
};

void recordTask(void * parameter) {
    for(;;) {
      if (deviceConnected && !playingAudio) {
            // Record audio
            uint32_t bytesToRead = 1024; // Read in smaller chunks
            uint32_t bytesRead = 0;
            esp_i2s::i2s_read(esp_i2s::I2S_NUM_0, recordingBuffer + recordWriteIndex, bytesToRead, &bytesRead, 0);

            xSemaphoreTake(recordBufferMutex, portMAX_DELAY);
            recordWriteIndex = (recordWriteIndex + bytesRead) % BUFFER_SIZE;
            if (recordWriteIndex == recordReadIndex) {
                Serial.println("Recording buffer full!");
                recordBufferFull = true;
            }
            xSemaphoreGive(recordBufferMutex);
        }
        // Small delay to prevent this task from starving others
        delay(1);
    }
}

void playAudioTask(void *parameter) {
    while (1) {
        xSemaphoreTake(playbackBufferMutex, portMAX_DELAY);
        if (playbackReadIndex == 0 && receivingAudio == true) {
            playingAudio = true;
        }
        if (playbackReadIndex != playbackWriteIndex || playbackBufferFull) {
            uint16_t sample = playbackBuffer[playbackReadIndex];
            playbackReadIndex = (playbackReadIndex + 1) % BUFFER_SIZE;
            playbackBufferFull = false;
            xSemaphoreGive(playbackBufferMutex);
            if (!ad5693.writeUpdateDAC(sample)) {
                Serial.println("Failed to update DAC.");
            }
            delayMicroseconds(140); 
        } else {
            xSemaphoreGive(playbackBufferMutex);
            // Buffer is empty, wait a bit
            delay(1);
        }
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

    // Initialize the AD5693 chip
    if (ad5693.begin(0x4C, &Wire)) {
        Serial.println("AD5693 initialization successful!");
    } else {
        Serial.println("Failed to initialize AD5693. Please check your connections.");
        while (1) delay(10); // Halt
    }
    
    // Reset the DAC
    ad5693.reset();
    
    // Configure the DAC for normal mode, internal reference, and no 2x gain
    if (ad5693.setMode(NORMAL_MODE, true, false)) {
        Serial.println("AD5693 configured");
    } else {
        Serial.println("Failed to configure AD5693.");
        while (1) delay(10); // Halt
    }
    
    // Set the I2C clock rate to 800KHz for faster communication
    Wire.setClock(800000);

    // Create mutexes for buffer access
    recordBufferMutex = xSemaphoreCreateMutex();
    playbackBufferMutex = xSemaphoreCreateMutex();

    // Initialize BLE
    BLEDevice::init(bleServerName);
    BLEServer *pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    // Create Recording Service
    BLEService *pRecordingService = pServer->createService(RECORDING_SERVICE_UUID);
    pRecordingCharacteristic = pRecordingService->createCharacteristic(
        RECORDING_CHARACTERISTIC_UUID,
        BLECharacteristic::PROPERTY_NOTIFY
    );
    pRecordingCharacteristic->addDescriptor(new BLE2902());

    // Create Playback Service
    BLEService *pPlaybackService = pServer->createService(PLAYBACK_SERVICE_UUID);
    BLECharacteristic *pPlaybackCharacteristic = pPlaybackService->createCharacteristic(
        PLAYBACK_CHARACTERISTIC_UUID,
        BLECharacteristic::PROPERTY_WRITE
    );
    pPlaybackCharacteristic->setCallbacks(new PlaybackCallbacks());

    pRecordingService->start();
    pPlaybackService->start();

    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(RECORDING_SERVICE_UUID);
    pAdvertising->addServiceUUID(PLAYBACK_SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);
    pAdvertising->setMinPreferred(0x12);

    BLEDevice::startAdvertising();

    // Allocate buffer for audio data
    recordingBuffer = (uint8_t *)ps_malloc(BUFFER_SIZE);
    playbackBuffer = (uint16_t *)ps_malloc(BUFFER_SIZE * sizeof(uint16_t));
    if (recordingBuffer == NULL || playbackBuffer == NULL) {
        Serial.println("Failed to allocate memory for audio buffers!");
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
        1);           /* pin task to core 0 */

    // Create playback task on core 1
    xTaskCreatePinnedToCore(
        playAudioTask,   /* Function to implement the task */
        "playAudioTask", /* Name of the task */
        10000,           /* Stack size in words */
        NULL,            /* Task input parameter */
        1,               /* Priority of the task */
        NULL,            /* Task handle */
        0);              /* Core where the task should run */

    Serial.println("BLE Audio System is ready!");
}

void loop() {
    static unsigned long lastSendTime = 0;
    uint32_t sendSize = SAMPLE_RATE * SAMPLE_BITS / 8 * SEND_INTERVAL / 1000;

    // Check if it's time to send data and enough data is available
    // Serial.print(recordWriteIndex);
    // Serial.print(", ");
    // Serial.print(recordReadIndex);
    // Serial.print(", ");
    // Serial.println((recordWriteIndex - recordReadIndex + BUFFER_SIZE) % BUFFER_SIZE);
    if (!playingAudio && deviceConnected && (millis() - lastSendTime >= SEND_INTERVAL)) {
        xSemaphoreTake(recordBufferMutex, portMAX_DELAY);
        uint32_t availableData = (recordWriteIndex - recordReadIndex + BUFFER_SIZE) % BUFFER_SIZE;
        if (recordBufferFull || availableData >= sendSize) {
            sendAudioData(sendSize);
            lastSendTime = millis();
        }
        xSemaphoreGive(recordBufferMutex);
    }

    if (playingAudio && playbackReadIndex > (lastPacketIndex - 500)) { // accounting for missed packets
        playingAudio = false;
        Serial.println("Finished playing");
    }

    // Small delay to prevent this task from starving others
    delay(500);
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
    pRecordingCharacteristic->setValue(startPacket, 8);
    pRecordingCharacteristic->notify();
    delay(20);  // Give the client some time to process

    // Send audio data in chunks
    for (uint32_t i = 0; i < size; i += CHUNK_SIZE) {
        uint32_t chunkSize = (CHUNK_SIZE < size - i) ? CHUNK_SIZE : (size - i);
        uint8_t header[4] = {0xFF, 0xFF, (i >> 8) & 0xFF, i & 0xFF};
        uint8_t chunk[CHUNK_SIZE + 4];
        memcpy(chunk, header, 4);

        // Copy data from circular buffer to chunk
        for (uint32_t j = 0; j < chunkSize; j++) {
            chunk[j + 4] = recordingBuffer[(recordReadIndex + i + j) % BUFFER_SIZE];
            // Apply volume gain
            if (j % 2 == 1) { // Assuming 16-bit samples
                uint16_t sample = *((uint16_t*)&chunk[j + 3]);
                sample <<= VOLUME_GAIN;
                *((uint16_t*)&chunk[j + 3]) = sample;
            }
        }

        pRecordingCharacteristic->setValue(chunk, chunkSize + 4);
        pRecordingCharacteristic->notify();
        delay(50);  // Give the client some time to process
    }

    // Update read index
    recordReadIndex = (recordReadIndex + size) % BUFFER_SIZE;
    recordBufferFull = false;

    // Send end packet
    uint8_t endPacket[4] = {'E', 'N', 'D', 0};
    pRecordingCharacteristic->setValue(endPacket, 4);
    pRecordingCharacteristic->notify();

    unsigned long endTime = millis();
    unsigned long duration = endTime - startTime;
    Serial.printf("Audio data sent successfully. Total time: %lu ms\n", duration);
}