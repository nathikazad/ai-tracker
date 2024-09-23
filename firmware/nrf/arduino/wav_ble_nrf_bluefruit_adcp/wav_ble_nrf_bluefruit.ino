#include <bluefruit.h>
#include <PDM.h>
#include "adpcm-lib.h"

#define FAST
#define CONN_PARAM 6
#define DATA_NUM 240

BLEService uploadService("19B10000-E8F2-537E-4F6C-D104768A1214");
BLECharacteristic dataCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, DATA_NUM);
BLECharacteristic delayCharacteristic("19B10002-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite, sizeof(uint32_t));
BLECharacteristic burstTimeCharacteristic("19B10003-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, sizeof(uint32_t));

const unsigned long sendInterval = 10000; // 10 seconds in milliseconds
unsigned long lastSendTime = 0;
bool connectedFlag = false;

#define RECORD_TIME 5 // seconds
#define SAMPLE_RATE 4000
#define SAMPLE_BITS 16
#define VOLUME_GAIN 2
#define CHUNK_SIZE 236

// Buffer to read samples into, each sample is 16-bits
short sampleBuffer[512];
// Number of audio samples read
volatile int samplesRead;

uint8_t *audioBuffer = NULL;
uint32_t audioBufferSize = 0;
uint8_t *compressedBuffer = NULL;
uint32_t compressedBufferSize = 0;
// int16_t *decodedBuffer = NULL;
void *adpcm_context = NULL;


void onPDMdata() {
  // Query the number of available bytes
  int bytesAvailable = PDM.available();

  // Read into the sample buffer
  PDM.read(sampleBuffer, bytesAvailable);

  // 16-bit, 2 bytes per sample
  samplesRead = bytesAvailable / 2;
}


void setupBle() {
  Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);
  Bluefruit.configUuid128Count(15);
  Bluefruit.begin();
  Bluefruit.setTxPower(0);
  Bluefruit.setName("Random Data Sender");
  Bluefruit.setConnLedInterval(50);
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

  uploadService.begin();
  dataCharacteristic.setProperties(CHR_PROPS_NOTIFY);
  dataCharacteristic.setFixedLen(DATA_NUM);
  dataCharacteristic.begin();

  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  Bluefruit.Advertising.addService(uploadService);
  Bluefruit.ScanResponse.addName();
  
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setIntervalMS(20, 153);     // fast mode 20mS, slow mode 153mS
  Bluefruit.Advertising.setFastTimeout(30);         // fast mode 30 sec
  Bluefruit.Advertising.start(0);    

}


void setup() {
  Serial.begin(9600);
  while (!Serial);

  // Initialize PDM
  PDM.onReceive(onPDMdata);
  if (!PDM.begin(1, 16000)) {
    Serial.println("Failed to start PDM!");
    while (1);
  }

  // Allocate memory for buffers
  uint32_t recordSize = (SAMPLE_RATE * SAMPLE_BITS / 8) * RECORD_TIME;
  audioBuffer = (uint8_t *)malloc(recordSize);
  compressedBufferSize = recordSize / 2; // ADPCM typically compresses 2:1
  compressedBuffer = (uint8_t *)malloc(compressedBufferSize);
  // decodedBuffer = (int16_t *)malloc(recordSize);

  if (audioBuffer == NULL || compressedBuffer == NULL) {
    Serial.println("Failed to allocate memory for buffers!");
    while (1); // Halt if memory allocation fails
  }

  // Create ADPCM context
  int32_t initial_deltas[2] = {0, 0}; // For mono audio, we only need one channel
  adpcm_context = adpcm_create_context(1, 0, 0, initial_deltas);
  if (adpcm_context == NULL) {
    Serial.println("Failed to create ADPCM context!");
    while (1); // Halt if context creation fails
  }

  //   // Reset ADPCM state
  // adpcm_free_context(adpcm_context);
  // int32_t initial_deltas[2] = {0, 0};
  // adpcm_context = adpcm_create_context(1, 0, 0, initial_deltas);

  setupBle();
  Serial.println("BLE Random Data Sender Ready");
}


void loop() {
  if (Bluefruit.connected() && connectedFlag) {
    unsigned long currentTime = millis();
    if (currentTime - lastSendTime >= sendInterval) {
      recordAndSendAudio();
      lastSendTime = currentTime;
    }
  }
}

void recordAndSendAudio() {
  uint32_t recordSize = (SAMPLE_RATE * SAMPLE_BITS / 8) * RECORD_TIME;
  
  // Clear the buffers
  memset(audioBuffer, 0, recordSize);
  memset(compressedBuffer, 0, compressedBufferSize);
  
  // Record audio
  Serial.print("Recording audio of size: ");
  Serial.println(recordSize);
  uint32_t recordedSize = 0;
  unsigned long startTime = millis();
  while (recordedSize < recordSize) {
    if (samplesRead > 0) {
      for (int i = 0; i < samplesRead; i += 4) {
          // Copy every other 16-bit sample
          *((int16_t*)(audioBuffer + recordedSize)) = sampleBuffer[i];
          recordedSize += 2;
      }
      samplesRead = 0;
    }
    if (millis() - startTime > RECORD_TIME * 1000) break;
  }
  audioBufferSize = recordedSize;
  
  if (audioBufferSize == 0) {
    Serial.println("Failed to record audio!");
    return;
  }
  
  Serial.print("Recorded ");
  Serial.print(audioBufferSize);
  Serial.println(" bytes");
  unsigned long endTime = millis();
  unsigned long duration = endTime - startTime;
  Serial.print("Record time: ");
  Serial.print(duration); 
  Serial.println(" ms");
  
  // Increase volume
  for (uint32_t i = 0; i < audioBufferSize; i += SAMPLE_BITS/8) {
    (*(int16_t *)(audioBuffer+i)) <<= VOLUME_GAIN;
  }

  startTime = millis();

  // Encode audio using ADPCM
  size_t outbufsize = compressedBufferSize;
  int result = adpcm_encode_block(adpcm_context, compressedBuffer, &outbufsize, (const int16_t*)audioBuffer, audioBufferSize / 2);
  if (result < 0) {
    Serial.println("ADPCM encoding failed!");
    return;
  }

  Serial.print("Compressed size: ");
  Serial.println(outbufsize);

  endTime = millis();
  duration = endTime - startTime;
  Serial.print("Encoding time. Total time: ");
  Serial.print(duration); 
  Serial.println(" ms");

  // Start timing the BLE transmission
  startTime = millis();

  // Send start packet
  uint32_t numPackets = (outbufsize + CHUNK_SIZE - 1) / CHUNK_SIZE;
  uint8_t startPacket[8] = {'S', 'T', 'A', 'R', 'T', 0, 0, 0};
  startPacket[5] = (numPackets >> 16) & 0xFF;
  startPacket[6] = (numPackets >> 8) & 0xFF;
  startPacket[7] = numPackets & 0xFF;
  dataCharacteristic.notify(startPacket, 8);
  delay(20);  // Give the client some time to process
  
  // Send compressed audio data in chunks
  for (uint32_t i = 0; i < outbufsize; i += CHUNK_SIZE) {
    uint32_t chunkSize = (CHUNK_SIZE < outbufsize - i) ? CHUNK_SIZE : (outbufsize - i);
    uint8_t header[4] = {0xFF, 0xFF, (i >> 8) & 0xFF, i & 0xFF};
    uint8_t chunk[CHUNK_SIZE + 4];
    memcpy(chunk, header, 4);
    memcpy(chunk + 4, compressedBuffer + i, chunkSize);
    dataCharacteristic.notify(chunk, chunkSize + 4);
  }
  
  // Send end packet
  uint8_t endPacket[4] = {'E', 'N', 'D', 0};
  dataCharacteristic.notify(endPacket, 4);
  
  endTime = millis();
  duration = endTime - startTime;
  Serial.print("Compressed audio data sent successfully. Total time: ");
  Serial.print(duration); 
  Serial.println(" ms");
}

void connect_callback(uint16_t conn_handle) {
  BLEConnection* connection = Bluefruit.Connection(conn_handle);

  connection->requestPHY();
  delay(1000);
  connection->requestDataLengthUpdate();
  connection->requestMtuExchange(DATA_NUM + 3);
  connection->requestConnectionParameter(CONN_PARAM);
  delay(1000);

  char central_name[32] = { 0 };
  connection->getPeerName(central_name, sizeof(central_name));

  Serial.print("Connected to ");
  Serial.println(central_name);
  Serial.print("PHY: "); Serial.println(connection->getPHY());
  Serial.print("Data Length: "); Serial.println(connection->getDataLength());
  Serial.print("MTU: "); Serial.println(connection->getMtu());
  Serial.print("Connection Interval: "); Serial.println(connection->getConnectionInterval());

  connectedFlag = true;
}

void disconnect_callback(uint16_t conn_handle, uint8_t reason) {
  (void) conn_handle;
  (void) reason;

  Serial.print("Disconnected, reason = 0x");
  Serial.println(reason, HEX);
  connectedFlag = false;
}