#include "ble_serial.h"

BLEService serialService(SERIAL_SERVICE_UUID);
BLECharacteristic serialRxCharacteristic(SERIAL_RX_UUID, BLEWrite | BLEWriteWithoutResponse, SER_BUFFER_SIZE);
BLECharacteristic serialTxCharacteristic(SERIAL_TX_UUID, BLENotify, SER_BUFFER_SIZE);

static uint8_t serialBuffer[SER_BUFFER_SIZE];
static bool newSerialData = false;

// Callback for when central writes to RX characteristic
void serial_rx_callback(uint16_t conn_hdl, BLECharacteristic* chr, uint8_t* data, uint16_t len) {
  // Forward received data to Serial1
  Serial1.write(data, len);
}

void setupSerialRelay() {
  // Setup Serial1 for hardware UART
  Serial1.begin(921600);
  
  // Configure the Serial service
  serialService.begin();

  // Configure RX characteristic
  serialRxCharacteristic.setWriteCallback(serial_rx_callback);
  serialRxCharacteristic.begin();

  // Configure TX characteristic
  serialTxCharacteristic.begin();

  // Add service to advertising packet
  Bluefruit.Advertising.addService(serialService);
}

void handleSerialRelay() {
  // Check if there's data available from Serial1
  if (Serial1.available()) {
    uint16_t len = 0;
    
    // Read up to buffer size or available data
    while (Serial1.available() && len < SER_BUFFER_SIZE) {
      serialBuffer[len++] = Serial1.read();
    }

    // If connected and subscribed, send the data
    if (Bluefruit.connected() && serialTxCharacteristic.notifyEnabled()) {
      serialTxCharacteristic.notify(serialBuffer, len);
    }
  }
}