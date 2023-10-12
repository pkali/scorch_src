import argparse
from PIL import Image
import random

class AtariFont:
    """representation of Atari 8-bit font as a list 128 characters, each character is a 8 bytes long list"""
    def __init__(self):
        self.font = [[0, 0, 255, 0, 0, 0xaa, 1, 0] for _ in range(128)]

    def to_image(self) -> Image:
        fnt_img = Image.new("1", (32 * 8, 4 * 8))
        i = 0
        for x in range(32):
            for y in range(4):
                for y_offset, v in enumerate(self.font[i]):
                    for b in range(8):
                        c = (v & (1 << b)) >> b
                        pos = (x * 8 + b, y * 8 + y_offset)
                        fnt_img.putpixel(pos, c)
                i += 1
        return fnt_img


def convert_st(im: Image):
    print(im.format, im.size, im.mode)
    im.convert('1')
    print(im.format, im.size, im.mode)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Convert AtariST 128x256 font image to Atari 8-bit fnt file(s) ")
    parser.add_argument('--file', '-f', dest='file', type=str, required=True,
                        help="AtariST picture file")
    args = parser.parse_args()

    st = Image.open(args.file)
    convert_st(st)
    a = AtariFont()
    a.to_image().save("test.bmp")



