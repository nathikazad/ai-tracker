#include <SPI.h>
#include <SD.h>
#include "AudioTools.h"
#include "AudioTools/AudioCodecs/CodecMP3Helix.h"

#define SCK 10
#define MOSI 11
#define MISO 12
#define CS 13
#define SPSL SPI1
const int chipSelect = 10;

I2SStream i2s; // final output of decoded stream
EncodedAudioStream decoder(&i2s, new MP3DecoderHelix()); // Decoding stream
StreamCopy copier;
File audioFile;
bool isPlaying = false;

void setup() {
    Serial.begin(115200);
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

    auto config = i2s.defaultConfig(TX_MODE);
    if (!i2s.begin(config)) {
        Serial.println("Failed to initialize I2S!");
        while(1);
    }

    if (!decoder.begin()) {
        Serial.println("Failed to initialize decoder!");
        while(1);
    }

    Serial.println("Setup completed");
}

void startPlayback() {
    audioFile = SD.open("/input.mp3");
    if (!audioFile) {
        Serial.println("Failed to open audio file!");
        return;
    }
    copier.begin(decoder, audioFile);
    isPlaying = true;
    Serial.println("Playback started");
}

void stopPlayback() {
    copier.end();
    audioFile.close();
    isPlaying = false;
    Serial.println("Playback stopped");
}

void loop() {
    if (Serial.available() > 0) {
        char command = Serial.read();
        if (command == 'p') {
            if (!isPlaying) {
                startPlayback();
            } else {
                Serial.println("Already playing");
            }
        } else if (command == 's') {
            if (isPlaying) {
                stopPlayback();
            } else {
                Serial.println("Not currently playing");
            }
        }
    }

    if (isPlaying && !copier.copy()) {
        Serial.println("Playback completed");
        stopPlayback();
    }
}