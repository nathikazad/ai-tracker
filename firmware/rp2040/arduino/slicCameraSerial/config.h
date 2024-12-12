#ifndef CONFIG_H
#define CONFIG_H

#include "hm01b0.h"

#define LED 8
#define NRF_BAUD_RATE 1000000
#define IMAGE_WIDTH 160
#define IMAGE_HEIGHT 120
#define BUFFER_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT)
#define CHUNK_SIZE 256
#define ACK_TIMEOUT_MS 5
#define ACK_RETRIES 5

// Camera configuration definitions
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

#endif // CAMERA_CONFIG_H