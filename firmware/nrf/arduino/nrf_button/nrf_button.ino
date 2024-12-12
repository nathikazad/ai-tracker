#include "ble_config.h"
#include "audio_handler.h"
#include <bluefruit.h>
#include <PDM.h>

// Button configuration
#define BUTTON_PIN D0

// Button state variables
int buttonState = 0;
int lastButtonState = 0;

void setup() {
  Serial.begin(9600);
  while (!Serial);

  // Initialize button pin
  pinMode(BUTTON_PIN, INPUT);

  setupAudio();
  setupBle();
  Serial.println("Button Controlled Audio Sender Ready");
}

void loop() {
  buttonState = digitalRead(BUTTON_PIN);

  if (buttonState != lastButtonState) {
    if (buttonState == LOW) {
      Serial.println("Button pressed - Starting recording");
      Serial.print("Counter: ");
      Serial.println(getCounter());
      startRecording();
    } else {
      Serial.println("Button released - Stopping recording and sending data");
      Serial.print("Recording size: ");
      Serial.println(getWriteIndex());
      stopRecording();
      
      if (Bluefruit.connected() && isConnected()) {
        compressAndSendAudio();
      }
    }
    delay(50); // Debounce delay
  }

  lastButtonState = buttonState;
}