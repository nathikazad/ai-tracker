#include "MP3DecoderHelix.h"
#include <I2S.h>
#include "pico/multicore.h"
#include "pico/sync.h"

using namespace libhelix;

#define pBCLK 16
#define pWS 17
#define pDOUT 18

I2S i2s(OUTPUT);
const int sampleRate = 24000; // Adjust if needed
const int BUFFER_SIZE = 1024*64; // Adjust based on your needs

// Dual buffers for ping-pong operation
struct AudioBuffer {
    uint8_t data[BUFFER_SIZE];
    volatile int size;
    volatile bool ready;
};

AudioBuffer buffers[2];
volatile int currentBuffer = 0;
volatile bool processingDone = true;

using namespace libhelix;

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

MP3DecoderHelix mp3(dataCallback);

// Core 1 function: handle MP3 decoding and playback
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
        tight_loop_contents(); // Prevent core from overheating
    }
}

void setup() {
    Serial.begin(115200);
    // while (!Serial);
    Serial1.begin(921600);
    pinMode(15, OUTPUT);
    digitalWrite(15, HIGH);
    pinMode(8, OUTPUT);
    digitalWrite(8, HIGH);
    Serial.println("Initializing...");
    
    // Initialize I2S
    i2s.setBCLK(pBCLK);
    i2s.setDATA(pDOUT);
    i2s.setBitsPerSample(16);
    if (!i2s.begin(sampleRate)) {
        Serial.println("Failed to initialize I2S!");
        while (1);
    }
    
    // Initialize buffers
    buffers[0].ready = false;
    buffers[1].ready = false;
    
    // Launch core 1
    multicore_launch_core1(core1_entry);
    Serial.println("Initialized");
}

void loop() {
    if (Serial1.available() >= 2) {
      digitalWrite(8, LOW);
        Serial.println("Receiving");
        // Read batch size (2 bytes)
        uint16_t batchSize = (Serial1.read() << 8) | Serial1.read();
        
        // Find available buffer
        int bufferIndex = currentBuffer;
        int dataIndex = 0;
        
        // Wait if both buffers are full
        while (!processingDone && buffers[bufferIndex].ready) {
            tight_loop_contents();
        }
        
        // Read batch data
        while (dataIndex < batchSize) {
            if (Serial1.available()) {
                buffers[bufferIndex].data[dataIndex++] = Serial1.read();
            }
        }
        
        // Mark buffer as ready for processing
        buffers[bufferIndex].size = batchSize;
        buffers[bufferIndex].ready = true;
        processingDone = false;
        
        // Switch to other buffer
        currentBuffer = (currentBuffer + 1) % 2;
        Serial.println("Received, sending ack now");
        // Send acknowledgment
        Serial1.write('A');
        digitalWrite(8, LOW);
    }
}