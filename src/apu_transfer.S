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
.globl apu_mvadir
.globl apu_mvadrx
.globl apu_mvabrx
.globl apu_mvabxp
.globl apu_mvaabs
.globl apu_mvaabx
.globl apu_mvaaby
.globl apu_mvaidx
.globl apu_mvaidy
.globl apu_mvximm
.globl apu_mvxdir
.globl apu_mvxdry
.globl apu_mvxabs
.globl apu_mvyimm
.globl apu_mvydir
.globl apu_mvydrx
.globl apu_mvyabs
.globl apu_movwya
.globl apu_movdri
.globl apu_movdr2
.globl apu_amvdir
.globl apu_amvdrx
.globl apu_amvbrx
.globl apu_amvbxp
.globl apu_amvabs
.globl apu_amvabx
.globl apu_amvaby
.globl apu_amvidx
.globl apu_amvidy
.globl apu_xmvdir
.globl apu_xmvdry
.globl apu_xmvabs
.globl apu_ymvdir
.globl apu_ymvdrx
.globl apu_ymvabs
.globl apu_movway
.globl apu_pha
.globl apu_phx
.globl apu_phy
.globl apu_php
.globl apu_ppa
.globl apu_ppx
.globl apu_ppy
.globl apu_ppp

.text

apu_movax: // MOV A,X
    // Move a value to the accumulator from register X and set flags
    NONE
    lbu  a0, apu_reg_x
    sb   a0, apu_accum
    j    apu_set_nz


apu_movxa: // MOV X,A
    // Move a value to register X from the accumulator and set flags
    NONE
    lbu  a0, apu_accum
    sb   a0, apu_reg_x
    j    apu_set_nz


apu_movay: // MOV A,Y
    // Move a value to the accumulator from register Y and set flags
    NONE
    lbu  a0, apu_reg_y
    sb   a0, apu_accum
    j    apu_set_nz


apu_movya: // MOV Y,A
    // Move a value to register Y from the accumulator and set flags
    NONE
    lbu  a0, apu_accum
    sb   a0, apu_reg_y
    j    apu_set_nz


apu_movxs: // MOV X,SP
    // Move a value to register X from the stack pointer and set flags
    NONE
    lbu  a0, apu_stack + 1
    sb   a0, apu_reg_x
    j    apu_set_nz


apu_movsx: // MOV SP,X
    // Move a value to the stack pointer from register X
    NONE
    lbu  a0, apu_reg_x
    sb   a0, apu_stack + 1
    j    cpu_execute


.macro MVA // MOV A,op
    // Move a value to the accumulator and set flags
    jal  apu_read8
    move a0, v0
    sb   a0, apu_accum
    j    apu_set_nz
.endm

apu_mvaimm: IMM; MVA // MOV A,#nn
apu_mvadir: DIR; MVA // MOV A,aa
apu_mvadrx: DRX; MVA // MOV A,aa+X
apu_mvabrx: BRX; MVA // MOV A,(X)
apu_mvabxp: BXP; MVA // MOV A,(X)+
apu_mvaabs: ABS; MVA // MOV A,aaaa
apu_mvaabx: ABX; MVA // MOV A,aaaa+X
apu_mvaaby: ABY; MVA // MOV A,aaaa+Y
apu_mvaidx: IDX; MVA // MOV A,[aa+X]
apu_mvaidy: IDY; MVA // MOV A,[aa]+Y


.macro MVX // MOV X,op
    // Move a value to register X and set flags
    jal  apu_read8
    move a0, v0
    sb   a0, apu_reg_x
    j    apu_set_nz
.endm

apu_mvximm: IMM; MVX // MOV X,#nn
apu_mvxdir: DIR; MVX // MOV X,aa
apu_mvxdry: DRY; MVX // MOV X,aa+Y
apu_mvxabs: ABS; MVX // MOV X,aaaa


.macro MVY // MOV Y,op
    // Move a value to register Y and set flags
    jal  apu_read8
    move a0, v0
    sb   a0, apu_reg_y
    j    apu_set_nz
.endm

apu_mvyimm: IMM; MVY // MOV Y,#nn
apu_mvydir: DIR; MVY // MOV Y,aa
apu_mvydrx: DRX; MVY // MOV Y,aa+X
apu_mvyabs: ABS; MVY // MOV Y,aaaa


apu_movwya: // MOVW YA,aa
    // Move a 16-bit value to register Y and the accumulator
    DIR
    move s1, a0
    jal  apu_read8
    move s2, v0
    addi a0, s1, 1
    jal  apu_read8
    sll  a0, v0, 8
    or   a0, a0, s2
    sh   a0, apu_reg_y

    // Adjust the 16-bit value for 8-bit flag logic and set flags
    sne  t0, a0, zero
    srl  t1, a0, 8
    or   a0, t0, t1
    j    apu_set_nz


apu_movdri: // MOV aa,#nn
    // Move an immediate value to a zero page address
    DRI
    move a1, s1
    jal  apu_write8
    j    cpu_execute


apu_movdr2: // MOV aa,bb
    // Move a zero page value to another zero page address
    DR2
    move a1, v0
    jal  apu_write8
    j    cpu_execute


.macro AMV // MOV op,A
    // Move a value to memory from the accumulator
    lbu  a1, apu_accum
    jal  apu_write8
    j    cpu_execute
.endm

apu_amvdir: DIR; AMV // MOV aa,A
apu_amvdrx: DRX; AMV // MOV aa+X,A
apu_amvbrx: BRX; AMV // MOV (X),A
apu_amvbxp: BXP; AMV // MOV (X)+,A
apu_amvabs: ABS; AMV // MOV aaaa,A
apu_amvabx: ABX; AMV // MOV aaaa+X,A
apu_amvaby: ABY; AMV // MOV aaaa+Y,A
apu_amvidx: IDX; AMV // MOV [aa+X],A
apu_amvidy: IDY; AMV // MOV [aa]+Y,A


.macro XMV // MOV op,X
    // Move a value to memory from register X
    lbu  a1, apu_reg_x
    jal  apu_write8
    j    cpu_execute
.endm

apu_xmvdir: DIR; XMV // MOV aa,X
apu_xmvdry: DRY; XMV // MOV aa+Y,X
apu_xmvabs: ABS; XMV // MOV aaaa,X


.macro YMV // MOV op,Y
    // Move a value to memory from register Y
    lbu  a1, apu_reg_y
    jal  apu_write8
    j    cpu_execute
.endm

apu_ymvdir: DIR; YMV // MOV aa,Y
apu_ymvdrx: DRX; YMV // MOV aa+X,Y
apu_ymvabs: ABS; YMV // MOV aaaa,Y


apu_movway: // MOVW aa,YA
    // Move a 16-bit value to memory from register Y and the accumulator
    DIR
    lhu  s1, apu_reg_y
    move s2, a0
    andi a1, s1, 0xFF
    jal  apu_write8
    addi a0, s2, 1
    srl  a1, s1, 8
    jal  apu_write8
    j    cpu_execute


apu_pha: // PUSH A
    // Push the accumulator to the stack
    NONE
    lhu  a0, apu_stack
    lbu  a1, apu_accum
    addi t0, a0, -1
    sb   t0, apu_stack + 1
    jal  apu_write8
    j    cpu_execute


apu_phx: // PUSH X
    // Push register X to the stack
    NONE
    lhu  a0, apu_stack
    lbu  a1, apu_reg_x
    addi t0, a0, -1
    sb   t0, apu_stack + 1
    jal  apu_write8
    j    cpu_execute


apu_phy: // PUSH Y
    // Push register Y to the stack
    NONE
    lhu  a0, apu_stack
    lbu  a1, apu_reg_y
    addi t0, a0, -1
    sb   t0, apu_stack + 1
    jal  apu_write8
    j    cpu_execute


apu_php: // PUSH PSW
    // Push the flags to the stack
    NONE
    lhu  a0, apu_stack
    lbu  a1, apu_flags
    addi t0, a0, -1
    sb   t0, apu_stack + 1
    jal  apu_write8
    j    cpu_execute


apu_ppa: // POP A
    // Pop the accumulator from the stack
    NONE
    lhu  a0, apu_stack
    addi a0, a0, 1
    sb   a0, apu_stack + 1
    jal  apu_read8
    lbu  v0, apu_accum
    j    cpu_execute


apu_ppx: // POP X
    // Pop register X from the stack
    NONE
    lhu  a0, apu_stack
    addi a0, a0, 1
    sb   a0, apu_stack + 1
    jal  apu_read8
    lbu  v0, apu_reg_x
    j    cpu_execute


apu_ppy: // POP Y
    // Pop register Y from the stack
    NONE
    lhu  a0, apu_stack
    addi a0, a0, 1
    sb   a0, apu_stack + 1
    jal  apu_read8
    lbu  v0, apu_reg_y
    j    cpu_execute


apu_ppp: // POP PSW
    // Pop the flags from the stack
    NONE
    lhu  a0, apu_stack
    addi a0, a0, 1
    sb   a0, apu_stack + 1
    jal  apu_read8
    lbu  v0, apu_flags
    j    cpu_execute
