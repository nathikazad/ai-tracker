// com.h
#ifndef CAM_H
#define CAM_H

#include <Arduino.h>

#define IMAGE_WIDTH 160
#define IMAGE_HEIGHT 120
#define MAX_FRAME_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT)
#define CHUNK_SIZE 256
#define RECEIVE_TIMEOUT 3000

enum CamReceptionState {
  IDLE = 0,
  WAITING_FOR_START = 1,
  RECEIVING_SIZE = 2,
  RECEIVING_CHUNKS = 3
};



void receiveCameraImage();
void sendBufferInPackets();

#endif