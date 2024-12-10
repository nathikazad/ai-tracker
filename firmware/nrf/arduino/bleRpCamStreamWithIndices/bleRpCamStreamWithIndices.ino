// main.ino
#include "ble.h"
#include "com.h"

void setup() {
    Serial.begin(115200);
    setupCom();
    setupBLE();
}

void loop() {
    processIncomingData();
}