#pragma once

#include <Arduino.h>

class SDCard;

const size_t MAX_FRAME_SIZE = 512;
const size_t MAX_PACKET_SIZE = MAX_FRAME_SIZE + 4;

class BLETransmitter {
public:
    BLETransmitter(SDCard& sd);
    void begin();
    void transmitFiles();

private:
    // void sendPacket(uint16_t packetIndex, const uint8_t* data, size_t length, uint16_t numFrames = 0);
    static void transmitTask(void *pvParameters);
    SDCard& sdCard;
};