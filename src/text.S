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

.globl draw_value

.data

char_0:
    .hword  0,  0, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0, -1, -1, -1, -1,  0,  0

char_1:
    .hword  0,  0,  0, -1, -1,  0,  0,  0
    .hword  0,  0, -1, -1, -1,  0,  0,  0
    .hword  0,  0, -1, -1, -1,  0,  0,  0
    .hword  0,  0,  0, -1, -1,  0,  0,  0
    .hword  0,  0,  0, -1, -1,  0,  0,  0
    .hword  0,  0,  0, -1, -1,  0,  0,  0
    .hword  0,  0,  0, -1, -1,  0,  0,  0
    .hword  0,  0,  0, -1, -1,  0,  0,  0

char_2:
    .hword  0,  0, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0,  0,  0,  0,  0, -1, -1,  0
    .hword  0,  0,  0,  0, -1, -1,  0,  0
    .hword  0,  0,  0, -1, -1,  0,  0,  0
    .hword  0,  0, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0

char_3:
    .hword  0,  0, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0,  0,  0,  0, -1, -1,  0,  0
    .hword  0,  0,  0,  0, -1, -1,  0,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0, -1, -1, -1, -1,  0,  0

char_4:
    .hword  0,  0,  0, -1, -1, -1,  0,  0
    .hword  0,  0, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1,  0, -1, -1,  0,  0
    .hword  0, -1, -1,  0, -1, -1,  0,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0,  0,  0, -1, -1,  0,  0
    .hword  0,  0,  0,  0, -1, -1,  0,  0

char_5:
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1,  0,  0,  0,  0,  0
    .hword  0, -1, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0,  0,  0,  0, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0, -1, -1, -1, -1,  0,  0

char_6:
    .hword  0,  0, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1,  0,  0,  0,  0,  0
    .hword  0, -1, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0, -1, -1, -1, -1,  0,  0

char_7:
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0,  0,  0,  0, -1, -1,  0
    .hword  0,  0,  0,  0, -1, -1,  0,  0
    .hword  0,  0,  0,  0, -1, -1,  0,  0
    .hword  0,  0,  0, -1, -1,  0,  0,  0
    .hword  0,  0, -1, -1,  0,  0,  0,  0
    .hword  0,  0, -1, -1,  0,  0,  0,  0

char_8:
    .hword  0,  0, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0,  0, -1, -1, -1, -1,  0,  0
    .hword  0,  0, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0, -1, -1, -1, -1,  0,  0

char_9:
    .hword  0,  0, -1, -1, -1, -1,  0,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0, -1, -1,  0,  0, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0, -1, -1, -1, -1, -1,  0
    .hword  0,  0,  0,  0,  0, -1, -1,  0
    .hword  0, -1, -1, -1, -1, -1, -1,  0
    .hword  0,  0, -1, -1, -1, -1,  0,  0

.text

.macro DRAW line
    // Copy a line of character pixels to the framebuffer
    ld   t3, \line *  16 +  0(t2)
    sd   t3, \line * 560 +  0(a1)
    ld   t3, \line *  16 +  8(t2)
    sd   t3, \line * 560 +  8(a1)
.endm

draw_value: // a0: value, a1: top-right offset
    // Apply the offset within the current rendered frame
    lw   t0, 0xA4000EB0
    add  a1, a1, t0
    li   t1, 10

draw_digit:
    // Isolate the lowest base-10 digit and convert to sprite address
    div  a0, t1
    addi a1, a1, -16
    mfhi t2 // Remainder
    sll  t2, t2, 7
    la   t3, char_0
    add  t2, t2, t3

    // Copy a character sprite to the framebuffer
    DRAW 0
    DRAW 1
    DRAW 2
    DRAW 3
    DRAW 4
    DRAW 5
    DRAW 6
    DRAW 7

    // Move to the next digit if there is one
    mflo a0 // Quotient
    bnez a0, draw_digit
    jr   ra
