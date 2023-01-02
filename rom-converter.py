#!/usr/bin/python

import os

print("sodium64 ROM converter")
print("Place sodium64.z64 and SNES ROMs with extension .sfc in the same folder as this script.")
print("The out folder will contain the ROMs converted to .z64 format, ready to play.")

if not os.path.isfile("sodium64.z64"):
    print("Error: sodium64.z64 not found!")
    exit()

if not os.path.isdir("out"):
    os.mkdir("out")

for filename in os.listdir("."):
    if filename[-4:] == ".sfc" and os.path.isfile(filename):
        print("Converting " + filename + "...")
        baseFile = open("sodium64.z64", "rb")
        inFile = open(filename, "rb")
        outFile = open("out/" + filename[:-4] + ".z64", "wb")
        outFile.write(baseFile.read())
        outFile.write(inFile.read())

print("Done!")
