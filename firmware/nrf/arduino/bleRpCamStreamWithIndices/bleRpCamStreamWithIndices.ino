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
  int startTime = millis();
  Serial1.write('c');
  processIncomingData();
  Serial.printf("Captured and sent in %d ms\n", millis()-startTime);
  // delay(500);
}