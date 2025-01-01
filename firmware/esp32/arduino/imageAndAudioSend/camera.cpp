#include "config.h"

unsigned long lastCaptureTime = 0;

void setup_camera() {
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
    config.frame_size = FRAMESIZE_UXGA;
    config.pixel_format = PIXFORMAT_JPEG;
    config.grab_mode = CAMERA_GRAB_WHEN_EMPTY;
    config.fb_location = CAMERA_FB_IN_PSRAM;
    config.jpeg_quality = 12;
    config.fb_count = 1;

    if(psramFound()) {
        config.jpeg_quality = 10;
        config.fb_count = 2;
        config.grab_mode = CAMERA_GRAB_LATEST;
    }

    esp_err_t err = esp_camera_init(&config);
    if (err != ESP_OK) {
        Serial.printf("Camera init failed: 0x%x\n", err);
        return;
    }

    sensor_t * s = esp_camera_sensor_get();
    if (s) {
        s->set_hmirror(s, 1);
        s->set_vflip(s, 1);
    }
    
    camera_initialized = true;
    Serial.println("Camera initialized successfully");
}

void camera_loop(void * parameter) {
    while(true) {
        if (camera_initialized && sd_initialized && timeSync) {
            unsigned long now = millis();
            if ((now - lastCaptureTime) >= CAPTURE_INTERVAL) {
                char filename[32];
                get_timestamp_filename(filename, "/pix");
                Serial.println("Capturing image");
                camera_fb_t *fb = esp_camera_fb_get();
                if (fb) {
                    if (xSemaphoreTake(sdMutex, portMAX_DELAY)) {
                        File file = SD.open(filename, FILE_WRITE);
                        if (file) {
                            file.write(fb->buf, fb->len);
                            file.close();
                            Serial.printf("Saved: %s\n", filename);
                        }
                        xSemaphoreGive(sdMutex);
                    }
                    esp_camera_fb_return(fb);
                }
                lastCaptureTime = now;
            }
        }
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
}