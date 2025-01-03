#include "config.h"

void setup_sd() {
    if (!SD.begin(21)) {
        Serial.println("SD Card Mount Failed");
        return;
    }
    
    // Create required directories
    if (!SD.exists("/pix")) SD.mkdir("/pix");
    if (!SD.exists("/audio")) SD.mkdir("/audio");
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

void get_timestamp_filename(char* filename, const char* prefix) {
    time_t now;
    time(&now);
    
    sprintf(filename, "%s/%llu.%s",
        prefix,
        (unsigned long long)now,
        strstr(prefix, "audio") ? "wav" : "jpg");
}