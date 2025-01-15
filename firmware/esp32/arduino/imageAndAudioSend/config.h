#pragma once

#include "esp_camera.h"
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLEServer.h>
#include <ESP_I2S.h>
#include "FS.h"
#include "SD.h"
#include "SPI.h"
#include "time.h"

// Camera model definition
#define CAMERA_MODEL_XIAO_ESP32S3
#include "camera_pins.h"

// BLE Configuration
#define bleServerName "XIAOESP32S3_BLE"
#define PACKET_SIZE 512
#define HEADER_SIZE 3
#define ACK_TIMEOUT 10000

// Service and characteristics UUIDs
#define SERVICE_UUID        "181A"
#define CHAR_UUID_TRANSFER  "2A59"  // For image transfer
#define CHAR_UUID_ACK      "2A58"
#define CHAR_UUID_TIME     "2A57"

// Audio Configuration
#define RECORD_TIME 4  // seconds
#define SAMPLE_RATE 4000U
#define SAMPLE_BITS I2S_DATA_BIT_WIDTH_16BIT
#define VOLUME_GAIN 2
#define AUDIO_CHUNK_SIZE 512

// Timing configurations
#define CAPTURE_INTERVAL 20000 // 1 minute interval

enum MainState {
    IDLE = 0,
    LISTENING = 1,
    RECORDING = 2
};

// Global flags and variables
extern MainState mainState;
extern bool timeSync;
extern bool deviceConnected;
extern bool camera_initialized;
extern bool sd_initialized;
extern bool audio_initialized;
extern SemaphoreHandle_t sdMutex;

extern uint8_t compressedBuffer[2048*RECORD_TIME];
extern size_t compressedBufferSize;
extern volatile bool new_audio_available;
extern SemaphoreHandle_t audioBufferToSendMutex;
// volatile bool new_audio_available = false; // need to set to false when state change

// Function declarations for BLE
void setup_ble();
void ble_loop(void * parameter);

// Function declarations for Camera
void setup_camera();
void capture_image(const char* filename);

// Function declarations for Audio
void setup_audio();
void record_audio(const char* filename);
void record_audio();


// Function declarations for SD
void setup_sd();
bool move_file(const char* sourcePath, const char* destPath);
void get_timestamp_filename(char* filename);
String get_latest_file(String dirPath);

// Task handles
extern TaskHandle_t sensorTask;
extern TaskHandle_t bleTask;