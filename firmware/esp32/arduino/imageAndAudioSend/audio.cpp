#include "config.h"

I2SClass I2S;
uint8_t *audioBuffer;
size_t audioBufferSize;

void setup_audio() {
    // Initialize I2S
    
  I2S.setPinsPdmRx(42, 41);
  // start I2S at 16 kHz with 16-bits per sample
  if (!I2S.begin(I2S_MODE_PDM_RX, 4000, I2S_DATA_BIT_WIDTH_16BIT, I2S_SLOT_MODE_MONO)) {
    Serial.println("Failed to initialize I2S!");
        Serial.println("Failed to initialize I2S!");
        return;
    }
    audio_initialized = true;
    Serial.println("Audio system initialized successfully");
}

void record_audio(const char* filename) {
  if (audio_initialized) {
    // Record audio
    Serial.println("Recording audio...");
    audioBuffer = I2S.recordWAV(20, &audioBufferSize);
    
    if (audioBufferSize == 0) {
        Serial.println("Failed to record audio!");
        return;
    }
    
    Serial.printf("Recorded %d bytes, now saving to %s\n", audioBufferSize, filename);
    
    // // Increase volume
    // for (uint32_t i = 0; i < audioBufferSize; i += SAMPLE_BITS/8) {
    //     (*(uint16_t *)(audioBuffer+i)) <<= VOLUME_GAIN;
    // }
    // Save to SD card
    if (xSemaphoreTake(sdMutex, portMAX_DELAY)) {
        File file = SD.open(filename, FILE_WRITE);
        if (file) {
            file.write(audioBuffer, audioBufferSize);
            file.close();
            Serial.printf("Audio saved: %s\n", filename);
        }
        xSemaphoreGive(sdMutex);
    } else {
      Serial.println("Did not get mutex");
    }
    if (audioBuffer) {
        free(audioBuffer);
        audioBuffer = nullptr;
    }
  }
}