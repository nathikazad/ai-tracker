
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
  // camera.startImageCaptureTask();
  bleTransmitter.startBleServer();
}

void loop() {

}

//modified this file to get ride of include error
// /Users/nathikazad/Library/Arduino15/packages/esp32/hardware/esp32/2.0.17/tools/sdk/esp32s3/include/xtensa/esp32s3/include/xtensa/config/core.h 