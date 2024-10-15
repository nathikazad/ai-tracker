#include <I2S.h>
#include <SPI.h>
#include <SD.h>

#define micro

// GPIO pin numbers for SD card (SPI)
#ifdef pico
  #define  SCK  10
  #define MOSI  11
  #define MISO  12
  #define   CS  13
  #define SPSL  SPI1
#else 
  #define MISO  20
  #define   CS  21
  #define  SCK  22
  #define MOSI  23
  #define SPSL  SPI
#endif

// GPIO pin numbers for I2S
#ifdef pico
  #define pBCLK 26 //BCLK --> 32
  #define   pWS 27 //LRC  --> 31
  #define pDOUT 28 //DIN  --> 34
#else 
  #define pBCLK 26 //BCLK --> A0
  #define   pWS 27 //LRC  --> A1
  #define pDOUT  6 //D0   --> D0
#endif
I2S i2s(OUTPUT);


const int sampleRate = 48000; // Sample rate (adjust if needed)
const int bufferSize = 1024;  // Size of the buffer to read from SD card
int16_t buffer[bufferSize];   // Buffer to hold audio data

File wavFile;

void setup() {
  Serial.begin(115200);
  while (!Serial) {
    delay(1); // wait for serial port to connect
  }

  Serial.println("\nInitializing SD card...");
  
  // Initialize SPI for SD card
  SPSL.setRX(MISO);
  SPSL.setTX(MOSI);
  SPSL.setSCK(SCK);
  
  if (!SD.begin(CS, SPSL)) {
    Serial.println("SD card initialization failed!");
    while (1);
  }
  Serial.println("SD card initialized.");

  // Open the WAV file
  wavFile = SD.open("input.wav");
  if (!wavFile) {
    Serial.println("Failed to open input.wav!");
    while (1);
  }

  // Skip the WAV header (44 bytes)
  wavFile.seek(44);

  // Initialize I2S
  i2s.setBCLK(pBCLK);
  i2s.setDATA(pDOUT);
  i2s.setBitsPerSample(16);

  if (!i2s.begin(sampleRate)) {
    Serial.println("Failed to initialize I2S!");
    while (1);
  }

  Serial.println("I2S initialized. Starting playback...");
}

void loop() {
  if (wavFile.available()) {
    // Read a buffer of audio data from the file
    int bytesRead = wavFile.read((uint8_t*)buffer, bufferSize * 2);
    int samplesRead = bytesRead / 2;

    // Play the audio data through I2S
    for (int i = 0; i < samplesRead; i++) {
      i2s.write(buffer[i]);
      i2s.write(buffer[i]); // Write the same sample twice for stereo
    }
  } else {
    // End of file reached
    wavFile.seek(44); // Seek back to the start of audio data
    Serial.println("Reached end of file. Looping...");
  }
}