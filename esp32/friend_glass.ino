
#include "ble.h"
#include "mic.h"
#include "camera.h"


// Global variables
bool isCapturingPhotos = false;
int captureInterval = 0;
unsigned long lastCaptureTime = 0;
size_t sent_photo_bytes = 0;
size_t sent_photo_frames = 0;
bool photoDataUploading = false;
uint16_t audio_frame_count = 0;
uint8_t batteryLevel = 100;

void setup() {
    Serial.begin(921600);
    configure_ble();
    configure_microphone();
    configure_camera();
}

void loop() {
    // Handle audio processing and transmission
    process_audio();

    // Handle photo capture and transmission
    process_photo();

    // Update battery level periodically
    update_battery();

    delay(20);
}

void process_audio() {
    size_t bytes_recorded = read_microphone();
    if (bytes_recorded > 0 && is_ble_connected()) {
        compress_and_send_audio(bytes_recorded);
    }
}

void process_photo() {
    unsigned long now = millis();
    if (isCapturingPhotos && !photoDataUploading && is_ble_connected()) {
        if ((captureInterval == 0) || ((now - lastCaptureTime) >= captureInterval)) {
            if (captureInterval == 0) {
                isCapturingPhotos = false;
            }
            if (take_photo()) {
                photoDataUploading = true;
                sent_photo_bytes = 0;
                sent_photo_frames = 0;
                lastCaptureTime = now;
            }
        }
    }
    if (photoDataUploading) {
        send_photo_data();
    }
}

void update_battery() {
    static unsigned long lastBatteryUpdate = 0;
    unsigned long now = millis();
    if (now - lastBatteryUpdate > 60000) {
        updateBatteryLevel(batteryLevel);
        lastBatteryUpdate = now;
    }
}