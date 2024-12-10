// com.cpp
#include "com.h"
#include "ble.h"

static uint8_t buffer[MAX_FRAME_SIZE];
static uint32_t bufferIndex = 0;
static uint16_t chunkNumber = 0;
static uint16_t indexInChunk = 0;

uint8_t markerBuffer[4];  // To store the last 4 bytes for marker detection
int markerIndex = 0;
static uint32_t expectedBytes = 0;
static uint32_t overflowSize = 0;
byte state = 0;  // 0=looking for start, 1=reading size, 2=collecting data
int startMarkerReceivedTime = 0;


void setupCom() {
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

bool isChunkMarker() {
    return (markerBuffer[0] == 0xFF && markerBuffer[1] == 0xCC &&
            markerBuffer[2] == 0xFF && markerBuffer[3] == 0xCC);
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

void processIncomingData() {
    while (Serial1.available()) {
        uint8_t inByte = Serial1.read();
        updateMarkerBuffer(inByte);
        
        switch(state) {
            case 0: // Looking for start marker
                if (isStartMarker()) {
                    Serial.println("Start marker received");
                    state = 1;
                    bufferIndex = 0;
                    chunkNumber = 0;
                    indexInChunk = 0;
                    expectedBytes = 0;
                    startMarkerReceivedTime = millis();
                }
                break;
                
            case 1: // First size byte
                expectedBytes |= (inByte << (8*bufferIndex));
                // Serial.printf("Expected bytes: 0x%08lX\n", expectedBytes); 
                bufferIndex++;
                if(bufferIndex == 3) {
                  overflowSize = expectedBytes + 20;
                  Serial.print("Starting to receive ");
                  Serial.print(expectedBytes);
                  Serial.println(" bytes");
                  bufferIndex = 0;
                  state = 2;
                }
                break;
            case 2: // Collecting data
                if (isChunkMarker()) {
                    // Don't store marker bytes in buffer
                    bufferIndex -= 4;  // Remove marker bytes if they got in
                    bufferIndex -= (indexInChunk - 4);  // Remove incomplete chunk
                    indexInChunk = 0;
                } else {
                  buffer[bufferIndex++] = inByte;
                  indexInChunk++;
                  
                  if (bufferIndex == expectedBytes) {
                    Serial1.write(0xAC);
                    Serial.printf("Received %d bytes\n", bufferIndex);
                    sendBufferInPackets();
                    state = 0;
                  } else if (indexInChunk == CHUNK_SIZE) {
                    Serial1.write(0xAC);
                    // Serial.printf("Received chunk: %d, bufferIndex: %d, expected bytes: %d, expected chunks: %d\n", chunkNumber, bufferIndex, expectedBytes, expectedBytes/CHUNK_SIZE);
                    indexInChunk = 0;
                    chunkNumber++;
                    if ((millis() - startMarkerReceivedTime) > RECEIVE_TIMEOUT) {
                      Serial.println("Timed out 2");
                      state = 0;
                    }
                  }  
                }
                break;
        }
    }

    if(state != 0 && (millis() - startMarkerReceivedTime) > RECEIVE_TIMEOUT) {
      Serial.println("Timed out 1");
      state = 0;
    }
}

void sendBufferInPackets() {
  if (!isConnected() || !serialTxCharacteristic.notifyEnabled()) {
    return;
  }
  
  uint16_t numPackets = (expectedBytes + PACKET_DATA_SIZE - 1) / PACKET_DATA_SIZE;
  
  sendHandshake(expectedBytes, numPackets, IMAGE_WIDTH, IMAGE_HEIGHT);
  
  for (uint16_t i = 0; i < numPackets; i++) {
    uint16_t offset = i * PACKET_DATA_SIZE;
    uint16_t remainingBytes = expectedBytes - offset;
    uint16_t packetDataSize = min(remainingBytes, PACKET_DATA_SIZE);
    
    sendPacket(i, &buffer[offset], packetDataSize);
    delay(1);
  }
}