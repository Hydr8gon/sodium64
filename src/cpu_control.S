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

#include "cpu_address.h"

.globl bra
.globl brl
.globl jmp
.globl jml_e
.globl jml
.globl jmpind
.globl jmpidx
.globl jmlind_e
.globl jmlind
.globl jsr
.globl jsl_e
.globl jsl
.globl jsridx
.globl rti_e
.globl rti
.globl rtl_e
.globl rtl
.globl rts
.globl bpl
.globl bmi
.globl bvc
.globl bvs
.globl bcc
.globl bcs
.globl bne
.globl beq
.globl brk_e
.globl brk
.globl cop_e
.globl cop
.globl clc
.globl cli
.globl cld
.globl clv
.globl sec
.globl sei
.globl sed
.globl rep
.globl sep
.globl xce
.globl stp
.globl xba
.globl wai
.globl wdm
.globl nop

.text

bra: // BRA disp8
    // Add the signed 8-bit immediate value to the PC
    MEM_READ8 1(s7), lb
    addi s7, s7, 2
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0
    j    cpu_execute


brl: // BRL disp16
    // Add the signed 16-bit immediate value to the PC
    MEM_READ16 1(s7)
    addi s7, s7, 3
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0
    j    cpu_execute


jmp: // JMP nnnn
    // Set the PC to the 16-bit immediate value
    MEM_READ16 1(s7)
    lui  t0, 0xFFFF
    and  s7, s7, t0
    add  s7, s7, v0
    j    cpu_execute


jml_e: // JML nnnnnn (emulation mode)
    // Set the PC to the 16-bit immediate value
    MEM_READ16 1(s7)
    move s7, v0
    j    cpu_execute


jml: // JML nnnnnn
    // Set the PC and bank to the 24-bit immediate value
    MEM_READ16 1(s7)
    move s0, v0
    MEM_READ8 3(s7)
    sll  t0, v0, 16
    or   s7, s0, t0
    j    cpu_execute


jmpind: // JMP (nnnn)
    // Set the PC to the value at the 16-bit immediate address
    MEM_READ16 1(s7)
    move s0, v0
    MEM_READ16
    lui  t0, 0xFFFF
    and  s7, s7, t0
    add  s7, s7, v0
    j    cpu_execute


jmpidx: // JMP (nnnn,X)
    // Get the 16-bit immediate value plus register X added to the program bank as an address
    MEM_READ16 1(s7)
    lhu  t0, register_x
    add  t0, t0, v0
    lui  s1, 0xFFFF
    and  t1, s7, s1
    add  s0, t0, t1

    // Set the PC to the memory value at the address
    MEM_READ16
    and  s7, s7, s1
    add  s7, s7, v0
    j    cpu_execute


jmlind_e: // JML [nnnn] (emulation mode)
    // Set the PC to the value at the 16-bit immediate address
    MEM_READ16 1(s7)
    move s0, v0
    MEM_READ16
    move s7, v0
    j    cpu_execute


jmlind: // JML [nnnn]
    // Set the PC and bank to the value at the 16-bit immediate address
    MEM_READ16 1(s7)
    move s0, v0
    MEM_READ16
    move s7, v0
    MEM_READ8 2(s0)
    sll  t0, v0, 16
    or   s7, s7, t0
    j    cpu_execute


jsr: // JSR nnnn
    // Update the stack pointer
    lhu  s0, stack_ptr
    addi s0, s0, -2
    sh   s0, stack_ptr

    // Push the PC+2 to the stack
    addi a1, s7, 2
    MEM_WRITE16 1(s0)

    // Set the PC to the 16-bit immediate value
    MEM_READ16 1(s7)
    lui  t0, 0xFFFF
    and  s7, s7, t0
    add  s7, s7, v0
    j    cpu_execute


jsl_e: // JSL nnnnnn (emulation mode)
    // Update the stack pointer
    lhu  s0, stack_ptr
    addi s0, s0, -2
    sh   s0, stack_ptr

    // Push the PC+3 to the stack
    addi a1, s7, 3
    MEM_WRITE16 1(s0)

    // Set the PC to the 16-bit immediate value
    MEM_READ16 1(s7)
    move s7, v0
    j    cpu_execute


jsl: // JSL nnnnnn
    // Update the stack pointer
    lhu  s0, stack_ptr
    addi s0, s0, -3
    sh   s0, stack_ptr

    // Push the PC+3 and bank to the stack
    srl  a1, s7, 16
    MEM_WRITE8 3(s0)
    addi a1, s7, 3
    MEM_WRITE16 1(s0)

    // Set the PC and bank to the 24-bit immediate value
    MEM_READ16 1(s7)
    move s0, v0
    MEM_READ8 3(s7)
    sll  t0, v0, 16
    or   s7, s0, t0
    j    cpu_execute


jsridx: // JSR (nnnn,X)
    // Update the stack pointer
    lhu  s0, stack_ptr
    addi s0, s0, -2
    sh   s0, stack_ptr

    // Push the PC+2 to the stack
    addi a1, s7, 2
    MEM_WRITE16 1(s0)

    // Get the 16-bit immediate value plus register X added to the program bank as an address
    MEM_READ16 1(s7)
    lhu  t0, register_x
    add  t0, t0, v0
    lui  s1, 0xFFFF
    and  t1, s7, s1
    add  s0, t0, t1

    // Set the PC to the memory value at the address
    MEM_READ16
    and  s7, s7, s1
    add  s7, s7, v0
    j    cpu_execute


rti_e: // RTI (emulation mode)
    // Pop the flags from the stack
    lhu  s0, stack_ptr
    MEM_READ8 1(s0)
    andi t0, v0, 0xFFEF // Clear B
    andi s4, s4, 0xFF00
    or   s4, s4, t0

    // Pop the PC from the stack
    MEM_READ16 2(s0)
    move s7, v0

    // Update the stack pointer
    addi t0, s0, 3
    sh   t0, stack_ptr
    j    cpu_execute


rti: // RTI
    // Pop the flags from the stack
    lhu  s0, stack_ptr
    MEM_READ8 1(s0)
    andi s4, s4, 0xFF00
    or   s4, s4, v0

    // Pop the PC and bank from the stack
    MEM_READ16 2(s0)
    move s7, v0
    MEM_READ8 4(s0)
    sll  t0, v0, 16
    add  s7, s7, t0

    // Update the stack pointer
    addi t0, s0, 4
    sh   t0, stack_ptr
    j    update_mode


rtl_e: // RTL (emulation mode)
    // Pop the PC+1 from the stack
    lhu  s0, stack_ptr
    MEM_READ16 1(s0)
    addi s7, v0, 1

    // Update the stack pointer
    addi t0, s0, 2
    sh   t0, stack_ptr
    j    cpu_execute


rtl: // RTL
    // Pop the PC+1 and bank from the stack
    lhu  s0, stack_ptr
    MEM_READ16 1(s0)
    addi s7, v0, 1
    MEM_READ8 3(s0)
    sll  t0, v0, 16
    add  s7, s7, t0

    // Update the stack pointer
    addi t0, s0, 3
    sh   t0, stack_ptr
    j    cpu_execute


rts: // RTS
    // Pop the PC+1 from the stack
    lhu  s0, stack_ptr
    MEM_READ16 1(s0)
    addi t0, v0, 1
    lui  t1, 0xFFFF
    and  s7, s7, t1
    add  s7, s7, t0

    // Update the stack pointer
    addi t0, s0, 2
    sh   t0, stack_ptr
    j    cpu_execute


bpl: // BPL disp8
    // Check the condition
    andi t0, s4, 0x80 // N
    MEM_READ8 1(s7), lb
    addi s7, s7, 2
    bnez t0, cpu_execute

    // Add the signed 8-bit immediate value to the PC
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0
    j    cpu_execute


bmi: // BMI disp8
    // Check the condition
    andi t0, s4, 0x80 // N
    MEM_READ8 1(s7), lb
    addi s7, s7, 2
    beqz t0, cpu_execute

    // Add the signed 8-bit immediate value to the PC
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0
    j    cpu_execute


bvc: // BVC disp8
    // Check the condition
    andi t0, s4, 0x40 // V
    MEM_READ8 1(s7), lb
    addi s7, s7, 2
    bnez t0, cpu_execute

    // Add the signed 8-bit immediate value to the PC
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0
    j    cpu_execute


bvs: // BVS disp8
    // Check the condition
    andi t0, s4, 0x40 // V
    MEM_READ8 1(s7), lb
    addi s7, s7, 2
    beqz t0, cpu_execute

    // Add the signed 8-bit immediate value to the PC
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0
    j    cpu_execute


bcc: // BCC disp8
    // Check the condition
    andi t0, s4, 0x1 // C
    MEM_READ8 1(s7), lb
    addi s7, s7, 2
    bnez t0, cpu_execute

    // Add the signed 8-bit immediate value to the PC
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0
    j    cpu_execute


bcs: // BCS disp8
    // Check the condition
    andi t0, s4, 0x1 // C
    MEM_READ8 1(s7), lb
    addi s7, s7, 2
    beqz t0, cpu_execute

    // Add the signed 8-bit immediate value to the PC
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0
    j    cpu_execute


bne: // BNE disp8
    // Check the condition
    andi t0, s4, 0x2 // Z
    MEM_READ8 1(s7), lb
    addi s7, s7, 2
    bnez t0, cpu_execute

    // Add the signed 8-bit immediate value to the PC
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0
    j    cpu_execute


beq: // BEQ disp8
    // Check the condition
    andi t0, s4, 0x2 // Z
    MEM_READ8 1(s7), lb
    addi s7, s7, 2
    beqz t0, cpu_execute

    // Add the signed 8-bit immediate value to the PC
    add  t0, s7, v0
    andi t0, t0, 0xFFFF
    andi t1, s7, 0xFFFF
    sub  s7, s7, t1
    add  s7, s7, t0

    // Check for a basic type of idle loop
    addi t0, v0, 4 // Offset
    bnez t0, cpu_execute
    MEM_READ8 4(s7)
    bne  v0, 0x58, cpu_execute // CLI
    MEM_READ8 0(s7)
    bne  v0, 0xA5, cpu_execute // LDA

    // Halt the CPU until the next interrupt
    ori  s4, s4, 0x200 // Halted
    li   s5, 0
    j    cpu_execute


brk_e: // BRK (emulation mode)
    // Update the stack pointer
    lhu  s0, stack_ptr
    addi s0, s0, -3
    sh   s0, stack_ptr

    // Push the PC+2 to the stack
    addi a1, s7, 2
    MEM_WRITE16 2(s0)

    // Push the flags to the stack and modify them
    ori  a1, s4, 0x10 // Set B
    MEM_WRITE8 1(s0)
    ori  s4, s4, 0x4 // Set I
    andi s4, s4, 0xFFF7 // Clear D

    // Jump to the BRK vector (emulation mode)
    li   s0, 0xFFFE
    MEM_READ16
    move s7, v0
    j    cpu_execute


brk: // BRK
    // Update the stack pointer
    lhu  s0, stack_ptr
    addi s0, s0, -4
    sh   s0, stack_ptr

    // Push the PC+2 and bank to the stack
    srl  a1, s7, 16
    MEM_WRITE8 4(s0)
    addi a1, s7, 2
    MEM_WRITE16 2(s0)

    // Push the flags to the stack and modify them
    move a1, s4
    MEM_WRITE8 1(s0)
    ori  s4, s4, 0x4 // Set I
    andi s4, s4, 0xFFF7 // Clear D

    // Jump to the BRK vector
    li   s0, 0xFFE6
    MEM_READ16
    move s7, v0
    j    cpu_execute


cop_e: // COP (emulation mode)
    // Update the stack pointer
    lhu  s0, stack_ptr
    addi s0, s0, -3
    sh   s0, stack_ptr

    // Push the PC+2 to the stack
    addi a1, s7, 2
    MEM_WRITE16 2(s0)

    // Push the flags to the stack and modify them
    ori  a1, s4, 0x10 // Set B
    MEM_WRITE8 1(s0)
    ori  s4, s4, 0x4 // Set I
    andi s4, s4, 0xFFF7 // Clear D

    // Jump to the COP vector (emulation mode)
    li   s0, 0xFFF4
    MEM_READ16
    move s7, v0
    j    cpu_execute


cop: // COP
    // Update the stack pointer
    lhu  s0, stack_ptr
    addi s0, s0, -4
    sh   s0, stack_ptr

    // Push the PC+2 and bank to the stack
    srl  a1, s7, 16
    MEM_WRITE8 4(s0)
    addi a1, s7, 2
    MEM_WRITE16 2(s0)

    // Push the flags to the stack and modify them
    move a1, s4
    MEM_WRITE8 1(s0)
    ori  s4, s4, 0x4 // Set I
    andi s4, s4, 0xFFF7 // Clear D

    // Jump to the COP vector
    li   s0, 0xFFE4
    MEM_READ16
    move s7, v0
    j    cpu_execute


clc: // CLC
    // Clear the carry flag
    andi s4, s4, 0xFFFE
    addi s7, s7, 1
    j    cpu_execute


cli: // CLI
    // Clear the interrupt flag
    andi s4, s4, 0xFFFB
    addi s7, s7, 1
    j    cpu_execute


cld: // CLD
    // Clear the decimal flag
    andi s4, s4, 0xFFF7
    addi s7, s7, 1
    j    update_mode


clv: // CLV
    // Clear the overflow flag
    andi s4, s4, 0xFFBF
    addi s7, s7, 1
    j    cpu_execute


sec: // SEC
    // Set the carry flag
    ori  s4, s4, 0x1
    addi s7, s7, 1
    j    cpu_execute


sei: // SEI
    // Set the interrupt flag
    ori  s4, s4, 0x4
    addi s7, s7, 1
    j    cpu_execute


sed: // SED
    // Set the decimal flag
    ori  s4, s4, 0x8
    addi s7, s7, 1
    j    update_mode


rep: // REP #nn
    // Clear flags from the 8-bit immediate value
    MEM_READ8 1(s7)
    not  v0, v0
    and  s4, s4, v0
    addi s7, s7, 2
    j    update_mode


sep: // SEP #nn
    // Set flags from the 8-bit immediate value
    MEM_READ8 1(s7)
    or   s4, s4, v0
    addi s7, s7, 2
    j    update_mode


xce: // XCE
    // Swap the carry and emulation flags
    sll  t0, s4, 8
    srl  t1, s4, 8
    or   t0, t0, t1
    andi t0, t0, 0x101
    andi s4, s4, 0xFEFE
    or   s4, s4, t0
    addi s7, s7, 1
    j    update_mode


stp: // STP
    // Stop execution
    j    stp


xba: // XBA
    // Swap the accumulator bytes and set flags for the low byte
    lhu  t0, accumulator
    sll  t1, t0, 8
    srl  t0, t0, 8
    or   t0, t0, t1
    sh   t0, accumulator
    andi a0, t0, 0xFF
    addi s7, s7, 1
    j    set_nz8


wai: // WAI
    // Halt the CPU until the next interrupt
    ori  s4, s4, 0x200 // Halted
    li   s5, 0
    addi s7, s7, 1
    j    cpu_execute


wdm: // WDM #nn
    // Do nothing
    addi s7, s7, 2
    j    cpu_execute


nop: // NOP
    // Do nothing
    addi s7, s7, 1
    j    cpu_execute
