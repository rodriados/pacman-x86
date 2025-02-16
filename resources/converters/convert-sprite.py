#!/usr/bin/env python
"""
Pacman-x86: a Pacman implementation in pure x86 assembly.
@file Sprite image converter.
@author Rodrigo Siqueira <rodriados@gmail.com>
@copyright 2023-present Rodrigo Siqueira
"""
import sys, struct

from argparse import ArgumentParser
from PIL import Image
from typing import List

# Converts an image sprite file into a file with the raw image bytes.
# @param infile The source sprite file to be converted.
# @param outfile The destination file to store the binary data.
def convert_sprite(*, infile: str, outfile: str) -> None:
    with Image.open(infile, 'r') as fsource:
        with open(outfile, 'wb') as fdestination:
            rgba = fsource.convert('RGBA')
            shape = struct.pack('<LL', rgba.width, rgba.height)

            fdestination.write(shape)
            fdestination.write(rgba.tobytes())

if __name__ == '__main__':
    parser = ArgumentParser(description = "sprite image files conversion script")

    parser.add_argument('-i', '--infile',
        help = "the sprite file to be converted",
        type = str, dest = 'infile')

    parser.add_argument('-o', '--outfile',
        help = "the path to save the converted sprite file",
        type = str, dest = 'outfile')

    args = parser.parse_args()

    convert_sprite(infile = args.infile, outfile = args.outfile)
