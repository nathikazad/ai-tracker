#include "Camera.h"

const char* Camera::IMAGE_FILE_PREFIX = "/image";

Camera::Camera(SDCard& sd) : sdCard(sd), imageCount(0), imageCaptureTaskHandle(NULL) {}

bool Camera::begin() {
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

  if(psramFound()){
    config.jpeg_quality = 10;
    config.fb_count = 2;
    config.grab_mode = CAMERA_GRAB_LATEST;
  } else {
    config.frame_size = FRAMESIZE_SVGA;
    config.fb_location = CAMERA_FB_IN_DRAM;
  }

  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return false;
  }
  
  return true;
}

void Camera::startImageCaptureTask() {
  xTaskCreatePinnedToCore(
    this->imageCaptureTask,
    "ImageCaptureTask",
    10000,
    this,
    1,
    &imageCaptureTaskHandle,
    1  // Run on core 1
  );
}

void Camera::imageCaptureTask(void *pvParameters) {
  Camera* camera = static_cast<Camera*>(pvParameters);
  for (;;) {
    camera->captureAndSaveImage();
    vTaskDelay(pdMS_TO_TICKS(CAPTURE_INTERVAL));
  }
}

void Camera::captureAndSaveImage() {
  camera_fb_t *fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Failed to get camera frame buffer");
    return;
  }

  char filename[32];
  snprintf(filename, sizeof(filename), "%s%d.jpg", IMAGE_FILE_PREFIX, imageCount++);

  if (sdCard.writeFile(filename, fb->buf, fb->len)) {
    Serial.printf("Saved image: %s\n", filename);
  } else {
    Serial.println("Failed to save image");
  }

  esp_camera_fb_return(fb);
}