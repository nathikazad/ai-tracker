#ifndef BLE_CONFIG_H
#define BLE_CONFIG_H

#include <bluefruit.h>

// BLE Configuration
#define FAST
#define CONN_PARAM 6
#define DATA_NUM 240
#define CHUNK_SIZE 236

// Service and Characteristic UUIDs
extern BLEService uploadService;
extern BLECharacteristic dataCharacteristic;
extern BLECharacteristic delayCharacteristic;
extern BLECharacteristic burstTimeCharacteristic;

void setupBle();
void connect_callback(uint16_t conn_handle);
void disconnect_callback(uint16_t conn_handle, uint8_t reason);
bool isConnected();

#endif