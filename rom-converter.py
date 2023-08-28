#!/usr/bin/python

import os

print("sodium64 ROM converter")
print("Place sodium64.z64 and SNES ROMs with extension .sfc/.smc in the same folder as this script.")
print("The out folder will contain the ROMs converted to .z64 format, ready to play.")

if not os.path.isfile("sodium64.z64"):
    print("Error: sodium64.z64 not found!")
    exit()

if not os.path.isdir("out"):
    os.mkdir("out")

for filename in os.listdir("."):
    if (filename[-4:] == ".sfc" or filename[-4:] == ".smc") and os.path.isfile(filename):
        print("Converting " + filename + "...")
        baseFile = open("sodium64.z64", "rb")
        inFile = open(filename, "rb")
        if os.stat(filename).st_size & 0x3FF == 0x200:
            inFile.seek(0x200) # Skip header
        outFile = open("out/" + filename[:-4] + ".z64", "wb")
        outFile.write(baseFile.read())
        outFile.seek(0x200000, 0)
        outFile.write(inFile.read())

print("Done!")
