// com.h
#ifndef COM_H
#define COM_H

#include <Arduino.h>

#define IMAGE_WIDTH 160
#define IMAGE_HEIGHT 120
#define MAX_FRAME_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT)
#define CHUNK_SIZE 256
#define RECEIVE_TIMEOUT 3000

void processIncomingData();
void sendBufferInPackets();

#endif