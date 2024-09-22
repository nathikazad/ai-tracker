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

static BLEUUID serviceUUID("19B00000-E8F2-537E-4F6C-D104768A1214");
static BLEUUID fileDataUUID("19B00001-E8F2-537E-4F6C-D104768A1214");
static BLEUUID ackUUID("19B00002-E8F2-537E-4F6C-D104768A1214");

const size_t MAX_FRAME_SIZE = 512;
const size_t MAX_PACKET_SIZE = MAX_FRAME_SIZE + 4;

const size_t MAX_PACKETS = 3000;
const size_t ACK_WAIT_TIME = 1000; // 1 second wait time for ACKs
const size_t BITMAP_SIZE = ((MAX_PACKETS + 31) / 32);
const int SEND_FILE_INTERVAL = 20000;

class BLETransmitter
{
public:
  BLETransmitter(SDCard &sd);
  ~BLETransmitter();
  bool begin();
  void startBleServer();
  void setDeviceConnected(bool connected) { m_deviceConnected = connected; }
  void setAckBit(uint16_t packetIndex);

private:
  static void sendFileTask(void *pvParameters);
  void transmitFiles();
  void sendPacket(uint16_t packetIndex, const uint8_t *data, size_t length, uint16_t numFrames = 0);
  void setPHY();

  SDCard &sdCard;
  TaskHandle_t sendFileTaskHandle;

  bool m_deviceConnected;
  uint8_t* m_ackBitmap;
  // uint8_t* m_ackBitmap_copy;
  BLECharacteristic* ackCharacteristic;
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




class AckCharacteristicCallbacks : public BLECharacteristicCallbacks
{
public:
    AckCharacteristicCallbacks(BLETransmitter* transmitter) : m_transmitter(transmitter) {}
    void onWrite(BLECharacteristic *pCharacteristic);

private:
    BLETransmitter* m_transmitter;
};

#endif
