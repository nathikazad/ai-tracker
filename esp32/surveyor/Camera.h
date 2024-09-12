#ifndef CAMERA_H
#define CAMERA_H

#include "esp_camera.h"
#include "SDCard.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define PWDN_GPIO_NUM     -1
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM     10
#define SIOD_GPIO_NUM     40
#define SIOC_GPIO_NUM     39

#define Y9_GPIO_NUM       48
#define Y8_GPIO_NUM       11
#define Y7_GPIO_NUM       12
#define Y6_GPIO_NUM       14
#define Y5_GPIO_NUM       16
#define Y4_GPIO_NUM       18
#define Y3_GPIO_NUM       17
#define Y2_GPIO_NUM       15
#define VSYNC_GPIO_NUM    38
#define HREF_GPIO_NUM     47
#define PCLK_GPIO_NUM     13

#define LED_GPIO_NUM      21

class Camera {
public:
  Camera(SDCard& sd);
  bool begin();
  void startImageCaptureTask();

private:
  void captureAndSaveImage();
  static void imageCaptureTask(void *pvParameters);

  SDCard& sdCard;
  int imageCount;
  TaskHandle_t imageCaptureTaskHandle;
  static const char* IMAGE_FILE_PREFIX;
  static const int CAPTURE_INTERVAL = 60000; // 60 seconds
};

#endif // CAMERA_H
