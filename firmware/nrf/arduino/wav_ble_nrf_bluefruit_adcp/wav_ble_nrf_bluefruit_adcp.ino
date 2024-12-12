#include <bluefruit.h>
#include <PDM.h>
#include "adpcm.h"

#define FAST
#define CONN_PARAM 6
#define DATA_NUM 240

#define RECORD_TIME 5 // seconds
#define INPUT_SAMPLE_RATE 16000
#define OUTPUT_SAMPLE_RATE 4000
#define SAMPLE_BITS 16
#define VOLUME_GAIN 2
#define CHUNK_SIZE 236

#define DOWNSAMPLE_FACTOR (INPUT_SAMPLE_RATE / OUTPUT_SAMPLE_RATE)

BLEService uploadService("19B10000-E8F2-537E-4F6C-D104768A1214");
BLECharacteristic dataCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, DATA_NUM);
BLECharacteristic delayCharacteristic("19B10002-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite, sizeof(uint32_t));
BLECharacteristic burstTimeCharacteristic("19B10003-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, sizeof(uint32_t));

bool connectedFlag = false;

// Circular buffer for continuous recording (stores downsampled audio)
#define BUFFER_SIZE (OUTPUT_SAMPLE_RATE * SAMPLE_BITS / 8 * RECORD_TIME * 2)
int16_t audioBuffer[BUFFER_SIZE / 2];
volatile uint32_t writeIndex = 0;
volatile uint32_t readIndex = 0;

// Buffer for compressed data
uint8_t *compressedBuffer = NULL;
uint32_t compressedBufferSize = 0;

void *adpcm_context = NULL;

// Timer for periodic compression and sending
unsigned long lastCompressAndSendTime = 0;
const unsigned long compressAndSendInterval = RECORD_TIME * 1000; // 5 seconds in milliseconds

void onPDMdata() {
  // Query the number of available bytes
  int bytesAvailable = PDM.available();

  // Read into a temporary buffer
  int16_t sampleBuffer[512];
  int samplesRead = PDM.read(sampleBuffer, bytesAvailable) / 2;

  // Downsample and copy to circular buffer
  for (int i = 0; i < samplesRead; i += DOWNSAMPLE_FACTOR) {
    audioBuffer[writeIndex] = sampleBuffer[i];
    writeIndex = (writeIndex + 1) % (BUFFER_SIZE / 2);
  }
}

void setupBle() {
  Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);
  Bluefruit.configUuid128Count(15);
  Bluefruit.begin();
  Bluefruit.setTxPower(0);
  Bluefruit.setName("Audio Sender");
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
  if (!PDM.begin(1, INPUT_SAMPLE_RATE)) {
    Serial.println("Failed to start PDM!");
    while (1);
  }

  // Allocate memory for compressed buffer
  compressedBufferSize = BUFFER_SIZE / 2; // ADPCM typically compresses 2:1
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

  setupBle();
  Serial.println("BLE Continuous Audio Sender Ready");
}

void loop() {
  if (Bluefruit.connected() && connectedFlag) {
    unsigned long currentTime = millis();
    if (currentTime - lastCompressAndSendTime >= compressAndSendInterval) {
      compressAndSendAudio();
      lastCompressAndSendTime = currentTime;
    }
  }
}

void compressAndSendAudio() {
  uint32_t audioToProcess = (writeIndex - readIndex + (BUFFER_SIZE / 2)) % (BUFFER_SIZE / 2);
  if (audioToProcess < OUTPUT_SAMPLE_RATE * RECORD_TIME) {
    return; // Not enough data to process
  }

  // Compress audio
  size_t outbufsize = compressedBufferSize;
  int result = adpcm_encode_block(adpcm_context, compressedBuffer, &outbufsize, 
                                  (const int16_t*)(audioBuffer + readIndex), 
                                  OUTPUT_SAMPLE_RATE * RECORD_TIME);
  if (result < 0) {
    Serial.println("ADPCM encoding failed!");
    return;
  }

  // Update read index
  readIndex = (readIndex + OUTPUT_SAMPLE_RATE * RECORD_TIME) % (BUFFER_SIZE / 2);

  // Send compressed audio over BLE
  sendCompressedAudio(compressedBuffer, outbufsize);
}

void sendCompressedAudio(uint8_t* buffer, uint32_t size) {
  // Send start packet
  uint32_t numPackets = (size + CHUNK_SIZE - 1) / CHUNK_SIZE;
  uint8_t startPacket[8] = {'S', 'T', 'A', 'R', 'T', 0, 0, 0};
  startPacket[5] = (numPackets >> 16) & 0xFF;
  startPacket[6] = (numPackets >> 8) & 0xFF;
  startPacket[7] = numPackets & 0xFF;
  dataCharacteristic.notify(startPacket, 8);
  delay(20);

  // Send compressed audio data in chunks
  for (uint32_t i = 0; i < size; i += CHUNK_SIZE) {
    uint32_t chunkSize = (CHUNK_SIZE < size - i) ? CHUNK_SIZE : (size - i);
    uint8_t header[4] = {0xFF, 0xFF, (i >> 8) & 0xFF, i & 0xFF};
    uint8_t chunk[CHUNK_SIZE + 4];
    memcpy(chunk, header, 4);
    memcpy(chunk + 4, buffer + i, chunkSize);
    dataCharacteristic.notify(chunk, chunkSize + 4);
  }

  // Send end packet
  uint8_t endPacket[4] = {'E', 'N', 'D', 0};
  dataCharacteristic.notify(endPacket, 4);

  Serial.println("Compressed audio data sent successfully.");
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