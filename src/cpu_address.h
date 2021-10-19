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

.macro IM8
    // Get the address of the 8-bit immediate value
    add  a0, s7, 1
    addi s7, s7, 2
.endm

.macro I16
    // Get the address of the 16-bit immediate value
    add  a0, s7, 1
    addi s7, s7, 3
.endm

.macro DIR
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0
    addi s7, s7, 2
.endm

.macro DRX
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0
    addi s7, s7, 2
.endm

.macro DRY
    // Get the 8-bit immediate value plus register Y added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_y
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0
    addi s7, s7, 2
.endm

.macro DRS
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0
    addi s7, s7, 2
.endm

.macro ABS
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0
    addi s7, s7, 3
.endm

.macro ABX
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0
    addi s7, s7, 3
.endm

.macro ABY
    // Get the 16-bit immediate value plus register Y added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_y
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0
    addi s7, s7, 3
.endm

.macro LNG
    // Get the 24-bit immediate value as an address
    addi a0, s7, 1
    jal  memory_read16
    move s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0
    addi s7, s7, 4
.endm

.macro LNX
    // Get the 24-bit immediate value plus register X as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  s0, register_x
    add  s0, s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0
    addi s7, s7, 4
.endm

.macro IND
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0
    addi s7, s7, 2
.endm

.macro IDX
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0
    addi s7, s7, 2
.endm

.macro IDY
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0
    addi s7, s7, 2
.endm

.macro ISY
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0
    addi s7, s7, 2
.endm

.macro IDL
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory as an address
    jal  memory_read16
    move s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0
    addi s7, s7, 2
.endm

.macro ILY
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  s0, register_y
    add  s0, s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0
    addi s7, s7, 2
.endm
