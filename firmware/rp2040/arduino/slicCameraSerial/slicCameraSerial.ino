#include "hm01b0.h"
#include <slic.h>

#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 320
#define BUFFER_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT)
#define CHUNK_SIZE 256
#define ACK_TIMEOUT_MS 5
#define ACK_RETRIES 5

#define ASP_NRF
const struct hm01b0_config hm01b0_config = {
  .i2c = i2c_default,
  .sda_pin = PICO_DEFAULT_I2C_SDA_PIN,
  .scl_pin = PICO_DEFAULT_I2C_SCL_PIN,

#if defined SPARKFUN_MICROMOD
  .vsync_pin = 6,
  .hsync_pin = 7,
  .pclk_pin = 8,
  .data_pin_base = 9,
  .data_bits = 1,
  .pio = pio0,
  .pio_sm = 0,
  .reset_pin = -1, // Not connected
  .mclk_pin = -1,  // Not connected
#elif defined ASP_NRF
  .vsync_pin = 25,
  .hsync_pin = 24,
  .pclk_pin = 26,
  .data_pin_base = 19,
  .data_bits = 4,
  .pio = pio0,
  .pio_sm = 0,
  .reset_pin = 23, // Not connected
  .mclk_pin = 27,  // Not connected
#else
  .vsync_pin = 25,
  .hsync_pin = 28,
  .pclk_pin = 11,
  .data_pin_base = 16, // Base data pin
  .data_bits = 8,      // The SparkFun MicroMod ML Carrier Board has all 8 data pins connected
  .pio = pio0,
  .pio_sm = 0,
  .reset_pin = 24,
  .mclk_pin = 10,
#endif
  .width = IMAGE_WIDTH,
  .height = IMAGE_HEIGHT,
};

static SLIC slic;
uint8_t pixels[BUFFER_SIZE];
uint8_t compressedBuffer[BUFFER_SIZE];

void setup() {
  Serial.begin(921600);
  pinMode(8, OUTPUT);
  digitalWrite(8, HIGH);
  // while(!Serial);
  Serial.println("Initializing Camera");
  if (hm01b0_init(&hm01b0_config) != 0) {
    Serial.println("Failed to initialize camera!");
    while(true) {}
  }
  Serial.println("Camera Initialized");
  Serial1.begin(1000000);
  while(!Serial1);
  Serial.println("Serial1 Initialized");
  delay(5000);
  digitalWrite(8, LOW);
}

bool writeChunked(uint8_t* buffer, size_t totalSize) {
    
    const uint8_t CHUNK_START_MARKER[] = {0xFF, 0xCC, 0xFF, 0xCC};
    const uint8_t CHUNK_END_MARKER[] = {0xFF, 0xDD, 0xFF, 0xDD};
    
    size_t bytesRemaining = totalSize;
    size_t offset = 0;
    uint8_t ackByte;
    uint16_t chunk_index = 0;
    int total_retries = 0;

    Serial.printf("Sending %d bytes in %d chunks\n", totalSize, totalSize/CHUNK_SIZE);
    // Serial.printf("In hex 0x%08lX\n", totalSize, totalSize);
    while (bytesRemaining > 0) {
        // Calculate size of next chunk
        size_t chunkSize = min(CHUNK_SIZE, bytesRemaining);
        bool chunkAcked = false;
        // Serial.printf("Sending chunk %d, size: %d\n", chunk_index, chunkSize);
        int tries = 0;
        
        while (!chunkAcked) {
            // Send chunk marker
            Serial1.write(CHUNK_START_MARKER, 4);
            
            // Write chunk
            Serial1.write(buffer + offset, chunkSize);

            Serial1.write(CHUNK_END_MARKER, 4);
            
            // Wait for ACK
            unsigned long startTime = millis();
            while (millis() - startTime < ACK_TIMEOUT_MS) {
                if (Serial1.available()) {
                    ackByte = Serial1.read();
                    if (ackByte == 0xAC) {
                        chunkAcked = true;
                        // Serial.println("Ack received");
                        chunk_index++;
                        break;
                    }
                }
            }
            if(!chunkAcked) {
              tries++;
              // Serial.printf("Sending chunk %d again\n", chunk_index);
              total_retries++;
            }
            if(tries > ACK_RETRIES) {
              return false;
            }
        }
        
        // Update tracking variables
        offset += chunkSize;
        bytesRemaining -= chunkSize;
    }
    Serial.printf("Total Retries: %d\n", total_retries);
    return true;
}

void loop() {
  if(Serial1.available()) {
    char c = Serial1.read();
    if(c == 'c') {
      Serial.printf("Received capture command\n", c);
      sendImage();
    }
  }
  delay(10); 
}

void sendImage() {
  digitalWrite(8, HIGH);
  int startTime = millis();
  hm01b0_read_frame(pixels, sizeof(pixels));

   // Initialize SLIC encoder for grayscale image (8bpp)
  int rc = slic.init_encode_ram(IMAGE_WIDTH, IMAGE_HEIGHT, 8, NULL, 
                              compressedBuffer, BUFFER_SIZE);
  
  if (rc != SLIC_SUCCESS) {
    Serial.print("SLIC initialization failed with error: ");
    Serial.println(rc);
  } else {
    // Encode the entire image
    rc = slic.encode(pixels, IMAGE_WIDTH * IMAGE_HEIGHT);
        
    if (rc == SLIC_DONE) {
      
    //   // Get the size of compressed data
      uint32_t compressedSize = slic.get_output_size();
      Serial.printf("Compressed size: %d\n", compressedSize);

      delay(10);
      Serial1.write(0xFF);
      Serial1.write(0xAA);
      Serial1.write(0xFF);
      Serial1.write(0xAA);
      
      // Serial1.write((uint8_t*)&compressedSize, sizeof(compressedSize));
      // bool written = writeChunked(compressedBuffer, compressedSize);
      // uint32_t checksum = fletcher32(compressedBuffer, compressedSize);
      
      uint32_t pixelSize = 102400;
      Serial1.write((uint8_t*)&pixelSize, sizeof(pixelSize));
      bool written = writeChunked(pixels, pixelSize);
      uint32_t checksum = fletcher32(pixels, pixelSize);
      
      Serial.printf("Fletcher-32 checksum: 0x%08X\n", checksum);

      if (written) {
        delay(10);
        Serial.print("Sent in ");
        Serial.println(millis()-startTime);
      } else {
        Serial.println("Write failed, NRF isn't responding");
      }

      
    } else {
      Serial.print("SLIC encoding failed with error: ");
      Serial.println(rc);
    }
  }
  digitalWrite(8, LOW);
}


// Fletcher checksum calculation for uint8_t array
uint32_t fletcher32(uint8_t const *data, size_t len) {
    uint32_t sum1 = 0xffff, sum2 = 0xffff;
    size_t tlen = len;
    
    // Process pairs of bytes as 16-bit words
    while (len > 1) {
        size_t blocks = (len > 718) ? 718 : len;
        len -= blocks;
        blocks /= 2;  // Process two bytes at a time
        
        while (blocks) {
            // Combine two bytes into a 16-bit word
            uint16_t word = (data[0] << 8) | data[1];
            sum1 += word;
            sum2 += sum1;
            data += 2;
            blocks--;
        }
        
        sum1 = (sum1 & 0xffff) + (sum1 >> 16);
        sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    }
    
    // Handle last byte if length is odd
    if (len) {
        sum1 += (*data << 8);
        sum2 += sum1;
        sum1 = (sum1 & 0xffff) + (sum1 >> 16);
        sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    }
    
    // Second reduction step to reduce sums to 16 bits
    sum1 = (sum1 & 0xffff) + (sum1 >> 16);
    sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    
    return (sum2 << 16) | sum1;
}