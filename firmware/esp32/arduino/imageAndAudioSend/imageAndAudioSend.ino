#include "config.h"

// Global variables initialization
MainState mainState = IDLE;
bool timeSync = false;
bool deviceConnected = false;
bool camera_initialized = false;
bool sd_initialized = false;
bool audio_initialized = false;
SemaphoreHandle_t sdMutex = NULL;
TaskHandle_t sensorTask;
TaskHandle_t bleTask;
uint8_t compressedBuffer[2048 * RECORD_TIME];
size_t compressedBufferSize = 0;
volatile bool new_audio_available = false;
SemaphoreHandle_t audioBufferToSendMutex = NULL;
QueueHandle_t audioQueue = NULL;
uint8_t noOfFilesRemaining = 0;

void setup() {
  Serial.begin(115200);
  // while(!Serial);

  // Initialize components
  setup_sd();
  setup_camera();
  setup_audio();
  setup_ble();

  // Create mutex for SD card access
  sdMutex = xSemaphoreCreateMutex();
  audioBufferToSendMutex = xSemaphoreCreateMutex();
  audioQueue = xQueueCreate(10, sizeof(AudioRecord));

  xTaskCreatePinnedToCore(
    audio_loop,
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

  xTaskCreatePinnedToCore(
    process_audios_task,
    "processingAudioTask",
    10000,
    NULL,
    1,
    NULL,
    1
  );

  xTaskCreatePinnedToCore(
    camera_loop,
    "cameraTask",
    10000,
    NULL,
    1,
    NULL,
    1
  );

  Serial.println("System initialized and ready!");
}

void loop() {
  // Main loop remains empty as tasks handle the work
  delay(1000);
}

void audio_loop(void* parameter) {
  while (true) {
    if (sd_initialized && timeSync && audio_initialized) {
      if (mainState == RECORDING) {
        record_audio_to_queue();
      } else if (mainState == LISTENING && deviceConnected) {
        Serial.println("Recording temporary audio");
        record_audio();
      }
    }
    vTaskDelay(10 / portTICK_PERIOD_MS);
  }
}

void camera_loop(void* parameter) {
  while (true) {
    if (sd_initialized && timeSync) {
      if (mainState == RECORDING) {
        capture_image();
        vTaskDelay(60000 / portTICK_PERIOD_MS);
      }
    }
    vTaskDelay(1000 / portTICK_PERIOD_MS);
  }
}