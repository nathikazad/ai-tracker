#include "config.h"

// Global variables initialization
bool timeSync = false;
bool deviceConnected = false;
bool camera_initialized = false;
bool sd_initialized = false;
SemaphoreHandle_t sdMutex = NULL;
TaskHandle_t cameraTask;
TaskHandle_t bleTask;

void setup() {
    Serial.begin(115200);
    while(!Serial);

    // Initialize components
    setup_sd();
    setup_camera();
    setup_ble();

    // Create mutex for SD card access
    sdMutex = xSemaphoreCreateMutex();

    // Create tasks for dual core operation
    xTaskCreatePinnedToCore(
        camera_loop,
        "cameraTask",
        10000,
        NULL,
        1,
        &cameraTask,
        0  // Camera task on Core 0
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