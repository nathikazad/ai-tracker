#include "config.h"

// Global variables initialization
bool timeSync = false;
bool deviceConnected = false;
bool camera_initialized = false;
bool sd_initialized = false;
bool audio_initialized = false;
SemaphoreHandle_t sdMutex = NULL;
TaskHandle_t sensorTask;
TaskHandle_t bleTask;

void setup() {
    Serial.begin(115200);
    // while(!Serial);

    // Initialize components
    setup_sd();
    setup_camera();
    // setup_audio();
    setup_ble();

    // Create mutex for SD card access
    sdMutex = xSemaphoreCreateMutex();

    xTaskCreatePinnedToCore(
        sensor_loop,
        "sensorTask",
        10000,
        NULL,
        1,
        &sensorTask,
        0  // Audio task on Core 0
    );

    xTaskCreatePinnedToCore(
        ble_loop,
        "bleTask",
        10000,
        NULL,
        1,
        &bleTask,
        1  // BLE task on Core 1
    );

    Serial.println("System initialized and ready!");
}

void loop() {
    // Main loop remains empty as tasks handle the work
    delay(1000);
}

void sensor_loop(void * parameter) {
  while(true) {
    if (sd_initialized && timeSync) {
      unsigned long now = millis();
      char fileaddress[32];
      get_timestamp_filename(fileaddress);
      char filename[32];
      // sprintf(filename, "%s.%s", fileaddress, "wav");
      // Serial.printf("Sensor loop, recording sound to %s\n", filename);
      // record_audio(filename);
      delay(10000);
      sprintf(filename, "%s.%s", fileaddress, "jpg");
      Serial.printf("Sensor loop, capturing image to %s\n", filename);
      capture_image(filename);
    }
    vTaskDelay(10 / portTICK_PERIOD_MS);
  }
}