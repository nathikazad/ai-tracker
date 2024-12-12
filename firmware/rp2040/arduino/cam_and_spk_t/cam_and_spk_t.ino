#include "config.h"
#include "cam.h"
#include "speaker.h"

void setup() {
  Serial.begin(921600);
  while(!Serial);

  pinMode(LED, OUTPUT);
  digitalWrite(LED, HIGH);
  // while(!Serial);
  setupCamera();

  setupSpeaker();

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
      Serial.println("Received capture command");
      sendImage();
    } else if(c == 's') {
      Serial.println("Received Audio play command");
      playAudio();
    }
  }
  delay(10); 
}

