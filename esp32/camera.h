// Camera functionality header for OpenGlass project
// Declares functions and variables for camera operations

#ifndef CAMERA_H
#define CAMERA_H

#include <stdint.h>
#include <stdbool.h>

// Function declarations
void configure_camera();
bool take_photo();
void send_photo_data();

// External variable declarations
extern size_t sent_photo_bytes;
extern size_t sent_photo_frames;
extern bool photoDataUploading;

#endif // CAMERA_H