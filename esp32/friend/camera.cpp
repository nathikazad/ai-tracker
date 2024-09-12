#include <Arduino.h>
#include "camera.h"
#include "esp_camera.h"
#include "camera_pins.h"
#include <BLECharacteristic.h>

// External BLE characteristic
extern BLECharacteristic* photoDataCharacteristic;

// Global variables
camera_fb_t* fb = nullptr;
static uint8_t* s_compressed_frame_2 = nullptr;
static const size_t compressed_buffer_size = 202; // 2 bytes for frame number + 200 bytes for data

void configure_camera() {
    camera_config_t config;
    config.ledc_channel = LEDC_CHANNEL_0;
    config.ledc_timer = LEDC_TIMER_0;
    config.pin_d0 = Y2_GPIO_NUM;
    config.pin_d1 = Y3_GPIO_NUM;
    config.pin_d2 = Y4_GPIO_NUM;
    config.pin_d3 = Y5_GPIO_NUM;
    config.pin_d4 = Y6_GPIO_NUM;
    config.pin_d5 = Y7_GPIO_NUM;
    config.pin_d6 = Y8_GPIO_NUM;
    config.pin_d7 = Y9_GPIO_NUM;
    config.pin_xclk = XCLK_GPIO_NUM;
    config.pin_pclk = PCLK_GPIO_NUM;
    config.pin_vsync = VSYNC_GPIO_NUM;
    config.pin_href = HREF_GPIO_NUM;
    config.pin_sscb_sda = SIOD_GPIO_NUM;
    config.pin_sscb_scl = SIOC_GPIO_NUM;
    config.pin_pwdn = PWDN_GPIO_NUM;
    config.pin_reset = RESET_GPIO_NUM;
    config.xclk_freq_hz = 20000000;
    config.frame_size = FRAMESIZE_SVGA;
    config.pixel_format = PIXFORMAT_JPEG;
    config.grab_mode = CAMERA_GRAB_LATEST;
    config.fb_location = CAMERA_FB_IN_PSRAM;
    config.jpeg_quality = 10;
    config.fb_count = 1;

    // Initialize the camera
    esp_err_t err = esp_camera_init(&config);
    if (err != ESP_OK) {
        Serial.printf("Camera init failed with error 0x%x", err);
        return;
    }

    // Allocate buffer for compressed frame
    s_compressed_frame_2 = (uint8_t*)ps_calloc(compressed_buffer_size, sizeof(uint8_t));
    if (!s_compressed_frame_2) {
        Serial.println("Failed to allocate memory for compressed frame");
    }
}

bool take_photo() {
    // Release previous frame buffer if it exists
    if (fb) {
        esp_camera_fb_return(fb);
    }

    // Capture a new frame
    fb = esp_camera_fb_get();
    if (!fb) {
        Serial.println("Failed to get camera frame buffer");
        return false;
    }

    return true;
}

void send_photo_data() {
    if (!fb || !s_compressed_frame_2) {
        return;
    }

    size_t remaining = fb->len - sent_photo_bytes;
    if (remaining > 0) {
        // Populate buffer
        s_compressed_frame_2[0] = sent_photo_frames & 0xFF;
        s_compressed_frame_2[1] = (sent_photo_frames >> 8) & 0xFF;
        size_t bytes_to_copy = remaining > 200 ? 200 : remaining;
        memcpy(&s_compressed_frame_2[2], &fb->buf[sent_photo_bytes], bytes_to_copy);

        // Push to BLE
        photoDataCharacteristic->setValue(s_compressed_frame_2, bytes_to_copy + 2);
        photoDataCharacteristic->notify();
        sent_photo_bytes += bytes_to_copy;
        sent_photo_frames++;
    } else {
        // End flag
        s_compressed_frame_2[0] = 0xFF;
        s_compressed_frame_2[1] = 0xFF;
        photoDataCharacteristic->setValue(s_compressed_frame_2, 2);
        photoDataCharacteristic->notify();

        photoDataUploading = false;

        // Release the frame buffer
        esp_camera_fb_return(fb);
        fb = nullptr;
    }
}