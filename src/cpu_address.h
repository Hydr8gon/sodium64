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

// Master cycle counts for CPU memory accesses
#define RAM_CYCLE 8
#define IO_CYCLE  6

.macro MEM_READ8 // a0: address - v0: value
    // Read a byte from memory and decrease the cycle count
    addi s5, s5, -RAM_CYCLE
    lbu  v0, (a0)
.endm

.macro MEM_READ16 // a0: address - v0: value
    // Read 2 bytes from memory and form a 16-bit value
    addi s5, s5, -RAM_CYCLE * 2
    lbu  v0, (a0)
    move a2, v0
    addi a0, a0, 1
    lbu  v0, (a0)
    addi a0, a0, -1
    sll  v0, v0, 8
    or   v0, v0, a2
.endm

.macro MEM_WRITE8 // a0: address, a1: value
    // Write a byte to memory and decrease the cycle count
    addi s5, s5, -RAM_CYCLE
    sb   a1, (a0)
.endm

.macro MEM_WRITE16 // a0: address, a1: value
    // Write a 16-bit value to memory as 2 bytes
    addi s5, s5, -RAM_CYCLE * 2
    move a2, a1
    sb   a1, (a0)
    addi a0, a0, 1
    srl  a1, a1, 8
    sb   a1, (a0)
    addi a0, a0, -1
    move a1, a2
.endm

.macro IM8 // #nn
    // Get the address of the 8-bit immediate value
    add  a0, s7, 1
    addi s7, s7, 2
.endm

.macro I16 // #nnnn
    // Get the address of the 16-bit immediate value
    add  a0, s7, 1
    addi s7, s7, 3
.endm

.macro DIR // nn
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  a0, direct_ofs
    add  a0, a0, v0
    addi s7, s7, 2
.endm

.macro DRX // nn,X
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0
    addi s7, s7, 2
.endm

.macro DRY // nn,Y
    // Get the 8-bit immediate value plus register Y added to the direct offset as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  t0, register_y
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0
    addi s7, s7, 2
.endm

.macro DRS // nn,S
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  a0, stack_ptr
    add  a0, a0, v0
    addi s7, s7, 2
.endm

.macro ABS // nnnn
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    MEM_READ16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0
    addi s7, s7, 3
.endm

.macro ABX // nnnn,X
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    MEM_READ16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0
    addi s7, s7, 3
.endm

.macro ABY // nnnn,Y
    // Get the 16-bit immediate value plus register Y added to the data bank as an address
    addi a0, s7, 1
    MEM_READ16
    lhu  t0, register_y
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0
    addi s7, s7, 3
.endm

.macro LNG // nnnnnn
    // Get the 24-bit immediate value as an address
    addi a0, s7, 1
    MEM_READ16
    move s0, v0
    addi a0, s7, 3
    MEM_READ8
    sll  a0, v0, 16
    add  a0, a0, s0
    addi s7, s7, 4
.endm

.macro LNX // nnnnnn,X
    // Get the 24-bit immediate value plus register X as an address
    addi a0, s7, 1
    MEM_READ16
    lhu  s0, register_x
    add  s0, s0, v0
    addi a0, s7, 3
    MEM_READ8
    sll  a0, v0, 16
    add  a0, a0, s0
    addi s7, s7, 4
.endm

.macro IND // (nn)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Get a 16-bit value from memory added to the data bank as an address
    MEM_READ16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0
    addi s7, s7, 2
.endm

.macro IDX // (nn,X)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Get a 16-bit value from memory added to the data bank as an address
    MEM_READ16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0
    addi s7, s7, 2
.endm

.macro IDY // (nn),Y
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Get a 16-bit value from memory plus register Y added to the data bank as an address
    MEM_READ16
    lbu  a0, data_bank
    sll  a0, a0, 16
    lhu  t0, register_y
    add  a0, a0, v0
    add  a0, a0, t0
    addi s7, s7, 2
.endm

.macro ISY // (nn,S),Y
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Get a 16-bit value from memory plus register Y added to the data bank as an address
    MEM_READ16
    lbu  a0, data_bank
    sll  a0, a0, 16
    lhu  t0, register_y
    add  a0, a0, v0
    add  a0, a0, t0
    addi s7, s7, 2
.endm

.macro IDL // [nn]
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory as an address
    MEM_READ16
    move s0, v0
    addi a0, a0, 2
    MEM_READ8
    sll  a0, v0, 16
    add  a0, a0, s0
    addi s7, s7, 2
.endm

.macro ILY // [nn],Y
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    MEM_READ8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory plus register Y as an address
    MEM_READ16
    lhu  s0, register_y
    add  s0, s0, v0
    addi a0, a0, 2
    MEM_READ8
    sll  a0, v0, 16
    add  a0, a0, s0
    addi s7, s7, 2
.endm
