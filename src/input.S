/*
    Copyright 2021 Hydr8gon

    This file is part of sodium64.

    sodium64 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published
    by the Free Software Foundation, either version 3 of the License,
    or (at your option) any later version.

    sodium64 is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with sodium64. If not, see <https://www.gnu.org/licenses/>.
*/

#include <regdef.h>

.globl update_input
.globl read_joy1l
.globl read_joy1h

.data

input_data: .word 0:16

.text

update_input:
    // Update the input data every frame using libdragon
    la   a0, input_data
    j    controller_read


read_joy1l: // v0: value
    // Read the button data for controller 1
    lhu  t0, input_data + 4

    // Map N64 LR to SNES LR
    andi v0, t0, 0x3 << 4

    // Map N64 C-up to SNES X
    andi t1, t0, 0x1 << 3
    sll  t1, t1, 3
    or   v0, v0, t1

    // Map N64 C-right to SNES A
    andi t1, t0, 0x1
    sll  t1, t1, 7
    or   v0, v0, t1
    jr   ra


read_joy1h: // v0: value
    // Read the button data for controller 1
    lhu  t0, input_data + 4

    // Map N64 Dpad to SNES Dpad
    srl  t1, t0, 8
    andi v0, t1, 0xF

    // Map N64 A to SNES Start
    andi t1, t0, 0x1 << 15
    srl  t1, t1, 11
    or   v0, v0, t1

    // Map N64 B to SNES Select
    andi t1, t0, 0x1 << 14
    srl  t1, t1, 9
    or   v0, v0, t1

    // Map N64 C-left and C-down to SNES Y and B
    andi t1, t0, 0x3 << 1
    sll  t1, t1, 5
    or   v0, v0, t1
    jr   ra
