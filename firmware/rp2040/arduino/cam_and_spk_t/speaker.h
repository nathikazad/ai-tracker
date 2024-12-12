#ifndef SPEAKER_H
#define SPEAKER_H

#include "config.h"
#include "Arduino.h"
#include "MP3DecoderHelix.h"
#include <I2S.h>
#include "pico/multicore.h"
#include "pico/sync.h"

void setupSpeaker();
void playAudio();

#endif // SERIAL_TRANSFER_H