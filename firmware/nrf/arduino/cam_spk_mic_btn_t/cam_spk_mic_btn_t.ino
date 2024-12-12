// main.ino
#include "ble.h"
#include "cam.h"
#include "mic.h"
#include "state.h"


#define LISTEN_BUTTON_PIN D0
#define RP_SWITCH_PIN D5

MainState mainState = READY;
int lastImageCaptureTime = 0;
int audioReceiveStartTime = 0;
int buttonState;

void setup() {
    Serial.begin(115200);
    // while(!Serial);

    pinMode(RP_SWITCH_PIN, OUTPUT);
    digitalWrite(RP_SWITCH_PIN, HIGH);
    delay(1000);
    digitalWrite(RP_SWITCH_PIN, LOW);

    pinMode(LISTEN_BUTTON_PIN, INPUT);
    setupAudio();
    Serial.println("Mic Initialized");
    setupBLE();
    Serial.println("BLE Initialized");
    Serial1.begin(1000000);
    while(!Serial1);
    Serial.println("RP2040 Comms Initialized");
}

void loop() {
  switch(mainState) {
    case READY: // Looking for start marker
      buttonState = digitalRead(LISTEN_BUTTON_PIN);
      if (buttonState == LOW) {
        mainState = RECORDING_AUDIO;
        Serial.println("Button pressed - Starting recording");
        startRecording();
      } else {
        if((millis() - lastImageCaptureTime) > IMAGE_CAPTURE_PERIOD) {
          Serial1.write('c');
          receiveCameraImage();
          lastImageCaptureTime = millis();
        }
      }
      break;
    case RECORDING_AUDIO:
      buttonState = digitalRead(LISTEN_BUTTON_PIN);
      if (buttonState == HIGH) {
        Serial.println("Button released - Stopping recording and sending data");
        Serial.print("Recording size: ");
        Serial.println(getWriteIndex());
        stopRecording();
        
        if (Bluefruit.connected() && isConnected()) {
          compressAndSendAudio();
        }
        Serial.println("Audio sent, waiting for response");
        mainState = READY;
      }
      break;
    case RECEIVING_AUDIO:
      if((millis() - audioReceiveStartTime) > AUDIO_RECEIVE_TIMEOUT) {
        Serial.println("Timed out waiting for audio");
        mainState = READY;
      }
      break;
    case CAPTURING_IMAGE:
      if(false) {

      }
      break;
  }
  delay(5);
}

void receiveAudio(uint8_t* data, uint16_t len) {
  if (mainState = RECEIVING_AUDIO) {
    Serial1.write(data, len);
  }
}