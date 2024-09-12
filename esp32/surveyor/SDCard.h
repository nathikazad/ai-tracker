// SDCard.h
#ifndef SDCARD_H
#define SDCARD_H

#include "FS.h"
#include "SD.h"
#include "SPI.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"

class SDCard {
public:
  SDCard();
  bool begin(int csPin);
  bool writeFile(const char* path, const uint8_t* buffer, size_t size);
  bool appendFile(const char* path, const uint8_t* buffer, size_t size);
  bool acquireNextFile(String& filename);
  size_t getFileSize(const String& filename);
  void removeFile(const String& filename);
  bool readFile(const String& filename, uint8_t* buffer, size_t offset, size_t bufferSize, size_t& bytesRead);

private:
  SemaphoreHandle_t semaphore;
  bool acquireLock(TickType_t waitTime = portMAX_DELAY);
  void releaseLock();
  bool defragment();
  void deleteAllFiles();
};

#endif // SDCARD_H