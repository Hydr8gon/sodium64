/*
    Copyright 2021-2023 Hydr8gon

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

.macro NONE
    // Increment the program counter by 1
    addi t0, s0, 1
    sh   t0, apu_count
.endm

.macro IMM // #nn
    // Increment the program counter by 2
    addi t0, s0, 2
    sh   t0, apu_count

    // Read the 8-bit immediate value
    addi a0, s0, 1
    jal  apu_read8
.endm
