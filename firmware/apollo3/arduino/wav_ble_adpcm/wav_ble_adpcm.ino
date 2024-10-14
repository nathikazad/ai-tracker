#include <PDM.h>
#include <ArduinoBLE.h>
#include <mbed.h>

AP3_PDM myPDM;

#define PDM_BUFFER_SIZE 4096
#define CIRCULAR_BUFFER_SIZE 81920 // 80KB circular buffer
#define SEND_BUFFER_SIZE 40960 // 40KB send buffer
#define STATUS_COUNT_TOTAL 10
#define CHUNK_SIZE 239

uint16_t pdmBuffer[PDM_BUFFER_SIZE];
uint8_t circularBuffer[CIRCULAR_BUFFER_SIZE];
uint8_t* sendBuffer = NULL;

volatile size_t writeIndex = 0;
volatile size_t readIndex = 0;

rtos::Thread pdmThread;
rtos::Thread bleThread;
rtos::Mutex bufferMutex;

// PDM Configuration
void *PDMHandle = NULL;
am_hal_pdm_config_t newConfig = {
    .eClkDivider = AM_HAL_PDM_MCLKDIV_1,
    .eLeftGain = AM_HAL_PDM_GAIN_0DB,
    .eRightGain = AM_HAL_PDM_GAIN_P90DB,
    .ui32DecimationRate = 48,
    .bHighPassEnable = 0,
    .ui32HighPassCutoff = 0xB,
    .ePDMClkSpeed = AM_HAL_PDM_CLK_375KHZ,
    .bInvertI2SBCLK = 0,
    .ePDMClkSource = AM_HAL_PDM_INTERNAL_CLK,
    .bPDMSampleDelay = 0,
    .bDataPacking = 1,
    .ePCMChannels = AM_HAL_PDM_CHANNEL_RIGHT,
    .ui32GainChangeDelay = 1,
    .bI2SEnable = 0,
    .bSoftMute = 0,
    .bLRSwap = 0,
};

// BLE Configuration
BLEService dataService("19B10000-E8F2-537E-4F6C-D104768A1214");
BLECharacteristic dataCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, CHUNK_SIZE);

volatile bool bleConnected = false;

void pdmThreadFunction() {
    while (true) {
        if (myPDM.available()) {
            myPDM.getData(pdmBuffer, PDM_BUFFER_SIZE);
            
            bufferMutex.lock();
            for (int i = 0; i < PDM_BUFFER_SIZE * 2; i++) {
                circularBuffer[writeIndex] = ((uint8_t*)pdmBuffer)[i];
                writeIndex = (writeIndex + 1) % CIRCULAR_BUFFER_SIZE;
            }
            bufferMutex.unlock();
        }
        rtos::ThisThread::sleep_for(100);
    }
}

void bleThreadFunction() {
  while (true) {
    if (bleConnected) {
      size_t availableData = (writeIndex - readIndex + CIRCULAR_BUFFER_SIZE) % CIRCULAR_BUFFER_SIZE;
      while (availableData >= SEND_BUFFER_SIZE) {
          bufferMutex.lock();
          for (size_t i = 0; i < SEND_BUFFER_SIZE; i++) {
              sendBuffer[i] = circularBuffer[readIndex];
              readIndex = (readIndex + 1) % CIRCULAR_BUFFER_SIZE;
          }
          bufferMutex.unlock();     
          sendData();
          availableData = (writeIndex - readIndex + CIRCULAR_BUFFER_SIZE) % CIRCULAR_BUFFER_SIZE;
      }
    }
    rtos::ThisThread::sleep_for(100);
  }
}

void setup() {
    Serial.begin(500000);
    delay(10);

    if (myPDM.begin() == false) {
        Serial.println("PDM Init failed. Are you sure these pins are PDM capable?");
        while (1);
    }
    myPDM.updateConfig(newConfig);

    if (!BLE.begin()) {
        Serial.println("Starting Bluetooth® Low Energy module failed!");
        while (1);
    }

    BLE.setLocalName("PDM Data Sender");
    BLE.setAdvertisedService(dataService);
    dataService.addCharacteristic(dataCharacteristic);
    BLE.addService(dataService);
    BLE.advertise();

    sendBuffer = (uint8_t*)malloc(SEND_BUFFER_SIZE);
    if (sendBuffer == NULL) {
        Serial.println("Failed to allocate send buffer!");
        while (1);
    }

    pdmThread.start(pdmThreadFunction);
    bleThread.start(bleThreadFunction);

    Serial.println("BLE PDM Data Sender Ready");
}

void loop() {
    BLEDevice central = BLE.central();
    if (central) {
        Serial.print("Connected to central: ");
        Serial.println(central.address());
        bleConnected = true;

        while (central.connected()) {
          // rtos::ThisThread::sleep_for(100);
        }

        Serial.print("Disconnected from central: ");
        Serial.println(central.address());
        bleConnected = false;
    }
}

void sendData() {
    unsigned long startTime = millis();
    Serial.println("Sending 40KB of data...");

    for (size_t i = 0; i < SEND_BUFFER_SIZE; i += CHUNK_SIZE) {
        size_t chunkSize = min(CHUNK_SIZE, SEND_BUFFER_SIZE - i);
        dataCharacteristic.writeValue(sendBuffer + i, chunkSize);
    }

    Serial.println("Data sent successfully.");
    unsigned long endTime = millis();
    unsigned long duration = endTime - startTime;
    Serial.print("Time taken: ");
    Serial.print(duration);
    Serial.println(" ms");
}