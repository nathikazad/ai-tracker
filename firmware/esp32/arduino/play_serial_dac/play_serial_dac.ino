#include "Adafruit_AD569x.h"

Adafruit_AD569x ad5693; // Create an object of the AD5693 library

const uint16_t START_MARKER = 0xFFFF;
const uint16_t STOP_MARKER = 0xFFFE;

unsigned long startTime = 0;
unsigned long sampleCount = 0;

enum State {
  WAITING,
  PLAYING
};

State currentState = WAITING;

void setup() {
  Serial.begin(115200);
  while (!Serial) delay(10); // Wait for serial port to start
  Serial.println("Adafruit AD5693 Serial Playback with Timing and State Machine");

  // Initialize the AD5693 chip
  if (ad5693.begin(0x4C, &Wire)) { // If A0 jumper is set high, use 0x4E
    Serial.println("AD5693 initialization successful!");
  } else {
    Serial.println("Failed to initialize AD5693. Please check your connections.");
    while (1) delay(10); // Halt
  }

  // Reset the DAC
  ad5693.reset();

  // Configure the DAC for normal mode, internal reference, and no 2x gain
  if (ad5693.setMode(NORMAL_MODE, true, false)) {
    Serial.println("AD5693 configured");
  } else {
    Serial.println("Failed to configure AD5693.");
    while (1) delay(10); // Halt
  }

  // Set the I2C clock rate to 800KHz for faster communication
  Wire.setClock(800000);
  Serial.println("Ready to receive data from serial");
}

void loop() {
  if (Serial.available() >= 2) {
    // Read two bytes from serial
    uint8_t msb = Serial.read();
    uint8_t lsb = Serial.read();
    // Combine the two bytes into a 16-bit value
    uint16_t value = (msb << 8) | lsb;

    switch (currentState) {
      case WAITING:
        if (value == START_MARKER) {
          startTime = millis();
          sampleCount = 0;
          currentState = PLAYING;
          // Serial.println("Playback started");
        }
        break;

      case PLAYING:
        if (value == STOP_MARKER) {
          unsigned long duration = millis() - startTime;
          currentState = WAITING;
          
          Serial.println("Playback stopped");
          delay(1000);
          Serial.print("Duration: ");
          Serial.print(duration);
          Serial.println(" ms");
          delay(1000);
          Serial.print("Samples played: ");
          Serial.println(sampleCount);
          Serial.print("Average sample rate: ");
          Serial.print((float)sampleCount);
          Serial.println(" Hz");
        } else {
          // Write the value to the DAC
          if (!ad5693.writeUpdateDAC(value)) {
            Serial.println("Failed to update DAC.");
          }
          sampleCount++;
        }
        break;
    }
  }
}