#include "SDCard.h"

SDCard::SDCard() : semaphore(NULL) {}

// bool SDCard::begin(int csPin) {
//   if (semaphore == NULL) {
//     semaphore = xSemaphoreCreateMutex();
//   }
//   bool success = SD.begin(csPin);
//   if (success) {
//     Serial.println("SD card initialized successfully.");
//     // Delete all files and defragment
//     // deleteAllFiles();
//     // defragment();
//   } else {
//     Serial.println("Failed to initialize SD card.");
//   }
//   return success;
// }

bool SDCard::acquireLock(TickType_t waitTime) {
  return xSemaphoreTake(semaphore, waitTime) == pdTRUE;
}

void SDCard::releaseLock() {
  xSemaphoreGive(semaphore);
}

bool SDCard::begin(int csPin) {
  semaphore = xSemaphoreCreateMutex();
  return SD.begin(csPin);
}

bool SDCard::writeFile(const char* path, const uint8_t* buffer, size_t size) {
  if (!acquireLock()) return false;

  // Add millis time to the file name
//   String filename = String(path) + "_" + String(millis()) + ".bin";

//   File file = SD.open(filename.c_str(), FILE_WRITE);
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

  // Add millis time to the file name
//   String filename = String(path) + "_" + String(millis()) + ".bin";

//   File file = SD.open(filename.c_str(), FILE_APPEND);
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

bool SDCard::acquireNextFile(String& filename) {
  if (!acquireLock()) {
    Serial.println("Failed to acquire lock for SD card.");
    return false;
  }

  File root = SD.open("/");
  if (!root) {
    Serial.println("Failed to open root directory.");
    releaseLock();
    return false;
  }

  File entry = root.openNextFile();
  if (!entry) {
    Serial.println("No files found on SD card.");
    root.close();
    releaseLock();
    return false;
  }

  filename = entry.name();
  entry.close();
  root.close();
  Serial.printf("Found file: %s\n", filename.c_str());
  return true;
}

size_t SDCard::getFileSize(const String& filename) {
  File file = SD.open(filename.c_str());
  if (!file) return 0;

  size_t fileSize = file.size();
  file.close();
  return fileSize;
}

void SDCard::removeFile(const String& filename) {
  SD.remove(filename.c_str());
}

bool SDCard::defragment() {
    if (!acquireLock()) return false;

    File root = SD.open("/");
    if (!root) {
        releaseLock();
        return false;
    }

    File tempFile = SD.open("/temp.bin", FILE_WRITE);
    if (!tempFile) {
        root.close();
        releaseLock();
        return false;
    }

    File entry = root.openNextFile();
    while (entry) {
        if (!entry.isDirectory()) {
            String filename = entry.name();
            File file = SD.open(filename.c_str());
            if (file) {
                uint8_t buffer[512];
                while (file.available()) {
                    size_t bytesRead = file.read(buffer, sizeof(buffer));
                    tempFile.write(buffer, bytesRead);
                }
                file.close();
            }
        }
        entry.close();
        entry = root.openNextFile();
    }

    root.close();
    tempFile.close();

    SD.remove("/temp.bin");

    releaseLock();
    return true;
}

// New method to delete all files
void SDCard::deleteAllFiles() {
  if (!acquireLock()) return;

  File root = SD.open("/");
  if (!root) {
    releaseLock();
    return;
  }

  File entry = root.openNextFile();
  while (entry) {
    if (!entry.isDirectory()) {
      SD.remove(entry.name());
    }
    entry.close();
    entry = root.openNextFile();
  }

  root.close();
  releaseLock();
}

bool SDCard::readFile(const String& filename, uint8_t* buffer, size_t bufferSize, size_t& bytesRead) {
    if (!acquireLock()) return false;

    File file = SD.open(filename.c_str(), FILE_READ);
    if (!file) {
        releaseLock();
        return false;
    }

    bytesRead = file.read(buffer, bufferSize);
    file.close();
    releaseLock();

    return true;
}