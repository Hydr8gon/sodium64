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

.globl cpu_tay8
.globl cpu_tay16
.globl cpu_tax8
.globl cpu_tax16
.globl cpu_tsx8
.globl cpu_tsx16
.globl cpu_tya8
.globl cpu_tya16
.globl cpu_txa8
.globl cpu_txa16
.globl cpu_txse
.globl cpu_txs
.globl cpu_txy8
.globl cpu_txy16
.globl cpu_tyx8
.globl cpu_tyx16
.globl cpu_tdc
.globl cpu_tcd
.globl cpu_tsc
.globl cpu_tcse
.globl cpu_tcs
.globl cpu_lda8
.globl cpu_lda16
.globl cpu_ldx8
.globl cpu_ldx16
.globl cpu_ldy8
.globl cpu_ldy16
.globl cpu_stz8
.globl cpu_stz16
.globl cpu_sta8
.globl cpu_sta16
.globl cpu_stx8
.globl cpu_stx16
.globl cpu_sty8
.globl cpu_sty16
.globl cpu_pha8
.globl cpu_pha16
.globl cpu_phx8
.globl cpu_phx16
.globl cpu_phy8
.globl cpu_phy16
.globl cpu_php
.globl cpu_phb
.globl cpu_phk
.globl cpu_phd
.globl cpu_pei
.globl cpu_pea
.globl cpu_per
.globl cpu_pla8
.globl cpu_pla16
.globl cpu_plx8
.globl cpu_plx16
.globl cpu_ply8
.globl cpu_ply16
.globl cpu_pld
.globl cpu_plb
.globl cpu_plp
.globl cpu_mvp8
.globl cpu_mvp16
.globl cpu_mvn8
.globl cpu_mvn16

.text
.set noreorder

.align 5
cpu_tay8: // TAY (8-bit)
    // Transfer the accumulator to register Y and set flags (8-bit)
    lbu a0, accumulator + 1
    sb a0, register_y + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_tay16: // TAY (16-bit)
    // Transfer the accumulator to register Y and set flags (16-bit)
    lhu a0, accumulator
    sh a0, register_y
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_tax8: // TAX (8-bit)
    // Transfer the accumulator to register X and set flags (8-bit)
    lbu a0, accumulator + 1
    sb a0, register_x + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_tax16: // TAX (16-bit)
    // Transfer the accumulator to register X and set flags (16-bit)
    lhu a0, accumulator
    sh a0, register_x
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_tsx8: // TSX (8-bit)
    // Transfer the stack pointer to register X and set flags (8-bit)
    lbu a0, stack_ptr + 1
    sb a0, register_x + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_tsx16: // TSX (16-bit)
    // Transfer the stack pointer to register X and set flags (16-bit)
    lhu a0, stack_ptr
    sh a0, register_x
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_tya8: // TYA (8-bit)
    // Transfer register Y to the accumulator and set flags (8-bit)
    lbu a0, register_y + 1
    sb a0, accumulator + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_tya16: // TYA (16-bit)
    // Transfer register Y to the accumulator and set flags (16-bit)
    lhu a0, register_y
    sh a0, accumulator
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_txa8: // TXA (8-bit)
    // Transfer register X to the accumulator and set flags (8-bit)
    lbu a0, register_x + 1
    sb a0, accumulator + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_txa16: // TXA (16-bit)
    // Transfer register X to the accumulator and set flags (16-bit)
    lhu a0, register_x
    sh a0, accumulator
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_txse: // TXS (emulation mode)
    // Transfer register X to the stack pointer (emulation mode)
    lbu a0, register_x + 1
    sb a0, stack_ptr + 1
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_txs: // TXS
    // Transfer register X to the stack pointer
    lhu a0, register_x
    sh a0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_txy8: // TXY (8-bit)
    // Transfer register X to register Y and set flags (8-bit)
    lbu a0, register_x + 1
    sb a0, register_y + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_txy16: // TXY (16-bit)
    // Transfer register X to register Y and set flags (16-bit)
    lhu a0, register_x
    sh a0, register_y
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_tyx8: // TYX (8-bit)
    // Transfer register Y to register X and set flags (8-bit)
    lbu a0, register_y + 1
    sb a0, register_x + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_tyx16: // TYX (16-bit)
    // Transfer register Y to register X and set flags (16-bit)
    lhu a0, register_y
    sh a0, register_x
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_tdc: // TDC
    // Transfer the direct offset to the accumulator and set flags
    move a0, s8
    sh a0, accumulator
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_tcd: // TCD
    // Transfer the accumulator to the direct offset and set flags
    lhu a0, accumulator
    move s8, a0
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_tsc: // TSC
    // Transfer the stack pointer to the accumulator and set flags
    lhu a0, stack_ptr
    sh a0, accumulator
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_tcse: // TCS (emulation mode)
    // Transfer the accumulator to the stack pointer (emulation mode)
    lbu a0, accumulator + 1
    sb a0, stack_ptr + 1
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_tcs: // TCS
    // Transfer the accumulator to the stack pointer
    lhu a0, accumulator
    sh a0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_lda8: // LDA op (8-bit)
    // Load a value to the accumulator and set flags (8-bit)
    MEM_READ8
    sb v0, accumulator + 1
    j set_nz8
    move a0, v0

.align 5
cpu_lda16: // LDA op (16-bit)
    // Load a value to the accumulator and set flags (16-bit)
    MEM_READ16
    sh v0, accumulator
    j set_nz16
    move a0, v0

.align 5
cpu_ldx8: // LDX op (8-bit)
    // Load a value to register X and set flags (8-bit)
    MEM_READ8
    sb v0, register_x + 1
    j set_nz8
    move a0, v0

.align 5
cpu_ldx16: // LDX op (16-bit)
    // Load a value to register X and set flags (16-bit)
    MEM_READ16
    sh v0, register_x
    j set_nz16
    move a0, v0

.align 5
cpu_ldy8: // LDY op (8-bit)
    // Load a value to register Y and set flags (8-bit)
    MEM_READ8
    sb v0, register_y + 1
    j set_nz8
    move a0, v0

.align 5
cpu_ldy16: // LDY op (16-bit)
    // Load a value to register Y and set flags (16-bit)
    MEM_READ16
    sh v0, register_y
    j set_nz16
    move a0, v0

.align 5
cpu_stz8: // STZ op (8-bit)
    // Store zero to memory (8-bit)
    li a1, 0
    MEM_WRITE8
    j cpu_execute
    nop

.align 5
cpu_stz16: // STZ op (16-bit)
    // Store zero to memory (16-bit)
    li a1, 0
    MEM_WRITE16
    j cpu_execute
    nop

.align 5
cpu_sta8: // STA op (8-bit)
    // Store the accumulator to memory (8-bit)
    lbu a1, accumulator + 1
    MEM_WRITE8
    j cpu_execute
    nop

.align 5
cpu_sta16: // STA op (16-bit)
    // Store the accumulator to memory (16-bit)
    lhu a1, accumulator
    MEM_WRITE16
    j cpu_execute
    nop

.align 5
cpu_stx8: // STX op (8-bit)
    // Store register X to memory (8-bit)
    lbu a1, register_x + 1
    MEM_WRITE8
    j cpu_execute
    nop

.align 5
cpu_stx16: // STX op (16-bit)
    // Store register X to memory (16-bit)
    lhu a1, register_x
    MEM_WRITE16
    j cpu_execute
    nop

.align 5
cpu_sty8: // STY op (8-bit)
    // Store register Y to memory (8-bit)
    lbu a1, register_y + 1
    MEM_WRITE8
    j cpu_execute
    nop

.align 5
cpu_sty16: // STY op (16-bit)
    // Store register Y to memory (16-bit)
    lhu a1, register_y
    MEM_WRITE16
    j cpu_execute
    nop

.align 5
cpu_pha8: // PHA (8-bit)
    // Push the accumulator to the stack (8-bit)
    lhu s0, stack_ptr
    lbu a1, accumulator + 1
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_pha16: // PHA (16-bit)
    // Push the accumulator to the stack (16-bit)
    lhu s0, stack_ptr
    lhu a1, accumulator
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_phx8: // PHX (8-bit)
    // Push register X to the stack (8-bit)
    lhu s0, stack_ptr
    lbu a1, register_x + 1
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_phx16: // PHX (16-bit)
    // Push register X to the stack (16-bit)
    lhu s0, stack_ptr
    lhu a1, register_x
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_phy8: // PHY (8-bit)
    // Push register Y to the stack (8-bit)
    lhu s0, stack_ptr
    lbu a1, register_y + 1
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_phy16: // PHY (16-bit)
    // Push register Y to the stack (16-bit)
    lhu s0, stack_ptr
    lhu a1, register_y
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_php: // PHP
    // Push the flags to the stack
    lhu s0, stack_ptr
    andi a1, s4, 0xFF
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_phb: // PHB
    // Push the data bank to the stack
    lhu s0, stack_ptr
    lbu a1, data_bank + 1
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_phk: // PHK
    // Push the PC bank to the stack
    lhu s0, stack_ptr
    srl a1, s7, 16
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_phd: // PHD
    // Push the direct offset to the stack
    lhu s0, stack_ptr
    move a1, s8
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 1

.align 5
cpu_pei: // PEI nn
    // Get the 8-bit immediate value added to the direct offset as an address
    MEM_READ8 1(s7)
    add s0, s8, v0

    // Load a 16-bit value from memory and push it to the stack
    MEM_READ16
    lhu s0, stack_ptr
    move a1, v0
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 2

.align 5
cpu_pea: // PEA #nnnn
    // Push a 16-bit immediate value to the stack
    MEM_READ16 1(s7)
    lhu s0, stack_ptr
    move a1, v0
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh s0, stack_ptr
    j cpu_execute
    addi s7, s7, 3

.align 5
cpu_per: // PER disp16
    // Push the PC plus a 16-bit immediate value to the stack
    MEM_READ16 1(s7)
    addi s7, s7, 3
    add a1, s7, v0
    la s1, stack_ptr
    lhu s0, (s1)
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    j cpu_execute
    sh s0, (s1)

.align 5
cpu_pla8: // PLA (8-bit)
    // Pop the accumulator from the stack and set flags (8-bit)
    lhu s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh t0, stack_ptr
    move a0, v0
    sb a0, accumulator + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_pla16: // PLA (16-bit)
    // Pop the accumulator from the stack and set flags (16-bit)
    lhu s0, stack_ptr
    MEM_READ16 1(s0)
    addi t0, s0, 2
    sh t0, stack_ptr
    move a0, v0
    sh a0, accumulator
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_plx8: // PLX (8-bit)
    // Pop register X from the stack and set flags (8-bit)
    lhu s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh t0, stack_ptr
    move a0, v0
    sb a0, register_x + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_plx16: // PLX (16-bit)
    // Pop register X from the stack and set flags (16-bit)
    lhu s0, stack_ptr
    MEM_READ16 1(s0)
    addi t0, s0, 2
    sh t0, stack_ptr
    move a0, v0
    sh a0, register_x
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_ply8: // PLY (8-bit)
    // Pop register Y from the stack and set flags (8-bit)
    lhu s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh t0, stack_ptr
    move a0, v0
    sb a0, register_y + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_ply16: // PLY (16-bit)
    // Pop register Y from the stack and set flags (16-bit)
    lhu s0, stack_ptr
    MEM_READ16 1(s0)
    addi t0, s0, 2
    sh t0, stack_ptr
    move a0, v0
    sh a0, register_y
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_pld: // PLD
    // Pop the direct offset from the stack and set flags
    lhu s0, stack_ptr
    MEM_READ16 1(s0)
    addi t0, s0, 2
    sh t0, stack_ptr
    move a0, v0
    move s8, a0
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_plb: // PLB
    // Pop the data bank from the stack and set flags
    lhu s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh t0, stack_ptr
    move a0, v0
    sb a0, data_bank + 1
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_plp: // PLP
    // Pop the flags from the stack
    lhu s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh t0, stack_ptr
    andi s4, s4, 0xFF00
    or s4, s4, v0
    j update_mode
    addi s7, s7, 1

.align 5
cpu_mvp8: // MVP ss,dd (8-bit)
    // Set the data bank and add register Y to get the destination address (8-bit)
    MEM_READ8 1(s7)
    sb v0, data_bank + 1
    sll s0, v0, 16
    lbu t0, register_y + 1
    add s0, s0, t0

    // Add register Y to the source bank to get the source address (8-bit)
    MEM_READ8 2(s7)
    sll s1, v0, 16
    lbu t0, register_x + 1
    add s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    MEM_READ8 0(s1)
    move a1, v0
    MEM_WRITE8

    // Decrement the registers (8-bit)
    addi t0, s1, -1
    sb t0, register_x + 1
    addi t0, s0, -1
    sb t0, register_y + 1

    // Decrement the accumulator and don't increment the PC until it underflows
    la t2, accumulator
    lhu t0, (t2)
    addi t1, t0, -1
    bnez t0, cpu_execute
    sh t1, (t2)
    j cpu_execute
    addi s7, s7, 3

.align 5
cpu_mvp16: // MVP ss,dd (16-bit)
    // Set the data bank and add register Y to get the destination address (16-bit)
    MEM_READ8 1(s7)
    sb v0, data_bank + 1
    sll s0, v0, 16
    lhu t0, register_y
    add s0, s0, t0

    // Add register Y to the source bank to get the source address (16-bit)
    MEM_READ8 2(s7)
    sll s1, v0, 16
    lhu t0, register_x
    add s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    MEM_READ8 0(s1)
    move a1, v0
    MEM_WRITE8

    // Decrement the registers (16-bit)
    addi t0, s1, -1
    sh t0, register_x
    addi t0, s0, -1
    sh t0, register_y

    // Decrement the accumulator and don't increment the PC until it underflows
    la t2, accumulator
    lhu t0, (t2)
    addi t1, t0, -1
    bnez t0, cpu_execute
    sh t1, (t2)
    j cpu_execute
    addi s7, s7, 3

.align 5
cpu_mvn8: // MVN ss,dd (8-bit)
    // Set the data bank and add register Y to get the destination address (8-bit)
    MEM_READ8 1(s7)
    sb v0, data_bank + 1
    sll s0, v0, 16
    lbu t0, register_y + 1
    add s0, s0, t0

    // Add register Y to the source bank to get the source address (8-bit)
    MEM_READ8 2(s7)
    sll s1, v0, 16
    lbu t0, register_x + 1
    add s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    MEM_READ8 0(s1)
    move a1, v0
    MEM_WRITE8

    // Increment the registers (8-bit)
    addi t0, s1, 1
    sb t0, register_x + 1
    addi t0, s0, 1
    sb t0, register_y + 1

    // Decrement the accumulator and don't increment the PC until it underflows
    la t2, accumulator
    lhu t0, (t2)
    addi t1, t0, -1
    bnez t0, cpu_execute
    sh t1, (t2)
    j cpu_execute
    addi s7, s7, 3

.align 5
cpu_mvn16: // MVN ss,dd (16-bit)
    // Set the data bank and add register Y to get the destination address (16-bit)
    MEM_READ8 1(s7)
    sb v0, data_bank + 1
    sll s0, v0, 16
    lhu t0, register_y
    add s0, s0, t0

    // Add register Y to the source bank to get the source address (16-bit)
    MEM_READ8 2(s7)
    sll s1, v0, 16
    lhu t0, register_x
    add s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    MEM_READ8 0(s1)
    move a1, v0
    MEM_WRITE8

    // Increment the registers (16-bit)
    addi t0, s1, 1
    sh t0, register_x
    addi t0, s0, 1
    sh t0, register_y

    // Decrement the accumulator and don't increment the PC until it underflows
    la t2, accumulator
    lhu t0, (t2)
    addi t1, t0, -1
    bnez t0, cpu_execute
    sh t1, (t2)
    j cpu_execute
    addi s7, s7, 3
