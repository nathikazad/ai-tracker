// main.cpp
#include <Arduino.h>
#include "WavRecorder.h"
#include "SDCard.h"

SDCard sdCard;
WavRecorder recorder(sdCard);

void setup() {
  Serial.begin(115200);
  while (!Serial);

  if (!sdCard.begin(21)) {
    Serial.println("Failed to initialize SD card!");
    while (1);
  }

  if (!recorder.begin()) {
    Serial.println("Failed to initialize recorder!");
    while (1);
  }

  Serial.println("Setup complete. Starting recording task.");
  recorder.startRecordingTask();
}

void loop() {
  // Your main loop code here
  Serial.println("Main loop running...");
  delay(5000);  // Just a placeholder delay
}
// WavUtil.h and WavUtil.cpp remain unchanged