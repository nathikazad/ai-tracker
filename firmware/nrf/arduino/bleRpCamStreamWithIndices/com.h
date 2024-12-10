// com.h
#ifndef COM_H
#define COM_H

#include <Arduino.h>

#define FRAME_WIDTH 320
#define FRAME_HEIGHT 320
#define FRAME_SIZE (FRAME_WIDTH * FRAME_HEIGHT)

void setupCom();
void processIncomingData();
void sendBufferInPackets();

#endif