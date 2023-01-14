# sodium64
A SNES emulator for the N64, written in assembly.

### Overview
The goal of sodium64 is to be fast and accurate enough to at least get some SNES games playable on the N64. It does its rendering entirely on the RSP in an attempt to reduce load on the main CPU. I thought it would be fun to write something specifically for older hardware in assembly, so sodium64 was born! It's still in very early stages, so don't expect much.

### Downloads
Automatic builds of the latest sodium64 commit are provided via GitHub Actions; you can download them on the [releases page](https://github.com/Hydr8gon/NooDS/releases).

### Usage
Place SNES ROMs with extension `.sfc`/`.smc` in the same folder as `sodium64.z64` and `rom-converter.py`. Run `rom-converter.py` using [Python](https://www.python.org) to convert the SNES ROMs to N64 ROMs. The output ROMs will be in a new folder called `out`. Currently only ROMs up to 3MB are supported.

### Compiling
Although sodium64 is written in assembly, it relies on [libdragon](https://github.com/DragonMinded/libdragon.git) for its build system and a select few functions. When you have that set up, you can simply run `make` in the project root directory to compile.

### References
* [Fullsnes](https://problemkaputt.de/fullsnes.htm) by Martin Korth

### Other Links
* [Hydra's Lair](https://hydr8gon.github.io) - Blog where I may or may not write about things
* [Discord Server](https://discord.gg/JbNz7y4) - Place to chat about my projects and stuff
