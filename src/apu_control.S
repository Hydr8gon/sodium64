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

#include "defines.h"

.globl apu_bpl
.globl apu_bmi
.globl apu_bvc
.globl apu_bvs
.globl apu_bcc
.globl apu_bcs
.globl apu_bne
.globl apu_beq
.globl apu_bbc1
.globl apu_bbs1
.globl apu_cbne
.globl apu_dbnzy
.globl apu_dbnzm
.globl apu_bra
.globl apu_jmp
.globl apu_jmpm
.globl apu_call
.globl apu_tcall1
.globl apu_pcall
.globl apu_ret
.globl apu_ret1
.globl apu_brk
.globl apu_clrp
.globl apu_setp
.globl apu_ei
.globl apu_di

.text

.align 5
apu_bpl: // BPL dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if the N flag is clear
    jal load_flags
    jal update_nz
    li t0, ANDI(T0, S1, 0x80) // N
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    la ra, finish_block
    j emit_op

.align 5
apu_bmi: // BMI dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if the N flag is set
    jal load_flags
    jal update_nz
    li t0, ANDI(T0, S1, 0x80) // N
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    la ra, finish_block
    j emit_op

.align 5
apu_bvc: // BVC dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if the V flag is clear
    jal load_flags
    li t0, ANDI(T0, S1, 0x40) // V
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    la ra, finish_block
    j emit_op

.align 5
apu_bvs: // BVS dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if the V flag is set
    jal load_flags
    li t0, ANDI(T0, S1, 0x40) // V
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    la ra, finish_block
    j emit_op

.align 5
apu_bcc: // BCC dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if the C flag is clear
    jal load_flags
    li t0, ANDI(T0, S1, 0x1) // C
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    la ra, finish_block
    j emit_op

.align 5
apu_bcs: // BCS dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if the C flag is set
    jal load_flags
    li t0, ANDI(T0, S1, 0x1) // C
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    la ra, finish_block
    j emit_op

.align 5
apu_bne: // BNE dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if the Z flag is clear
    jal load_flags
    jal update_nz
    li t0, ANDI(T0, S1, 0x2) // Z
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    la ra, finish_block
    j emit_op

.align 5
apu_beq: // BEQ dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if the Z flag is set
    jal load_flags
    jal update_nz
    li t0, ANDI(T0, S1, 0x2) // Z
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    la ra, finish_block
    j emit_op

.align 5
apu_bbc1: // BBC op.b,dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Create a mask based on the opcode number
    srl t0, v1, 8
    li t1, 1
    sll t2, t1, t0

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if a bit in a memory value is clear
    li t0, ANDI(T0, V0, 0)
    or t0, t0, t2
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    la ra, finish_block
    j emit_op

.align 5
apu_bbs1: // BBS op.b,dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Create a mask based on the opcode number
    srl t0, v1, 8
    li t1, 1
    sll t2, t1, t0

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if a bit in a memory value is set
    li t0, ANDI(T0, V0, 0)
    or t0, t0, t2
    jal emit_op
    li t0, BEQ(T0, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    la ra, finish_block
    j emit_op

.align 5
apu_cbne: // CBNE op,dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to branch if the accumulator doesn't equal a memory value
    jal load_accum
    li t0, ANDI(T7, T7, 0xFF)
    jal emit_op
    li t0, BEQ(T7, V0, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    la ra, finish_block
    j emit_op

.align 5
apu_dbnzy: // DBNZ Y,dest
    // Update the JIT register state
    ori s1, s1, FLAG_SY | FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to decrement register Y and branch if it's not zero
    jal load_reg_y
    li t0, ANDI(T8, T8, 0xFF)
    jal emit_op
    li t0, ADDI(T8, T8, -1)
    jal emit_op
    li t0, BEQ(T8, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    la ra, finish_block
    j emit_op

.align 5
apu_dbnzm: // DBNZ op,dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll v0, v0, 24
    sra v0, v0, 24
    add v0, v0, a0

    // Emit code to decrement a memory value and branch if it's not zero
    la t0, apu_write8
    jal emit_jal
    li t0, ADDI(A1, V0, -1)
    jal emit_op
    li t0, BEQ(A1, ZERO, 2)
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, a0
    jal emit_op
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, v0
    la ra, finish_block
    j emit_op

.align 5
apu_bra: // BRA dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll t2, v0, 24
    sra t2, t2, 24
    add t2, t2, a0

    // Emit code to branch unconditionally
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, t2
    la ra, finish_block
    j emit_op

.align 5
apu_jmp: // JMP op
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Emit code to jump to an address
    li t0, OR(S0, ZERO, A0)
    la ra, finish_block
    j emit_op

.align 5
apu_jmpm: // JMP [op]
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Emit code to jump to an address from memory
    li t0, OR(S0, ZERO, V0)
    jal emit_op
    la t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, 1)
    jal emit_op
    li t0, SLL(T0, V0, 8)
    jal emit_op
    li t0, OR(S0, S0, T0)
    la ra, finish_block
    j emit_op

.align 5
apu_call: // CALL op
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_PC

    // Emit code to jump to an address
    li t0, OR(S0, ZERO, A0)
    jal emit_op

    // Emit code to push the old program counter to the stack
    jal load_stack
    li t0, ANDI(A0, S2, 0xFF)
    jal emit_op
    li t0, ORI(A0, A0, 0x100)
    jal emit_op
    la t0, apu_write8
    jal emit_jal
    li t0, ORI(A1, ZERO, 0)
    srl t2, a0, 8
    or t0, t0, t2
    jal emit_op
    li t0, ADDI(A0, A0, -1)
    jal emit_op
    la t0, apu_write8
    jal emit_jal
    li t0, ORI(A1, ZERO, 0)
    andi t2, a0, 0xFF
    or t0, t0, t2
    jal emit_op
    li t0, ADDI(S2, S2, -2)
    la ra, finish_block
    j emit_op

.align 5
apu_tcall1: // TCALL n
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_PC

    // Create an address based on the opcode number
    srl t0, v1, 7
    sll t0, t0, 1
    li t1, 0xFFDE
    sub t7, t1, t0

    // Emit code to jump to an address from memory
    la t0, apu_read8
    jal emit_jal
    li t0, ORI(A0, ZERO, 0)
    or t0, t0, t7
    jal emit_op
    li t0, OR(S0, ZERO, V0)
    jal emit_op
    la t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, 1)
    jal emit_op
    li t0, SLL(T0, V0, 8)
    jal emit_op
    li t0, OR(S0, S0, T0)
    jal emit_op

    // Emit code to push the old program counter to the stack
    jal load_stack
    li t0, ANDI(A0, S2, 0xFF)
    jal emit_op
    li t0, ORI(A0, A0, 0x100)
    jal emit_op
    la t0, apu_write8
    jal emit_jal
    li t0, ORI(A1, ZERO, 0)
    srl t2, a0, 8
    or t0, t0, t2
    jal emit_op
    li t0, ADDI(A0, A0, -1)
    jal emit_op
    la t0, apu_write8
    jal emit_jal
    li t0, ORI(A1, ZERO, 0)
    andi t2, a0, 0xFF
    or t0, t0, t2
    jal emit_op
    li t0, ADDI(S2, S2, -2)
    la ra, finish_block
    j emit_op

.align 5
apu_pcall: // PCALL uu
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_PC

    // Create an address based on the parameter
    jal jit_read8
    ori t2, v0, 0xFF00

    // Emit code to jump to an address in the highest page of RAM
    li t0, ORI(S0, ZERO, 0)
    or t0, t0, t2
    jal emit_op

    // Emit code to push the old program counter to the stack
    jal load_stack
    li t0, ANDI(A0, S2, 0xFF)
    jal emit_op
    li t0, ORI(A0, A0, 0x100)
    jal emit_op
    la t0, apu_write8
    jal emit_jal
    li t0, ORI(A1, ZERO, 0)
    srl t2, a0, 8
    or t0, t0, t2
    jal emit_op
    li t0, ADDI(A0, A0, -1)
    jal emit_op
    la t0, apu_write8
    jal emit_jal
    li t0, ORI(A1, ZERO, 0)
    andi t2, a0, 0xFF
    or t0, t0, t2
    jal emit_op
    li t0, ADDI(S2, S2, -2)
    la ra, finish_block
    j emit_op

.align 5
apu_ret: // RET
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_PC

    // Emit code to pop the program counter from the stack
    jal load_stack
    li t0, ADDI(A0, S2, 1)
    jal emit_op
    li t0, ANDI(A0, A0, 0xFF)
    jal emit_op
    li t0, apu_read8
    jal emit_jal
    li t0, ORI(A0, A0, 0x100)
    jal emit_op
    li t0, OR(S0, ZERO, V0)
    jal emit_op
    li t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, 1)
    jal emit_op
    li t0, SLL(T0, V0, 8)
    jal emit_op
    li t0, OR(S0, S0, T0)
    jal emit_op
    li t0, ADDI(S2, S2, 2)
    la ra, finish_block
    j emit_op

.align 5
apu_ret1: // RET1
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_SF | FLAG_LF | FLAG_PC
    li t0, ~FLAG_NZ
    and s1, s1, t0

    // Emit code to pop the flags from the stack
    jal load_stack
    li t0, ADDI(A0, S2, 1)
    jal emit_op
    li t0, ANDI(A0, A0, 0xFF)
    jal emit_op
    la t0, apu_read8
    jal emit_jal
    li t0, ORI(A0, A0, 0x100)
    jal emit_op
    li t0, OR(S1, ZERO, V0)
    jal emit_op

    // Emit code to pop the program counter from the stack
    li t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, 1)
    jal emit_op
    li t0, OR(S0, ZERO, V0)
    jal emit_op
    li t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, 1)
    jal emit_op
    li t0, SLL(T0, V0, 8)
    jal emit_op
    li t0, OR(S0, S0, T0)
    jal emit_op
    li t0, ADDI(S2, S2, 3)
    la ra, finish_block
    j emit_op

.align 5
apu_brk: // BRK
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_SF | FLAG_PC

    // Emit code to jump to an address stored at 0xFFDE
    la t0, apu_read8
    jal emit_jal
    li t0, ORI(A0, ZERO, 0xFFDE)
    jal emit_op
    li t0, OR(S0, ZERO, V0)
    jal emit_op
    la t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, 1)
    jal emit_op
    li t0, SLL(T0, V0, 8)
    jal emit_op
    li t0, OR(S0, S0, T0)
    jal emit_op

    // Emit code to push the old program counter to the stack
    jal load_stack
    li t0, ANDI(A0, S2, 0xFF)
    jal emit_op
    li t0, ORI(A0, A0, 0x100)
    jal emit_op
    la t0, apu_write8
    jal emit_jal
    li t0, ORI(A1, ZERO, 0)
    srl t2, a0, 8
    or t0, t0, t2
    jal emit_op
    li t0, ADDI(A0, A0, -1)
    jal emit_op
    la t0, apu_write8
    jal emit_jal
    li t0, ORI(A1, ZERO, 0)
    andi t2, a0, 0xFF
    or t0, t0, t2
    jal emit_op

    // Emit code to push the flags to the stack and modify current ones
    jal load_flags
    jal update_nz
    li t0, ADDI(A0, A0, -1)
    jal emit_op
    la t0, apu_write8
    jal emit_jal
    li t0, OR(A1, ZERO, S1)
    jal emit_op
    li t0, ANDI(S1, S1, 0xFB) // Clear I
    jal emit_op
    li t0, ORI(S1, S1, 0x10) // Set B
    jal emit_op
    li t0, ADDI(S2, S2, -3)
    la ra, finish_block
    j emit_op

.align 5
apu_clrp: // CLRP
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to clear the P flag
    jal load_flags
    li t0, ANDI(S1, S1, 0xDF)
    la ra, finish_opcode
    j emit_op

.align 5
apu_setp: // SETP
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to set the P flag
    jal load_flags
    li t0, ORI(S1, S1, 0x20)
    la ra, finish_opcode
    j emit_op

.align 5
apu_di: // DI
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to clear the I flag
    jal load_flags
    li t0, ANDI(S1, S1, 0xFB)
    la ra, finish_opcode
    j emit_op

.align 5
apu_ei: // EI
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to set the I flag
    jal load_flags
    li t0, ORI(S1, S1, 0x4)
    la ra, finish_opcode
    j emit_op
