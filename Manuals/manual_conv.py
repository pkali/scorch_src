""" Converts manual files to atari SCREENCODES ready for display
"""
import re
import sys

MAX_W = 40


def break_long_string(long_string):
    """ write a python function that breaks a long string of words to a list of MAX_W long strings.
    Important - each new string must contain the full word, no breaking inside words."""
    words = long_string.split()
    result = []
    current_string = ''

    for word in words:
        if len(current_string) + len(word) <= MAX_W:
            current_string += word + ' '
        else:
            result.append(current_string.rstrip())
            current_string = word + ' '

    if current_string:
        result.append(current_string.rstrip())

    return result


def remove_wierd(t: str) -> str:
    t = re.sub(r'!.*\)?', '', t)  # remove embedded image
    return re.sub(r'[#`]', '', t)


with open(sys.argv[1], 'r') as f:
    md = f.readlines()
out = ''
for line in md:
    if line.startswith('#'):
        line = remove_wierd(line)
        out += line
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
}

# convert to SCREENCODES
bin_out = bytearray()
for line in out2.split('\n'):
    for i, c in enumerate(line):

        bin_out.append(utf_to_internal[c])
print(bin_out)
