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

#include "apu_address.h"

.globl apu_movax
.globl apu_movxa
.globl apu_movay
.globl apu_movya
.globl apu_movxs
.globl apu_movsx
.globl apu_mvaimm
.globl apu_mvximm
.globl apu_mvyimm

.text


apu_movax: // MOV A,X
    // Move a value to the accumulator from register X
    NONE
    lbu  a0, apu_reg_x
    sb   a0, apu_accum
    j    apu_set_nz


apu_movxa: // MOV X,A
    // Move a value to register X from the accumulator
    NONE
    lbu  a0, apu_accum
    sb   a0, apu_reg_x
    j    apu_set_nz


apu_movay: // MOV A,Y
    // Move a value to the accumulator from register Y
    NONE
    lbu  a0, apu_reg_y
    sb   a0, apu_accum
    j    apu_set_nz


apu_movya: // MOV Y,A
    // Move a value to register Y from the accumulator
    NONE
    lbu  a0, apu_accum
    sb   a0, apu_reg_y
    j    apu_set_nz


apu_movxs: // MOV X,SP
    // Move a value to register X from the stack pointer
    NONE
    lbu  a0, apu_stack + 1
    sb   a0, apu_reg_x
    j    apu_set_nz


apu_movsx: // MOV SP,X
    // Move a value to the stack pointer from register X
    NONE
    lbu  a0, apu_reg_x
    sb   a0, apu_stack + 1
    j    apu_set_nz


.macro MVA // MOV A,op
    // Move a value to the accumulator and set flags
    move a0, v0
    sb   a0, apu_accum
    j    apu_set_nz
.endm

apu_mvaimm: IMM; MVA // MOV A,#nn


.macro MVX // MOV X,op
    // Move a value to register X and set flags
    move a0, v0
    sb   a0, apu_reg_x
    j    apu_set_nz
.endm

apu_mvximm: IMM; MVX // MOV X,#nn


.macro MVY // MOV Y,op
    // Move a value to register Y and set flags
    move a0, v0
    sb   a0, apu_reg_y
    j    apu_set_nz
.endm

apu_mvyimm: IMM; MVY // MOV Y,#nn
