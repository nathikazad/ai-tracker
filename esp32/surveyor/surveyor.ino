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

  if (!bleTransmitter.begin()) {
    Serial.println("Failed to initialize BLE Transmitter!");
    while (1);
  }

  Serial.println("Setup complete. Starting recording, image capture and BLE server tasks.");
//   recorder.startRecordingTask();
  camera.startImageCaptureTask();
  bleTransmitter.startBleServer();
}

void loop() {

}