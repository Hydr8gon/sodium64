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
.globl apu_mova
.globl apu_movx
.globl apu_movy
.globl apu_movwya
.globl apu_movm
.globl apu_amov
.globl apu_xmov
.globl apu_ymov
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
    // Update the JIT register state
    ori s1, s1, FLAG_SA | FLAG_LA

    // Emit code to move a value to the accumulator from register X and set flags
    jal load_reg_x
    li t0, T7
    li t1, ZERO
    li t2, T9
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_movxa: // MOV X,A
    // Update the JIT register state
    ori s1, s1, FLAG_SX | FLAG_LX

    // Emit code to move a value to register X from the accumulator and set flags
    jal load_accum
    li t0, T9
    li t1, ZERO
    li t2, T7
    jal emit_or
    li t1, T9
    la ra, finish_opcode
    j queue_nz


apu_movay: // MOV A,Y
    // Update the JIT register state
    ori s1, s1, FLAG_SA | FLAG_LA

    // Emit code to move a value to the accumulator from register Y and set flags
    jal load_reg_y
    li t0, T7
    li t1, ZERO
    li t2, T8
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_movya: // MOV Y,A
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_LY

    // Emit code to move a value to register Y from the accumulator and set flags
    jal load_accum
    li t0, T8
    li t1, ZERO
    li t2, T7
    jal emit_or
    li t1, T8
    la ra, finish_opcode
    j queue_nz


apu_movxs: // MOV X,SP
    // Update the JIT register state
    ori s1, s1, FLAG_SX | FLAG_LX

    // Emit code to move a value to register X from the stack pointer and set flags
    jal load_stack
    li t0, T9
    li t1, ZERO
    li t2, S2
    jal emit_or
    li t1, T9
    la ra, finish_opcode
    j queue_nz


apu_movsx: // MOV SP,X
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_LS

    // Emit code to move a value to the stack pointer from register X
    jal load_reg_x
    li t0, S2
    li t1, ZERO
    li t2, T9
    la ra, finish_opcode
    j emit_or


apu_mova: // MOV A,op
    // Update the JIT register state
    ori s1, s1, FLAG_SA | FLAG_LA

    // Emit code to move a value to the accumulator and set flags
    li t0, T7
    li t1, ZERO
    li t2, V0
    jal emit_or
    li t1, T7
    la ra, finish_opcode
    j queue_nz


apu_movx: // MOV X,op
    // Update the JIT register state
    ori s1, s1, FLAG_SX | FLAG_LX

    // Emit code to move a value to register X and set flags
    li t0, T9
    li t1, ZERO
    li t2, V0
    jal emit_or
    li t1, T9
    la ra, finish_opcode
    j queue_nz


apu_movy: // MOV Y,op
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_LY

    // Emit code to move a value to register Y and set flags
    li t0, T8
    li t1, ZERO
    li t2, V0
    jal emit_or
    li t1, T8
    la ra, finish_opcode
    j queue_nz


apu_movwya: // MOVW YA,op
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_SA | FLAG_LY | FLAG_LA

    // Emit code to move a 16-bit value to register YA
    li t0, T7
    li t1, ZERO
    li t2, V0
    jal emit_or
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    li t0, T8
    li t1, ZERO
    li t2, V0
    jal emit_or

    // Emit code to set flags for the 16-bit value
    li t0, T0
    li t1, ZERO
    li t2, T8
    jal emit_slt
    li t0, T0
    li t1, T0
    li t2, T7
    jal emit_or
    li t1, T0
    la ra, finish_opcode
    j queue_nz


apu_movm: // MOV op
    // Emit code to move a value to a memory address
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    li t2, V0
    la ra, finish_opcode
    j emit_or


apu_amov: // MOV op,A
    // Emit code to move a value to memory from the accumulator
    jal load_accum
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    li t2, T7
    la ra, finish_opcode
    j emit_or


apu_xmov: // MOV op,X
    // Emit code to move a value to memory from register X
    jal load_reg_x
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    li t2, T9
    la ra, finish_opcode
    j emit_or


apu_ymov: // MOV op,Y
    // Emit code to move a value to memory from register Y
    jal load_reg_y
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    li t2, T8
    la ra, finish_opcode
    j emit_or


apu_movway: // MOVW op,YA
    // Emit code to move a 16-bit value to memory from register YA
    jal load_reg_y
    jal load_accum
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    li t2, T7
    jal emit_or
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    li t2, T8
    la ra, finish_opcode
    j emit_or


apu_pha: // PUSH A
    // Update the JIT register state
    ori s1, s1, FLAG_SS

    // Emit code to push the accumulator to the stack
    jal load_stack
    jal load_accum
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    li t0, A1
    li t1, ZERO
    li t2, T7
    jal emit_or
    la t0, apu_write8
    jal emit_jal
    li t0, S2
    li t1, S2
    li t2, -1
    la ra, finish_opcode
    j emit_addi


apu_phx: // PUSH X
    // Update the JIT register state
    ori s1, s1, FLAG_SS

    // Emit code to push register X to the stack
    jal load_stack
    jal load_reg_x
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    li t0, A1
    li t1, ZERO
    li t2, T9
    jal emit_or
    la t0, apu_write8
    jal emit_jal
    li t0, S2
    li t1, S2
    li t2, -1
    la ra, finish_opcode
    j emit_addi


apu_phy: // PUSH Y
    // Update the JIT register state
    ori s1, s1, FLAG_SS

    // Emit code to push register Y to the stack
    jal load_stack
    jal load_reg_y
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    li t0, A1
    li t1, ZERO
    li t2, T8
    jal emit_or
    la t0, apu_write8
    jal emit_jal
    li t0, S2
    li t1, S2
    li t2, -1
    la ra, finish_opcode
    j emit_addi


apu_php: // PUSH PSW
    // Update the JIT register state
    ori s1, s1, FLAG_SS

    // Emit code to push the flags to the stack
    jal load_stack
    jal load_flags
    jal update_nz
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    li t0, A1
    li t1, ZERO
    li t2, S1
    jal emit_or
    la t0, apu_write8
    jal emit_jal
    li t0, S2
    li t1, S2
    li t2, -1
    la ra, finish_opcode
    j emit_addi


apu_ppa: // POP A
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_SA | FLAG_LA

    // Emit code to pop the accumulator from the stack
    jal load_stack
    li t0, S2
    li t1, S2
    li t2, 1
    jal emit_addi
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    li t0, T7
    li t1, ZERO
    li t2, V0
    la ra, finish_opcode
    j emit_or


apu_ppx: // POP X
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_SX | FLAG_LX

    // Emit code to pop register X from the stack
    jal load_stack
    li t0, S2
    li t1, S2
    li t2, 1
    jal emit_addi
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    li t0, T9
    li t1, ZERO
    li t2, V0
    la ra, finish_opcode
    j emit_or


apu_ppy: // POP Y
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_SY | FLAG_LY

    // Emit code to pop the accumulator from the stack
    jal load_stack
    li t0, S2
    li t1, S2
    li t2, 1
    jal emit_addi
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    li t0, T8
    li t1, ZERO
    li t2, V0
    la ra, finish_opcode
    j emit_or


apu_ppp: // POP PSW
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_SF | FLAG_LF
    li t0, ~FLAG_NZ
    and s1, s1, t0

    // Emit code to pop the flags from the stack
    jal load_stack
    li t0, S2
    li t1, S2
    li t2, 1
    jal emit_addi
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    li t0, S1
    li t1, ZERO
    li t2, V0
    la ra, finish_opcode
    j emit_or
