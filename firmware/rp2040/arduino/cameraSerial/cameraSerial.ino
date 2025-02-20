#include "hm01b0.h"
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
    .width = 320,
    .height = 320,
};

uint8_t pixels[320 * 320];

void setup() {
    Serial.begin(921600); // Increase baud rate for faster transmission
    Serial.println("Initializing");
    Serial.println("Initializing Camera");
    if (hm01b0_init(&hm01b0_config) != 0) {
        Serial.println("Failed to initialize camera!");
        while(true) {}
    }
    Serial.println("Camera Initialized");
}

void loop() {
    hm01b0_read_frame(pixels, sizeof(pixels));
    
    // Send start marker
    Serial.write(0xFF);
    Serial.write(0xAA);
    
    // Send pixel data
    Serial.write(pixels, sizeof(pixels));
    
    // Send end marker
    Serial.write(0xFF);
    Serial.write(0xBB);
    
    // Optional: Add a small delay to control frame rate
    delay(10);
}