/**
 * @file streams-sd_mp3-i2s.ino
 * @author Phil Schatzmann
 * @brief decode MP3 file and output it on I2S
 * @version 0.1
 * @date 2021-96-25
 *
 * @copyright Copyright (c) 2021
 */
#include <SPI.h>
#include <SD.h>
#include "AudioTools.h"
#include "AudioTools/AudioCodecs/CodecMP3Helix.h"

#define  SCK  10
#define MOSI  11
#define MISO  12
#define   CS  13
#define SPSL  SPI1

const int chipSelect=10;
I2SStream i2s; // final output of decoded stream
EncodedAudioStream decoder(&i2s, new MP3DecoderHelix()); // Decoding stream
StreamCopy copier;
File audioFile;

void setup(){
  Serial.begin(115200);
  // while(!Serial) { delay(10); } // Wait for Serial to be ready
  Serial.println("Setup started");

  AudioLogger::instance().begin(Serial, AudioLogger::Info);
  // Initialize SPI for SD card
  SPSL.setRX(MISO);
  SPSL.setTX(MOSI);
  SPSL.setSCK(SCK);
  
  if (!SD.begin(CS, SPSL)) {
    Serial.println("SD card initialization failed!");
    while (1);
  }
  audioFile = SD.open("/input.mp3");
  if (!audioFile) {
    Serial.println("Failed to open audio file!");
    while(1);
  }
  auto config = i2s.defaultConfig(TX_MODE);
  if (!i2s.begin(config)) {
    Serial.println("Failed to initialize I2S!");
    while(1);
  }
  
  if (!decoder.begin()) {
    Serial.println("Failed to initialize decoder!");
    while(1);
  }

  copier.begin(decoder, audioFile);
  Serial.println("Setup completed");
}

void loop(){
  if (!copier.copy()) {
    Serial.println("Copy process failed or completed");
    stop();
  }
}
