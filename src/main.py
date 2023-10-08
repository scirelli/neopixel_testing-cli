#!/usr/bin/env python3
# NeoPixels must be connected to GPIO10, GPIO12, GPIO18 or GPIO21 to work!
import board
import neopixel

PIXEL_COUNT = 24
ORDER = neopixel.GRB

# Choose an open pin connected to the Data In of the NeoPixel strip, i.e. board.D18
# NeoPixels must be connected to D10, D12, D18 or D21 to work.
pixel_pin = board.D18

def main():
    pixels = neopixel.NeoPixel(pixel_pin, PIXEL_COUNT, bpp=3, brightness=1, auto_write=False, pixel_order=ORDER)
    #pixels[0] = (0, 0, 0)
    pixels.fill((255, 255, 255))
    pixels.show()


if __name__ == "__main__":
    main()
