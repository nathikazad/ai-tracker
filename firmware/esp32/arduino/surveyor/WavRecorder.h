// WavRecorder.h
#ifndef WAV_RECORDER_H
#define WAV_RECORDER_H

#include <I2S.h>
#include "SDCard.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

class WavUtil {
public:
  static void generate_wav_header(uint8_t *wav_header, uint32_t wav_size, uint32_t sample_rate, uint16_t bits_per_sample);
};

class WavRecorder {
public:
  WavRecorder(SDCard& sd);
  bool begin();
  void startRecordingTask();

private:
  static void recordTask(void *pvParameters);
  void record_wav();

  static const int RECORD_TIME = 60; // seconds
  static const char* WAV_FILE_NAME;
  static const unsigned int SAMPLE_RATE = 16000U;
  static const int SAMPLE_BITS = 16;
  static const int VOLUME_GAIN = 2;

  int fileCounter;
  TaskHandle_t recordTaskHandle;
  SDCard& sdCard;
};

#endif // WAV_RECORDER_H