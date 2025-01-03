#include "config.h"

void setup_sd() {
    if (!SD.begin(21)) {
        Serial.println("SD Card Mount Failed");
        return;
    }
    
    // Create required directories
    if (!SD.exists("/toSend")) SD.mkdir("/toSend");
    if (!SD.exists("/sent")) SD.mkdir("/sent");
    
    sd_initialized = true;
    Serial.println("SD card initialized successfully");
}

bool move_file(const char* sourcePath, const char* destPath) {
    if (xSemaphoreTake(sdMutex, portMAX_DELAY)) {
        Serial.printf("Moving from %s to %s\n", sourcePath, destPath);
        bool success = SD.rename(sourcePath, destPath);
        Serial.printf("Move %s\n", success ? "succeeded" : "failed");
        xSemaphoreGive(sdMutex);
        return success;
    }
    return false;
}

void get_timestamp_filename(char* filename) {
    time_t now;
    time(&now);
    sprintf(filename, "/%s/%llu", "toSend", (unsigned long long)now);
}