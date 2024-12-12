// state.h
#ifndef STATE_H
#define STATE_H

enum MainState {
    READY = 0,
    RECORDING_AUDIO = 1,
    RECEIVING_AUDIO = 2,
    CAPTURING_IMAGE = 3
};

extern MainState mainState;

#define IMAGE_CAPTURE_PERIOD 10000
extern int lastImageCaptureTime;

#define AUDIO_RECEIVE_TIMEOUT 20000
extern int audioReceiveStartTime;

extern int buttonState;

extern void receiveAudio(uint8_t* data, uint16_t len); 

#endif