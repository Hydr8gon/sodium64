# sodium64
A SNES emulator for the N64, written in assembly.

### Overview
The goal of sodium64 is to be fast and accurate enough to at least make some SNES games playable on the N64. It handles
rendering entirely on the RSP in order to reduce load on the main CPU. I thought it would be fun to write something
specifically for older hardware in assembly, so sodium64 was born!

### Downloads
The latest build of sodium64 is automatically provided via GitHub Actions, and can be downloaded from the
[releases page](https://github.com/Hydr8gon/sodium64/releases).

### Usage
Place SNES ROMs with extension `.sfc`/`.smc` in the same folder as `sodium64.z64` and `rom-converter.py`. Run
`rom-converter.py` using [Python](https://www.python.org) to convert the SNES ROMs to N64 ROMs. The output ROMs will be
in a new folder called `out`.

Alternatively, some flashcarts support loading ROMs directly with a supplied emulator. If you have an EverDrive, copy
`sodium64.z64` to the `ED64/emu` folder on your SD card and rename it to `smc.v64`. SNES ROMs must be in headerless
`.smc` format to work this way; `rom-converter.py` can optionally convert input ROMs for this.

### Controls
|  **N64**  |   **SNES**   |
|:---------:|:------------:|
| C-Buttons |     ABXY     |
|   D-Pad   |    D-Pad     |
|    L/R    |     L/R      |
|    A/B    | Start/Select |
|   Start   |   Settings   |

### Contributing
This is a personal project, and I've decided to not review or accept pull requests for it. If you want to help, you can
test things and report issues or provide feedback. If you can afford it, you can also donate to motivate me and allow me
to spend more time on things like this. Nothing is mandatory, and I appreciate any interest in my projects, even if
you're just a user!

### Building
Although sodium64 is written in assembly, it relies on [libdragon](https://github.com/DragonMinded/libdragon.git) for
its build system. With that set up, run `make` in the project root directory to start building.

### Hardware References
* [Fullsnes](https://problemkaputt.de/fullsnes.htm) - The main source of information on SNES hardware
* [Anomie Docs](https://www.romhacking.net/community/548) - More detailed documentation for certain components
* [6502 Tutorials](http://6502.org/tutorials/) - Has articles thoroughly covering the CPU and its quirks

### Other Links
* [Hydra's Lair](https://hydr8gon.github.io) - Blog where I may or may not write about things
* [Discord Server](https://discord.gg/JbNz7y4) - A place to chat about my projects and stuff
