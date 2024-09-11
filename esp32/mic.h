#ifndef MIC_H
#define MIC_H

#include <stdint.h>
#include <stdlib.h>

// Constants
#define SAMPLE_RATE 16000
#define SAMPLE_BITS 16
#define FRAME_SIZE 160
#define VOLUME_GAIN 2

// Function declarations
void configure_microphone();
size_t read_microphone();
void compress_and_send_audio(size_t bytes_recorded);

// Declare audio_frame_count as extern
extern uint16_t audio_frame_count;

#endif // MIC_H