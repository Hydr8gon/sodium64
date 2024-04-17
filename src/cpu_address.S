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

#include "memory.h"

.globl cpu_im8
.globl cpu_i16
.globl cpu_dir
.globl cpu_drx
.globl cpu_dry
.globl cpu_drs
.globl cpu_abs
.globl cpu_abx
.globl cpu_aby
.globl cpu_lng
.globl cpu_lnx
.globl cpu_ind
.globl cpu_idx
.globl cpu_idy
.globl cpu_isy
.globl cpu_idl
.globl cpu_ily

.text

.align 5
cpu_im8: // #nn
    // Get the address of the 8-bit immediate value
    addi s0, s7, 1
    addi s7, s7, 2
    jr gp

cpu_i16: // #nnnn
    // Get the address of the 16-bit immediate value
    addi s0, s7, 1
    addi s7, s7, 3
    jr gp

.align 5
cpu_dir: // nn
    // Get the 8-bit immediate value added to the direct offset as an address
    MEM_READ8 1(s7)
    add s0, s8, v0
    andi s0, s0, 0xFFFF
    addi s7, s7, 2
    jr gp

.align 5
cpu_drx: // nn,X
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    MEM_READ8 1(s7)
    lhu t0, register_x
    add t0, t0, v0
    add s0, s8, t0
    andi s0, s0, 0xFFFF
    addi s7, s7, 2
    jr gp

.align 5
cpu_dry: // nn,Y
    // Get the 8-bit immediate value plus register Y added to the direct offset as an address
    MEM_READ8 1(s7)
    lhu t0, register_y
    add t0, t0, v0
    add s0, s8, t0
    andi s0, s0, 0xFFFF
    addi s7, s7, 2
    jr gp

.align 5
cpu_drs: // nn,S
    // Get the 8-bit immediate value added to the stack pointer as an address
    MEM_READ8 1(s7)
    lhu s0, stack_ptr
    add s0, s0, v0
    addi s7, s7, 2
    jr gp

.align 5
cpu_abs: // nnnn
    // Get the 16-bit immediate value added to the data bank as an address
    MEM_READ16 1(s7)
    lw s0, data_bank
    add s0, s0, v0
    addi s7, s7, 3
    jr gp

.align 5
cpu_abx: // nnnn,X
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    MEM_READ16 1(s7)
    lhu t0, register_x
    add t0, t0, v0
    lw s0, data_bank
    add s0, s0, t0
    addi s7, s7, 3
    jr gp

.align 5
cpu_aby: // nnnn,Y
    // Get the 16-bit immediate value plus register Y added to the data bank as an address
    MEM_READ16 1(s7)
    lhu t0, register_y
    add t0, t0, v0
    lw s0, data_bank
    add s0, s0, t0
    addi s7, s7, 3
    jr gp

.align 5
cpu_lng: // nnnnnn
    // Get the 24-bit immediate value as an address
    MEM_READ8 3(s7)
    sll s0, v0, 16
    MEM_READ16 1(s7)
    or s0, s0, v0
    addi s7, s7, 4
    jr gp

.align 5
cpu_lnx: // nnnnnn,X
    // Get the 24-bit immediate value plus register X as an address
    MEM_READ8 3(s7)
    sll s0, v0, 16
    MEM_READ16 1(s7)
    lhu t0, register_x
    add t0, t0, v0
    add s0, s0, t0
    addi s7, s7, 4
    jr gp

.align 5
cpu_ind: // (nn)
    // Get the 8-bit immediate value added to the direct offset as an address
    MEM_READ8 1(s7)
    add s0, s8, v0
    andi s0, s0, 0xFFFF

    // Get a 16-bit value from memory added to the data bank as an address
    MEM_READ16
    lw s0, data_bank
    add s0, s0, v0
    addi s7, s7, 2
    jr gp

.align 5
cpu_idx: // (nn,X)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    MEM_READ8 1(s7)
    lhu t0, register_x
    add t0, t0, v0
    add s0, s8, t0
    andi s0, s0, 0xFFFF

    // Get a 16-bit value from memory added to the data bank as an address
    MEM_READ16
    lw s0, data_bank
    add s0, s0, v0
    addi s7, s7, 2
    jr gp

.align 5
cpu_idy: // (nn),Y
    // Get the 8-bit immediate value added to the direct offset as an address
    MEM_READ8 1(s7)
    add s0, s8, v0
    andi s0, s0, 0xFFFF

    // Get a 16-bit value from memory plus register Y added to the data bank as an address
    MEM_READ16
    lw s0, data_bank
    lhu t0, register_y
    add s0, s0, v0
    add s0, s0, t0
    addi s7, s7, 2
    jr gp

.align 5
cpu_isy: // (nn,S),Y
    // Get the 8-bit immediate value added to the stack pointer as an address
    MEM_READ8 1(s7)
    lhu s0, stack_ptr
    add s0, s0, v0

    // Get a 16-bit value from memory plus register Y added to the data bank as an address
    MEM_READ16
    lw s0, data_bank
    lhu t0, register_y
    add s0, s0, v0
    add s0, s0, t0
    addi s7, s7, 2
    jr gp

.align 5
cpu_idl: // [nn]
    // Get the 8-bit immediate value added to the direct offset as an address
    MEM_READ8 1(s7)
    add s0, s8, v0
    andi s0, s0, 0xFFFF

    // Read a 24-bit value from memory as an address
    MEM_READ8 2(s0)
    sll s1, v0, 16
    MEM_READ16
    or s0, s1, v0
    addi s7, s7, 2
    jr gp

.align 5
cpu_ily: // [nn],Y
    // Get the 8-bit immediate value added to the direct offset as an address
    MEM_READ8 1(s7)
    add s0, s8, v0
    andi s0, s0, 0xFFFF

    // Read a 24-bit value from memory plus register Y as an address
    MEM_READ8 2(s0)
    sll s1, v0, 16
    MEM_READ16
    lhu t0, register_y
    add t0, t0, v0
    add s0, s1, t0
    addi s7, s7, 2
    jr gp
