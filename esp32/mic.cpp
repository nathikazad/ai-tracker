#include <I2S.h>
#include "mic.h"
#include "ble.h" // Include for send_audio_data function

// Buffer sizes
static size_t recording_buffer_size = FRAME_SIZE * 2; // 16-bit samples
static size_t compressed_buffer_size = recording_buffer_size + 3; // header

// Buffers
static uint8_t *s_recording_buffer = nullptr;
static uint8_t *s_compressed_frame = nullptr;

// Declare audio_frame_count here if it's not defined elsewhere
// uint16_t audio_frame_count = 0;

void configure_microphone() {
    // Configure I2S for the microphone
    I2S.setAllPins(-1, 42, 41, -1, -1);
    if (!I2S.begin(PDM_MONO_MODE, SAMPLE_RATE, SAMPLE_BITS)) {
        Serial.println("Failed to initialize I2S!");
        while (1); // do nothing
    }

    // Allocate buffers
    s_recording_buffer = (uint8_t *)ps_calloc(recording_buffer_size, sizeof(uint8_t));
    s_compressed_frame = (uint8_t *)ps_calloc(compressed_buffer_size, sizeof(uint8_t));
}

size_t read_microphone() {
    // Update to use the correct I2S.read() function
    return I2S.read(s_recording_buffer, recording_buffer_size);
}

void compress_and_send_audio(size_t bytes_recorded) {
    // Simple PCM compression (just amplification in this case)
    for (size_t i = 0; i < bytes_recorded / 4; i++) {
        int16_t sample = ((int16_t *)s_recording_buffer)[i * 2] << VOLUME_GAIN;
        s_compressed_frame[i * 2 + 3] = sample & 0xFF;
        s_compressed_frame[i * 2 + 4] = (sample >> 8) & 0xFF;
    }

    // Add frame header
    s_compressed_frame[0] = audio_frame_count & 0xFF;
    s_compressed_frame[1] = (audio_frame_count >> 8) & 0xFF;
    s_compressed_frame[2] = 0;

    // Send the compressed audio data
    send_audio_data(s_compressed_frame, bytes_recorded / 2 + 3);
    audio_frame_count++;
}