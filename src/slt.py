#!/usr/bin/python3
import argparse
import math
import sys

# Construct an argument parser
parser = argparse.ArgumentParser(description='Generate a Sine Lookup Table')

# Add arguments to the parser
parser.add_argument("-d", "--depth", type=float, default=16,
    help="Depth of the waveform")
parser.add_argument("-l", "--length", type=float, default=16,
    help="Length of the array")
parser.add_argument("-o", "--offset", type=float, default=0,
    help="Offset the waveform this value positive from zero")
parser.add_argument("-x", "--hex", action='store_true',
    help="Output values in hex format")

# Get the args and flags
flags = parser.parse_args()
args = vars(flags)

# Store these values for convenience
depth = args['depth']
length = args['length']
offset = args['offset']

# Computes each value based on the index
def compute_sine(index):
    hypotenuse = (depth - 1) / 2
    radsPerIndex = (2 * math.pi) / length
    rads = index * radsPerIndex
    value = (math.sin(rads) * hypotenuse) + hypotenuse
    return int(round(value, 0))

sys.stdout.write("{")
# The true depth is reduced by the offset
depth = depth - offset

# Iterate through the entire range
for i in range(int(length)):
    entry = compute_sine(i) + offset
    # Line break every 12 entries
    if (i % 12 == 0):
        sys.stdout.write("\n    ")
    if (flags.hex):
        sys.stdout.write(format(hex(int(entry))))
    else:
        sys.stdout.write(format(int(entry)))
    # Don't print the trailing comma on the final entry
    if (i < int(length) - 1):
        sys.stdout.write(", ")
print("\n};")
