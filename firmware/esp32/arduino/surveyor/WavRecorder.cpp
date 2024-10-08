// WavRecorder.cpp
#include "WavRecorder.h"

void WavUtil::generate_wav_header(uint8_t *wav_header, uint32_t wav_size, uint32_t sample_rate, uint16_t bits_per_sample) {
  uint32_t file_size = wav_size + 44 - 8;
  uint32_t byte_rate = sample_rate * bits_per_sample / 8;
  uint8_t block_align = bits_per_sample / 8;

  const uint8_t set_wav_header[] = {
    'R', 'I', 'F', 'F', // ChunkID
    file_size, file_size >> 8, file_size >> 16, file_size >> 24, // ChunkSize
    'W', 'A', 'V', 'E', // Format
    'f', 'm', 't', ' ', // Subchunk1ID
    0x10, 0x00, 0x00, 0x00, // Subchunk1Size (16 for PCM)
    0x01, 0x00, // AudioFormat (1 for PCM)
    0x01, 0x00, // NumChannels (1 channel)
    sample_rate, sample_rate >> 8, sample_rate >> 16, sample_rate >> 24, // SampleRate
    byte_rate, byte_rate >> 8, byte_rate >> 16, byte_rate >> 24, // ByteRate
    block_align, 0x00, // BlockAlign
    bits_per_sample, 0x00, // BitsPerSample
    'd', 'a', 't', 'a', // Subchunk2ID
    wav_size, wav_size >> 8, wav_size >> 16, wav_size >> 24, // Subchunk2Size
  };
  memcpy(wav_header, set_wav_header, sizeof(set_wav_header));
}

const char* WavRecorder::WAV_FILE_NAME = "arduino_rec";

WavRecorder::WavRecorder(SDCard& sd) 
  : fileCounter(0), recordTaskHandle(NULL), sdCard(sd) {}

bool WavRecorder::begin() {
  I2S.setAllPins(-1, 42, 41, -1, -1);
  return I2S.begin(PDM_MONO_MODE, SAMPLE_RATE, SAMPLE_BITS);
}

void WavRecorder::startRecordingTask() {
  xTaskCreatePinnedToCore(
    this->recordTask,
    "RecordTask",
    10000,
    this,
    1,
    &recordTaskHandle,
    0
  );
}

void WavRecorder::recordTask(void *pvParameters) {
  WavRecorder* recorder = static_cast<WavRecorder*>(pvParameters);
  for (;;) {
    Serial.println(millis());
    recorder->record_wav();
    Serial.println(millis());
    
    recorder->fileCounter++;
    Serial.printf("Completed recording file %d\n", recorder->fileCounter);
    
    vTaskDelay(pdMS_TO_TICKS(1000));
  }
}

void WavRecorder::record_wav() {
  uint32_t sample_size = 0;
  uint32_t record_size = (SAMPLE_RATE * SAMPLE_BITS / 8) * RECORD_TIME;
  uint8_t *rec_buffer = NULL;
  uint8_t wav_header[44];

  Serial.printf("Starting recording for file %d...\n", fileCounter);

  char filename[32];
  snprintf(filename, sizeof(filename), "/%s_%d.wav", WAV_FILE_NAME, fileCounter);

  // Allocate buffer for both header and audio data
  uint32_t total_size = 44 + record_size;
  uint8_t *total_buffer = (uint8_t *)ps_malloc(total_size);
  if (total_buffer == NULL) {
    Serial.println("malloc failed!");
    return;
  }

  // Generate WAV header
  WavUtil::generate_wav_header(wav_header, record_size, SAMPLE_RATE, SAMPLE_BITS);

  // Copy header to the beginning of total_buffer
  memcpy(total_buffer, wav_header, 44);

  // Record audio data
  rec_buffer = total_buffer + 44;  // Point to the part of total_buffer after the header
  esp_i2s::i2s_read(esp_i2s::I2S_NUM_0, rec_buffer, record_size, &sample_size, portMAX_DELAY);
  if (sample_size == 0) {
    Serial.println("Record Failed!");
    free(total_buffer);
    return;
  }

  Serial.printf("Recorded %d bytes\n", sample_size);

  // Apply volume gain
  for (uint32_t i = 0; i < sample_size; i += SAMPLE_BITS/8) {
    (*(uint16_t *)(rec_buffer+i)) <<= VOLUME_GAIN;
  }

  // Write entire buffer (header + audio data) to file
  Serial.printf("Writing to file %s ...\n", filename);
  if (!sdCard.writeFile(filename, total_buffer, total_size)) {
    Serial.println("Failed to write audio data");
  } else {
    Serial.printf("Recording of file %d is complete.\n", fileCounter);
  }

  free(total_buffer);
}
