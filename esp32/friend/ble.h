// BLE functionality header for OpenGlass project
// Declares functions and variables for BLE operations

#ifndef BLE_H
#define BLE_H

#include <stdint.h>
#include <stdlib.h>

// Function declarations
void configure_ble();
bool is_ble_connected();
void send_audio_data(uint8_t* data, size_t length);
void send_photo_data(uint8_t* data, size_t length);
void updateBatteryLevel(uint8_t level);

// External variable declarations
extern uint16_t audio_frame_count;

#endif // BLE_H