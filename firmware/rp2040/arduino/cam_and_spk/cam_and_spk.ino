#include "hm01b0.h"
#include <slic.h>
#include "MP3DecoderHelix.h"
#include <I2S.h>
#include "pico/multicore.h"
#include "pico/sync.h"

// Camera definitions
#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 320
#define BUFFER_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT)
#define CHUNK_SIZE 256
#define ACK_TIMEOUT_MS 5
#define ACK_RETRIES 5

// Audio definitions
#define pBCLK 16
#define pWS 17
#define pDOUT 18
const int sampleRate = 24000;
const int AUDIO_BUFFER_SIZE = 1024*64;

// Camera configuration
#define ASP_NRF
const struct hm01b0_config hm01b0_config = {
    .i2c = i2c_default,
    .sda_pin = PICO_DEFAULT_I2C_SDA_PIN,
    .scl_pin = PICO_DEFAULT_I2C_SCL_PIN,
    .vsync_pin = 25,
    .hsync_pin = 24,
    .pclk_pin = 26,
    .data_pin_base = 19,
    .data_bits = 4,
    .pio = pio0,
    .pio_sm = 0,
    .reset_pin = 23,
    .mclk_pin = 27,
    .width = IMAGE_WIDTH,
    .height = IMAGE_HEIGHT,
};

// Camera variables
static SLIC slic;
uint8_t pixels[BUFFER_SIZE];
// uint8_t compressedBuffer[BUFFER_SIZE];

// Audio variables
using namespace libhelix;
I2S i2s(OUTPUT);

struct AudioBuffer {
    uint8_t data[AUDIO_BUFFER_SIZE];
    volatile int size;
    volatile bool ready;
};

AudioBuffer buffers[2];
volatile int currentBuffer = 0;
volatile bool processingDone = true;

// Audio callback function
void dataCallback(MP3FrameInfo &info, int16_t *pcm_buffer, size_t len, void* ref) {
    for (size_t i = 0; i < len; i++) {
        int16_t sample = pcm_buffer[i];
        float adjusted = sample * 8.0;
        if (adjusted > 32767) adjusted = 32767;
        if (adjusted < -32768) adjusted = -32768;
        i2s.write((int16_t)adjusted);
        i2s.write((int16_t)adjusted);
    }
}

MP3DecoderHelix mp3(dataCallback);

// Core 1 function: handle MP3 decoding and playback
void core1_entry() {
    mp3.begin();
    while (true) {
        for (int i = 0; i < 2; i++) {
            if (buffers[i].ready) {
                mp3.write(buffers[i].data, buffers[i].size);
                buffers[i].ready = false;
                processingDone = true;
            }
        }
        tight_loop_contents();
    }
}

// Camera functions
bool writeChunked(uint8_t* buffer, size_t totalSize) {
    const uint8_t CHUNK_START_MARKER[] = {0xFF, 0xCC, 0xFF, 0xCC};
    const uint8_t CHUNK_END_MARKER[] = {0xFF, 0xDD, 0xFF, 0xDD};
    
    size_t bytesRemaining = totalSize;
    size_t offset = 0;
    uint8_t ackByte;
    uint16_t chunk_index = 0;
    int total_retries = 0;

    Serial.printf("Sending %d bytes in %d chunks\n", totalSize, totalSize/CHUNK_SIZE);
    
    while (bytesRemaining > 0) {
        size_t chunkSize = min(CHUNK_SIZE, bytesRemaining);
        bool chunkAcked = false;
        int tries = 0;
        
        while (!chunkAcked && tries <= ACK_RETRIES) {
            Serial1.write(CHUNK_START_MARKER, 4);
            Serial1.write(buffer + offset, chunkSize);
            Serial1.write(CHUNK_END_MARKER, 4);
            
            unsigned long startTime = millis();
            while (millis() - startTime < ACK_TIMEOUT_MS) {
                if (Serial1.available()) {
                    ackByte = Serial1.read();
                    if (ackByte == 0xAC) {
                        chunkAcked = true;
                        chunk_index++;
                        break;
                    }
                }
            }
            if(!chunkAcked) {
                tries++;
                total_retries++;
                Serial.printf("Trying again for %d\n", chunk_index);
            }
        }
        
        if (tries > ACK_RETRIES) {
          Serial.printf("Total Retries: %d\n", total_retries);
            return false;
        }
        
        offset += chunkSize;
        bytesRemaining -= chunkSize;
    }
    Serial.printf("Total Retries: %d\n", total_retries);
    return true;
}

void sendImage() {
  digitalWrite(8, HIGH);
  int startTime = millis();
  hm01b0_read_frame(pixels, sizeof(pixels));
  
  Serial1.write(0xFF);
  Serial1.write(0xAA);
  Serial1.write(0xFF);
  Serial1.write(0xAA);  
  uint32_t pixelSize = 102400;
  Serial1.write((uint8_t*)&pixelSize, sizeof(pixelSize));
  bool written = writeChunked(pixels, pixelSize);
  uint32_t checksum = fletcher32(pixels, pixelSize);
  
  Serial.printf("Fletcher-32 checksum: 0x%08X\n", checksum);

  if (written) {
      Serial.print("Sent in ");
      Serial.println(millis()-startTime);
  } else {
      Serial.println("Write failed, NRF isn't responding");
  }
  digitalWrite(8, LOW);
}

uint32_t fletcher32(uint8_t const *data, size_t len) {
    uint32_t sum1 = 0xffff, sum2 = 0xffff;
    
    while (len > 1) {
        size_t blocks = (len > 718) ? 718 : len;
        len -= blocks;
        blocks /= 2;
        
        while (blocks) {
            uint16_t word = (data[0] << 8) | data[1];
            sum1 += word;
            sum2 += sum1;
            data += 2;
            blocks--;
        }
        
        sum1 = (sum1 & 0xffff) + (sum1 >> 16);
        sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    }
    
    if (len) {
        sum1 += (*data << 8);
        sum2 += sum1;
        sum1 = (sum1 & 0xffff) + (sum1 >> 16);
        sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    }
    
    sum1 = (sum1 & 0xffff) + (sum1 >> 16);
    sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    
    return (sum2 << 16) | sum1;
}

void playAudio() {
    digitalWrite(8, LOW);
    Serial.println("Receiving");
    
    uint16_t batchSize = (Serial1.read() << 8) | Serial1.read();
    int bufferIndex = currentBuffer;
    int dataIndex = 0;
    
    while (!processingDone && buffers[bufferIndex].ready) {
        tight_loop_contents();
    }
    
    while (dataIndex < batchSize) {
        if (Serial1.available()) {
            buffers[bufferIndex].data[dataIndex++] = Serial1.read();
        }
    }
    
    buffers[bufferIndex].size = batchSize;
    buffers[bufferIndex].ready = true;
    processingDone = false;
    currentBuffer = (currentBuffer + 1) % 2;
    
    Serial.println("Received, sending ack now");
    Serial1.write('A');
    digitalWrite(8, HIGH);
}

void setup() {
    Serial.begin(921600);
    while (!Serial);
    Serial1.begin(1000000);
    
    // Initialize pins
    pinMode(8, OUTPUT);
    pinMode(15, OUTPUT);
    digitalWrite(8, HIGH);
    digitalWrite(15, HIGH);
    
    Serial.println("Initializing Camera");
    if (hm01b0_init(&hm01b0_config) != 0) {
        Serial.println("Failed to initialize camera!");
        while(true) {}
    }
    Serial.println("Camera Initialized");

    // Initialize I2S
    i2s.setBCLK(pBCLK);
    i2s.setDATA(pDOUT);
    i2s.setBitsPerSample(16);
    if (!i2s.begin(sampleRate)) {
        Serial.println("Failed to initialize I2S!");
        while (1);
    }

    // Initialize audio buffers
    buffers[0].ready = false;
    buffers[1].ready = false;

    // Launch core 1 for audio processing
    multicore_launch_core1(core1_entry);
    
    Serial.println("System Initialized");
    delay(5000);
    digitalWrite(8, LOW);
}

void loop() {
  if(Serial1.available()) {
      char c = Serial1.read();
      if(c == 'c') {
          Serial.println("Received capture command");
          sendImage();
      }
      else if(c == 's') {
          playAudio();
      }
  }
  delay(10);
}