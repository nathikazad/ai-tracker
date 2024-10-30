#ifndef AUDIO_HANDLER_H
#define AUDIO_HANDLER_H

#include <PDM.h>
#include "adpcm-lib.h"

// Audio configuration
#define RECORD_TIME 5 // seconds
#define INPUT_SAMPLE_RATE 16000
#define OUTPUT_SAMPLE_RATE 4000
#define SAMPLE_BITS 16
#define VOLUME_GAIN 2
#define DOWNSAMPLE_FACTOR (INPUT_SAMPLE_RATE / OUTPUT_SAMPLE_RATE)

void setupAudio();
void onPDMdata();
void startRecording();
void stopRecording();
void compressAndSendAudio();
int getCounter();
uint32_t getWriteIndex();

#endif