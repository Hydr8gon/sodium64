/*
    Copyright 2021-2024 Hydr8gon

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

#include "macros.h"

.globl apu_ora
.globl apu_orm
.globl apu_anda
.globl apu_andm
.globl apu_eora
.globl apu_eorm
.globl apu_cmpa
.globl apu_cmpx
.globl apu_cmpy
.globl apu_cmpm
.globl apu_adca
.globl apu_adcm
.globl apu_sbca
.globl apu_sbcm
.globl apu_asla
.globl apu_aslm
.globl apu_lsra
.globl apu_lsrm
.globl apu_rola
.globl apu_rolm
.globl apu_rora
.globl apu_rorm
.globl apu_deca
.globl apu_decx
.globl apu_decy
.globl apu_decm
.globl apu_inca
.globl apu_incx
.globl apu_incy
.globl apu_incm
.globl apu_addw
.globl apu_subw
.globl apu_cmpw
.globl apu_decw
.globl apu_incw
.globl apu_div
.globl apu_mul
.globl apu_clr1
.globl apu_set1
.globl apu_not1
.globl apu_mov1a
.globl apu_mov1b
.globl apu_or1a
.globl apu_or1b
.globl apu_and1a
.globl apu_and1b
.globl apu_eor1
.globl apu_clrc
.globl apu_setc
.globl apu_notc
.globl apu_clrv
.globl apu_xcn
.globl apu_tclr1
.globl apu_tset1

.text
.set noreorder

.align 5
apu_ora: // OR A,op
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA

    // Emit code to bitwise or a value with the accumulator and set flags
    EMIT_OP OR(T7, T7, V0)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_orm: // OR op
    // Emit code to bitwise or a value with another memory value and set flags
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP OR(S0, ZERO, V0)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(A1, S0, V0)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_anda: // AND A,op
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA

    // Emit code to bitwise and a value with the accumulator and set flags
    EMIT_OP AND(T7, T7, V0)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_andm: // AND op
    // Emit code to bitwise and a value with another memory value and set flags
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP OR(S0, ZERO, V0)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP AND(A1, S0, V0)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_eora: // EOR A,op
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA

    // Emit code to bitwise exclusive or a value with the accumulator and set flags
    EMIT_OP XOR(T7, T7, V0)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_eorm: // EOR op
    // Emit code to bitwise exclusive or a value with another memory value and set flags
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP OR(S0, ZERO, V0)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP XOR(A1, S0, V0)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_cmpa: // CMP A,op
    // Update the JIT register state
    jal load_accum
    nop
    jal load_flags
    nop

    // Emit code to compare a value with the accumulator and set flags
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP SUB(T0, T7, V0)
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP ADDI(T1, T7, 1)
    EMIT_OP SLTU(T1, T0, T1) // C
    EMIT_OP OR(S1, S1, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_cmpx: // CMP X,op
    // Update the JIT register state
    jal load_reg_x
    nop
    jal load_flags
    nop

    // Emit code to compare a value with register X and set flags
    EMIT_OP ANDI(T9, T9, 0xFF)
    EMIT_OP SUB(T0, T9, V0)
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP ADDI(T1, T9, 1)
    EMIT_OP SLTU(T1, T0, T1) // C
    EMIT_OP OR(S1, S1, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_cmpy: // CMP Y,op
    // Update the JIT register state
    jal load_reg_y
    nop
    jal load_flags
    nop

    // Emit code to compare a value with register Y and set flags
    EMIT_OP ANDI(T8, T8, 0xFF)
    EMIT_OP SUB(T0, T8, V0)
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP ADDI(T1, T8, 1)
    EMIT_OP SLTU(T1, T0, T1) // C
    EMIT_OP OR(S1, S1, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_cmpm: // CMP op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to compare a value with another memory value and set flags
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP OR(S0, ZERO, V0)
    EMIT_OP SUB(T0, V0, S0)
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP ADDI(T1, V0, 1)
    EMIT_OP SLTU(T1, T0, T1) // C
    EMIT_OP OR(S1, S1, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_adca: // ADC A,op
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA
    jal load_flags
    nop

    // Emit code to add a value with carry to the accumulator
    EMIT_OP ANDI(T0, T7, 0xFF)
    EMIT_OP ADD(T7, T0, V0)
    EMIT_OP ANDI(T1, S1, 0x1) // C
    EMIT_OP ADD(T7, T7, T1)

    // Emit code to set flags for addition
    // TODO: set the H flag
    EMIT_OP ANDI(S1, S1, 0xB6)
    EMIT_OP SRL(T1, T7, 8) // C
    EMIT_OP OR(S1, S1, T1)
    EMIT_OP XOR(T1, T7, T0)
    EMIT_OP XOR(T2, T7, V0)
    EMIT_OP AND(T1, T1, T2)
    EMIT_OP SRL(T1, T1, 1)
    EMIT_OP ANDI(T1, T1, 0x40) // V
    EMIT_OP OR(S1, S1, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_adcm: // ADC op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to add a value with carry to another memory value
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP OR(S0, ZERO, V0)
    EMIT_OP ADD(A1, V0, S0)
    EMIT_OP ANDI(T1, S1, 0x1) // C
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADD(A1, A1, T1)

    // Emit code to set flags for addition
    // TODO: set the H flag
    EMIT_OP ANDI(S1, S1, 0xB6)
    EMIT_OP SRL(T1, A1, 8) // C
    EMIT_OP OR(S1, S1, T1)
    EMIT_OP XOR(T1, A1, V0)
    EMIT_OP XOR(T2, A1, S0)
    EMIT_OP AND(T1, T1, T2)
    EMIT_OP SRL(T1, T1, 1)
    EMIT_OP ANDI(T1, T1, 0x40) // V
    EMIT_OP OR(S1, S1, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_sbca: // SBC A,op
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA
    jal load_flags
    nop

    // Emit code to subtract a value with carry from the accumulator
    EMIT_OP ANDI(T0, T7, 0xFF)
    EMIT_OP SUB(T7, T0, V0)
    EMIT_OP ADDI(T7, T7, -1)
    EMIT_OP ANDI(T1, S1, 0x1) // C
    EMIT_OP ADD(T7, T7, T1)

    // Emit code to set flags for subtraction
    // TODO: set the H flag
    EMIT_OP ANDI(S1, S1, 0xB6)
    EMIT_OP ADDI(T1, T0, 1)
    EMIT_OP SLTU(T1, T7, T1) // C
    EMIT_OP OR(S1, S1, T1)
    EMIT_OP XOR(T1, T0, V0)
    EMIT_OP XOR(T2, T0, T7)
    EMIT_OP AND(T1, T1, T2)
    EMIT_OP SRL(T1, T1, 1)
    EMIT_OP ANDI(T1, T1, 0x40) // V
    EMIT_OP OR(S1, S1, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_sbcm: // SBC op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to subtract a value with carry from another memory value
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP OR(S0, ZERO, V0)
    EMIT_OP SUB(A1, V0, S0)
    EMIT_OP ADDI(A1, A1, -1)
    EMIT_OP ANDI(T1, S1, 0x1) // C
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADD(A1, A1, T1)

    // Emit code to set flags for subtraction
    // TODO: set the H flag
    EMIT_OP ANDI(S1, S1, 0xB6)
    EMIT_OP ADDI(T1, V0, 1)
    EMIT_OP SLTU(T1, A1, T1) // C
    EMIT_OP OR(S1, S1, T1)
    EMIT_OP XOR(T1, V0, S0)
    EMIT_OP XOR(T2, V0, A1)
    EMIT_OP AND(T1, T1, T2)
    EMIT_OP SRL(T1, T1, 1)
    EMIT_OP ANDI(T1, T1, 0x40) // V
    EMIT_OP OR(S1, S1, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_asla: // ASL A
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA
    jal load_flags
    nop

    // Emit code to shift the accumulator left and set flags
    EMIT_OP SLL(T7, T7, 1)
    EMIT_OP SRL(T0, T7, 8)
    EMIT_OP ANDI(T0, T0, 0x1) // C
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP OR(S1, S1, T0)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_aslm: // ASL op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to shift a memory value left and set flags
    EMIT_OP SLL(A1, V0, 1)
    EMIT_OP SRL(T0, A1, 8)
    EMIT_OP ANDI(T0, T0, 0x1) // C
    EMIT_OP ANDI(S1, S1, 0xFE)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(S1, S1, T0)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_lsra: // LSR A
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA
    jal load_flags
    nop

    // Emit code to shift the accumulator right and set flags
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP ANDI(T0, T7, 0x1) // C
    EMIT_OP SRL(T7, T7, 1)
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP OR(S1, S1, T0)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_lsrm: // LSR op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to shift a memory value right and set flags
    EMIT_OP ANDI(T0, V0, 0x1) // C
    EMIT_OP SRL(A1, V0, 1)
    EMIT_OP ANDI(S1, S1, 0xFE)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(S1, S1, T0)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_rola: // ROL A
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA
    jal load_flags
    nop

    // Emit code to rotate the accumulator left and set flags
    EMIT_OP SLL(T7, T7, 1)
    EMIT_OP ANDI(T1, S1, 0x1)
    EMIT_OP OR(T7, T7, T1)
    EMIT_OP SRL(T0, T7, 8)
    EMIT_OP ANDI(T0, T0, 0x1) // C
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP OR(S1, S1, T0)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_rolm: // ROL op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to rotate a memory value left and set flags
    EMIT_OP SLL(A1, V0, 1)
    EMIT_OP ANDI(T1, S1, 0x1)
    EMIT_OP OR(A1, A1, T1)
    EMIT_OP SRL(T0, A1, 8)
    EMIT_OP ANDI(T0, T0, 0x1) // C
    EMIT_OP ANDI(S1, S1, 0xFE)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(S1, S1, T0)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_rora: // ROR A
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA
    jal load_flags
    nop

    // Emit code to rotate the accumulator right and set flags
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP ANDI(T0, T7, 0x1) // C
    EMIT_OP SRL(T7, T7, 1)
    EMIT_OP SLL(T1, S1, 7)
    EMIT_OP OR(T7, T7, T1)
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP OR(S1, S1, T0)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_rorm: // ROR op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to rotate a memory value right and set flags
    EMIT_OP ANDI(T0, V0, 0x1) // C
    EMIT_OP SRL(A1, V0, 1)
    EMIT_OP SLL(T1, S1, 7)
    EMIT_OP OR(A1, A1, T1)
    EMIT_OP ANDI(S1, S1, 0xFE)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(S1, S1, T0)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_deca: // DEC A
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA

    // Emit code to decrement the accumulator and set flags
    EMIT_OP ADDI(T7, T7, -1)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_decx: // DEC X
    // Update the JIT register state
    jal load_reg_x
    ori s1, s1, FLAG_SX

    // Emit code to decrement register X and set flags
    EMIT_OP ADDI(T9, T9, -1)
    la ra, finish_opcode
    j queue_nz
    li t1, T9

.align 5
apu_decy: // DEC Y
    // Update the JIT register state
    jal load_reg_y
    ori s1, s1, FLAG_SY

    // Emit code to decrement register Y and set flags
    EMIT_OP ADDI(T8, T8, -1)
    la ra, finish_opcode
    j queue_nz
    li t1, T8

.align 5
apu_decm: // DEC op
    // Emit code to decrement a memory value and set flags
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(A1, V0, -1)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_inca: // INC A
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA

    // Emit code to increment the accumulator and set flags
    EMIT_OP ADDI(T7, T7, 1)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_incx: // INC X
    // Update the JIT register state
    jal load_reg_x
    ori s1, s1, FLAG_SX

    // Emit code to increment register X and set flags
    EMIT_OP ADDI(T9, T9, 1)
    la ra, finish_opcode
    j queue_nz
    li t1, T9

.align 5
apu_incy: // INC Y
    // Update the JIT register state
    jal load_reg_y
    ori s1, s1, FLAG_SY

    // Emit code to increment register Y and set flags
    EMIT_OP ADDI(T8, T8, 1)
    la ra, finish_opcode
    j queue_nz
    li t1, T8

.align 5
apu_incm: // INC op
    // Emit code to increment a memory value and set flags
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(A1, V0, 1)
    la ra, finish_opcode
    j queue_nz
    li t1, A1

.align 5
apu_addw: // ADDW YA,op
    // Update the JIT register state
    jal load_reg_y
    ori s1, s1, FLAG_SY | FLAG_SA
    jal load_accum
    nop
    jal load_flags
    nop

    // Emit code to load a 16-bit value from memory
    EMIT_OP OR(S0, ZERO, V0)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)
    EMIT_OP SLL(T0, V0, 8)
    EMIT_OP OR(A1, S0, T0)

    // Emit code to add the value to register YA
    EMIT_OP ANDI(T8, T8, 0xFF)
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP SLL(T0, T8, 8)
    EMIT_OP OR(T0, T0, T7)
    EMIT_OP ADD(T7, T0, A1)
    EMIT_OP SRL(T8, T7, 8)

    // Emit code to set carry and overflow
    // TODO: set the H flag
    EMIT_OP ANDI(S1, S1, 0xB6)
    EMIT_OP SRL(T1, T7, 16) // C
    EMIT_OP OR(S1, S1, T1)
    EMIT_OP XOR(T1, T7, T0)
    EMIT_OP XOR(T2, T7, A1)
    EMIT_OP AND(T1, T1, T2)
    EMIT_OP SRL(T1, T1, 9)
    EMIT_OP ANDI(T1, T1, 0x40) // V
    EMIT_OP OR(S1, S1, T1)

    // Emit code to set flags for the 16-bit result
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP SLT(T0, ZERO, T7)
    EMIT_OP OR(T0, T0, T8)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_subw: // SUBW YA,op
    // Update the JIT register state
    jal load_reg_y
    ori s1, s1, FLAG_SY | FLAG_SA
    jal load_accum
    nop
    jal load_flags
    nop

    // Emit code to load a 16-bit value from memory
    EMIT_OP OR(S0, ZERO, V0)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)
    EMIT_OP SLL(T0, V0, 8)
    EMIT_OP OR(A1, S0, T0)

    // Emit code to subtract the value from register YA
    EMIT_OP ANDI(T8, T8, 0xFF)
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP SLL(T0, T8, 8)
    EMIT_OP OR(T0, T0, T7)
    EMIT_OP SUB(T7, T0, A1)
    EMIT_OP SRL(T8, T7, 8)

    // Emit code to set carry and overflow
    // TODO: set the H flag
    EMIT_OP ANDI(S1, S1, 0xB6)
    EMIT_OP ADDI(T1, T0, 1)
    EMIT_OP SLTU(T1, T7, T1) // C
    EMIT_OP OR(S1, S1, T1)
    EMIT_OP XOR(T1, T0, A1)
    EMIT_OP XOR(T2, T0, T7)
    EMIT_OP AND(T1, T1, T2)
    EMIT_OP SRL(T1, T1, 9)
    EMIT_OP ANDI(T1, T1, 0x40) // V
    EMIT_OP OR(S1, S1, T1)

    // Emit code to set flags for the 16-bit result
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP SLT(T0, ZERO, T7)
    EMIT_OP OR(T0, T0, T8)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_cmpw: // CMPW YA,op
    // Update the JIT register state
    jal load_reg_y
    nop
    jal load_accum
    nop
    jal load_flags
    nop

    // Emit code to load a 16-bit value from memory
    EMIT_OP OR(S0, ZERO, V0)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)
    EMIT_OP SLL(T0, V0, 8)
    EMIT_OP OR(A1, S0, T0)

    // Emit code to compare the value with register YA and set carry
    EMIT_OP ANDI(T8, T8, 0xFF)
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP SLL(T1, T8, 8)
    EMIT_OP OR(T1, T1, T7)
    EMIT_OP SUB(T0, T1, A1)
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP ADDI(T1, T1, 1)
    EMIT_OP SLTU(T1, T0, T1) // C
    EMIT_OP OR(S1, S1, T1)

    // Emit code to set flags for the 16-bit result
    EMIT_OP ANDI(T1, T0, 0xFF)
    EMIT_OP SLT(T1, ZERO, T1)
    EMIT_OP SRL(T0, T0, 8)
    EMIT_OP OR(T0, T0, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_decw: // DECW op
    // Emit code to load a 16-bit value from memory
    EMIT_OP OR(S0, ZERO, V0)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)
    EMIT_OP SLL(T0, V0, 8)
    EMIT_OP OR(A1, S0, T0)

    // Emit code to decrement the value and store it back in memory
    EMIT_OP ADDI(A1, A1, -1)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, -1)
    EMIT_OP ANDI(S0, A1, 0xFF)
    EMIT_OP SRL(A1, A1, 8)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)

    // Emit code to set flags for the 16-bit result
    EMIT_OP SLT(T0, ZERO, S0)
    EMIT_OP OR(T0, T0, A1)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_incw: // INCW op
    // Emit code to load a 16-bit value from memory
    EMIT_OP OR(S0, ZERO, V0)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)
    EMIT_OP SLL(T0, V0, 8)
    EMIT_OP OR(A1, S0, T0)

    // Emit code to increment the value and store it back in memory
    EMIT_OP ADDI(A1, A1, 1)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, -1)
    EMIT_OP ANDI(S0, A1, 0xFF)
    EMIT_OP SRL(A1, A1, 8)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)

    // Emit code to set flags for the 16-bit result
    EMIT_OP SLT(T0, ZERO, S0)
    EMIT_OP OR(T0, T0, A1)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_div: // DIV YA,X
    // Update the JIT register state
    jal load_reg_x
    ori s1, s1, FLAG_SY | FLAG_SA
    jal load_reg_y
    nop
    jal load_accum
    nop
    jal load_flags
    nop

    // Emit code to divide register YA by register X
    EMIT_OP ANDI(T9, T9, 0xFF)
    EMIT_OP ANDI(T8, T8, 0xFF)
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP SLL(T0, T8, 8)
    EMIT_OP OR(T0, T0, T7)
    EMIT_OP DIV(T0, T9)

    // Emit code to move the result to register YA and set flags for Y
    // TODO: set the H flag
    EMIT_OP MFLO(T7) // Quotient
    EMIT_OP MFHI(T8) // Remainder
    EMIT_OP ANDI(S1, S1, 0xB7)
    EMIT_OP SRL(T0, T7, 8)
    EMIT_OP SLT(T0, ZERO, T0)
    EMIT_OP SLL(T0, T0, 6) // V
    EMIT_OP OR(S1, S1, T0)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_mul: // MUL YA
    // Update the JIT register state
    jal load_reg_y
    ori s1, s1, FLAG_SY | FLAG_SA
    jal load_accum
    nop

    // Emit code to multiply register Y by the accumulator
    EMIT_OP ANDI(T8, T8, 0xFF)
    EMIT_OP ANDI(T7, T7, 0xFF)
    EMIT_OP MULT(T8, T7)

    // Emit code to move the result to register YA and set flags for Y
    EMIT_OP MFLO(T7)
    EMIT_OP SRL(T8, T7, 8)
    la ra, finish_opcode
    j queue_nz
    li t1, T8

.align 5
apu_clr1: // CLR1 op.b
    // Create a mask based on the opcode number
    srl t0, v1, 8
    andi t0, t0, 0x7
    li t1, 1
    sll t1, t1, t0
    xori t2, t1, 0xFF

    // Emit code to clear a bit in a memory value
    la t0, apu_write8
    jal emit_jal
    nop
    li t0, ANDI(A1, V0, 0)
    la ra, finish_opcode
    j emit_op
    or t0, t0, t2

.align 5
apu_set1: // SET1 op.b
    // Create a mask based on the opcode number
    srl t0, v1, 8
    andi t0, t0, 0x7
    li t1, 1
    sll t2, t1, t0

    // Emit code to set a bit in a memory value
    la t0, apu_write8
    jal emit_jal
    nop
    li t0, ORI(A1, V0, 0)
    la ra, finish_opcode
    j emit_op
    or t0, t0, t2

.align 5
apu_not1: // NOT1 op
    // Emit code to invert a bit in a memory value
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP XOR(A1, A1, V0)
    j finish_opcode
    nop

.align 5
apu_mov1a: // MOV1 op,C
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to set a bit in a memory value to the carry flag
    EMIT_OP XORI(T0, A1, 0xFF)
    EMIT_OP AND(T0, T0, V0)
    EMIT_OP ANDI(T1, S1, 0x1)
    EMIT_OP SUB(T1, ZERO, T1)
    EMIT_OP AND(T1, T1, A1)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(A1, T0, T1)
    j finish_opcode
    nop

.align 5
apu_mov1b: // MOV1 C,op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to set the carry flag to a bit from a memory value
    EMIT_OP AND(T0, V0, A1)
    EMIT_OP SLT(T0, ZERO, T0)
    EMIT_OP ANDI(S1, S1, 0xFE)
    EMIT_OP OR(S1, S1, T0)
    j finish_opcode
    nop

.align 5
apu_or1a: // OR1 C,op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to bitwise or the carry flag with a bit from a memory value
    EMIT_OP AND(T0, V0, A1)
    EMIT_OP SLT(T0, ZERO, T0)
    EMIT_OP OR(S1, S1, T0)
    j finish_opcode
    nop

.align 5
apu_or1b: // OR1 C,/op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to bitwise or the carry flag with a negated bit from a memory value
    EMIT_OP AND(T0, V0, A1)
    EMIT_OP SLT(T0, ZERO, T0)
    EMIT_OP XORI(T0, T0, 0x1)
    EMIT_OP OR(S1, S1, T0)
    j finish_opcode
    nop

.align 5
apu_and1a: // AND1 C,op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to bitwise and the carry flag with a bit from a memory value
    EMIT_OP AND(T0, V0, A1)
    EMIT_OP SLT(T0, ZERO, T0)
    EMIT_OP ORI(T0, T0, 0xFE)
    EMIT_OP AND(S1, S1, T0)
    j finish_opcode
    nop

.align 5
apu_and1b: // AND1 C,/op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to bitwise and the carry flag with a negated bit from a memory value
    EMIT_OP AND(T0, V0, A1)
    EMIT_OP SLT(T0, ZERO, T0)
    EMIT_OP XORI(T0, T0, 0x1)
    EMIT_OP ORI(T0, T0, 0xFE)
    EMIT_OP AND(S1, S1, T0)
    j finish_opcode
    nop

.align 5
apu_eor1: // EOR1 C,op
    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to bitwise exclusive or the carry flag with a bit from a memory value
    EMIT_OP AND(T0, V0, A1)
    EMIT_OP SLT(T0, ZERO, T0)
    EMIT_OP XOR(S1, S1, T0)
    j finish_opcode
    nop

.align 5
apu_clrc: // CLRC
    // Update the JIT register state
    jal load_flags
    ori s1, s1, FLAG_SF

    // Emit code to clear the C flag
    EMIT_OP ANDI(S1, S1, 0xFE)
    j finish_opcode
    nop

.align 5
apu_setc: // SETC
    // Update the JIT register state
    jal load_flags
    ori s1, s1, FLAG_SF

    // Emit code to set the C flag
    EMIT_OP ORI(S1, S1, 0x1)
    j finish_opcode
    nop

.align 5
apu_notc: // NOTC
    // Update the JIT register state
    jal load_flags
    ori s1, s1, FLAG_SF

    // Emit code to negate the C flag
    EMIT_OP XORI(S1, S1, 0x1)
    j finish_opcode
    nop

.align 5
apu_clrv: // CLRV
    // Update the JIT register state
    jal load_flags
    ori s1, s1, FLAG_SF

    // Emit code to clear the V and H flags
    EMIT_OP ANDI(S1, S1, 0xB7)
    j finish_opcode
    nop

.align 5
apu_xcn: // XCN A
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SA

    // Emit code to reverse the accumulator's high and low nibbles
    EMIT_OP SRL(T0, T7, 4)
    EMIT_OP SLL(T1, T7, 4)
    EMIT_OP OR(T7, T0, T1)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_tclr1: // TCLR1 op
    // Update the JIT register state
    jal load_accum
    nop

    // Emit code to clear bits in a memory value and set flags
    EMIT_OP XORI(T0, T7, 0xFF)
    EMIT_OP AND(A1, V0, T0)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP SUB(T0, T7, V0) // CMP
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_tset1: // TSET1 op
    // Update the JIT register state
    jal load_accum
    nop

    // Emit code to set bits in a memory value and set flags
    EMIT_OP OR(A1, V0, T7)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP SUB(T0, T7, V0) // CMP
    la ra, finish_opcode
    j queue_nz
    li t1, T0
