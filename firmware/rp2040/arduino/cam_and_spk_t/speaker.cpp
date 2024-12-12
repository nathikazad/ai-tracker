#include "speaker.h"

using namespace libhelix;
I2S i2s(OUTPUT);

struct AudioBuffer {
    uint8_t data[AUDIO_BUFFER_SIZE];
    volatile int size;
    volatile bool ready;
};

AudioBuffer buffers[2];
volatile int currentBuffer = 0;
volatile bool processingDone = true;

extern void core1_entry();
extern void dataCallback(MP3FrameInfo &info, int16_t *pcm_buffer, size_t len, void* ref);
MP3DecoderHelix mp3(dataCallback);


void setupSpeaker() {
    i2s.setBCLK(pBCLK);
    i2s.setDATA(pDOUT);
    i2s.setBitsPerSample(16);
    if (!i2s.begin(SAMPLE_RATE)) {
        Serial.println("Failed to initialize I2S!");
        while (1);
    }

    // Initialize audio buffers
    buffers[0].ready = false;
    buffers[1].ready = false;

    // Launch core 1 for audio processing
    multicore_launch_core1(core1_entry);
    Serial.println("Speaker Initialized");
}

void dataCallback(MP3FrameInfo &info, int16_t *pcm_buffer, size_t len, void* ref) {
    for (size_t i = 0; i < len; i++) {
        int16_t sample = pcm_buffer[i];
        float adjusted = sample * 8.0;
        if (adjusted > 32767) adjusted = 32767;
        if (adjusted < -32768) adjusted = -32768;
        i2s.write((int16_t)adjusted);
        i2s.write((int16_t)adjusted);
    }
}

void core1_entry() {
  mp3.begin();
  while (true) {
    for (int i = 0; i < 2; i++) {
      if (buffers[i].ready) {
        mp3.write(buffers[i].data, buffers[i].size);
        buffers[i].ready = false;
        processingDone = true;
      }
    }
    tight_loop_contents();
  }
}

void playAudio() {
    digitalWrite(LED, LOW);
    Serial.println("Receiving");
    
    uint16_t batchSize = (Serial1.read() << 8) | Serial1.read();
    int bufferIndex = currentBuffer;
    int dataIndex = 0;
    
    while (!processingDone && buffers[bufferIndex].ready) {
        tight_loop_contents();
    }
    
    while (dataIndex < batchSize) {
        if (Serial1.available()) {
            buffers[bufferIndex].data[dataIndex++] = Serial1.read();
        }
    }
    
    buffers[bufferIndex].size = batchSize;
    buffers[bufferIndex].ready = true;
    processingDone = false;
    currentBuffer = (currentBuffer + 1) % 2;
    
    Serial.println("Received, sending ack now");
    Serial1.write('A');
    digitalWrite(LED, HIGH);
}