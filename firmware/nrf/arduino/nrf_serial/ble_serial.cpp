#include "Adafruit_USBD_CDC.h"
#include "ble_serial.h"

BLEService serialService(SERIAL_SERVICE_UUID);
BLECharacteristic serialRxCharacteristic(SERIAL_RX_UUID, BLEWrite | BLEWriteWithoutResponse, MTU);
BLECharacteristic serialTxCharacteristic(SERIAL_TX_UUID, BLENotify, MTU);

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
// uint16_t len = 0;
// uint16_t bytesRead = 0;
// void handleSerialRelay() {
//   // Check if there's data available from Serial1
//   uint16_t available = Serial1.available();
//   uint16_t readThisTime = 0;
//     // Read up to buffer size or available data
//   while (available > 0 && bytesRead < SER_BUFFER_SIZE) {
//     uint16_t actuallyRead = Serial1.readBytes(&serialBuffer[bytesRead], available);
//     bytesRead += actuallyRead;
//     readThisTime += actuallyRead;
//     available = Serial1.available();
//   }
//   if(readThisTime > 0) {
//     Serial.print(readThisTime);
//     Serial.print(" ");
//     Serial.println(bytesRead);
//   }


//   // If connected and subscribed, send the data
//   // if (Bluefruit.connected() && serialTxCharacteristic.notifyEnabled()) {
//   //   // serialTxCharacteristic.notify(serialBuffer, len);

//   //   const uint16_t CHUNK_SIZE = MTU;  // MTU size
//   //   uint16_t sent = 0;
//   //   while (sent < len) {
//   //     // Calculate size of next chunk
//   //     uint16_t chunk_size = min(CHUNK_SIZE, len - sent);
      
//   //     // Send chunk
//   //     serialTxCharacteristic.notify(serialBuffer + sent, chunk_size);
      
//   //     // Update sent counter
//   //     sent += chunk_size;
      
//   //     // Small delay to prevent overwhelming the BLE stack
//   //     delay(1);
//   //   }
//   // }
// }