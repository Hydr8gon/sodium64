# sodium64
A SNES emulator for the N64, written in assembly.

### Overview
The goal of sodium64 is to be fast and accurate enough to at least get some SNES games playable on the N64. It does its rendering entirely on the RSP in an attempt to reduce load on the main CPU. I thought it would be fun to write something specifically for older hardware in assembly, so sodium64 was born! It's still in very early stages, so don't expect much.

### Compiling
Although sodium64 is written in assembly, it relies on [libdragon](https://github.com/DragonMinded/libdragon.git) for its build system and a select few functions. When you have that set up, you can simply run `make` in the project root directory to compile. You will need to supply a ROM during the build process; see the below section.

### Usage
Due to the apparent lack of file I/O drivers for N64 flashcarts, a ROM must be provided at compile time. The ROM must be called `rom.sfc` and placed in the project root directory before compiling. Currently only headerless ROMs are supported, and LoROM mapping is hardcoded.

### References
* [Fullsnes](https://problemkaputt.de/fullsnes.htm) by Martin Korth
