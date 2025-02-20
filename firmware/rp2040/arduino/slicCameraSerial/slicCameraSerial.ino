#include "config.h"
#include "cam.h"

void setup() {
  Serial.begin(921600);
  pinMode(LED, OUTPUT);
  digitalWrite(LED, HIGH);
  // while(!Serial);
  setupCamera();
  Serial1.begin(NRF_BAUD_RATE);
  while(!Serial1);
  Serial.println("Serial1 Initialized");
  delay(5000);
  digitalWrite(LED, LOW);
}

void loop() {
  if(Serial1.available()) {
    char c = Serial1.read();
    if(c == 'c') {
      Serial.printf("Received capture command\n", c);
      sendImage();
    }
  }
  delay(10); 
}

