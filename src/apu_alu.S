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

apu_ora: // OR A,op
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to bitwise or a value with the accumulator and set flags
    jal load_accum
    li t0, T7
    li t1, T7
    li t2, V0
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_orm: // OR op
    // Emit code to bitwise or a value with another memory value and set flags
    la t0, apu_read8
    jal emit_jal
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, S0
    li t2, V0
    jal emit_or
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_anda: // AND A,op
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to bitwise and a value with the accumulator and set flags
    jal load_accum
    li t0, T7
    li t1, T7
    li t2, V0
    jal emit_and
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_andm: // AND op
    // Emit code to bitwise and a value with another memory value and set flags
    la t0, apu_read8
    jal emit_jal
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, S0
    li t2, V0
    jal emit_and
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_eora: // EOR A,op
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to bitwise exclusive or a value with the accumulator and set flags
    jal load_accum
    li t0, T7
    li t1, T7
    li t2, V0
    jal emit_xor
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_eorm: // EOR op
    // Emit code to bitwise exclusive or a value with another memory value and set flags
    la t0, apu_read8
    jal emit_jal
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, S0
    li t2, V0
    jal emit_xor
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_cmpa: // CMP A,op
    // Emit code to compare a value with the accumulator and set flags
    jal load_accum
    jal load_flags
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, T7
    li t2, V0
    jal emit_sub
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, T1
    li t1, T7
    li t2, 1
    jal emit_addi
    li t0, T1
    li t1, T0
    li t2, T1
    jal emit_sltu // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_cmpx: // CMP X,op
    // Emit code to compare a value with register X and set flags
    jal load_reg_x
    jal load_flags
    li t0, T9
    li t1, T9
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, T9
    li t2, V0
    jal emit_sub
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, T1
    li t1, T9
    li t2, 1
    jal emit_addi
    li t0, T1
    li t1, T0
    li t2, T1
    jal emit_sltu // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_cmpy: // CMP Y,op
    // Emit code to compare a value with register Y and set flags
    jal load_reg_y
    jal load_flags
    li t0, T8
    li t1, T8
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, T8
    li t2, V0
    jal emit_sub
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, T1
    li t1, T8
    li t2, 1
    jal emit_addi
    li t0, T1
    li t1, T0
    li t2, T1
    jal emit_sltu // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_cmpm: // CMP op
    // Emit code to compare a value with another memory value and set flags
    jal load_flags
    la t0, apu_read8
    jal emit_jal
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    li t0, T0
    li t1, V0
    li t2, S0
    jal emit_sub
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, T1
    li t1, V0
    li t2, 1
    jal emit_addi
    li t0, T1
    li t1, T0
    li t2, T1
    jal emit_sltu // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_adca: // ADC A,op
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to add a value with carry to the accumulator
    jal load_accum
    jal load_flags
    li t0, T0
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T7
    li t1, T0
    li t2, V0
    jal emit_add
    li t0, T1
    li t1, S1
    li t2, 0x1
    jal emit_andi // C
    li t0, T7
    li t1, T7
    li t2, T1
    jal emit_add

    // Emit code to set flags for addition
    // TODO: set the H flag
    li t0, S1
    li t1, S1
    li t2, 0xB6
    jal emit_andi
    li t0, T1
    li t1, T7
    li t2, 8
    jal emit_srl // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t0, T1
    li t1, T7
    li t2, T0
    jal emit_xor
    li t0, T2
    li t1, T7
    li t2, V0
    jal emit_xor
    li t0, T1
    li t1, T1
    li t2, T2
    jal emit_and
    li t0, T1
    li t1, T1
    li t2, 1
    jal emit_srl
    li t0, T1
    li t1, T1
    li t2, 0x40
    jal emit_andi // V
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_adcm: // ADC op
    // Emit code to add a value with carry to another memory value
    jal load_flags
    la t0, apu_read8
    jal emit_jal
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    li t0, A1
    li t1, V0
    li t2, S0
    jal emit_add
    li t0, T1
    li t1, S1
    li t2, 0x1
    jal emit_andi // C
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, A1
    li t2, T1
    jal emit_add

    // Emit code to set flags for addition
    // TODO: set the H flag
    li t0, S1
    li t1, S1
    li t2, 0xB6
    jal emit_andi
    li t0, T1
    li t1, A1
    li t2, 8
    jal emit_srl // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t0, T1
    li t1, A1
    li t2, V0
    jal emit_xor
    li t0, T2
    li t1, A1
    li t2, S0
    jal emit_xor
    li t0, T1
    li t1, T1
    li t2, T2
    jal emit_and
    li t0, T1
    li t1, T1
    li t2, 1
    jal emit_srl
    li t0, T1
    li t1, T1
    li t2, 0x40
    jal emit_andi // V
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_sbca: // SBC A,op
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to subtract a value with carry from the accumulator
    jal load_accum
    jal load_flags
    li t0, T0
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T7
    li t1, T0
    li t2, V0
    jal emit_sub
    li t0, T7
    li t1, T7
    li t2, -1
    jal emit_addi
    li t0, T1
    li t1, S1
    li t2, 0x1
    jal emit_andi // C
    li t0, T7
    li t1, T7
    li t2, T1
    jal emit_add

    // Emit code to set flags for subtraction
    // TODO: set the H flag
    li t0, S1
    li t1, S1
    li t2, 0xB6
    jal emit_andi
    li t0, T1
    li t1, T0
    li t2, 1
    jal emit_addi
    li t0, T1
    li t1, T7
    li t2, T1
    jal emit_sltu // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t0, T1
    li t1, T0
    li t2, V0
    jal emit_xor
    li t0, T2
    li t1, T0
    li t2, T7
    jal emit_xor
    li t0, T1
    li t1, T1
    li t2, T2
    jal emit_and
    li t0, T1
    li t1, T1
    li t2, 1
    jal emit_srl
    li t0, T1
    li t1, T1
    li t2, 0x40
    jal emit_andi // V
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_sbcm: // SBC op
    // Emit code to subtract a value with carry from another memory value
    jal load_flags
    la t0, apu_read8
    jal emit_jal
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    li t0, A1
    li t1, V0
    li t2, S0
    jal emit_sub
    li t0, A1
    li t1, A1
    li t2, -1
    jal emit_addi
    li t0, T1
    li t1, S1
    li t2, 0x1
    jal emit_andi // C
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, A1
    li t2, T1
    jal emit_add

    // Emit code to set flags for subtraction
    // TODO: set the H flag
    li t0, S1
    li t1, S1
    li t2, 0xB6
    jal emit_andi
    li t0, T1
    li t1, V0
    li t2, 1
    jal emit_addi
    li t0, T1
    li t1, A1
    li t2, T1
    jal emit_sltu // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t0, T1
    li t1, V0
    li t2, S0
    jal emit_xor
    li t0, T2
    li t1, V0
    li t2, A1
    jal emit_xor
    li t0, T1
    li t1, T1
    li t2, T2
    jal emit_and
    li t0, T1
    li t1, T1
    li t2, 1
    jal emit_srl
    li t0, T1
    li t1, T1
    li t2, 0x40
    jal emit_andi // V
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_asla: // ASL A
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to shift the accumulator left and set flags
    jal load_accum
    jal load_flags
    li t0, T7
    li t1, T7
    li t2, 1
    jal emit_sll
    li t0, T0
    li t1, T7
    li t2, 8
    jal emit_srl
    li t0, T0
    li t1, T0
    li t2, 0x1
    jal emit_andi // C
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, S1
    li t1, S1
    li t2, T0
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_aslm: // ASL op
    // Emit code to shift a memory value left and set flags
    jal load_flags
    li t0, A1
    li t1, V0
    li t2, 1
    jal emit_sll
    li t0, T0
    li t1, A1
    li t2, 8
    jal emit_srl
    li t0, T0
    li t1, T0
    li t2, 0x1
    jal emit_andi // C
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    la t0, apu_write8
    jal emit_jal
    li t0, S1
    li t1, S1
    li t2, T0
    jal emit_or
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_lsra: // LSR A
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to shift the accumulator right and set flags
    jal load_accum
    jal load_flags
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, T7
    li t2, 0x1
    jal emit_andi // C
    li t0, T7
    li t1, T7
    li t2, 1
    jal emit_srl
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, S1
    li t1, S1
    li t2, T0
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_lsrm: // LSR op
    // Emit code to shift a memory value right and set flags
    jal load_flags
    li t0, T0
    li t1, V0
    li t2, 0x1
    jal emit_andi // C
    li t0, A1
    li t1, V0
    li t2, 1
    jal emit_srl
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    la t0, apu_write8
    jal emit_jal
    li t0, S1
    li t1, S1
    li t2, T0
    jal emit_or
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_rola: // ROL A
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to rotate the accumulator left and set flags
    jal load_accum
    jal load_flags
    li t0, T7
    li t1, T7
    li t2, 1
    jal emit_sll
    li t0, T1
    li t1, S1
    li t2, 0x1
    jal emit_andi
    li t0, T7
    li t1, T7
    li t2, T1
    jal emit_or
    li t0, T0
    li t1, T7
    li t2, 8
    jal emit_srl
    li t0, T0
    li t1, T0
    li t2, 0x1
    jal emit_andi // C
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, S1
    li t1, S1
    li t2, T0
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_rolm: // ROL op
    // Emit code to rotate a memory value left and set flags
    jal load_flags
    li t0, A1
    li t1, V0
    li t2, 1
    jal emit_sll
    li t0, T1
    li t1, S1
    li t2, 0x1
    jal emit_andi
    li t0, A1
    li t1, A1
    li t2, T1
    jal emit_or
    li t0, T0
    li t1, A1
    li t2, 8
    jal emit_srl
    li t0, T0
    li t1, T0
    li t2, 0x1
    jal emit_andi // C
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    la t0, apu_write8
    jal emit_jal
    li t0, S1
    li t1, S1
    li t2, T0
    jal emit_or
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_rora: // ROR A
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to rotate the accumulator right and set flags
    jal load_accum
    jal load_flags
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, T7
    li t2, 0x1
    jal emit_andi // C
    li t0, T7
    li t1, T7
    li t2, 1
    jal emit_srl
    li t0, T1
    li t1, S1
    li t2, 7
    jal emit_sll
    li t0, T7
    li t1, T7
    li t2, T1
    jal emit_or
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, S1
    li t1, S1
    li t2, T0
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_rorm: // ROR op
    // Emit code to rotate a memory value right and set flags
    jal load_flags
    li t0, T0
    li t1, V0
    li t2, 0x1
    jal emit_andi // C
    li t0, A1
    li t1, V0
    li t2, 1
    jal emit_srl
    li t0, T1
    li t1, S1
    li t2, 7
    jal emit_sll
    li t0, A1
    li t1, A1
    li t2, T1
    jal emit_or
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    la t0, apu_write8
    jal emit_jal
    li t0, S1
    li t1, S1
    li t2, T0
    jal emit_or
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_deca: // DEC A
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to decrement the accumulator and set flags
    jal load_accum
    li t0, T7
    li t1, T7
    li t2, -1
    jal emit_addi
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_decx: // DEC X
    // Update the JIT register state
    ori s1, s1, FLAG_SX

    // Emit code to decrement register X and set flags
    jal load_reg_x
    li t0, T9
    li t1, T9
    li t2, -1
    jal emit_addi
    li t1, T9
    la ra, finish_opcode
    j queue_nz


apu_decy: // DEC Y
    // Update the JIT register state
    ori s1, s1, FLAG_SY

    // Emit code to decrement register Y and set flags
    jal load_reg_y
    li t0, T8
    li t1, T8
    li t2, -1
    jal emit_addi
    li t1, T8
    la ra, finish_opcode
    j queue_nz


apu_decm: // DEC op
    // Emit code to decrement a memory value and set flags
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, V0
    li t2, -1
    jal emit_addi
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_inca: // INC A
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to increment the accumulator and set flags
    jal load_accum
    li t0, T7
    li t1, T7
    li t2, 1
    jal emit_addi
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_incx: // INC X
    // Update the JIT register state
    ori s1, s1, FLAG_SX

    // Emit code to increment register X and set flags
    jal load_reg_x
    li t0, T9
    li t1, T9
    li t2, 1
    jal emit_addi
    li t1, T9
    la ra, finish_opcode
    j queue_nz


apu_incy: // INC Y
    // Update the JIT register state
    ori s1, s1, FLAG_SY

    // Emit code to increment register Y and set flags
    jal load_reg_y
    li t0, T8
    li t1, T8
    li t2, 1
    jal emit_addi
    li t1, T8
    la ra, finish_opcode
    j queue_nz


apu_incm: // INC op
    // Emit code to increment a memory value and set flags
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, V0
    li t2, 1
    jal emit_addi
    li t1, A1
    la ra, finish_opcode
    j queue_nz


apu_addw: // ADDW YA,op
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_SA

    // Emit code to load a 16-bit value from memory
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    li t0, T0
    li t1, V0
    li t2, 8
    jal emit_sll
    li t0, A1
    li t1, S0
    li t2, T0
    jal emit_or

    // Emit code to add the value to register YA
    jal load_reg_y
    jal load_accum
    li t0, T8
    li t1, T8
    li t2, 0xFF
    jal emit_andi
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, T8
    li t2, 8
    jal emit_sll
    li t0, T0
    li t1, T0
    li t2, T7
    jal emit_or
    li t0, T7
    li t1, T0
    li t2, A1
    jal emit_add
    li t0, T8
    li t1, T7
    li t2, 8
    jal emit_srl

    // Emit code to set carry and overflow
    // TODO: set the H flag
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0xB6
    jal emit_andi
    li t0, T1
    li t1, T7
    li t2, 16
    jal emit_srl // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t0, T1
    li t1, T7
    li t2, T0
    jal emit_xor
    li t0, T2
    li t1, T7
    li t2, A1
    jal emit_xor
    li t0, T1
    li t1, T1
    li t2, T2
    jal emit_and
    li t0, T1
    li t1, T1
    li t2, 9
    jal emit_srl
    li t0, T1
    li t1, T1
    li t2, 0x40
    jal emit_andi // V
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or

    // Emit code to set flags for the 16-bit result
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, ZERO
    li t2, T7
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, T8
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_subw: // SUBW YA,op
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_SA

    // Emit code to load a 16-bit value from memory
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    li t0, T0
    li t1, V0
    li t2, 8
    jal emit_sll
    li t0, A1
    li t1, S0
    li t2, T0
    jal emit_or

    // Emit code to subtract the value from register YA
    jal load_reg_y
    jal load_accum
    li t0, T8
    li t1, T8
    li t2, 0xFF
    jal emit_andi
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, T8
    li t2, 8
    jal emit_sll
    li t0, T0
    li t1, T0
    li t2, T7
    jal emit_or
    li t0, T7
    li t1, T0
    li t2, A1
    jal emit_sub
    li t0, T8
    li t1, T7
    li t2, 8
    jal emit_srl

    // Emit code to set carry and overflow
    // TODO: set the H flag
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0xB6
    jal emit_andi
    li t0, T1
    li t1, T0
    li t2, 1
    jal emit_addi
    li t0, T1
    li t1, T7
    li t2, T1
    jal emit_sltu // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or
    li t0, T1
    li t1, T0
    li t2, A1
    jal emit_xor
    li t0, T2
    li t1, T0
    li t2, T7
    jal emit_xor
    li t0, T1
    li t1, T1
    li t2, T2
    jal emit_and
    li t0, T1
    li t1, T1
    li t2, 9
    jal emit_srl
    li t0, T1
    li t1, T1
    li t2, 0x40
    jal emit_andi // V
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or

    // Emit code to set flags for the 16-bit result
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, ZERO
    li t2, T7
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, T8
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_cmpw: // CMPW YA,op
    // Emit code to load a 16-bit value from memory
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    li t0, T0
    li t1, V0
    li t2, 8
    jal emit_sll
    li t0, A1
    li t1, S0
    li t2, T0
    jal emit_or

    // Emit code to compare the value with register YA and set carry
    jal load_reg_y
    jal load_accum
    jal load_flags
    li t0, T8
    li t1, T8
    li t2, 0xFF
    jal emit_andi
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T1
    li t1, T8
    li t2, 8
    jal emit_sll
    li t0, T1
    li t1, T1
    li t2, T7
    jal emit_or
    li t0, T0
    li t1, T1
    li t2, A1
    jal emit_sub
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, T1
    li t1, T1
    li t2, 1
    jal emit_addi
    li t0, T1
    li t1, T0
    li t2, T1
    jal emit_sltu // C
    li t0, S1
    li t1, S1
    li t2, T1
    jal emit_or

    // Emit code to set flags for the 16-bit result
    li t0, T1
    li t1, T0
    li t2, 0xFF
    jal emit_andi
    li t0, T1
    li t1, ZERO
    li t2, T1
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, 8
    jal emit_srl
    li t0, T0
    li t1, T0
    li t2, T1
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_decw: // DECW op
    // Emit code to load a 16-bit value from memory
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    li t0, T0
    li t1, V0
    li t2, 8
    jal emit_sll
    li t0, A1
    li t1, S0
    li t2, T0
    jal emit_or

    // Emit code to decrement the value and store it back in memory
    li t0, A1
    li t1, A1
    li t2, -1
    jal emit_addi
    la t0, apu_write8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, -1
    jal emit_addi
    li t0, S0
    li t1, A1
    li t2, 0xFF
    jal emit_andi
    li t0, A1
    li t1, A1
    li t2, 8
    jal emit_srl
    la t0, apu_write8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi

    // Emit code to set flags for the 16-bit result
    li t0, T0
    li t1, ZERO
    li t2, S0
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, A1
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_incw: // INCW op
    // Emit code to load a 16-bit value from memory
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    li t0, T0
    li t1, V0
    li t2, 8
    jal emit_sll
    li t0, A1
    li t1, S0
    li t2, T0
    jal emit_or

    // Emit code to increment the value and store it back in memory
    li t0, A1
    li t1, A1
    li t2, 1
    jal emit_addi
    la t0, apu_write8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, -1
    jal emit_addi
    li t0, S0
    li t1, A1
    li t2, 0xFF
    jal emit_andi
    li t0, A1
    li t1, A1
    li t2, 8
    jal emit_srl
    la t0, apu_write8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi

    // Emit code to set flags for the 16-bit result
    li t0, T0
    li t1, ZERO
    li t2, S0
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, A1
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_div: // DIV YA,X
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_SA

    // Emit code to divide register YA by register X
    jal load_reg_x
    jal load_reg_y
    jal load_accum
    li t0, T9
    li t1, T9
    li t2, 0xFF
    jal emit_andi
    li t0, T8
    li t1, T8
    li t2, 0xFF
    jal emit_andi
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T0
    li t1, T8
    li t2, 8
    jal emit_sll
    li t0, T0
    li t1, T0
    li t2, T7
    jal emit_or
    li t0, T0
    li t1, T9
    jal emit_div
    jal emit_nop
    jal emit_nop

    // Emit code to move the result to register YA and set flags for Y
    // TODO: set the H flag
    li t0, T7
    jal emit_mflo // Quotient
    li t0, T8
    jal emit_mfhi // Remainder
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0xB7
    jal emit_andi
    li t0, T0
    li t1, T7
    li t2, 8
    jal emit_srl
    li t0, T0
    li t1, ZERO
    li t2, T0
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, 6
    jal emit_sll // V
    li t0, S1
    li t1, S1
    li t2, T0
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_mul: // MUL YA
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_SA

    // Emit code to multiply register Y by the accumulator
    jal load_reg_y
    jal load_accum
    li t0, T8
    li t1, T8
    li t2, 0xFF
    jal emit_andi
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T8
    li t1, T7
    jal emit_mult
    jal emit_nop
    jal emit_nop

    // Emit code to move the result to register YA and set flags for Y
    li t0, T7
    jal emit_mflo
    li t0, T8
    li t1, T7
    li t2, 8
    jal emit_srl
    li t1, T8
    la ra, finish_opcode
    j queue_nz


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
    li t0, A1
    li t1, V0
    la ra, finish_opcode
    j emit_andi


apu_set1: // SET1 op.b
    // Create a mask based on the opcode number
    srl t0, v1, 8
    andi t0, t0, 0x7
    li t1, 1
    sll t2, t1, t0

    // Emit code to set a bit in a memory value
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, V0
    la ra, finish_opcode
    j emit_ori


apu_not1: // NOT1 op
    // Emit code to invert a bit in a memory value
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, A1
    li t2, V0
    la ra, finish_opcode
    jal emit_xor


apu_mov1a: // MOV1 op,C
    // Emit code to set a bit in a memory value to the carry flag
    jal load_flags
    li t0, T0
    li t1, A1
    li t2, 0xFF
    jal emit_xori
    li t0, T0
    li t1, T0
    li t2, V0
    jal emit_and
    li t0, T1
    li t1, S1
    li t2, 0x1
    jal emit_andi
    li t0, T1
    li t1, ZERO
    li t2, T1
    jal emit_sub
    li t0, T1
    li t1, T1
    li t2, A1
    jal emit_and
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, T0
    li t2, T1
    la ra, finish_opcode
    j emit_or


apu_mov1b: // MOV1 C,op
    // Emit code to set the carry flag to a bit from a memory value
    jal load_flags
    li t0, T0
    li t1, V0
    li t2, A1
    jal emit_and
    li t0, T0
    li t1, ZERO
    li t2, T0
    jal emit_slt
    li t0, S1
    li t1, S1
    li t2, 0xFE
    jal emit_andi
    li t0, S1
    li t1, S1
    li t2, T0
    la ra, finish_opcode
    j emit_or


apu_or1a: // OR1 C,op
    // Emit code to bitwise or the carry flag with a bit from a memory value
    jal load_flags
    li t0, T0
    li t1, V0
    li t2, A1
    jal emit_and
    li t0, T0
    li t1, ZERO
    li t2, T0
    jal emit_slt
    li t0, S1
    li t1, S1
    li t2, T0
    la ra, finish_opcode
    j emit_or


apu_or1b: // OR1 C,/op
    // Emit code to bitwise or the carry flag with a negated bit from a memory value
    jal load_flags
    li t0, T0
    li t1, V0
    li t2, A1
    jal emit_and
    li t0, T0
    li t1, ZERO
    li t2, T0
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, 0x1
    jal emit_xori
    li t0, S1
    li t1, S1
    li t2, T0
    la ra, finish_opcode
    j emit_or


apu_and1a: // AND1 C,op
    // Emit code to bitwise and the carry flag with a bit from a memory value
    jal load_flags
    li t0, T0
    li t1, V0
    li t2, A1
    jal emit_and
    li t0, T0
    li t1, ZERO
    li t2, T0
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, 0xFE
    jal emit_ori
    li t0, S1
    li t1, S1
    li t2, T0
    la ra, finish_opcode
    j emit_and


apu_and1b: // AND1 C,/op
    // Emit code to bitwise and the carry flag with a negated bit from a memory value
    jal load_flags
    li t0, T0
    li t1, V0
    li t2, A1
    jal emit_and
    li t0, T0
    li t1, ZERO
    li t2, T0
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, 0x1
    jal emit_xori
    li t0, T0
    li t1, T0
    li t2, 0xFE
    jal emit_ori
    li t0, S1
    li t1, S1
    li t2, T0
    la ra, finish_opcode
    j emit_and


apu_eor1: // EOR1 C,op
    // Emit code to bitwise exclusive or the carry flag with a bit from a memory value
    jal load_flags
    li t0, T0
    li t1, V0
    li t2, A1
    jal emit_and
    li t0, T0
    li t1, ZERO
    li t2, T0
    jal emit_slt
    li t0, S1
    li t1, S1
    li t2, T0
    la ra, finish_opcode
    j emit_xor


apu_clrc: // CLRC
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to clear the C flag
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0xFE
    la ra, finish_opcode
    j emit_andi


apu_setc: // SETC
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to set the C flag
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0x1
    la ra, finish_opcode
    j emit_ori


apu_notc: // NOTC
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to negate the C flag
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0x1
    la ra, finish_opcode
    j emit_xori


apu_clrv: // CLRV
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to clear the V and H flags
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0xB7
    la ra, finish_opcode
    j emit_andi


apu_xcn: // XCN A
    // Update the JIT register state
    ori s1, s1, FLAG_SA

    // Emit code to reverse the accumulator's high and low nibbles
    jal load_accum
    li t0, T0
    li t1, T7
    li t2, 4
    jal emit_srl
    li t0, T1
    li t1, T7
    li t2, 4
    jal emit_sll
    li t0, T7
    li t1, T0
    li t2, T1
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_tclr1: // TCLR1 op
    // Emit code to clear bits in a memory value and set flags
    jal load_accum
    li t0, T0
    li t1, T7
    li t2, 0xFF
    jal emit_xori
    li t0, A1
    li t1, V0
    li t2, T0
    jal emit_and
    la t0, apu_write8
    jal emit_jal
    li t0, T0
    li t1, T7
    li t2, V0
    jal emit_sub // CMP
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_tset1: // TSET1 op
    // Emit code to set bits in a memory value and set flags
    jal load_accum
    li t0, A1
    li t1, V0
    li t2, T7
    jal emit_or
    la t0, apu_write8
    jal emit_jal
    li t0, T0
    li t1, T7
    li t2, V0
    jal emit_sub // CMP
    li t1, T0
    la ra, finish_opcode
    j queue_nz
