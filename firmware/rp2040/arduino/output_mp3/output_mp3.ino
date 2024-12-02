#include "MP3DecoderHelix.h"
#include "BabyElephantWalk60_mp3.h"
#include <I2S.h>
#include "pico/multicore.h"
#include "pico/sync.h"

using namespace libhelix;

// Define I2S pins
#define pBCLK 16
#define pWS 17
#define pDOUT 18

MP3DecoderHelix mp3;
I2S i2s(OUTPUT);

const int sampleRate = 44100; // Adjust if needed
const int bufferSize = 1024;
int16_t buffer[bufferSize];
int bufferIndex = 0;

// Volume adjustment factor (starting at 1.0 for original volume)
volatile float volumeFactor = 1.0;

// Mutex for thread-safe access to volumeFactor
mutex_t volumeMutex;

// Function to adjust volume
int16_t adjustVolume(int16_t sample) {
    float factor;
    mutex_enter_blocking(&volumeMutex);
    factor = volumeFactor;
    mutex_exit(&volumeMutex);
    
    float adjusted = sample * factor;
    // Clamp the value to prevent overflow
    if (adjusted > 32767) return 32767;
    if (adjusted < -32768) return -32768;
    return (int16_t)adjusted;
}

void dataCallback(MP3FrameInfo &info, int16_t *pcm_buffer, size_t len, void* ref) {
    for (size_t i = 0; i < len; i++) {
        buffer[bufferIndex++] = adjustVolume(pcm_buffer[i]);
        if (bufferIndex >= bufferSize) {
            // Buffer is full, write to I2S
            for (int j = 0; j < bufferSize; j++) {
                i2s.write(buffer[j]);
                i2s.write(buffer[j]); // Write twice for stereo
            }
            bufferIndex = 0;
        }
    }
}

// Core 1 task: MP3 playback
void core1_main() {
    while (1) {
        mp3.write(BabyElephantWalk60_mp3, BabyElephantWalk60_mp3_len);
        mp3.begin(); // Reset decoder for looping
    }
}

// Core 0 task: Serial interaction and other tasks
void core0_main() {
    while (1) {
        if (Serial.available()) {
            char input = Serial.read();
            if (input == 'u') {
                mutex_enter_blocking(&volumeMutex);
                volumeFactor += 1;
                float currentVolume = volumeFactor;
                mutex_exit(&volumeMutex);
                Serial.print("Volume increased. Factor: ");
                Serial.println(currentVolume);
            } else if (input == 'l') {
                mutex_enter_blocking(&volumeMutex);
                volumeFactor -= 1;
                if (volumeFactor < 0) volumeFactor = 0;
                float currentVolume = volumeFactor;
                mutex_exit(&volumeMutex);
                Serial.print("Volume decreased. Factor: ");
                Serial.println(currentVolume);
            }
        }
        sleep_ms(10); // Small delay to prevent this task from hogging CPU
    }
}

void setup() {
    Serial.begin(115200);
    while (!Serial) {
        delay(10);
    }
    Serial.println("Initializing...");

    // Initialize I2S
    i2s.setBCLK(pBCLK);
    i2s.setDATA(pDOUT);
    i2s.setBitsPerSample(16);
    if (!i2s.begin(sampleRate)) {
        Serial.println("Failed to initialize I2S!");
        while (1);
    }

    // Initialize MP3 decoder
    mp3.setDataCallback(dataCallback);
    mp3.begin();

    // Initialize mutex
    mutex_init(&volumeMutex);

    Serial.println("Initialization complete. Starting playback...");
    Serial.println("Use 'u' to increase volume and 'l' to lower volume.");

    // Launch core 1 task
    multicore_launch_core1(core1_main);

    // Start core 0 task (which will run in place of the regular loop())
    core0_main();
}

void loop() {
    // Empty. Everything is now handled by core-specific tasks.
}