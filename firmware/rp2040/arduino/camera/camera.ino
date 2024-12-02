// #include <stdio.h>
// #include "pico/stdlib.h"
// #include "pico/binary_info.h"
#include "hm01b0.h"

#define ASP_NRF
// // Data will be copied from src to dst
const char src[] = "Hello, world! (from DMA)";
char dst[count_of(src)];

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

    .width = 160,
    .height = 120,
};

// // based on: http://paulbourke.net/dataformats/asciiart/
const char REMAP[] = {
    '$', '$', '$', '$', '@', '@', '@', '@', 'B', 'B', 'B', 'B', '%', '%', '%', '8',
    '8', '8', '8', '&', '&', '&', '&', 'W', 'W', 'W', 'M', 'M', 'M', 'M', '#', '#',
    '#', '#', '*', '*', '*', 'o', 'o', 'o', 'o', 'a', 'a', 'a', 'a', 'h', 'h', 'h',
    'h', 'k', 'k', 'k', 'b', 'b', 'b', 'b', 'd', 'd', 'd', 'd', 'p', 'p', 'p', 'q',
    'q', 'q', 'q', 'w', 'w', 'w', 'w', 'm', 'm', 'm', 'Z', 'Z', 'Z', 'Z', 'O', 'O',
    'O', 'O', '0', '0', '0', 'Q', 'Q', 'Q', 'Q', 'L', 'L', 'L', 'L', 'C', 'C', 'C',
    'C', 'J', 'J', 'J', 'U', 'U', 'U', 'U', 'Y', 'Y', 'Y', 'Y', 'X', 'X', 'X', 'z',
    'z', 'z', 'z', 'c', 'c', 'c', 'c', 'v', 'v', 'v', 'u', 'u', 'u', 'u', 'n', 'n',
    'n', 'n', 'x', 'x', 'x', 'x', 'r', 'r', 'r', 'j', 'j', 'j', 'j', 'f', 'f', 'f',
    'f', 't', 't', 't', '/', '/', '/', '/', '\\', '\\', '\\', '\\', '|', '|', '|',
    '(', '(', '(', '(', ')', ')', ')', ')', '1', '1', '1', '{', '{', '{', '{', '}',
    '}', '}', '}', '[', '[', '[', '[', ']', ']', ']', '?', '?', '?', '?', '-', '-',
    '-', '-', '_', '_', '_', '+', '+', '+', '+', '~', '~', '~', '~', '<', '<', '<',
    '>', '>', '>', '>', 'i', 'i', 'i', 'i', '!', '!', '!', '!', 'l', 'l', 'l', 'I',
    'I', 'I', 'I', ';', ';', ';', ';', ':', ':', ':', ',', ',', ',', ',', '"', '"',
    '"', '"', '^', '^', '^', '`', '`', '`', '`', '\'', '\'', '\'', '\'', '.', '.', '.',
    ' '};

uint8_t pixels[160 * 120];
char row[160 + 1];

bool reserved_addr(uint8_t addr)
{
    return (addr & 0x78) == 0 || (addr & 0x78) == 0x78;
}

void setup() {
  Serial.begin(115200);
  while(!Serial);
  Serial.print("Initializing \n");

  Serial.print("Initializing Camera \n");
  if (hm01b0_init(&hm01b0_config) != 0)
  {
      Serial.print("failed to initialize camera!\n");
      while(true) {
      }
  }
  Serial.print("Camera Initialized \n");

}

void loop() {
  if (Serial.available()) {
    // get the new byte:
    char userInput = Serial.read();
    if (userInput == '1')
    {
        row[160] = '\0';
        Serial.println("Starting stream");
        while (true) {
          hm01b0_read_frame(pixels, sizeof(pixels));
          Serial.printf("\033[2J");
          for (int y = 0; y < 120; y += 2)
          {
              // Map each pixel in the row to an ASCII character, and send the row over stdio
              Serial.printf("\033[%dH", y / 2);
              for (int x = 0; x < 160; x++)
              {
                  uint8_t pixel = pixels[160 * y + x];
                  row[x] = REMAP[pixel];
              }
              Serial.printf("%s\033[K", row);
              Serial.println();
          }
          Serial.printf("\033[J");
        }
    }
    else
    {
        Serial.printf("Invalid Input!\n");
    }
  }

}
