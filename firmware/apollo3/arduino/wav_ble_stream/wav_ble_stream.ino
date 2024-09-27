#include <PDM.h>
#include <ArduinoBLE.h>

AP3_PDM myPDM;

#define PDM_BUFFER_SIZE 4096
#define SEND_BUFFER_SIZE 40960 // 40KB

uint16_t pdmBuffer[PDM_BUFFER_SIZE];
uint8_t* sendBuffer = NULL;
size_t sendBufferIndex = 0;

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
BLECharacteristic dataCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, 200);

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

  // Allocate the send buffer
  sendBuffer = (uint8_t*)malloc(SEND_BUFFER_SIZE);
  if (sendBuffer == NULL) {
    Serial.println("Failed to allocate send buffer!");
    while (1);
  }

  Serial.println("BLE PDM Data Sender Ready");
}

void loop() {
  BLEDevice central = BLE.central();

  if (central && central.connected()) {
    if (myPDM.available()) {
      myPDM.getData(pdmBuffer, PDM_BUFFER_SIZE);

      // Copy data to send buffer
      size_t bytesToCopy = PDM_BUFFER_SIZE * 2; // multiply by 2 because each uint16_t is 2 bytes
      if (sendBufferIndex + bytesToCopy > SEND_BUFFER_SIZE) {
        bytesToCopy = SEND_BUFFER_SIZE - sendBufferIndex;
      }
      memcpy(sendBuffer + sendBufferIndex, pdmBuffer, bytesToCopy);
      sendBufferIndex += bytesToCopy;

      // If send buffer is full, send the data
      if (sendBufferIndex >= SEND_BUFFER_SIZE) {
        sendData(central);
        sendBufferIndex = 0; // Reset buffer index
      }
    }
  } else {
    // If disconnected, reset the buffer
    sendBufferIndex = 0;
  }
}

void sendData(BLEDevice& central) {
  unsigned long startTime = millis();
  Serial.println("Sending 40KB of data...");
  for (size_t i = 0; i < SEND_BUFFER_SIZE; i += 200) {
    size_t chunkSize = min(200, SEND_BUFFER_SIZE - i);
    dataCharacteristic.writeValue(sendBuffer + i, chunkSize);
  }
  Serial.println("Data sent successfully.");
  unsigned long endTime = millis();
  unsigned long duration = endTime - startTime;
  Serial.print("Time taken: ");
  Serial.print(duration);
  Serial.println(" ms");
}