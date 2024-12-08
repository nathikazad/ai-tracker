#include "hm01b0.h"
#define ASP_NRF
const struct hm01b0_config hm01b0_config = {
  .i2c = i2c_default,
  .sda_pin = PICO_DEFAULT_I2C_SDA_PIN,
  .scl_pin = PICO_DEFAULT_I2C_SCL_PIN,


#define WIDTH 160
#define HEIGHT 120
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
    .width = WIDTH,
    .height = HEIGHT,
};

uint8_t pixels[WIDTH * HEIGHT];

void setup() {
    
    Serial.begin(921600); // Increase baud rate for faster transmission
    while(!Serial);
    Serial.println("Initializing Camera");
    if (hm01b0_init(&hm01b0_config) != 0) {
        Serial.println("Failed to initialize camera!");
        while(true) {}
    }
    Serial.println("Camera Initialized");
    Serial1.begin(460800);
    while(!Serial1);
    Serial.println("Serial1 Initialized");
}

void loop() {
    
    int startTime = millis();
    hm01b0_read_frame(pixels, sizeof(pixels));
    Serial.print("Captured in ");
    Serial.println(millis()-startTime);
    startTime = millis();
    // Send start marker
    Serial1.write(0xFF);
    Serial1.write(0xAA);
    
    // Send pixel data
    Serial1.write(pixels, sizeof(pixels));
    
    // Send end marker
    Serial1.write(0xFF);
    Serial1.write(0xBB);

    Serial.print("Sent in ");
    Serial.println(millis()-startTime);
    
    // Optional: Add a small delay to control frame rate
    delay(5000);
}