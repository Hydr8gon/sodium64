#!/usr/bin/python

import os

convert = 0

print("sodium64 ROM converter")
print("Place sodium64.z64 and SNES ROMs with extension .sfc/.smc in the same folder as this script.")
print("The out folder will contain the ROMs converted to .z64 format, ready to play.\n")

if not os.path.isfile("sodium64.z64"):
    print("Error: sodium64.z64 not found!")
    exit()

if not os.path.isdir("out"):
    os.mkdir("out")

for filename in os.listdir("."):
    ext = filename[-4:].lower()
    if (ext == ".sfc" or ext == ".smc") and os.path.isfile(filename):
        print("Converting " + filename + "...")
        baseFile = open("sodium64.z64", "rb")
        inFile = open(filename, "rb")
        if ext == ".sfc":
            convert = 1
        if os.stat(filename).st_size & 0x3FF == 0x200:
            inFile.seek(0x200) # Skip header
            convert = 1
        outFile = open("out/" + filename[:-4] + ".z64", "wb")
        outFile.write(baseFile.read())
        outFile.seek(0x200000, 0)
        outFile.write(inFile.read())
        inFile.close()

if convert == 1:
    print("\nA header or .sfc extension was detected in one or more ROMs.")
    print("Some flashcarts support loading ROMs directly with a supplied emulator.")
    print("To be compatible with this, ROMs must be converted to headerless .smc files.")
    print("Would you like to convert the input ROMs to this format? (y/N)")

    if input() == "y":
        for filename in os.listdir("."):
            ext = filename[-4:].lower()
            if (ext == ".sfc" or ext == ".smc") and os.path.isfile(filename):
                print("Converting " + filename + "...")
                file = open(filename, "rb")
                if os.stat(filename).st_size & 0x3FF == 0x200:
                    file.seek(0x200) # Skip header
                data = file.read()
                file.close()
                os.remove(filename)
                file = open(filename[:-4] + ".smc", "wb")
                file.write(data)

print("Done!")
