#!/usr/bin/env python
"""
Pacman-x86: a Pacman implementation in pure x86 assembly.
@file Sprite image converter.
@author Rodrigo Siqueira <rodriados@gmail.com>
@copyright 2023-present Rodrigo Siqueira
"""
import argparse
import struct
import sys

from PIL import Image
from typing import List

# Converts an image sprite file into a file with the raw image bytes.
# @param src The source sprite file to be converted.
# @param dest The destination file to store the binary data.
def convert_sprite(src: str, dest: str):
    with Image.open(src, 'r') as fsource:
        with open(dest, 'wb') as fdestination:
            rgba = fsource.convert('RGBA')
            shape = struct.pack('>LL', rgba.width, rgba.height)

            fdestination.write(shape)
            fdestination.write(rgba.tobytes())

# Parses the command line arguments and runs the script.
# @param args The script command line arguments.
def main(args: List[str]):
    parser = argparse.ArgumentParser(
        description = "script for converting sprite image files to binary files"
      , formatter_class = argparse.RawTextHelpFormatter)
    parser.add_argument('src',  type = str, help = "the original sprite file to be converted")
    parser.add_argument('dest', type = str, help = "the path to save the converted sprite file")
    args = parser.parse_args(args)

    convert_sprite(args.src, args.dest)

if __name__ == '__main__':
    r = main(sys.argv[1:])
    raise SystemExit(r)
