#include <Arduino.h>
#include "WavRecorder.h"
#include "SDCard.h"
#include "Camera.h"
#include "BLETransmitter.h"

SDCard sdCard;
WavRecorder recorder(sdCard);
Camera camera(sdCard);
BLETransmitter bleTransmitter(sdCard);

void setup() {
  Serial.begin(921600);
  while (!Serial);

  if (!sdCard.begin(21)) {
    Serial.println("Failed to initialize SD card!");
    while (1);
  }

//   if (!recorder.begin()) {
//     Serial.println("Failed to initialize recorder!");
//     while (1);
//   }

  if (!camera.begin()) {
    Serial.println("Failed to initialize camera!");
    while (1);
  }

  Serial.println("Setup complete. Starting recording and image capture tasks.");
//   recorder.startRecordingTask();
  camera.startImageCaptureTask();
  bleTransmitter.begin();
}

void loop() {
  // Your main loop code here
  Serial.println("Main loop running...v1");
  delay(10000);  // Just a placeholder delay

}