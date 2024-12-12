// ble.h
#ifndef BLE_H
#define BLE_H

#include <bluefruit.h>

// Configuration
#define FAST
#define CONN_PARAM 6
#define PACKET_SIZE 244
#define PACKET_HEADER_SIZE 2
#define PACKET_DATA_SIZE (PACKET_SIZE - PACKET_HEADER_SIZE)

// Service UUIDs
#define ASPIRE_SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define SPEAKER_RX_UUID "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CAM_TX_UUID "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
#define MIC_TX_UUID "19B10001-E8F2-537E-4F6C-D104768A1214"

// Service and Characteristic declarations
extern BLEService aspireService;
extern BLECharacteristic speakerRxCharacteristic;
extern BLECharacteristic camTxCharacteristic;
extern BLECharacteristic micTxCharacteristic;

// Function declarations
void setupBLE();
bool isConnected();
void connect_callback(uint16_t conn_handle);
void disconnect_callback(uint16_t conn_handle, uint8_t reason);
void speaker_rx_callback(uint16_t conn_hdl, BLECharacteristic* chr, uint8_t* data, uint16_t len);
void sendHandshake(uint32_t totalBytes, uint16_t numPackets, uint16_t width, uint16_t height);
void sendPacket(uint16_t packetNum, uint8_t* data, uint16_t dataSize);
uint32_t fletcher32(uint8_t const *data, size_t len);

#endif // UNIFIED_BLE_H