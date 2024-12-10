#include "hm01b0.h"
#include <slic.h>

#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 320
#define BUFFER_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT)

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
  Serial.println("Initializing Camera");
  if (hm01b0_init(&hm01b0_config) != 0) {
    Serial.println("Failed to initialize camera!");
    while(true) {}
  }
  Serial.println("Camera Initialized");
  Serial1.begin(1000000);
  while(!Serial1);
  Serial.println("Serial1 Initialized");

    // Initialize SLIC encoder for grayscale image (8bpp)
  int rc = slic.init_encode_ram(IMAGE_WIDTH, IMAGE_HEIGHT, 8, NULL, 
                              compressedBuffer, BUFFER_SIZE);
  
  if (rc != SLIC_SUCCESS) {
    Serial.print("SLIC initialization failed with error: ");
    Serial.println(rc);
    while(true) {}
  }
}

void writeChunked(uint8_t* buffer, size_t totalSize) {
    const size_t CHUNK_SIZE = 1024;
    const unsigned long DELAY_MS = 0;
    
    size_t bytesRemaining = totalSize;
    size_t offset = 0;
    
    while (bytesRemaining > 0) {
        // Calculate size of next chunk
        size_t chunkSize = min(CHUNK_SIZE, bytesRemaining);
        
        // Write chunk
        Serial1.write(buffer + offset, chunkSize);
        
        // Update tracking variables
        offset += chunkSize;
        bytesRemaining -= chunkSize;
        
        // Delay between chunks
        delay(DELAY_MS);
    }
}

void loop() {
  int startTime = millis();
  hm01b0_read_frame(pixels, sizeof(pixels));

  // Encode the entire image
  int rc = slic.encode(pixels, IMAGE_WIDTH * IMAGE_HEIGHT);
      
  if (rc == SLIC_DONE) {
    
    // Get the size of compressed data
    int compressedSize = slic.get_output_size();

    Serial.print("Compressed size: ");
    Serial.print(compressedSize);
    Serial.print(", ");
    delay(10);
    Serial1.write(0xFF);
    Serial1.write(0xAA);
    Serial1.write(0xFF);
    Serial1.write(0xAA);
    
    Serial1.write((uint8_t*)&compressedSize, sizeof(compressedSize));
    writeChunked(compressedBuffer, compressedSize);

    delay(10);
    Serial1.write(0xFF);
    Serial1.write(0xBB);
    Serial1.write(0xFF);
    Serial1.write(0xBB);

    Serial.print("Sent in ");
    Serial.println(millis()-startTime);
    
  } else {
    Serial.print("SLIC encoding failed with error: ");
    Serial.println(rc);
  }
  
  delay(5000); 
}