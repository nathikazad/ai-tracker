#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include "Adafruit_AD569x.h"
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>

Adafruit_AD569x ad5693;

#define SERVICE_UUID        "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

#define BUFFER_SIZE 64000
uint16_t audioBuffer[BUFFER_SIZE];
volatile uint32_t writeIndex = 0;
volatile uint32_t readIndex = 0;
volatile bool bufferFull = false;

SemaphoreHandle_t bufferMutex;
unsigned long startTime = 0;
unsigned long lastPacket = 0;
bool printedTime = false;
class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        if (value.length() == 2) {
          uint16_t sample = (uint8_t)value[0] << 8 | (uint8_t)value[1];
          // Serial.println(sample);
          if (sample == 65535) {
            Serial.println("Playback started");
            startTime = millis();
          } else if (sample == 65534) {
            lastPacket = writeIndex;
            // unsigned long duration = millis() - startTime;
            // delay(1000);
            // Serial.print("Duration: ");
            // Serial.print(duration);
            // Serial.println(" ms");
            // Serial.println(readIndex);
          }
        }
        if (value.length() > 0) {
            size_t dataSize = value.length();
            const uint8_t* data = reinterpret_cast<const uint8_t*>(value.data());
            
            xSemaphoreTake(bufferMutex, portMAX_DELAY);
            
            size_t samplesToWrite = dataSize / 2;
            size_t spaceAvailable = (readIndex > writeIndex) ? 
                (readIndex - writeIndex) : 
                (BUFFER_SIZE - writeIndex + readIndex);
            
            if (samplesToWrite > spaceAvailable) {
                samplesToWrite = spaceAvailable;
                bufferFull = true;
            }
            
            size_t bytesToCopy = samplesToWrite * 2;
            if (writeIndex + samplesToWrite <= BUFFER_SIZE) {
                memcpy(&audioBuffer[writeIndex], data, bytesToCopy);
            } else {
                size_t firstCopySize = (BUFFER_SIZE - writeIndex) * 2;
                memcpy(&audioBuffer[writeIndex], data, firstCopySize);
                memcpy(audioBuffer, data + firstCopySize, bytesToCopy - firstCopySize);
            }
            
            writeIndex = (writeIndex + samplesToWrite) % BUFFER_SIZE;
            
            xSemaphoreGive(bufferMutex);
        }
    }
};

void playAudioTask(void *parameter) {
    while (1) {
        xSemaphoreTake(bufferMutex, portMAX_DELAY);
        if (readIndex != writeIndex || bufferFull) {
            uint16_t sample = audioBuffer[readIndex];
            readIndex = (readIndex + 1) % BUFFER_SIZE;
            bufferFull = false;
            xSemaphoreGive(bufferMutex);
            if (!ad5693.writeUpdateDAC(sample)) {
                Serial.println("Failed to update DAC.");
            }
            delayMicroseconds(140); 
        } else {
            xSemaphoreGive(bufferMutex);
            // Buffer is empty, wait a bit
            delay(1);
        }
    }
}

void setup() {
    Serial.begin(115200);
    
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

    // Create mutex for buffer access
    bufferMutex = xSemaphoreCreateMutex();

    // Create the BLE Device
    BLEDevice::init("ESP32_Audio_DAC");

    // Create the BLE Server
    BLEServer *pServer = BLEDevice::createServer();

    // Create the BLE Service
    BLEService *pService = pServer->createService(SERVICE_UUID);

    // Create a BLE Characteristic
    BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                            CHARACTERISTIC_UUID,
                                            BLECharacteristic::PROPERTY_WRITE
                                        );

    pCharacteristic->setCallbacks(new MyCallbacks());

    // Start the service
    pService->start();

    // Start advertising
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
    pAdvertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();
    Serial.println("Characteristic defined! Now you can write to it");

    // Start audio playback task
    xTaskCreatePinnedToCore(
        playAudioTask,   /* Function to implement the task */
        "playAudioTask", /* Name of the task */
        10000,           /* Stack size in words */
        NULL,            /* Task input parameter */
        1,               /* Priority of the task */
        NULL,            /* Task handle */
        0);              /* Core where the task should run */
}

void loop() {
    // This loop can be used for other tasks if needed
    if(readIndex > (lastPacket - 500)) {
      unsigned long duration = millis() - startTime;
      // Serial.println("duration:");
      Serial.print(duration);
      Serial.print(", ");
      Serial.print(lastPacket);
      Serial.print(", ");
      Serial.println(readIndex);
      lastPacket = 0;
    }
    delay(1000);
}