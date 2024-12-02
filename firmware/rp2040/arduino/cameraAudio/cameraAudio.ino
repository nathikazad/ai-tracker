#include "MP3DecoderHelix.h"
#include <I2S.h>
#include "pico/multicore.h"
#include "pico/sync.h"
#include "hm01b0.h"

using namespace libhelix;

// I2S pins
#define pBCLK 26
#define pWS 27
#define pDOUT 28

// Audio configurations
I2S i2s(OUTPUT);
const int sampleRate = 24000;
const int BUFFER_SIZE = 1024*32;

// Camera configuration
const struct hm01b0_config hm01b0_config = {
    .i2c = i2c_default,
    .sda_pin = PICO_DEFAULT_I2C_SDA_PIN,
    .scl_pin = PICO_DEFAULT_I2C_SCL_PIN,
    .vsync_pin = 6,
    .hsync_pin = 7,
    .pclk_pin = 8,
    .data_pin_base = 9,
    .data_bits = 1,
    .pio = pio0,
    .pio_sm = 0,
    .reset_pin = -1,
    .mclk_pin = -1,
    .width = 320,
    .height = 320,
};

// Shared buffers and variables
struct AudioBuffer {
    uint8_t data[BUFFER_SIZE];
    volatile int size;
    volatile bool ready;
};

AudioBuffer buffers[2];
volatile int currentBuffer = 0;
volatile bool processingDone = true;
uint8_t pixels[320 * 320];

// Audio callback function
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
        tight_loop_contents();
    }
}

void captureAndSendImage() {
    hm01b0_read_frame(pixels, sizeof(pixels));
    
    // Send start marker
    Serial1.write(0xFF);
    Serial1.write(0xAA);
    
    // Send pixel data
    Serial1.write(pixels, sizeof(pixels));
    
    // Send end marker
    Serial1.write(0xFF);
    Serial1.write(0xBB);
    Serial.print("Sent: ");
    Serial.println(sizeof(pixels)+4);
}

void setup() {
    Serial.begin(921600);
    Serial1.begin(1000000);
    while (!Serial);
    
    Serial.println("Initializing...");
    
    // Initialize I2S
    i2s.setBCLK(pBCLK);
    i2s.setDATA(pDOUT);
    i2s.setBitsPerSample(16);
    if (!i2s.begin(sampleRate)) {
        Serial.println("Failed to initialize I2S!");
        while (1);
    }
    
    // Initialize Camera
    Serial.println("Initializing Camera");
    if (hm01b0_init(&hm01b0_config) != 0) {
        Serial.println("Failed to initialize camera!");
        while (true) {}
    }
    Serial.println("Camera Initialized");
    
    // Initialize audio buffers
    buffers[0].ready = false;
    buffers[1].ready = false;
    
    // Launch core 1 for audio processing
    multicore_launch_core1(core1_entry);
}

void loop() {
    if (Serial1.available() > 0) {
        // Check first byte to determine if it's a camera command
        char firstByte = Serial1.peek();
        
        if (firstByte == 'c') {
            Serial1.read(); // consume the 'c'
            Serial.println("Image capture command received");
            captureAndSendImage();
            Serial.println("Image sent");
        }
        else if (Serial1.available() >= 2) {
            Serial.println("Receiving audio data");
            
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
            Serial.println("Received audio data, sending ack");
            
            // Send acknowledgment
            Serial1.write('A');
        }
    }
}