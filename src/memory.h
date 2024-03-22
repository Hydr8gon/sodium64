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

#include "defines.h"

.macro MEM_READ8 addr=0(s0), lb=lbu // v0: value
    // Read a byte from memory and decrease the cycle count
    \lb v0, \addr
    addi s5, s5, -RAM_CYCLE
.endm

.macro MEM_READ16 addr=0(s0) // v0: value
    // Read 2 bytes from memory and form a 16-bit value
    lbu v0, 0 + \addr
    addi s5, s5, -RAM_CYCLE * 2
    move a2, v0
    lbu v0, 1 + \addr
    sll v0, v0, 8
    or v0, v0, a2
.endm

.macro MEM_WRITE8 addr=0(s0) // a1: value
    // Write a byte to memory and decrease the cycle count
    sb a1, \addr
    addi s5, s5, -RAM_CYCLE
.endm

.macro MEM_WRITE16 addr=0(s0) // a1: value
    // Write a 16-bit value to memory as 2 bytes
    move a2, a1
    sb a1, 0 + \addr
    addi s5, s5, -RAM_CYCLE * 2
    srl a1, a1, 8
    sb a1, 1 + \addr
    move a1, a2
.endm
