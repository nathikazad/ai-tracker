#include "MP3DecoderHelix.h"
#include "BabyElephantWalk60_mp3.h"

#include <I2S.h>
using namespace libhelix;

#define pBCLK 26
#define pWS 27
#define pDOUT 28
I2S i2s(OUTPUT);

const int sampleRate = 24000; // Adjust if needed

const int BUFFER_SIZE = 1024*128;  // Adjust based on your needs
uint8_t receiveBuffer[BUFFER_SIZE];
int bufferIndex = 0;

using namespace libhelix;

void dataCallback(MP3FrameInfo &info, int16_t *pcm_buffer, size_t len, void* ref) {
    for (size_t i = 0; i < len; i++) {
      int16_t sample = pcm_buffer[i];

      float adjusted = sample * 3.0;
      if (adjusted > 32767) adjusted = 32767;
      if (adjusted < -32768) adjusted = -32768;

      i2s.write((int16_t)adjusted);
      i2s.write((int16_t)adjusted);
    }
}
MP3DecoderHelix mp3(dataCallback);

void setup() {
    Serial.begin(921600);
    mp3.begin();

    Serial.println("Initializing...");

    // Initialize I2S
    i2s.setBCLK(pBCLK);
    i2s.setDATA(pDOUT);
    i2s.setBitsPerSample(16);
    if (!i2s.begin(sampleRate)) {
        Serial.println("Failed to initialize I2S!");
        while (1);
    }
}

void loop() {
  if (Serial.available() >= 2) {
    // Read batch size (2 bytes)
    uint16_t batchSize = (Serial.read() << 8) | Serial.read();
    
    // Read batch data
    bufferIndex = 0;
    while (bufferIndex < batchSize) {
      if (Serial.available()) {
        receiveBuffer[bufferIndex++] = Serial.read();
      }
    }
    
    // Process received frames
    if (bufferIndex > 0) {
      mp3.write(receiveBuffer, bufferIndex);
      
      // Send acknowledgment
      Serial.write('A');
      
      // Reset buffer
      bufferIndex = 0;
    }
  }
}