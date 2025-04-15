/*
    Copyright 2021-2025 Hydr8gon

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
.set noreorder

.align 5
apu_movax: // MOV A,X
    // Update the JIT register state
    jal load_reg_x
    ori s1, s1, FLAG_SA | FLAG_LA

    // Emit code to move a value to the accumulator from register X and set flags
    EMIT_OP OR(T7, ZERO, T9)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_movxa: // MOV X,A
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SX | FLAG_LX

    // Emit code to move a value to register X from the accumulator and set flags
    EMIT_OP OR(T9, ZERO, T7)
    la ra, finish_opcode
    j queue_nz
    li t1, T9

.align 5
apu_movay: // MOV A,Y
    // Update the JIT register state
    jal load_reg_y
    ori s1, s1, FLAG_SA | FLAG_LA

    // Emit code to move a value to the accumulator from register Y and set flags
    EMIT_OP OR(T7, ZERO, T8)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_movya: // MOV Y,A
    // Update the JIT register state
    jal load_accum
    ori s1, s1, FLAG_SY | FLAG_LY

    // Emit code to move a value to register Y from the accumulator and set flags
    EMIT_OP OR(T8, ZERO, T7)
    la ra, finish_opcode
    j queue_nz
    li t1, T8

.align 5
apu_movxs: // MOV X,SP
    // Update the JIT register state
    jal load_stack
    ori s1, s1, FLAG_SX | FLAG_LX

    // Emit code to move a value to register X from the stack pointer and set flags
    EMIT_OP OR(T9, ZERO, S2)
    la ra, finish_opcode
    j queue_nz
    li t1, T9

.align 5
apu_movsx: // MOV SP,X
    // Update the JIT register state
    jal load_reg_x
    ori s1, s1, FLAG_SS | FLAG_LS

    // Emit code to move a value to the stack pointer from register X
    EMIT_OP OR(S2, ZERO, T9)
    j finish_opcode
    nop

.align 5
apu_mova: // MOV A,op
    // Update the JIT register state
    ori s1, s1, FLAG_SA | FLAG_LA

    // Emit code to move a value to the accumulator and set flags
    EMIT_OP OR(T7, ZERO, V0)
    la ra, finish_opcode
    j queue_nz
    li t1, T7

.align 5
apu_movx: // MOV X,op
    // Update the JIT register state
    ori s1, s1, FLAG_SX | FLAG_LX

    // Emit code to move a value to register X and set flags
    EMIT_OP OR(T9, ZERO, V0)
    la ra, finish_opcode
    j queue_nz
    li t1, T9

.align 5
apu_movy: // MOV Y,op
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_LY

    // Emit code to move a value to register Y and set flags
    EMIT_OP OR(T8, ZERO, V0)
    la ra, finish_opcode
    j queue_nz
    li t1, T8

.align 5
apu_movwya: // MOVW YA,op
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_SA | FLAG_LY | FLAG_LA

    // Emit code to move a 16-bit value to register YA
    EMIT_OP OR(T7, ZERO, V0)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)
    EMIT_OP OR(T8, ZERO, V0)

    // Emit code to set flags for the 16-bit value
    EMIT_OP SLT(T0, ZERO, T7)
    EMIT_OP OR(T0, T0, T8)
    la ra, finish_opcode
    j queue_nz
    li t1, T0

.align 5
apu_movm: // MOV op
    // Emit code to move a value to a memory address
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(A1, ZERO, V0)
    j finish_opcode
    nop

.align 5
apu_amov: // MOV op,A
    // Update the JIT register state
    jal load_accum
    nop

    // Emit code to move a value to memory from the accumulator
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(A1, ZERO, T7)
    j finish_opcode
    nop

.align 5
apu_xmov: // MOV op,X
    // Update the JIT register state
    jal load_reg_x
    nop

    // Emit code to move a value to memory from register X
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(A1, ZERO, T9)
    j finish_opcode
    nop

.align 5
apu_ymov: // MOV op,Y
    // Update the JIT register state
    jal load_reg_y
    nop

    // Emit code to move a value to memory from register Y
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(A1, ZERO, T8)
    j finish_opcode
    nop

.align 5
apu_movway: // MOVW op,YA
    // Update the JIT register state
    jal load_reg_y
    nop
    jal load_accum
    nop

    // Emit code to move a 16-bit value to memory from register YA
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(A1, ZERO, T7)
    EMIT_OP ADDI(A0, A0, 1)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP OR(A1, ZERO, T8)
    j finish_opcode
    nop

.align 5
apu_pha: // PUSH A
    // Update the JIT register state
    jal load_stack
    ori s1, s1, FLAG_SS
    jal load_accum
    nop

    // Emit code to push the accumulator to the stack
    EMIT_OP ANDI(A0, S2, 0xFF)
    EMIT_OP ORI(A0, A0, 0x100)
    EMIT_OP OR(A1, ZERO, T7)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(S2, S2, -1)
    j finish_opcode
    nop

.align 5
apu_phx: // PUSH X
    // Update the JIT register state
    jal load_stack
    ori s1, s1, FLAG_SS
    jal load_reg_x
    nop

    // Emit code to push register X to the stack
    EMIT_OP ANDI(A0, S2, 0xFF)
    EMIT_OP ORI(A0, A0, 0x100)
    EMIT_OP OR(A1, ZERO, T9)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(S2, S2, -1)
    j finish_opcode
    nop

.align 5
apu_phy: // PUSH Y
    // Update the JIT register state
    jal load_stack
    ori s1, s1, FLAG_SS
    jal load_reg_y
    nop

    // Emit code to push register Y to the stack
    EMIT_OP ANDI(A0, S2, 0xFF)
    EMIT_OP ORI(A0, A0, 0x100)
    EMIT_OP OR(A1, ZERO, T8)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(S2, S2, -1)
    j finish_opcode
    nop

.align 5
apu_php: // PUSH PSW
    // Update the JIT register state
    jal load_stack
    ori s1, s1, FLAG_SS
    jal load_flags
    nop
    jal update_nz
    nop

    // Emit code to push the flags to the stack
    EMIT_OP ANDI(A0, S2, 0xFF)
    EMIT_OP ORI(A0, A0, 0x100)
    EMIT_OP OR(A1, ZERO, S1)
    la t0, apu_write8
    jal emit_jal
    nop
    EMIT_OP ADDI(S2, S2, -1)
    j finish_opcode
    nop

.align 5
apu_ppa: // POP A
    // Update the JIT register state
    jal load_stack
    ori s1, s1, FLAG_SS | FLAG_SA | FLAG_LA

    // Emit code to pop the accumulator from the stack
    EMIT_OP ADDI(S2, S2, 1)
    EMIT_OP ANDI(A0, S2, 0xFF)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ORI(A0, A0, 0x100)
    EMIT_OP OR(T7, ZERO, V0)
    j finish_opcode
    nop

.align 5
apu_ppx: // POP X
    // Update the JIT register state
    jal load_stack
    ori s1, s1, FLAG_SS | FLAG_SX | FLAG_LX

    // Emit code to pop register X from the stack
    EMIT_OP ADDI(S2, S2, 1)
    EMIT_OP ANDI(A0, S2, 0xFF)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ORI(A0, A0, 0x100)
    EMIT_OP OR(T9, ZERO, V0)
    j finish_opcode
    nop

.align 5
apu_ppy: // POP Y
    // Update the JIT register state
    jal load_stack
    ori s1, s1, FLAG_SS | FLAG_SY | FLAG_LY

    // Emit code to pop the accumulator from the stack
    EMIT_OP ADDI(S2, S2, 1)
    EMIT_OP ANDI(A0, S2, 0xFF)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ORI(A0, A0, 0x100)
    EMIT_OP OR(T8, ZERO, V0)
    j finish_opcode
    nop

.align 5
apu_ppp: // POP PSW
    // Update the JIT register state
    jal load_stack
    ori s1, s1, FLAG_SS | FLAG_SF | FLAG_LF
    li t0, ~FLAG_NZ
    and s1, s1, t0

    // Emit code to pop the flags from the stack
    EMIT_OP ADDI(S2, S2, 1)
    EMIT_OP ANDI(A0, S2, 0xFF)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ORI(A0, A0, 0x100)
    EMIT_OP OR(S1, ZERO, V0)
    j finish_opcode
    nop
