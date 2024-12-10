// com.cpp
#include "com.h"
#include "ble.h"

static uint8_t buffer[FRAME_SIZE];
static uint16_t bufferIndex = 0;
static bool startFound = false;
static uint8_t lastByte = 0;

void setupCom() {
    Serial1.begin(460800);
}

void processIncomingData() {
    while (Serial1.available()) {
        uint8_t inByte = Serial1.read();
        
        if (!startFound) {
            if (lastByte == 0xFF && inByte == 0xAA) {
                startFound = true;
                Serial.println("Start received");
                bufferIndex = 0;
            }
            lastByte = inByte;
            continue;
        }
        
        buffer[bufferIndex++] = inByte;
        Serial.println("Receiving all bytes");
        
        while (bufferIndex < FRAME_SIZE) {
            if (Serial1.available()) {
                buffer[bufferIndex++] = Serial1.read();
            }
        }

        Serial.print("Received ");
        Serial.print(bufferIndex);
        Serial.println(" bytes");
        
        if (bufferIndex >= FRAME_SIZE) {
            Serial.println("Sending!");
            sendBufferInPackets();
            
            startFound = false;
            bufferIndex = 0;
            lastByte = 0;
            Serial.println("Sent!");
        } else {
            Serial.println("Not received the correct number of bytes to send");
        }
    }
}

void sendBufferInPackets() {
    if (!isConnected() || !serialTxCharacteristic.notifyEnabled()) {
        return;
    }
    
    uint16_t numPackets = (FRAME_SIZE + PACKET_DATA_SIZE - 1) / PACKET_DATA_SIZE;
    
    sendHandshake(FRAME_SIZE, numPackets, FRAME_WIDTH, FRAME_HEIGHT);
    
    for (uint16_t i = 0; i < numPackets; i++) {
        uint16_t offset = i * PACKET_DATA_SIZE;
        uint16_t remainingBytes = FRAME_SIZE - offset;
        uint16_t packetDataSize = min(remainingBytes, PACKET_DATA_SIZE);
        
        sendPacket(i, &buffer[offset], packetDataSize);
        delay(1);
    }
}