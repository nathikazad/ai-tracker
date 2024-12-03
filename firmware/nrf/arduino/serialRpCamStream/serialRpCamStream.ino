/*
  Multiple Serial test

  Receives from the main serial port, sends to the others.
  Receives from serial port 1, sends to the main serial (Serial 0).

  This example works only with boards with more than one serial like Arduino Mega, Due, Zero etc.

  The circuit:
  - any serial device attached to Serial port 1
  - Serial Monitor open on Serial port 0

  created 30 Dec 2008
  modified 20 May 2012
  by Tom Igoe & Jed Roach
  modified 27 Nov 2015
  by Arturo Guadalupi

  This example code is in the public domain.

  https://www.arduino.cc/en/Tutorial/BuiltInExamples/MultiSerialMega
*/

#include <bluefruit.h>

#define BUFFER_SIZE (160 * 120)  // Size of one frame
#define START_MARKER_SIZE 2
#define END_MARKER_SIZE 2

uint8_t buffer[BUFFER_SIZE];  // Buffer to store the frame
uint8_t startMarker[2];      // Buffer for start marker
uint8_t endMarker[2];        // Buffer for end marker
int bufferIndex = 0;
bool startFound = false;
bool collecting = false;

void setup() {
  Serial.begin(921600);   // USB Serial
  Serial1.begin(921600);  // Hardware Serial from RP2040
}

void loop() {
  while (Serial1.available()) {
    uint8_t inByte = Serial1.read();
    
    // Looking for start marker
    if (!startFound) {
      startMarker[0] = startMarker[1];  // Shift previous byte
      startMarker[1] = inByte;          // Store new byte
      
      if (startMarker[0] == 0xFF && startMarker[1] == 0xAA) {
        startFound = true;
        collecting = true;
        bufferIndex = 0;
        
        // Send start marker immediately
        Serial.write(0xFF);
        Serial.write(0xAA);
      }
      continue;
    }
    
    // Collecting frame data
    if (collecting) {
      buffer[bufferIndex++] = inByte;
      
      // Check if we've collected a full frame
      if (bufferIndex >= BUFFER_SIZE) {
        collecting = false;
        startFound = false;
        
        // Send the entire frame at once
        Serial.write(buffer, BUFFER_SIZE);
        
        // Now wait for end marker
        while (Serial1.available() < 2) {
          delay(1);  // Wait for end marker bytes to arrive
        }
        
        // Read and forward end marker
        uint8_t endMarker[2];
        endMarker[0] = Serial1.read();
        endMarker[1] = Serial1.read();
        Serial.write(endMarker, 2);
      }
    }
  }
}
