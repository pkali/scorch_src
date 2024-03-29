""" Converts manual files to atari SCREENCODES ready for display
"""
import re
import sys

MAX_W = 40


def break_long_string(long_string):
    """ write a python function that breaks a long string of words to a list of MAX_W long strings.
    Important - each new string must contain the full word, no breaking inside words."""
    # words = long_string.split()
    result = []
    # current_string = ' ' * spaces
    # for word in words:
    #     if len(current_string) + len(word) <= MAX_W:
    #         current_string += word + ' '
    #     else:
    #         result.append(current_string.rstrip())
    #         current_string = word + ' '
    #
    # if current_string:
    #     result.append(current_string.rstrip())
    while len(long_string) > MAX_W:
        spaces = len(long_string) - len(long_string.lstrip())
        brk = long_string.rfind(' ', 0, MAX_W)
        result.append(long_string[0:brk])
        long_string = ' ' * (spaces - 1) + long_string[brk:]
    else:
        result.append(long_string)
    return result


def remove_wierd(t: str) -> str:
    t = re.sub(r'!.*\)?', '', t)  # remove embedded image
    t = re.sub(r'[#`]', '', t)
    # convert inverses (** to ascii+128
    i = 0
    out = ''
    while i < len(t):
        if t[i:i+2] == '**':
            star2_i = t.find('**', i+1)
            out += ''.join(chr(ord(x)+128) for x in t[i+2:star2_i])
            i = star2_i+2
        else:
            out += t[i]
            i += 1
    return out


with open(sys.argv[1], 'r') as f:
    md = f.readlines()
out = ''
for line in md:
    line = line.replace('ó', 'ɠ')  # this is a dirty trick to avoid tripping 'ó' which is a legit LATIN-1 char
    if line.startswith('#'):  # header
        line = remove_wierd(line)
        out += '←' + line[1:]  # header marker
        out += '-' * len(line) + '\n'
    else:
        line = remove_wierd(line)
        out += line

# make lines break on words
out2 = ''
for line in out.split('\n'):
    if len(line) <= MAX_W:
        out2 += line + '\n'
    else:
        for line_shorter in break_long_string(line):
            out2 += line_shorter + '\n'

utf_to_internal = {
    ' ': 0,
    '!': 1,
    '"': 2,
    '#': 3,
    '$': 4,
    '%': 5,
    '&': 6,
    "'": 7,
    '(': 8,
    ')': 9,
    '*': 10,
    '+': 11,
    ',': 12,
    '-': 13,
    '.': 14,
    '/': 15,
    '0': 16,
    '1': 17,
    '2': 18,
    '3': 19,
    '4': 20,
    '5': 21,
    '6': 22,
    '7': 23,
    '8': 24,
    '9': 25,
    ':': 26,
    ';': 27,
    '<': 28,
    '=': 29,
    '>': 30,
    '?': 31,
    '@': 32,
    'A': 33,
    'B': 34,
    'C': 35,
    'D': 36,
    'E': 37,
    'F': 38,
    'G': 39,
    'H': 40,
    'I': 41,
    'J': 42,
    'K': 43,
    'L': 44,
    'M': 45,
    'N': 46,
    'O': 47,
    'P': 48,
    'Q': 49,
    'R': 50,
    'S': 51,
    'T': 52,
    'U': 53,
    'V': 54,
    'W': 55,
    'X': 56,
    'Y': 57,
    'Z': 58,
    '[': 59,
    '\\': 60,
    ']': 61,
    '^': 62,
    '_': 63,
    'a': 97,
    'b': 98,
    'c': 99,
    'd': 100,
    'e': 101,
    'f': 102,
    'g': 103,
    'h': 104,
    'i': 105,
    'j': 106,
    'k': 107,
    'l': 108,
    'm': 109,
    'n': 110,
    'o': 111,
    'p': 112,
    'q': 113,
    'r': 114,
    's': 115,
    't': 116,
    'u': 117,
    'v': 118,
    'w': 119,
    'x': 120,
    'y': 121,
    'z': 122,
    '|': 124,
    'Ą': 65,
    'ą': 66,
    'Ć': 67,
    'ć': 68,
    'Ę': 69,
    'ę': 70,
    'Ł': 76,
    'ł': 77,
    'Ń': 78,
    'ń': 79,
    'Ó': 80,
    'ɠ': 81,  # 'ó': 81,
    'Ś': 83,
    'ś': 84,
    'Ż': 87,
    'ż': 88,
    'Ź': 89,
    'ź': 90,
    '↓': 93,
    '←': 0xfe,  # header marker
    # INVERSE
    chr(ord(' ')+128): 128+0,
    chr(ord('!')+128): 128+1,
    chr(ord('"')+128): 128+2,
    chr(ord('#')+128): 128+3,
    chr(ord('$')+128): 128+4,
    chr(ord('%')+128): 128+5,
    chr(ord('&')+128): 128+6,
    chr(ord("'")+128): 128+7,
    chr(ord('(')+128): 128+8,
    chr(ord(')')+128): 128+9,
    chr(ord('*')+128): 128+10,
    chr(ord('+')+128): 128+11,
    chr(ord(',')+128): 128+12,
    chr(ord('-')+128): 128+13,
    chr(ord('.')+128): 128+14,
    chr(ord('/')+128): 128+15,
    chr(ord('0')+128): 128+16,
    chr(ord('1')+128): 128+17,
    chr(ord('2')+128): 128+18,
    chr(ord('3')+128): 128+19,
    chr(ord('4')+128): 128+20,
    chr(ord('5')+128): 128+21,
    chr(ord('6')+128): 128+22,
    chr(ord('7')+128): 128+23,
    chr(ord('8')+128): 128+24,
    chr(ord('9')+128): 128+25,
    chr(ord(':')+128): 128+26,
    chr(ord(';')+128): 128+27,
    chr(ord('<')+128): 128+28,
    chr(ord('=')+128): 128+29,
    chr(ord('>')+128): 128+30,
    chr(ord('?')+128): 128+31,
    chr(ord('@')+128): 128+32,
    chr(ord('A')+128): 128+33,
    chr(ord('B')+128): 128+34,
    chr(ord('C')+128): 128+35,
    chr(ord('D')+128): 128+36,
    chr(ord('E')+128): 128+37,
    chr(ord('F')+128): 128+38,
    chr(ord('G')+128): 128+39,
    chr(ord('H')+128): 128+40,
    chr(ord('I')+128): 128+41,
    chr(ord('J')+128): 128+42,
    chr(ord('K')+128): 128+43,
    chr(ord('L')+128): 128+44,
    chr(ord('M')+128): 128+45,
    chr(ord('N')+128): 128+46,
    chr(ord('O')+128): 128+47,
    chr(ord('P')+128): 128+48,
    chr(ord('Q')+128): 128+49,
    chr(ord('R')+128): 128+50,
    chr(ord('S')+128): 128+51,
    chr(ord('T')+128): 128+52,
    chr(ord('U')+128): 128+53,
    chr(ord('V')+128): 128+54,
    chr(ord('W')+128): 128+55,
    chr(ord('X')+128): 128+56,
    chr(ord('Y')+128): 128+57,
    chr(ord('Z')+128): 128+58,
    chr(ord('[')+128): 128+59,
    chr(ord('\\')+128): 128+60,
    chr(ord(']')+128): 128+61,
    chr(ord('^')+128): 128+62,
    chr(ord('_')+128): 128+63,
    chr(ord('a')+128): 128+97,
    chr(ord('b')+128): 128+98,
    chr(ord('c')+128): 128+99,
    chr(ord('d')+128): 128+100,
    chr(ord('e')+128): 128+101,
    chr(ord('f')+128): 128+102,
    chr(ord('g')+128): 128+103,
    chr(ord('h')+128): 128+104,
    chr(ord('i')+128): 128+105,
    chr(ord('j')+128): 128+106,
    chr(ord('k')+128): 128+107,
    chr(ord('l')+128): 128+108,
    chr(ord('m')+128): 128+109,
    chr(ord('n')+128): 128+110,
    chr(ord('o')+128): 128+111,
    chr(ord('p')+128): 128+112,
    chr(ord('q')+128): 128+113,
    chr(ord('r')+128): 128+114,
    chr(ord('s')+128): 128+115,
    chr(ord('t')+128): 128+116,
    chr(ord('u')+128): 128+117,
    chr(ord('v')+128): 128+118,
    chr(ord('w')+128): 128+119,
    chr(ord('x')+128): 128+120,
    chr(ord('y')+128): 128+121,
    chr(ord('z')+128): 128+122,
    chr(ord('|')+128): 128+124,
    'ǂ': 128+77,  # ł
    'ˠ': 128+81,  # ó
    'Ǜ': 128+84,  # ś
    # chr(ord('Ą')+128): 128+65,
    # chr(ord('ą')+128): 128+66,
    # chr(ord('Ć')+128): 128+67,
    # chr(ord('ć')+128): 128+68,
    # chr(ord('Ę')+128): 128+69,
    # chr(ord('ę')+128): 128+70,
    # chr(ord('Ł')+128): 128+76,
    # chr(ord('ł')+128): 128+77,
    # chr(ord('Ń')+128): 128+78,
    # chr(ord('ń')+128): 128+79,
    # chr(ord('Ó')+128): 128+80,
    # chr(ord('ó')+128): 128+81,
    # chr(ord('Ś')+128): 128+83,
    # chr(ord('ś')+128): 128+84,
    # chr(ord('Ż')+128): 128+87,
    # chr(ord('ż')+128): 128+88,
    # chr(ord('Ź')+128): 128+89,
    # chr(ord('ź')+128): 128+90,
}

# convert to SCREENCODES
bin_out = bytearray()
for line in out2.split('\n'):
    # print(line)
    for i, c in enumerate(line):
        # print(c, ord(c), utf_to_internal[c])
        try:
            bin_out.append(utf_to_internal[c])
        except KeyError:
            print('-'*70, 'ERROR:', ord(c),  c)
            bin_out.append(0)
    if len(line) < 40:
        # bin_out += bytes(40-len(line))
        bin_out.append(255)
# save to a file
with open(sys.argv[1].split('.')[0]+'.bin', 'wb') as f:
    f.write(bin_out)
