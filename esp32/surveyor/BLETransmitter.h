// #pragma once



// class SDCard;



// class BLETransmitter {
// public:
//     BLETransmitter(SDCard& sd);
//     void begin();
//     // void transmitFiles();

// private:

//     static void transmitTask(void *pvParameters);
//     SDCard& sdCard;
// };

#ifndef BLE_TRANSMITTER_H
#define BLE_TRANSMITTER_H

#include <Arduino.h>
#include "SDCard.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include "esp_bt.h"
#include "esp_gap_ble_api.h"
#include "esp_gatt_defs.h"
#include "esp_bt_main.h"
#include "esp_gatt_common_api.h"
#include "esp_bt_device.h"

const size_t MAX_FRAME_SIZE = 512;
const size_t MAX_PACKET_SIZE = MAX_FRAME_SIZE + 4;

class BLETransmitter {
public:
  BLETransmitter(SDCard& sd);
  bool begin();
  void startBleServer();

private:
  static void sendFileTask(void *pvParameters);
  void transmitFiles();
  void sendPacket(uint16_t packetIndex, const uint8_t* data, size_t length, uint16_t numFrames = 0);
  void setPHY();

  SDCard& sdCard;
  TaskHandle_t sendFileTaskHandle;
  static const int SEND_FILE_INTERVAL = 10000; // 60 seconds
  
  bool fileSent = false;
  BLEServer *pServer;
  BLEService *pService;
  BLECharacteristic *fileDataCharacteristic;
  BLEAdvertising *pAdvertising;
  esp_ble_gap_ext_adv_params_t ext_adv_params_2M = {};
    esp_ble_gap_ext_adv_params_t ext_adv_params_1M = {};
    esp_ble_gap_conn_params_t conn_params_1M = {};
    esp_ble_gap_conn_params_t conn_params_2M = {};
};

#endif
