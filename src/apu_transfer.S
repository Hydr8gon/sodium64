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
    // Emit code to move a value to the accumulator from register X and set flags
    jal load_reg_x
    li t0, T7
    li t1, ZERO
    li t2, T9
    jal emit_or
    li t1, T7
    jal queue_nz

    // Update the JIT status
    ori s1, s1, FLAG_SA | FLAG_LA
    addi s2, s2, -APU_CYCLE
    addi a0, a0, 1
    j finish_opcode


apu_movxa: // MOV X,A
    // Emit code to move a value to register X from the accumulator and set flags
    jal load_accum
    li t0, T9
    li t1, ZERO
    li t2, T7
    jal emit_or
    li t1, T9
    jal queue_nz

    // Update the JIT status
    ori s1, s1, FLAG_SX | FLAG_LX
    addi s2, s2, -APU_CYCLE
    addi a0, a0, 1
    j finish_opcode


apu_movay: // MOV A,Y
    // Emit code to move a value to the accumulator from register Y and set flags
    jal load_reg_y
    li t0, T7
    li t1, ZERO
    li t2, T8
    jal emit_or
    li t1, T7
    jal queue_nz

    // Update the JIT status
    ori s1, s1, FLAG_SA | FLAG_LA
    addi s2, s2, -APU_CYCLE
    addi a0, a0, 1
    j finish_opcode


apu_movya: // MOV Y,A
    // Emit code to move a value to register Y from the accumulator and set flags
    jal load_accum
    li t0, T8
    li t1, ZERO
    li t2, T7
    jal emit_or
    li t1, T8
    jal queue_nz

    // Update the JIT status
    ori s1, s1, FLAG_SY | FLAG_LY
    addi s2, s2, -APU_CYCLE
    addi a0, a0, 1
    j finish_opcode


apu_movxs: // MOV X,SP
    // Emit code to move a value to register X from the stack pointer and set flags
    jal load_stack
    li t0, T9
    li t1, ZERO
    li t2, S2
    jal emit_or
    li t1, T9
    jal queue_nz

    // Update the JIT status
    ori s1, s1, FLAG_SX | FLAG_LX
    addi s2, s2, -APU_CYCLE
    addi a0, a0, 1
    j finish_opcode


apu_movsx: // MOV SP,X
    // Emit code to move a value to the stack pointer from register X
    jal load_reg_x
    li t0, S2
    li t1, T9
    li t2, 0xFF
    jal emit_andi
    li t0, S2
    li t1, S2
    li t2, 0x100
    jal emit_ori

    // Update the JIT status
    ori s1, s1, FLAG_SS | FLAG_LS
    addi s2, s2, -APU_CYCLE
    addi a0, a0, 1
    j finish_opcode


.macro MOVA // MOV A,op
    // Move a value to the accumulator and set flags
    jal apu_read8
    move a0, v0
    sb a0, apu_accum
    j apu_set_nz
.endm

apu_mvaimm: IMM; MOVA // MOV A,#nn
apu_mvadir: DIR; MOVA // MOV A,aa
apu_mvadrx: DRX; MOVA // MOV A,aa+X
apu_mvabrx: BRX; MOVA // MOV A,(X)
apu_mvabxp: BXP; MOVA // MOV A,(X)+
apu_mvaabs: ABS; MOVA // MOV A,aaaa
apu_mvaabx: ABX; MOVA // MOV A,aaaa+X
apu_mvaaby: ABY; MOVA // MOV A,aaaa+Y
apu_mvaidx: IDX; MOVA // MOV A,[aa+X]
apu_mvaidy: IDY; MOVA // MOV A,[aa]+Y


.macro MOVX // MOV X,op
    // Move a value to register X and set flags
    jal apu_read8
    move a0, v0
    sb a0, apu_reg_x
    j apu_set_nz
.endm

apu_mvximm: IMM; MOVX // MOV X,#nn
apu_mvxdir: DIR; MOVX // MOV X,aa
apu_mvxdry: DRY; MOVX // MOV X,aa+Y
apu_mvxabs: ABS; MOVX // MOV X,aaaa


.macro MOVY // MOV Y,op
    // Move a value to register Y and set flags
    jal apu_read8
    move a0, v0
    sb a0, apu_reg_y
    j apu_set_nz
.endm

apu_mvyimm: IMM; MOVY // MOV Y,#nn
apu_mvydir: DIR; MOVY // MOV Y,aa
apu_mvydrx: DRX; MOVY // MOV Y,aa+X
apu_mvyabs: ABS; MOVY // MOV Y,aaaa


apu_movwya: // MOVW YA,aa
    // Move a 16-bit value to register YA
    DIR
    addi a0, a0, 1
    jal apu_read8
    sll s1, v0, 8
    addi a0, a0, -1
    jal apu_read8
    or a0, v0, s1
    sh a0, apu_reg_y

    // Adjust the 16-bit value for 8-bit flag logic and set flags
    sne t0, a0, zero
    srl t1, a0, 8
    or a0, t0, t1
    j apu_set_nz


.macro MOVM // MOV aa,op
    // Move a value to another memory address
    jal apu_write8
    j cpu_execute
.endm

apu_movdri: DRI; MOVM // MOV aa,#nn
apu_movdr2: DR2; MOVM // MOV aa,bb


.macro AMOV // MOV op,A
    // Move a value to memory from the accumulator
    lbu a1, apu_accum
    jal apu_write8
    j cpu_execute
.endm

apu_amvdir: DIR; AMOV // MOV aa,A
apu_amvdrx: DRX; AMOV // MOV aa+X,A
apu_amvbrx: BRX; AMOV // MOV (X),A
apu_amvbxp: BXP; AMOV // MOV (X)+,A
apu_amvabs: ABS; AMOV // MOV aaaa,A
apu_amvabx: ABX; AMOV // MOV aaaa+X,A
apu_amvaby: ABY; AMOV // MOV aaaa+Y,A
apu_amvidx: IDX; AMOV // MOV [aa+X],A
apu_amvidy: IDY; AMOV // MOV [aa]+Y,A


.macro XMOV // MOV op,X
    // Move a value to memory from register X
    lbu a1, apu_reg_x
    jal apu_write8
    j cpu_execute
.endm

apu_xmvdir: DIR; XMOV // MOV aa,X
apu_xmvdry: DRY; XMOV // MOV aa+Y,X
apu_xmvabs: ABS; XMOV // MOV aaaa,X


.macro YMOV // MOV op,Y
    // Move a value to memory from register Y
    lbu a1, apu_reg_y
    jal apu_write8
    j cpu_execute
.endm

apu_ymvdir: DIR; YMOV // MOV aa,Y
apu_ymvdrx: DRX; YMOV // MOV aa+X,Y
apu_ymvabs: ABS; YMOV // MOV aaaa,Y


apu_movway: // MOVW aa,YA
    // Move a 16-bit value to memory from register YA
    DIR
    lhu s1, apu_reg_y
    move s2, a0
    andi a1, s1, 0xFF
    jal apu_write8
    addi a0, s2, 1
    srl a1, s1, 8
    jal apu_write8
    j cpu_execute


apu_pha: // PUSH A
    // Push the accumulator to the stack
    NONE
    lhu a0, apu_stack
    lbu a1, apu_accum
    addi t0, a0, -1
    sb t0, apu_stack + 1
    jal apu_write8
    j cpu_execute


apu_phx: // PUSH X
    // Push register X to the stack
    NONE
    lhu a0, apu_stack
    lbu a1, apu_reg_x
    addi t0, a0, -1
    sb t0, apu_stack + 1
    jal apu_write8
    j cpu_execute


apu_phy: // PUSH Y
    // Push register Y to the stack
    NONE
    lhu a0, apu_stack
    lbu a1, apu_reg_y
    addi t0, a0, -1
    sb t0, apu_stack + 1
    jal apu_write8
    j cpu_execute


apu_php: // PUSH PSW
    // Push the flags to the stack
    NONE
    lhu a0, apu_stack
    lbu a1, apu_flags
    addi t0, a0, -1
    sb t0, apu_stack + 1
    jal apu_write8
    j cpu_execute


apu_ppa: // POP A
    // Pop the accumulator from the stack
    NONE
    lhu a0, apu_stack
    addi a0, a0, 1
    sb a0, apu_stack + 1
    jal apu_read8
    sb v0, apu_accum
    j cpu_execute


apu_ppx: // POP X
    // Pop register X from the stack
    NONE
    lhu a0, apu_stack
    addi a0, a0, 1
    sb a0, apu_stack + 1
    jal apu_read8
    sb v0, apu_reg_x
    j cpu_execute


apu_ppy: // POP Y
    // Pop register Y from the stack
    NONE
    lhu a0, apu_stack
    addi a0, a0, 1
    sb a0, apu_stack + 1
    jal apu_read8
    sb v0, apu_reg_y
    j cpu_execute


apu_ppp: // POP PSW
    // Pop the flags from the stack
    NONE
    lhu a0, apu_stack
    addi a0, a0, 1
    sb a0, apu_stack + 1
    jal apu_read8
    sb v0, apu_flags
    j cpu_execute
