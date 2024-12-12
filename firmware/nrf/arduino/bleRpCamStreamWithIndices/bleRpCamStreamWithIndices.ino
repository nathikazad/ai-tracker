// main.ino
#include "ble.h"
#include "com.h"

void setup() {
    Serial.begin(115200);
    while(!Serial);
    
    setupBLE();
    Serial.println("BLE Initialized");
    Serial1.begin(1000000);
    while(!Serial1);
    Serial.println("Comms Initialized");
}

void loop() {
  Serial1.write('c');
  processIncomingData();
  delay(10000);
}