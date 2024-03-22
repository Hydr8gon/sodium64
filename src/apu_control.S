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
    li t0, T0
    li t1, S1
    li t2, 0x80
    jal emit_andi // N
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, v0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, a0
    la ra, finish_block
    j emit_ori


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
    li t0, T0
    li t1, S1
    li t2, 0x80
    jal emit_andi // N
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, a0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, v0
    la ra, finish_block
    j emit_ori


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
    li t0, T0
    li t1, S1
    li t2, 0x40
    jal emit_andi // V
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, v0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, a0
    la ra, finish_block
    j emit_ori


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
    li t0, T0
    li t1, S1
    li t2, 0x40
    jal emit_andi // V
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, a0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, v0
    la ra, finish_block
    j emit_ori


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
    li t0, T0
    li t1, S1
    li t2, 0x1
    jal emit_andi // C
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, v0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, a0
    la ra, finish_block
    j emit_ori


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
    li t0, T0
    li t1, S1
    li t2, 0x1
    jal emit_andi // C
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, a0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, v0
    la ra, finish_block
    j emit_ori


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
    li t0, T0
    li t1, S1
    li t2, 0x2
    jal emit_andi // Z
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, v0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, a0
    la ra, finish_block
    j emit_ori


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
    li t0, T0
    li t1, S1
    li t2, 0x2
    jal emit_andi // Z
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, a0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, v0
    la ra, finish_block
    j emit_ori


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
    li t0, T0
    li t1, V0
    jal emit_andi
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, v0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, a0
    la ra, finish_block
    j emit_ori


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
    li t0, T0
    li t1, V0
    jal emit_andi
    li t0, T0
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, a0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, v0
    la ra, finish_block
    j emit_ori


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
    li t0, T7
    li t1, T7
    li t2, 0xFF
    jal emit_andi
    li t0, T7
    li t1, V0
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, a0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, v0
    la ra, finish_block
    j emit_ori


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
    li t0, T8
    li t1, T8
    li t2, 0xFF
    jal emit_andi
    li t0, T8
    li t1, T8
    li t2, -1
    jal emit_addi
    li t0, T8
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, a0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, v0
    la ra, finish_block
    j emit_ori


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
    li t0, A1
    li t1, V0
    li t2, -1
    jal emit_addi
    li t0, A1
    li t1, ZERO
    li t2, 2
    jal emit_beq
    li t0, S0
    li t1, ZERO
    move t2, a0
    jal emit_ori
    li t0, S0
    li t1, ZERO
    move t2, v0
    la ra, finish_block
    j emit_ori


apu_bra: // BRA dest
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Sign-extend the offset value and add it to the PC
    jal jit_read8
    sll t2, v0, 24
    sra t2, t2, 24
    add t2, t2, a0

    // Emit code to branch unconditionally
    li t0, S0
    li t1, ZERO
    la ra, finish_block
    j emit_ori


apu_jmp: // JMP op
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Emit code to jump to an address
    li t0, S0
    li t1, ZERO
    li t2, A0
    la ra, finish_block
    j emit_or


apu_jmpm: // JMP [op]
    // Update the JIT register state
    ori s1, s1, FLAG_PC

    // Emit code to jump to an address from memory
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
    li t0, S0
    li t1, S0
    li t2, T0
    la ra, finish_block
    j emit_or


apu_call: // CALL op
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_PC

    // Emit code to jump to an address
    li t0, S0
    li t1, ZERO
    li t2, A0
    jal emit_or

    // Emit code to push the old program counter to the stack
    jal load_stack
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    srl t2, a0, 8
    jal emit_ori
    li t0, A0
    li t1, A0
    li t2, -1
    jal emit_addi
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    andi t2, a0, 0xFF
    jal emit_ori
    li t0, S2
    li t1, S2
    li t2, -2
    la ra, finish_block
    j emit_addi


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
    li t0, A0
    li t1, ZERO
    move t2, t7
    jal emit_ori
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
    li t0, S0
    li t1, S0
    li t2, T0
    jal emit_or

    // Emit code to push the old program counter to the stack
    jal load_stack
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    srl t2, a0, 8
    jal emit_ori
    li t0, A0
    li t1, A0
    li t2, -1
    jal emit_addi
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    andi t2, a0, 0xFF
    jal emit_ori
    li t0, S2
    li t1, S2
    li t2, -2
    la ra, finish_block
    j emit_addi


apu_pcall: // PCALL uu
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_PC

    // Create an address based on the parameter
    jal jit_read8
    ori t2, v0, 0xFF00

    // Emit code to jump to an address in the highest page of RAM
    li t0, S0
    li t1, ZERO
    jal emit_ori

    // Emit code to push the old program counter to the stack
    jal load_stack
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    srl t2, a0, 8
    jal emit_ori
    li t0, A0
    li t1, A0
    li t2, -1
    jal emit_addi
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    andi t2, a0, 0xFF
    jal emit_ori
    li t0, S2
    li t1, S2
    li t2, -2
    la ra, finish_block
    j emit_addi


apu_ret: // RET
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_PC

    // Emit code to pop the program counter from the stack
    jal load_stack
    li t0, A0
    li t1, S2
    li t2, 1
    jal emit_addi
    li t0, A0
    li t1, A0
    li t2, 0xFF
    jal emit_andi
    li t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    li t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    li t0, T0
    li t1, V0
    li t2, 8
    jal emit_sll
    li t0, S0
    li t1, S0
    li t2, T0
    jal emit_or
    li t0, S2
    li t1, S2
    li t2, 2
    la ra, finish_block
    j emit_addi


apu_ret1: // RET1
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_SF | FLAG_LF | FLAG_PC
    li t0, ~FLAG_NZ
    and s1, s1, t0

    // Emit code to pop the flags from the stack
    jal load_stack
    li t0, A0
    li t1, S2
    li t2, 1
    jal emit_addi
    li t0, A0
    li t1, A0
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
    jal emit_or

    // Emit code to pop the program counter from the stack
    li t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    li t0, S0
    li t1, ZERO
    li t2, V0
    jal emit_or
    li t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, A0
    li t2, 1
    jal emit_addi
    li t0, T0
    li t1, V0
    li t2, 8
    jal emit_sll
    li t0, S0
    li t1, S0
    li t2, T0
    jal emit_or
    li t0, S2
    li t1, S2
    li t2, 3
    la ra, finish_block
    j emit_addi


apu_brk: // BRK
    // Update the JIT register state
    ori s1, s1, FLAG_SS | FLAG_SF | FLAG_PC

    // Emit code to jump to an address stored at 0xFFDE
    la t0, apu_read8
    jal emit_jal
    li t0, A0
    li t1, ZERO
    li t2, 0xFFDE
    jal emit_ori
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
    li t0, S0
    li t1, S0
    li t2, T0
    jal emit_or

    // Emit code to push the old program counter to the stack
    jal load_stack
    li t0, A0
    li t1, S2
    li t2, 0xFF
    jal emit_andi
    li t0, A0
    li t1, A0
    li t2, 0x100
    jal emit_ori
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    srl t2, a0, 8
    jal emit_ori
    li t0, A0
    li t1, A0
    li t2, -1
    jal emit_addi
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    andi t2, a0, 0xFF
    jal emit_ori

    // Emit code to push the flags to the stack and modify current ones
    jal load_flags
    jal update_nz
    li t0, A0
    li t1, A0
    li t2, -1
    jal emit_addi
    la t0, apu_write8
    jal emit_jal
    li t0, A1
    li t1, ZERO
    li t2, S1
    jal emit_or
    li t0, S1
    li t1, S1
    li t2, 0xFB
    jal emit_andi // Clear I
    li t0, S1
    li t1, S1
    li t2, 0x10
    jal emit_ori // Set B
    li t0, S2
    li t1, S2
    li t2, -3
    la ra, finish_block
    j emit_addi


apu_clrp: // CLRP
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to clear the P flag
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0xDF
    la ra, finish_opcode
    j emit_andi


apu_setp: // SETP
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to set the P flag
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0x20
    la ra, finish_opcode
    j emit_ori


apu_di: // DI
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to clear the I flag
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0xFB
    la ra, finish_opcode
    j emit_andi


apu_ei: // EI
    // Update the JIT register state
    ori s1, s1, FLAG_SF

    // Emit code to set the I flag
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0x4
    la ra, finish_opcode
    j emit_ori
