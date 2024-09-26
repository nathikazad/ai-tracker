#include <PDM.h>
#include <ArduinoBLE.h>

AP3_PDM myPDM;
#define pdmDataSize 4096
uint16_t pdmData[pdmDataSize];

// PDM Configuration
void *PDMHandle = NULL;
am_hal_pdm_config_t newConfig = {
    .eClkDivider = AM_HAL_PDM_MCLKDIV_1,
    .eLeftGain = AM_HAL_PDM_GAIN_0DB,
    .eRightGain = AM_HAL_PDM_GAIN_P405DB,
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

const unsigned long sendInterval = 10000; // 10 seconds in milliseconds
unsigned long lastSendTime = 0;

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

    Serial.println("BLE PDM Data Sender Ready");
}

void loop() {
  BLEDevice central = BLE.central();

  if (central) {
    if (central.connected() && myPDM.available())
    {
      myPDM.getData(pdmData, pdmDataSize);
      int j = 0;
      for (int i = 0; i < pdmDataSize * 2; i += 200) {  // pdmDataSize * 2 because each uint16_t is 2 bytes
          int chunkSize = min(200, pdmDataSize * 2 - i);

          dataCharacteristic.writeValue(((uint8_t*)pdmData) + i, chunkSize);
          j++;
      }
      Serial.print(pdmDataSize);
      Serial.print(" ");
      Serial.println(j);
    }
  }
}