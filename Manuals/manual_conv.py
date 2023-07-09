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

# convert to SCREENCODES
for line in out2.split('\n'):
    # line = line + ' '*(MAX_W-len(line))
    line_out = ""
    if '**' not in line:
        line_out = line.replace('"', '""')
    else:
        # replace **text** with inverse 
        if line.strip().startswith('**'):
            inverse = True
        else:
            inverse = False
        chunks = line.split('**')
        line_length = 0

        for chunk in chunks:
            line_length += len(chunk)
            if not chunk:
                continue
            chunk = chunk.replace('"', '""')
            print(f'    dta d"{chunk}"', end='')
            if inverse:
                print('*')
            else:
                print()
            inverse = not inverse
        # add missing spaces
        print(f'    dta d"{" "*(MAX_W-line_length)}"')
    if '*' in line_out:
        if line_out.startswith('*'):
            line_out = line_out.replace('*', '$5a, d"', 1) + '"'
        else:
            line_out = 'd"' + line_out.replace('*', '", $5a, d"') + '"'
    elif line_out:
        line_out = '"' + line_out + '"'
    print('    .align 40')
    if line_out:
        print(f'    dta {line_out}')

    
