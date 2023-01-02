# sodium64
A SNES emulator for the N64, written in assembly.

### Overview
The goal of sodium64 is to be fast and accurate enough to at least get some SNES games playable on the N64. It does its rendering entirely on the RSP in an attempt to reduce load on the main CPU. I thought it would be fun to write something specifically for older hardware in assembly, so sodium64 was born! It's still in very early stages, so don't expect much.

### Downloads
Automatic builds of the latest sodium64 commit are provided via GitHub Actions; you can download them on the [releases page](https://github.com/Hydr8gon/NooDS/releases).

### Usage
Place SNES ROMs with extension `.sfc` in the same folder as `sodium64.z64` and `rom-converter.py`. Run `rom-converter.py` using [Python](https://www.python.org) to convert the SNES ROMs to N64 ROMs. The outputted ROMs will be in a new folder called `out`. Currently only headerless ROMs up to 3MB are supported, and LoROM mapping is hardcoded.

### Compiling
Although sodium64 is written in assembly, it relies on [libdragon](https://github.com/DragonMinded/libdragon.git) for its build system and a select few functions. When you have that set up, you can simply run `make` in the project root directory to compile. You will need to supply a ROM during the build process; see the below section.

### References
* [Fullsnes](https://problemkaputt.de/fullsnes.htm) by Martin Korth
