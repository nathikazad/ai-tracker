#include "hm01b0.h"
#define CAM_TEST
const struct hm01b0_config hm01b0_config = {
    .i2c = i2c_default,
    .sda_pin = PICO_DEFAULT_I2C_SDA_PIN,
    .scl_pin = PICO_DEFAULT_I2C_SCL_PIN,
#ifdef SPARKFUN_MICROMOD
    .vsync_pin = 25,
    .hsync_pin = 28,
    .pclk_pin = 11,
    .data_pin_base = 16,
    .data_bits = 8,
    .pio = pio0,
    .pio_sm = 0,
    .reset_pin = 24,
    .mclk_pin = 10,
#elif defined(CAM_TEST)
  .vsync_pin = 6,
  .hsync_pin = 7,
  .pclk_pin = 8,
  .data_pin_base = 10,
  .data_bits = 8,
  .pio = pio0,
  .pio_sm = 0,
  .reset_pin = 3,
  .mclk_pin = 9,
#else
    .vsync_pin = 6,
    .hsync_pin = 7,
    .pclk_pin = 8,
    .data_pin_base = 9,
    .data_bits = 1,
    .pio = pio0,
    .pio_sm = 0,
    .reset_pin = -1,
    .mclk_pin = -1,
#endif
    .width = 320,
    .height = 320,
};

uint8_t pixels[320 * 320];

void setup() {
    Serial.begin(921600);
    // Serial1.begin(921600);
    while(!Serial);
    Serial.println("Initializing");
    // Serial.println("Initializing Camera");
    if (hm01b0_init(&hm01b0_config) != 0) {
        Serial.println("Failed to initialize camera!");
        while(true) {}
    }
    while(!Serial);
    Serial.println("Camera Initialized");
}

void loop() {
    if (Serial.available() > 0) {
        char command = Serial.read();
        if (command == 'c') {
          // Serial.println("Camera capture");
          captureAndSendImage();
        }
    }
}

void captureAndSendImage() {
    hm01b0_read_frame(pixels, sizeof(pixels));
    
    // Send start marker
    Serial.write(0xFF);
    Serial.write(0xAA);
    
    // Send pixel data
    Serial.write(pixels, sizeof(pixels));
    
    // Send end marker
    Serial.write(0xFF);
    Serial.write(0xBB);
}