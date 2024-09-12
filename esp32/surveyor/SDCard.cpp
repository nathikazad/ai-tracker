#include "SDCard.h"

SDCard::SDCard() : semaphore(NULL) {}

bool SDCard::begin(int csPin) {
  semaphore = xSemaphoreCreateMutex();
  return SD.begin(csPin);
}

bool SDCard::writeFile(const char* path, const uint8_t* buffer, size_t size) {
  if (!acquireLock()) return false;

  File file = SD.open(path, FILE_WRITE);
  if (!file) {
    releaseLock();
    return false;
  }

  size_t written = file.write(buffer, size);
  file.close();
  releaseLock();

  return written == size;
}

bool SDCard::appendFile(const char* path, const uint8_t* buffer, size_t size) {
  if (!acquireLock()) return false;

  File file = SD.open(path, FILE_APPEND);
  if (!file) {
    releaseLock();
    return false;
  }

  size_t written = file.write(buffer, size);
  file.close();
  releaseLock();

  return written == size;
}

bool SDCard::acquireLock(TickType_t waitTime) {
  return xSemaphoreTake(semaphore, waitTime) == pdTRUE;
}

void SDCard::releaseLock() {
  xSemaphoreGive(semaphore);
}