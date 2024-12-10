#include <bluefruit.h>

#define MAX_BUFFER_SIZE (320 * 320)
#define TX 0
#define RX 1

uint8_t buffer[MAX_BUFFER_SIZE];
uint8_t markerBuffer[4];  // To store the last 4 bytes for marker detection
int markerIndex = 0;
int bufferIndex = 0;
uint16_t expectedSize = 0;
uint16_t overflowSize = 0;
byte state = 0;  // 0=looking for start, 1=verifying start, 2=reading size1, 3=reading size2, 4=collecting data

void setup() {
    Serial.begin(921600);
    Serial1.begin(1000000);
}

bool isStartMarker() {
    return (markerBuffer[0] == 0xFF && markerBuffer[1] == 0xAA && 
            markerBuffer[2] == 0xFF && markerBuffer[3] == 0xAA);
}

bool isEndMarker() {
    return (markerBuffer[0] == 0xFF && markerBuffer[1] == 0xBB && 
            markerBuffer[2] == 0xFF && markerBuffer[3] == 0xBB);
}

void updateMarkerBuffer(uint8_t newByte) {
    // Shift existing bytes left
    for(int i = 0; i < 3; i++) {
        markerBuffer[i] = markerBuffer[i + 1];
    }
    // Add new byte
    markerBuffer[3] = newByte;
    markerIndex = (markerIndex + 1) % 4;
}

void loop() {
    while (Serial1.available()) {
        uint8_t inByte = Serial1.read();
        updateMarkerBuffer(inByte);

        switch(state) {
            case 0:  // Looking for start marker
                if (isStartMarker()) {
                    state = 2;  // Move to reading size
                    bufferIndex = 0;
                }
                break;

            case 2:  // First size byte
                expectedSize = inByte;
                state = 3;
                break;

            case 3:  // Second size byte
                expectedSize |= (inByte << 8);
                overflowSize = expectedSize + 20;
                Serial.print("Starting to receive ");
                Serial.print(expectedSize);
                Serial.print(" bytes");
                state = 4;
                break;

            case 4:  // Collecting data
                buffer[bufferIndex++] = inByte;
                
                if (isEndMarker()) {
                    Serial.print(", received ");
                    Serial.print(bufferIndex-6);
                    Serial.println(" bytes");
                    if (bufferIndex - 6 == expectedSize) {  // -4 because of double end marker
                      
                        // Process complete message here
                        // Serial.write(buffer, bufferIndex - 4);
                        // Serial.write(0xFF);
                        // Serial.write(0xBB);
                        // Serial.write(0xFF);
                        // Serial.write(0xBB);
                    }
                    state = 0;
                } else if (bufferIndex >= overflowSize) {
                    state = 0;
                }
                break;
        }
    }
}