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
#define RECORD_TIME 5  // seconds
#define SAMPLE_RATE 4000U
#define SAMPLE_BITS I2S_DATA_BIT_WIDTH_16BIT
#define VOLUME_GAIN 2
#define AUDIO_CHUNK_SIZE 512

// Timing configurations
#define CAPTURE_INTERVAL 20000 // 1 minute interval

// Global flags and variables
extern bool timeSync;
extern bool deviceConnected;
extern bool camera_initialized;
extern bool sd_initialized;
extern bool audio_initialized;
extern SemaphoreHandle_t sdMutex;

// Function declarations for BLE
void setup_ble();
void ble_loop(void * parameter);

// Function declarations for Camera
void setup_camera();
void camera_loop(void * parameter);

// Function declarations for Audio
void setup_audio();
void audio_loop(void * parameter);

// Function declarations for SD
void setup_sd();
bool move_file(const char* sourcePath, const char* destPath);
void get_timestamp_filename(char* filename, const char* prefix);

// Task handles
extern TaskHandle_t cameraTask;
extern TaskHandle_t audioTask;
extern TaskHandle_t bleTask;