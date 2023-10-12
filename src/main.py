#!/usr/bin/env python3
# NeoPixels must be connected to GPIO10, GPIO12, GPIO18 or GPIO21 to work!
from os import path
from sys import stdout, stdin, stderr
from itertools import zip_longest
from collections import defaultdict
import argparse
import json
import board
import neopixel

PIXEL_COUNT = 24
ORDER = neopixel.GRB

# Choose an open pin connected to the Data In of the NeoPixel strip, i.e. board.D18
# NeoPixels must be connected to D10, D12, D18 or D21 to work.
pixel_pin = board.D18

SCRIPT_NAME = path.basename(__file__)
FORMATS = ('json', 'csv', 'text')


def lightIt():
    pixels = neopixel.NeoPixel(pixel_pin, PIXEL_COUNT, bpp=3, brightness=1, auto_write=False, pixel_order=ORDER)
    #pixels[0] = (0, 0, 0)
    pixels.fill((255, 255, 255))
    pixels.show()


def noop(_):
    print('Please choose a command to run.')


def color(args):
    print(args)


def on(args):
    print(args)


def off(args):
    print(args)


def main():
    parser = argparse.ArgumentParser(
        description='%(prog)s light up some pixels!',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.set_defaults(func=noop)
    subparsers = parser.add_subparsers(
        title='Commands',
        description='Please see individual commands\' help for more information on each command.',
        help='''Examples:
        %(prog)s color --help
        %(prog)s on --help
        %(prog)s off --help
        '''
    )

    parser_list_services = subparsers.add_parser('color', aliases=['c'], description='Set the pixel color.')
    parser_list_services.add_argument('-r', '--red', default=int, help='Red value')
    parser_list_services.add_argument('-g', '--green', default=int, help='Green value')
    parser_list_services.add_argument('-c', '--blue', default=int, help='Blue value')
    parser_list_services.set_defaults(func=color)

    parser_on = subparsers.add_parser('on',
                                       aliases=['o'],
                                       description='Turn pixels on.',
                                       usage='%(prog)s on',
                                       formatter_class=argparse.RawTextHelpFormatter)
    parser_off.set_defaults(func=on)

    parser_off = subparsers.add_parser('off',
                                        aliases=['f'],
                                        description='Turn pixels off.',
                                        usage='%(prog)s off',
                                        formatter_class=argparse.RawTextHelpFormatter)
    parser_off.set_defaults(func=off)

    args = parser.parse_args()
    args.func(args)


if __name__ == '__main__':
    main()
