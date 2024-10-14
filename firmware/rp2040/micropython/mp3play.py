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

board_id = "pi"

if board_id == "micromod":
    DATA = board.GP6
    LRCLK = board.GP26
    BCLK = board.GP27
    audio = audiobusio.I2SOut(BCLK, LRCLK, DATA)
    SD_CS = board.GP21
    spi = busio.SPI(board.GP22, board.GP23, board.GP20)
else:
    DATA = board.GP28
    LRCLK = board.GP26
    BCLK = board.GP27
    audio = audiobusio.I2SOut(BCLK, LRCLK, DATA)
    SD_CS = board.GP13
    spi = busio.SPI(board.GP10, board.GP11, board.GP12)

cs = digitalio.DigitalInOut(SD_CS)
sdcard = adafruit_sdcard.SDCard(spi, cs)
vfs = storage.VfsFat(sdcard)
storage.mount(vfs, "/sd")
print("Mounted SD card")


wave_files = ["/sd/"+file for file in os.listdir('/sd') if file.endswith('.mp3') and not file.startswith('._')]
print(wave_files)
decoder = audiomp3.MP3Decoder(open("/sd/input.mp3", "rb"))
print("playing")

while True:
    audio.play(decoder)
    while audio.playing:
        pass
print("Done playing!")








