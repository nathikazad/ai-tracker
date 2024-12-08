#include <bluefruit.h>

#define FRAME_WIDTH 160
#define FRAME_HEIGHT 120
#define FRAME_SIZE (FRAME_WIDTH * FRAME_HEIGHT)
#define PACKET_SIZE 240
#define PACKET_HEADER_SIZE 2
#define PACKET_DATA_SIZE (PACKET_SIZE - PACKET_HEADER_SIZE)
#define NUM_PACKETS ((FRAME_SIZE + PACKET_DATA_SIZE - 1) / PACKET_DATA_SIZE)

uint8_t buffer[FRAME_SIZE];
uint16_t bufferIndex = 0;
bool startFound = false;
uint8_t lastByte = 0;  // To store the previous byte for start marker detection

void setup() {
    Serial.begin(921600);  // USB Serial
    Serial1.begin(921600); // Hardware Serial from RP2040
}

void sendHandshake() {
    uint32_t totalBytes = FRAME_SIZE;
    uint16_t numPackets = NUM_PACKETS;
    uint16_t width = FRAME_WIDTH;
    uint16_t height = FRAME_HEIGHT;
    
    Serial.write(0xFF);
    Serial.write(0xAA);
    Serial.write((uint8_t*)&totalBytes, 4);
    Serial.write((uint8_t*)&numPackets, 2);
    Serial.write((uint8_t*)&width, 2);
    Serial.write((uint8_t*)&height, 2);
    Serial.write(0xFF);
    Serial.write(0xBB);
}

void sendPacket(uint16_t packetNum, uint8_t* data, uint16_t dataSize) {
    uint16_t pktNum = packetNum;
    Serial.write((uint8_t*)&pktNum, 2);
    Serial.write(data, dataSize);
}

void sendBufferInPackets() {
    // Send handshake first
    sendHandshake();
    
    // Send data packets
    for (uint16_t i = 0; i < NUM_PACKETS; i++) {
        uint16_t offset = i * PACKET_DATA_SIZE;
        uint16_t remainingBytes = FRAME_SIZE - offset;
        uint16_t packetDataSize = min(remainingBytes, PACKET_DATA_SIZE);
        
        sendPacket(i, &buffer[offset], packetDataSize);
        delay(1);  // Small delay to prevent overwhelming the receiver
    }
}

void loop() {
    while (Serial1.available()) {
        uint8_t inByte = Serial1.read();
        
        // Looking for start marker (0xFF 0xAA)
        if (!startFound) {
            if (lastByte == 0xFF && inByte == 0xAA) {
                startFound = true;
                bufferIndex = 0;
            }
            lastByte = inByte;
            continue;
        }
        
        // If we're here, we've found the start marker and are collecting data
        buffer[bufferIndex++] = inByte;
        
        // Check if we've filled the buffer
        if (bufferIndex >= FRAME_SIZE) {
            sendBufferInPackets();

            // Reset for next frame
            startFound = false;
            bufferIndex = 0;
            lastByte = 0;
        }
    }
}