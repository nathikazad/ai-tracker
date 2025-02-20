#include "Adafruit_USBD_CDC.h"
// com.cpp
#include "cam.h"
#include "ble.h"

static uint8_t buffer[MAX_FRAME_SIZE+100];
static uint32_t bufferIndex = 0;
static uint16_t chunkNumber = 0;
static uint16_t indexInChunk = 0;

uint8_t markerBuffer[4];  // To store the last 4 bytes for marker detection
int markerIndex = 0;
static uint32_t expectedBytes = 0;
static uint32_t overflowSize = 0;
CamReceptionState camState = IDLE;
int lastDataReceivedTime = 0;

bool isStartMarker() {
  return (markerBuffer[0] == 0xFF && markerBuffer[1] == 0xAA && 
          markerBuffer[2] == 0xFF && markerBuffer[3] == 0xAA);
}

bool isEndMarker() {
  return (markerBuffer[0] == 0xFF && markerBuffer[1] == 0xBB && 
          markerBuffer[2] == 0xFF && markerBuffer[3] == 0xBB);
}

bool isChunkStartMarker() {
  return (markerBuffer[0] == 0xFF && markerBuffer[1] == 0xCC &&
          markerBuffer[2] == 0xFF && markerBuffer[3] == 0xCC);
}

bool isChunkEndMarker() {
  return (markerBuffer[0] == 0xFF && markerBuffer[1] == 0xDD &&
          markerBuffer[2] == 0xFF && markerBuffer[3] == 0xDD);
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

void receiveCameraImage() {
  bufferIndex = 0;
  chunkNumber = 0;
  indexInChunk = 0;
  expectedBytes = 0;
  lastDataReceivedTime = millis();
  camState = WAITING_FOR_START;
  while(camState != IDLE) {
    while (Serial1.available()) {
      uint8_t inByte = Serial1.read();
      lastDataReceivedTime = millis();
      updateMarkerBuffer(inByte);
      
      switch(camState) {
        case WAITING_FOR_START: // Looking for start marker
          if (isStartMarker()) {
            camState = RECEIVING_SIZE;
          }
          break;
            
        case RECEIVING_SIZE: // First size byte
          expectedBytes |= (inByte << (8*bufferIndex));
          // Serial.printf("Expected bytes: 0x%08lX\n", expectedBytes); 
          bufferIndex++;
          if(bufferIndex == 3) {
            overflowSize = expectedBytes + 20;
            Serial.printf("Starting to receive %d bytes\n", expectedBytes);
            bufferIndex = 0;
            camState = RECEIVING_CHUNKS;
          }
          break;
        case RECEIVING_CHUNKS: // Collecting data
          if (isChunkStartMarker()) {
              // Serial.printf("Receiving chunk: %d, last index in chunk:%d \n", chunkNumber, indexInChunk);
              // Don't store marker bytes in buffer
            bufferIndex -= 4;  // Remove marker bytes if they got in
            bufferIndex -= indexInChunk - 4;  // Remove incomplete chunk
            // Serial.printf("Chunk %d, bufferIndex: %d, indexInChunk %d \n", chunkNumber, bufferIndex, indexInChunk);
            indexInChunk = 0;
          } else {
            buffer[bufferIndex++] = inByte;
            indexInChunk++;
            
            if (bufferIndex == expectedBytes+4 && isChunkEndMarker()) {
              bufferIndex -= 4;
              Serial1.write(0xAC);
              Serial.printf("Received %d bytes\n", bufferIndex);
              // for (size_t i = 0; i < expectedBytes; i++) {
              //   if(buffer[i] != (uint8_t)i) {
              //     Serial.printf("Expected %02X, Actual %02X, Difference:%02X @ %d Chunk: %d\n", buffer[i], (uint8_t)i, buffer[i]-i, i, i/CHUNK_SIZE);
              //     break;
              //   }
              // }
              
              sendBufferInPackets();
              uint32_t checksum = fletcher32(buffer, expectedBytes);
              Serial.printf("Fletcher-32 checksum: 0x%08X\n", checksum);
              camState = IDLE;
            } else if (indexInChunk == CHUNK_SIZE+4 && isChunkEndMarker()) {
              bufferIndex -= 4;
              Serial1.write(0xAC);
              // Serial.printf("Received chunk: %d \n", chunkNumber);
              // Serial.printf("Received chunk: %d, bufferIndex: %d, expected bytes: %d, expected chunks: %d\n", chunkNumber, bufferIndex, expectedBytes, expectedBytes/CHUNK_SIZE);
              indexInChunk = 0;
              chunkNumber++;
            }  
          }
          break;
      }
    }

    if((millis() - lastDataReceivedTime) > RECEIVE_TIMEOUT) {
      Serial.printf("Chunk Number: %d, Index in chunk: %d\n", chunkNumber, indexInChunk);
      Serial.println("Timed out 1");
      camState = IDLE;
    }
  }
}



void sendBufferInPackets() {
  if (!isConnected()) {// || !serialTxCharacteristic.notifyEnabled()) {
    return;
  }
  
  uint16_t numPackets = (expectedBytes + PACKET_DATA_SIZE - 1) / PACKET_DATA_SIZE;
  Serial.printf("Sending %d packets\n", numPackets);
  int startTime = millis();
  sendHandshake(expectedBytes, numPackets, IMAGE_WIDTH, IMAGE_HEIGHT);
  
  for (uint16_t pktNum = 0; pktNum < numPackets; pktNum++) {
    uint32_t offset = pktNum * PACKET_DATA_SIZE;
    uint32_t remainingBytes = expectedBytes - offset;
    uint32_t packetDataSize = min(remainingBytes, PACKET_DATA_SIZE);

    sendPacket(pktNum, &buffer[offset], packetDataSize);
    
    delay(1);
  }
  Serial.printf("Sent in %dms\n", millis()-startTime);
}