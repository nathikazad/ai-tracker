#include "config.h"

void setup_sd() {
  // int sck = 36;
  // int miso = 37;
  // int mosi = 35;
  // int cs = 3;
  //   SPI.begin(sck, miso, mosi, cs);
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

String get_latest_file(String dirPath) {
  if (xSemaphoreTake(sdMutex, portMAX_DELAY)) {
    String result = "";  // Store result to return after releasing mutex

    File root = SD.open("/toSend");
    // Serial.printf("Trying to open %s\n", dirPath);
    if (!root) {
      Serial.println("Root is not available");
      Serial.flush();
      xSemaphoreGive(sdMutex);
      return result;
    }

    if (!root.isDirectory()) {
      Serial.println("Root is not directory");
      Serial.flush();
      root.close();
      xSemaphoreGive(sdMutex);
      return result;
    }
    // Create a vector to store file information
    std::vector<std::pair<String, time_t>> files;

    // Collect all files and their timestamps
    File file = root.openNextFile();
    while (file) {
      if (!file.isDirectory()) {
        String fileName = file.name();
        // Parse timestamp from filename (format: YYMMDDHHMMSS)
        struct tm tm = {};
        int year, month, day, hour, minute, second;
        sscanf(fileName.c_str(), "%2d%2d%2d%2d%2d%2d",
               &year, &month, &day, &hour, &minute, &second);
        tm.tm_year = year + 100;  // Years since 1900
        tm.tm_mon = month - 1;    // 0-11
        tm.tm_mday = day;
        tm.tm_hour = hour;
        tm.tm_min = minute;
        tm.tm_sec = second;
        time_t timestamp = mktime(&tm);

        files.push_back({ fileName, timestamp });
      }
      file.close();
      file = root.openNextFile();
    }
    root.close();
    if(files.size() != noOfFilesRemaining){
      notify_of_files_remaining(files.size());
    }
    noOfFilesRemaining = files.size();

    // Sort files by timestamp, newest first
    std::sort(files.begin(), files.end(),
              [](const auto& a, const auto& b) {
                return a.second < b.second;
              });

    // Process files if any exist
    if (!files.empty()) {
      result = dirPath + "/" + files[0].first;
    } else {
      // Serial.println("No more new files to send");
      Serial.flush();
    }

    xSemaphoreGive(sdMutex);
    return result;
  } else {
    Serial.println("Time out Semaphore");
    return String("");
  }
}

void write_wav_header(File& file, uint32_t totalDataSize) {
  // RIFF chunk
  file.write((const uint8_t*)"RIFF", 4);

  // Total file size - 8
  uint32_t chunk_size = totalDataSize + 36;  // 36 = size of header minus first 8 bytes
  file.write((const uint8_t*)&chunk_size, 4);

  // WAVE header
  file.write((const uint8_t*)"WAVE", 4);

  // fmt chunk
  file.write((const uint8_t*)"fmt ", 4);

  // fmt chunk size (16 for PCM)
  uint32_t fmt_size = 16;
  file.write((const uint8_t*)&fmt_size, 4);

  // Audio format (1 = PCM)
  uint16_t audio_format = 1;
  file.write((const uint8_t*)&audio_format, 2);

  // Number of channels
  uint16_t num_channels = NUM_CHANNELS;
  file.write((const uint8_t*)&num_channels, 2);

  // Sample rate
  uint32_t sample_rate = SAMPLE_RATE;
  file.write((const uint8_t*)&sample_rate, 4);

  // Calculate and write byte rate
  uint16_t block_align = NUM_CHANNELS * BITS_PER_SAMPLE / 8;
  uint32_t byte_rate = SAMPLE_RATE * block_align;
  file.write((const uint8_t*)&byte_rate, 4);

  // Block align
  file.write((const uint8_t*)&block_align, 2);

  // Bits per sample
  uint16_t bits_per_sample = BITS_PER_SAMPLE;
  file.write((const uint8_t*)&bits_per_sample, 2);

  // Data chunk
  file.write((const uint8_t*)"data", 4);

  // Data size
  file.write((const uint8_t*)&totalDataSize, 4);
}