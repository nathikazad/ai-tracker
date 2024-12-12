#ifndef CAM_H
#define CAM_H

#include <stdint.h>
#include <stddef.h>
#include <slic.h>
#include <fletcher_checksum.h>
#include "config.h"
#include "Arduino.h"

void setupCamera();
void sendImage();
bool writeChunked(uint8_t* buffer, size_t totalSize);

#endif // SERIAL_TRANSFER_H