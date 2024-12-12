#include "mic.h"
#include "ble.h"

// Audio buffer configuration
#define BUFFER_SIZE (OUTPUT_SAMPLE_RATE * SAMPLE_BITS / 8 * RECORD_TIME)

static int counter = 0;
static bool isRecording = false;
static int16_t audioBuffer[BUFFER_SIZE];
static volatile uint32_t writeIndex = 0;

// Buffer for compressed data
static uint8_t *compressedBuffer = NULL;
static uint32_t compressedBufferSize = 0;

static void *adpcm_context = NULL;

void setupAudio() {
  // Initialize PDM
  PDM.onReceive(onPDMdata);
  if (!PDM.begin(1, INPUT_SAMPLE_RATE)) {
    Serial.println("Failed to start PDM!");
    while (1);
  }

  // Allocate memory for compressed buffer
  compressedBufferSize = BUFFER_SIZE / 2;  // ADPCM typically compresses 2:1
  compressedBuffer = (uint8_t *)malloc(compressedBufferSize);

  if (compressedBuffer == NULL) {
    Serial.println("Failed to allocate memory for compressed buffer!");
    while (1);
  }

  // Create ADPCM context
  int32_t initial_deltas[2] = {0, 0};
  adpcm_context = adpcm_create_context(1, 0, 0, initial_deltas);
  if (adpcm_context == NULL) {
    Serial.println("Failed to create ADPCM context!");
    while (1);
  }
}

void onPDMdata() {
  counter++;

  int bytesAvailable = PDM.available();
  int16_t sampleBuffer[512];
  int samplesRead = PDM.read(sampleBuffer, bytesAvailable) / 2;

  // Downsample and copy to buffer
  if (isRecording && writeIndex < BUFFER_SIZE) {
    for (int i = 0; i < samplesRead; i += DOWNSAMPLE_FACTOR) {
      if (writeIndex >= BUFFER_SIZE) break;  // Prevent buffer overflow
      audioBuffer[writeIndex++] = sampleBuffer[i];
    }
  }
}

void startRecording() {
  writeIndex = 0;  // Reset buffer position
  isRecording = true;
}

void stopRecording() {
  isRecording = false;
}

static void sendCompressedAudio(uint8_t* buffer, uint32_t size) {
  // Send start packet
  uint8_t chunkMaxSize = PACKET_SIZE - 4;
  uint32_t numPackets = (size + chunkMaxSize - 1) / chunkMaxSize;
  uint8_t startPacket[8] = {'S', 'T', 'A', 'R', 'T', 0, 0, 0};
  startPacket[5] = (numPackets >> 16) & 0xFF;
  startPacket[6] = (numPackets >> 8) & 0xFF;
  startPacket[7] = numPackets & 0xFF;
  micTxCharacteristic.notify(startPacket, 8);
  delay(20);

  // Send compressed audio data in chunks
  for (uint32_t i = 0; i < size; i += chunkMaxSize) {
    uint32_t chunkSize = (chunkMaxSize < size - i) ? chunkMaxSize : (size - i);
    uint8_t header[4] = {0xFF, 0xFF, (uint8_t)((i >> 8) & 0xFF), (uint8_t)(i & 0xFF)};
    uint8_t chunk[chunkMaxSize + 4];
    memcpy(chunk, header, 4);
    memcpy(chunk + 4, buffer + i, chunkSize);
    micTxCharacteristic.notify(chunk, chunkSize + 4);
  }

  // Send end packet
  uint8_t endPacket[4] = {'E', 'N', 'D', 0};
  micTxCharacteristic.notify(endPacket, 4);

  Serial.println("Compressed audio data sent successfully");
}

void compressAndSendAudio() {
  if (writeIndex < OUTPUT_SAMPLE_RATE) {
    Serial.println("Not enough audio data recorded");
    return;
  }

  // Compress audio
  size_t outbufsize = compressedBufferSize;
  int result = adpcm_encode_block(adpcm_context, compressedBuffer, &outbufsize, 
                                audioBuffer, writeIndex);
  if (result < 0) {
    Serial.println("ADPCM encoding failed!");
    return;
  }

  // Send compressed audio over BLE
  sendCompressedAudio(compressedBuffer, outbufsize);
}

int getCounter() {
  return counter;
}

uint32_t getWriteIndex() {
  return writeIndex;
}