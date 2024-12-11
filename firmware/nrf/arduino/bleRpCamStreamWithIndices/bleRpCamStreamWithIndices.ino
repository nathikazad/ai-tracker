// main.ino
#include "ble.h"
#include "com.h"

void setup() {
    Serial.begin(115200);
    while(!Serial);
    setupCom();
    Serial.println("Comms Initialized");
    setupBLE();
    Serial.println("BLE Initialized");
}

void loop() {
    processIncomingData();
}