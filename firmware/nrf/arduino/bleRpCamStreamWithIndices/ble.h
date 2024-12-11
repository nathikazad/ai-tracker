// ble.h
#ifndef BLE_H
#define BLE_H

#include <bluefruit.h>

#define CONN_PARAM 6
#define PACKET_SIZE 244
#define PACKET_HEADER_SIZE 2
#define PACKET_DATA_SIZE (PACKET_SIZE - PACKET_HEADER_SIZE)

// BLE Service UUIDs
#define SERIAL_SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define SERIAL_RX_UUID      "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define SERIAL_TX_UUID      "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

static BLEService serialService(SERIAL_SERVICE_UUID);
static BLECharacteristic serialRxCharacteristic(SERIAL_RX_UUID, BLEWrite | BLEWriteWithoutResponse, PACKET_SIZE);
static BLECharacteristic serialTxCharacteristic(SERIAL_TX_UUID, BLENotify, PACKET_SIZE);

static bool connectedFlag = false;

void setupBLE();
bool isConnected();
void sendHandshake(uint32_t totalBytes, uint16_t numPackets, uint16_t width, uint16_t height);
void sendPacket(uint16_t packetNum, uint8_t* data, uint16_t dataSize);
uint32_t fletcher32(uint8_t const *data, size_t len);
#endif
