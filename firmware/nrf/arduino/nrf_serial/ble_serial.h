#ifndef BLE_SERIAL_RELAY_H
#define BLE_SERIAL_RELAY_H

#include <bluefruit.h>

// BLE Serial Service UUID (using Nordic UART Service UUID)
#define SERIAL_SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define SERIAL_RX_UUID      "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define SERIAL_TX_UUID      "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

#define SER_BUFFER_SIZE 240

void setupSerialRelay();
void handleSerialRelay();

#endif