# SPDX-FileCopyrightText: 2021 ladyada for Adafruit Industries
# SPDX-License-Identifier: MIT

import os
import busio
import digitalio
import board
import storage
import adafruit_sdcard
import audiomp3
import audiobusio
from audiocore import WaveFile

board_id = "pi"

if board_id == "micromod":
    DATA = board.GP6
    BCLK = board.GP26
    LRCLK = board.GP27
    audio = audiobusio.I2SOut(BCLK, LRCLK, DATA)
    SD_CS = board.GP21
    CLK = board.GP22
    MOSI = board.GP23
    MISO = board.GP20
    spi = busio.SPI(CLK, MOSI, MISO)
else:
    DATA = board.GP28
    BCLK = board.GP26
    LRCLK = board.GP27
    audio = audiobusio.I2SOut(BCLK, LRCLK, DATA)
    SD_CS = board.GP13
    CLK = board.GP10
    MOSI = board.GP11
    MISO = board.GP12
    spi = busio.SPI(CLK, MOSI, MISO)

cs = digitalio.DigitalInOut(SD_CS)
sdcard = adafruit_sdcard.SDCard(spi, cs)
vfs = storage.VfsFat(sdcard)
storage.mount(vfs, "/sd")
print("Mounted SD card")


wave_files = ["/sd/"+file for file in os.listdir('/sd') if not file.startswith('._')]
print(wave_files)
decoder = audiomp3.MP3Decoder(open("/sd/input.mp3", "rb"))
#wave_file = open("/sd/nathik.wav", "rb")
#wave = WaveFile(wave_file)
print("playing")

while True:
    audio.play(decoder)
    while audio.playing:
        pass
print("Done playing!")








