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

private:
  SemaphoreHandle_t semaphore;
  bool acquireLock(TickType_t waitTime = portMAX_DELAY);
  void releaseLock();
};

#endif // SDCARD_H