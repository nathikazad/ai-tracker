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
        File sourceFile = SD.open(sourcePath, FILE_READ);
        File destFile = SD.open(destPath, FILE_WRITE);
        
        bool success = false;
        if (sourceFile && destFile) {
            while (sourceFile.available()) {
                destFile.write(sourceFile.read());
            }
            sourceFile.close();
            destFile.close();
            SD.remove(sourcePath);
            success = true;
        }
        
        xSemaphoreGive(sdMutex);
        return success;
    }
    return false;
}

void get_timestamp_filename(char* filename, const char* prefix) {
    struct tm timeinfo;
    time_t now;
    time(&now);
    localtime_r(&now, &timeinfo);
    sprintf(filename, "%s/%02d%02d%02d%02d%02d%02d.%s",
            prefix,
            timeinfo.tm_year % 100,
            timeinfo.tm_mon + 1,
            timeinfo.tm_mday,
            timeinfo.tm_hour,
            timeinfo.tm_min,
            timeinfo.tm_sec,
            strstr(prefix, "audio") ? "wav" : "jpg");
}