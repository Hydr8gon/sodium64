# sodium64
A SNES emulator for the N64, written in assembly.

### Overview
The goal of sodium64 is to be fast and accurate enough to at least get some SNES games playable on the N64. It does its rendering entirely on the RSP in an attempt to reduce load on the main CPU. I thought it would be fun to write something specifically for older hardware in assembly, so sodium64 was born! It's still in very early stages, so don't expect much.

### Downloads
Automatic builds of the latest sodium64 commit are provided via GitHub Actions; you can download them on the [releases page](https://github.com/Hydr8gon/sodium64/releases).

### Usage
Place SNES ROMs with extension `.sfc`/`.smc` in the same folder as `sodium64.z64` and `rom-converter.py`. Run `rom-converter.py` using [Python](https://www.python.org) to convert the SNES ROMs to N64 ROMs. The output ROMs will be in a new folder called `out`.

Alternatively, some flashcarts support loading ROMs directly with a supplied emulator. If you have an EverDrive, copy `sodium64.z64` to the `ED64/emu` folder on your SD card and rename it to `smc.v64`. SNES ROMs must be in headerless `.smc` format to work this way; `rom-converter.py` can optionally convert input ROMs for this.

### Compiling
Although sodium64 is written in assembly, it relies on [libdragon](https://github.com/DragonMinded/libdragon.git) for its build system. When you have that set up, you can simply run `make` in the project root directory to compile.

### Contributing
While I appreciate anyone who wants to contribute, my goal with this project is to challenge myself and not to review code. I feel guilty rejecting a change that someone spent time on, but I also don't feel great accepting changes that I didn't ask for. For this reason, I've decided to stop accepting pull requests. You're of course still free to do anything with the code that's allowed by the license, but if you submit a pull request it will likely be ignored. I hope this is understandable!

### References
* [Fullsnes](https://problemkaputt.de/fullsnes.htm) by Martin Korth - My main source of information on SNES hardware
* [Decimal Mode](http://6502.org/tutorials/decimal_mode.html) by Bruce Clark - Covers the CPU's barely-documented BCD mode

### Other Links
* [Hydra's Lair](https://hydr8gon.github.io) - Blog where I may or may not write about things
* [Discord Server](https://discord.gg/JbNz7y4) - Place to chat about my projects and stuff
