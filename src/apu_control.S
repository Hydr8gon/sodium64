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

.globl apu_bpl
.globl apu_bmi
.globl apu_bvc
.globl apu_bvs
.globl apu_bcc
.globl apu_bcs
.globl apu_bne
.globl apu_beq
.globl apu_bbc0
.globl apu_bbc1
.globl apu_bbc2
.globl apu_bbc3
.globl apu_bbc4
.globl apu_bbc5
.globl apu_bbc6
.globl apu_bbc7
.globl apu_bbs0
.globl apu_bbs1
.globl apu_bbs2
.globl apu_bbs3
.globl apu_bbs4
.globl apu_bbs5
.globl apu_bbs6
.globl apu_bbs7
.globl apu_cbnea
.globl apu_cbnex
.globl apu_dbnzy
.globl apu_dbnza
.globl apu_bra
.globl apu_jmpabs
.globl apu_jmpabx
.globl apu_call
.globl apu_tcall0
.globl apu_tcall1
.globl apu_tcall2
.globl apu_tcall3
.globl apu_tcall4
.globl apu_tcall5
.globl apu_tcall6
.globl apu_tcall7
.globl apu_tcall8
.globl apu_tcall9
.globl apu_tcallA
.globl apu_tcallB
.globl apu_tcallC
.globl apu_tcallD
.globl apu_tcallE
.globl apu_tcallF
.globl apu_pcall
.globl apu_ret
.globl apu_ret1
.globl apu_brk
.globl apu_nop
.globl apu_clrp
.globl apu_setp
.globl apu_ei
.globl apu_di

.text

apu_bpl: // BPL dest
    // Check the condition (N clear)
    NONE 2
    lbu  t0, apu_flags
    andi t0, t0, 0x80 // N
    bnez t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


apu_bmi: // BMI dest
    // Check the condition (N set)
    NONE 2
    lbu  t0, apu_flags
    andi t0, t0, 0x80 // N
    beqz t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


apu_bvc: // BVC dest
    // Check the condition (V clear)
    NONE 2
    lbu  t0, apu_flags
    andi t0, t0, 0x40 // V
    bnez t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


apu_bvs: // BVS dest
    // Check the condition (V set)
    NONE 2
    lbu  t0, apu_flags
    andi t0, t0, 0x40 // V
    beqz t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


apu_bcc: // BCC dest
    // Check the condition (C clear)
    NONE 2
    lbu  t0, apu_flags
    andi t0, t0, 0x1 // C
    bnez t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


apu_bcs: // BCS dest
    // Check the condition (C set)
    NONE 2
    lbu  t0, apu_flags
    andi t0, t0, 0x1 // C
    beqz t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


apu_bne: // BNE dest
    // Check the condition (Z clear)
    NONE 2
    lbu  t0, apu_flags
    andi t0, t0, 0x2 // Z
    bnez t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


apu_beq: // BEQ dest
    // Check the condition (Z set)
    NONE 2
    lbu  t0, apu_flags
    andi t0, t0, 0x2 // Z
    beqz t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


.macro BBC mask // BBC aa.b,dest
    // Check the condition (bit b in [aa] clear)
    DIR  3
    jal  apu_read8
    andi t0, v0, \mask
    bnez t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 2
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 3
    sh   t0, apu_count
    j    cpu_execute
.endm

apu_bbc0: BBC 0x01 // BBC aa.0,dest
apu_bbc1: BBC 0x02 // BBC aa.1,dest
apu_bbc2: BBC 0x04 // BBC aa.2,dest
apu_bbc3: BBC 0x08 // BBC aa.3,dest
apu_bbc4: BBC 0x10 // BBC aa.4,dest
apu_bbc5: BBC 0x20 // BBC aa.5,dest
apu_bbc6: BBC 0x40 // BBC aa.6,dest
apu_bbc7: BBC 0x80 // BBC aa.7,dest


.macro BBS mask // BBS aa.b,dest
    // Check the condition (bit b in [aa] set)
    DIR  3
    jal  apu_read8
    andi t0, v0, \mask
    beqz t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 2
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 3
    sh   t0, apu_count
    j    cpu_execute
.endm

apu_bbs0: BBS 0x01 // BBS aa.0,dest
apu_bbs1: BBS 0x02 // BBS aa.1,dest
apu_bbs2: BBS 0x04 // BBS aa.2,dest
apu_bbs3: BBS 0x08 // BBS aa.3,dest
apu_bbs4: BBS 0x10 // BBS aa.4,dest
apu_bbs5: BBS 0x20 // BBS aa.5,dest
apu_bbs6: BBS 0x40 // BBS aa.6,dest
apu_bbs7: BBS 0x80 // BBS aa.7,dest


.macro CBNE // CBNE op
    // Check the condition (accumulator not equal [aa])
    jal  apu_read8
    lbu  t0, apu_accum
    xor  t0, t0, v0
    beqz t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 2
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 3
    sh   t0, apu_count
    j    cpu_execute
.endm

apu_cbnea: DIR 3; CBNE // CBNE aa,dest
apu_cbnex: DRX 3; CBNE // CBNE aa+X,dest


apu_dbnzy: // DBNZ Y,dest
    // Decrement register Y and check the condition (Y not zero)
    NONE 2
    lbu  t0, apu_reg_y
    addi t0, t0, -1
    sb   t0, apu_reg_y
    beqz t0, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


apu_dbnza: // DBNZ aa,dest
    // Decrement the memory value and check the condition ([aa] not zero)
    DIR  3
    jal  apu_read8
    addi a1, v0, -1
    jal  apu_write8
    beqz a1, cpu_execute

    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 2
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 3
    sh   t0, apu_count
    j    cpu_execute


apu_bra: // BRA dest
    // Sign-extend the offset value and add it to the PC
    addi a0, s0, 1
    jal  apu_read8
    sll  t0, v0, 24
    sra  t0, t0, 24
    add  t0, t0, s0
    addi t0, t0, 2
    sh   t0, apu_count
    j    cpu_execute


apu_jmpabs: // JMP aaaa
    // Jump to an absolute address
    ABS
    sh   a0, apu_count
    j    cpu_execute


apu_jmpabx: // JMP [aaaa+X]
    // Jump to an absolute address from memory
    ABX
    addi s1, a0, 1
    jal  apu_read8
    andi a0, s1, 0xFFFF
    move s1, v0
    jal  apu_read8
    sll  t0, v0, 8
    or   t0, t0, s1
    sh   t0, apu_count
    j    cpu_execute


apu_call: // CALL aaaa
    // Jump to an absolute address
    ABS
    sh   a0, apu_count

    // Push the old program counter to the stack
    lhu  s1, apu_stack
    addi a0, s1, -1
    addi a1, s0, 3
    jal  apu_write8
    move a0, s1
    srl  a1, a1, 8
    jal  apu_write8
    addi t0, s1, -2
    sb   t0, apu_stack + 1
    j    cpu_execute


.macro TCALL n // TCALL n
    // Jump to a 16-bit value from an address based on n
    li   a0, 0xFFDE - (\n * 2) + 1
    jal  apu_read8
    sll  s1, v0, 8
    addi a0, a0, -1
    jal  apu_read8
    or   a1, v0, s1
    sh   a1, apu_count

    // Push the old program counter to the stack
    lhu  s1, apu_stack
    addi a0, s1, -1
    addi a1, s0, 1
    jal  apu_write8
    move a0, s1
    srl  a1, a1, 8
    jal  apu_write8
    addi t0, s1, -2
    sb   t0, apu_stack + 1
    j    cpu_execute
.endm

apu_tcall0: TCALL 0x0
apu_tcall1: TCALL 0x1
apu_tcall2: TCALL 0x2
apu_tcall3: TCALL 0x3
apu_tcall4: TCALL 0x4
apu_tcall5: TCALL 0x5
apu_tcall6: TCALL 0x6
apu_tcall7: TCALL 0x7
apu_tcall8: TCALL 0x8
apu_tcall9: TCALL 0x9
apu_tcallA: TCALL 0xA
apu_tcallB: TCALL 0xB
apu_tcallC: TCALL 0xC
apu_tcallD: TCALL 0xD
apu_tcallE: TCALL 0xE
apu_tcallF: TCALL 0xF


apu_pcall: // PCALL uu
    // Jump to an address in the highest page of RAM
    addi a0, s0, 1
    jal  apu_read8
    ori  t0, v0, 0xFF00
    sh   t0, apu_count

    // Push the old program counter to the stack
    lhu  s1, apu_stack
    addi a0, s1, -1
    addi a1, s0, 2
    jal  apu_write8
    move a0, s1
    srl  a1, a1, 8
    jal  apu_write8
    addi t0, s1, -2
    sb   t0, apu_stack + 1
    j    cpu_execute


apu_ret: // RET
    // Pop the program counter from the stack
    lhu  s1, apu_stack
    addi a0, s1, 2
    sb   a0, apu_stack + 1
    jal  apu_read8
    addi a0, s1, 1
    sll  s1, v0, 8
    jal  apu_read8
    or   t0, v0, s1
    sh   t0, apu_count
    j    cpu_execute


apu_ret1: // RET1
    // Pop the flags from the stack
    lhu  s1, apu_stack
    addi a0, s1, 1
    jal  apu_read8
    sb   v0, apu_flags

    // Pop the program counter from the stack
    addi a0, s1, 3
    sb   a0, apu_stack + 1
    jal  apu_read8
    addi a0, s1, 2
    sll  s1, v0, 8
    jal  apu_read8
    or   t0, v0, s1
    sh   t0, apu_count
    j    cpu_execute


apu_brk: // BRK
    // Jump to the address stored at 0xFFDE
    li   a0, 0xFFDF
    jal  apu_read8
    sll  s1, v0, 8
    li   a0, 0xFFDE
    jal  apu_read8
    or   t0, v0, s1
    sh   t0, apu_count

    // Push the old program counter to the stack
    lhu  s1, apu_stack
    addi a0, s1, -1
    addi a1, s0, 1
    jal  apu_write8
    move a0, s1
    srl  a1, a1, 8
    jal  apu_write8

    // Push the flags to the stack and modify current ones
    lbu  a1, apu_flags
    andi t0, a1, 0xFB // Clear I
    ori  t0, t0, 0x10 // Set B
    sb   t0, apu_flags
    addi a0, s1, -2
    jal  apu_write8
    addi t0, s1, -3
    sb   t0, apu_stack + 1
    j    cpu_execute


apu_nop: // NOP
    // Do nothing except advance the program counter
    NONE
    j    cpu_execute


apu_clrp: // CLRP
    // Clear the P flag
    NONE
    lbu  t0, apu_flags
    andi t0, t0, 0xDF
    sb   t0, apu_flags
    j    cpu_execute


apu_setp: // SETP
    // Set the P flag
    NONE
    lbu  t0, apu_flags
    ori  t0, t0, 0x20
    sb   t0, apu_flags
    j    cpu_execute


apu_di: // DI
    // Clear the I flag
    NONE
    lbu  t0, apu_flags
    andi t0, t0, 0xFB
    sb   t0, apu_flags
    j    cpu_execute


apu_ei: // EI
    // Set the I flag
    NONE
    lbu  t0, apu_flags
    ori  t0, t0, 0x4
    sb   t0, apu_flags
    j    cpu_execute
