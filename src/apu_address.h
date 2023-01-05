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

    // Get the address of the 8-bit immediate value
    addi a0, s0, 1
.endm

.macro DIR // aa
    // Increment the program counter by 2
    addi t0, s0, 2
    sh   t0, apu_count

    // Get the 8-bit immediate value as an address
    addi a0, s0, 1
    jal  apu_read8

    // Offset the zero page based on the P flag
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   a0, v0, t0
.endm

.macro DRX // aa+X
    // Increment the program counter by 2
    addi t0, s0, 2
    sh   t0, apu_count

    // Get the 8-bit immediate value plus register X as an address
    addi a0, s0, 1
    jal  apu_read8
    lbu  t0, apu_reg_x
    add  a0, v0, t0
    andi a0, a0, 0xFF

    // Offset the zero page based on the P flag
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   a0, a0, t0
.endm

.macro DRY // aa+Y
    // Increment the program counter by 2
    addi t0, s0, 2
    sh   t0, apu_count

    // Get the 8-bit immediate value plus register Y as an address
    addi a0, s0, 1
    jal  apu_read8
    lbu  t0, apu_reg_y
    add  a0, v0, t0
    andi a0, a0, 0xFF

    // Offset the zero page based on the P flag
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   a0, a0, t0
.endm

.macro BRX // (X)
    // Increment the program counter by 1
    addi t0, s0, 1
    sh   t0, apu_count

    // Get the value of register X, offset based on the P flag, as an address
    lbu  a0, apu_reg_x
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   a0, a0, t0
.endm

.macro BRY // (Y)
    // Increment the program counter by 1
    addi t0, s0, 1
    sh   t0, apu_count

    // Get the value of register Y, offset based on the P flag, as an address
    lbu  a0, apu_reg_y
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   a0, a0, t0
.endm

.macro BXP // (X)+
    // Increment the program counter by 1
    addi t0, s0, 1
    sh   t0, apu_count

    // Get the value of register X as an address, and increment the register
    lbu  a0, apu_reg_x
    addi t0, a0, 1
    sb   t0, apu_reg_x

    // Offset the zero page based on the P flag
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   a0, a0, t0
.endm

.macro ABS // aaaa
    // Increment the program counter by 3
    addi t0, s0, 3
    sh   t0, apu_count

    // Get the 16-bit immediate value as an address
    addi a0, s0, 1
    jal  apu_read8
    move s1, v0
    addi a0, s0, 2
    jal  apu_read8
    sll  a0, v0, 8
    or   a0, a0, s1
.endm

.macro ABX // aaaa+X
    // Increment the program counter by 3
    addi t0, s0, 3
    sh   t0, apu_count

    // Get the 16-bit immediate value
    addi a0, s0, 1
    jal  apu_read8
    move s1, v0
    addi a0, s0, 2
    jal  apu_read8
    sll  a0, v0, 8
    or   a0, a0, s1

    // Add register X to the value and use it as an address
    lbu  t0, apu_reg_x
    add  a0, a0, t0
    andi a0, a0, 0xFFFF
.endm

.macro ABY // aaaa+Y
    // Increment the program counter by 3
    addi t0, s0, 3
    sh   t0, apu_count

    // Get the 16-bit immediate value
    addi a0, s0, 1
    jal  apu_read8
    move s1, v0
    addi a0, s0, 2
    jal  apu_read8
    sll  a0, v0, 8
    or   a0, a0, s1

    // Add register Y to the value and use it as an address
    lbu  t0, apu_reg_y
    add  a0, a0, t0
    andi a0, a0, 0xFFFF
.endm

.macro IDX // [aa+X]
    // Increment the program counter by 2
    addi t0, s0, 2
    sh   t0, apu_count

    // Get the 8-bit immediate value plus register X as an address
    addi a0, s0, 1
    jal  apu_read8
    lbu  t0, apu_reg_x
    add  a0, v0, t0
    andi a0, a0, 0xFF

    // Offset the zero page based on the P flag
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   a0, a0, t0

    // Get a 16-bit value from the zero page as an address
    move s1, a0
    jal  apu_read8
    move s2, v0
    addi a0, s1, 1
    jal  apu_read8
    sll  a0, v0, 8
    or   a0, a0, s2
.endm

.macro IDY // [aa]+Y
    // Increment the program counter by 2
    addi t0, s0, 2
    sh   t0, apu_count

    // Get the 8-bit immediate value as an address
    addi a0, s0, 1
    jal  apu_read8

    // Offset the zero page based on the P flag
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   a0, v0, t0

    // Get a 16-bit value from the zero page
    move s1, a0
    jal  apu_read8
    move s2, v0
    addi a0, s1, 1
    jal  apu_read8
    sll  a0, v0, 8
    or   a0, a0, s2

    // Add register Y to the value and use it as an address
    lbu  t0, apu_reg_y
    add  a0, a0, t0
    andi a0, a0, 0xFFFF
.endm

.macro DRI // aa,#nn
    // Increment the program counter by 3
    addi t0, s0, 3
    sh   t0, apu_count

    // Save the first 8-bit immediate value (#nn)
    addi a0, s0, 1
    jal  apu_read8
    move s1, v0

    // Get the second 8-bit immediate value as an address
    addi a0, s0, 2
    jal  apu_read8

    // Offset the zero page based on the P flag
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   a0, v0, t0
.endm

.macro DR2 // aa,bb
    // Increment the program counter by 3
    addi t0, s0, 3
    sh   t0, apu_count

    // Save the first 8-bit immediate value (bb)
    addi a0, s0, 1
    jal  apu_read8
    move s1, v0

    // Get the second 8-bit immediate value as an address
    addi a0, s0, 2
    jal  apu_read8

    // Offset the zero page based on the P flag
    lbu  t0, apu_flags
    sll  t0, t0, 3
    andi t0, t0, 0x100
    or   s2, v0, t0

    // Return aa as an address and bb as a read value
    or   a0, s1, t0
    jal  apu_read8
    move a0, s2
.endm
