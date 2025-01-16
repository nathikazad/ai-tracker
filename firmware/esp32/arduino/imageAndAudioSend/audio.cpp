#include "config.h"
#include "adpcm.h"
I2SClass I2S;
uint8_t *audioBuffer;
size_t audioBufferSize;

static void *adpcm_context = NULL;
const size_t RECORD_SIZE = SAMPLE_RATE * RECORD_TIME * (BITS_PER_SAMPLE / 8) * NUM_CHANNELS;

void setup_audio() {
  // Initialize I2S

  I2S.setPinsPdmRx(42, 41);
  // start I2S at 16 kHz with 16-bits per sample
  if (!I2S.begin(I2S_MODE_PDM_RX, SAMPLE_RATE, I2S_DATA_BIT_WIDTH_16BIT, I2S_SLOT_MODE_MONO)) {
    Serial.println("Failed to initialize I2S!");
    Serial.println("Failed to initialize I2S!");
    return;
  }

  int32_t initial_deltas[2] = { 0, 0 };
  adpcm_context = adpcm_create_context(1, 0, 0, initial_deltas);
  if (adpcm_context == NULL) {
    Serial.println("Failed to create ADPCM context!");
    while (1)
      ;
  }

  audio_initialized = true;
  Serial.println("Audio system initialized successfully");
}

void record_audio_to_queue() {
  time_t now;
  time(&now);

  char *buffer = (char *)malloc(RECORD_SIZE);
  if (!buffer) {
    Serial.println("Failed to allocate memory for chunk!");
    return;
  }

  // For 10 seconds at 16kHz, 16-bit mono:
  // 10 seconds * 16000 samples/second * 2 bytes/sample = 320000 bytes
  size_t bytesRead = I2S.readBytes(buffer, RECORD_SIZE);

  if (bytesRead != RECORD_SIZE) {
    Serial.printf("Failed to read full chunk. Expected %u bytes, got %u bytes\n", RECORD_SIZE, bytesRead);
    free(buffer);
    return;
  }

  // int16_t *samples = (int16_t *)buffer;
  // int sampleCount = RECORD_SIZE / 2;
  // uint8_t *compressedBuffer = (uint8_t *)malloc(RECORD_SIZE / 4);
  // size_t compressedBufferSize = 0;
  // int result = adpcm_encode_block(adpcm_context, compressedBuffer, &compressedBufferSize,
  //                                 samples, sampleCount);
  // free(buffer);

  // AudioRecord record = {
  //   .audioBuffer = compressedBuffer,
  //   .bufferSize = compressedBufferSize,
  //   .timestamp = now
  // };
  AudioRecord record = {
    .audio_buffer = (uint8_t*)buffer,
    .buffer_size = RECORD_SIZE,
    .timestamp = now
  };
  Serial.printf("Audio %u recorded successfully, sending to queue\n", now);
  // Send to queue with timeout (e.g., 100 ticks)
  if (xQueueSend(audioQueue, &record, pdMS_TO_TICKS(100)) != pdPASS) {
    // Queue is full, free buffer to prevent memory leak
    free(record.audio_buffer);
    return;
  }

  
}

void process_audios_task(void *parameter) {
  AudioRecord record;

  while (true) {
    // Wait for data with timeout
    if (xQueueReceive(audioQueue, &record, pdMS_TO_TICKS(1000)) == pdPASS) {
      Serial.printf("Audio %u received in queue\n", record.timestamp);
      if (xSemaphoreTake(sdMutex, portMAX_DELAY)) {

        char filename[32];
        sprintf(filename, "/%s/%llu.%s", "toSend", (unsigned long long)record.timestamp, "wav");
        File file = SD.open(filename, FILE_WRITE);
        if (!file) {
          Serial.println("Failed to open file for writing!");
          return;
        }

        write_wav_header(file, record.buffer_size);
        file.write(record.audio_buffer, record.buffer_size);
        file.close();
        xSemaphoreGive(sdMutex);
        Serial.printf("Audio %u written to file\n", record.timestamp);
      }
      // Free the buffer
      free(record.audio_buffer);
    }
    vTaskDelay(100 / portTICK_PERIOD_MS);
  }
}

void record_audio(const char *filename) {
  if (audio_initialized) {
    // Record audio
    Serial.println("Recording audio...");
    audioBuffer = I2S.recordWAV(5, &audioBufferSize);
    I2S.read();
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

void record_audio() {
  if (audio_initialized) {
    // Record audio
    Serial.println("Recording audio...");
    audioBuffer = I2S.recordWAV(RECORD_TIME, &audioBufferSize);

    if (audioBufferSize == 0) {
      Serial.println("Failed to record audio!");
      return;
    }

    Serial.printf("Recorded %d bytes\n", audioBufferSize);
    Serial.println("Recorded");



    new_audio_available = true;

    if (xSemaphoreTake(audioBufferToSendMutex, portMAX_DELAY)) {
      int16_t *samples = (int16_t *)audioBuffer;
      int sampleCount = audioBufferSize / 2;
      int result = adpcm_encode_block(adpcm_context, compressedBuffer, &compressedBufferSize,
                                      samples, sampleCount);
      if (result < 0) {
        Serial.println("ADPCM encoding failed!");
        return;
      }
      Serial.printf("Compressed %d bytes to %d bytes\n", audioBufferSize, compressedBufferSize);

      free(audioBuffer);
      xSemaphoreGive(audioBufferToSendMutex);
    } else {
      Serial.println("Did not get audioBufferToSend mutex");
    }
  }
}