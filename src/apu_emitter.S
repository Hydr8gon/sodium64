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

.globl jit_tags
.globl jit_lookup

.globl jit_read8
.globl compile_block
.globl finish_opcode
.globl finish_block
.globl load_reg_x
.globl load_reg_y
.globl load_accum
.globl load_stack
.globl load_flags
.globl queue_nz
.globl update_nz
.globl emit_add
.globl emit_addi
.globl emit_andi
.globl emit_j
.globl emit_jal
.globl emit_lbu
.globl emit_lhu
.globl emit_lui
.globl emit_nop
.globl emit_or
.globl emit_ori
.globl emit_sb
.globl emit_sh
.globl emit_sll
.globl emit_slt
.globl emit_xori

.data

jit_tags: .word 0:0x400
jit_lookup: .word 0:0x10000
jit_pointer: .word JIT_BUFFER

jit_opcodes: // Lookup table for addressing and operation functions
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x00-0x03
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x04-0x07
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x08-0x0B
    .word apu_fallback, 0,  apu_php, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x0C-0x0F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x10-0x13
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x14-0x17
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x18-0x1B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x1C-0x1F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x20-0x23
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x24-0x27
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x28-0x2B
    .word apu_fallback, 0,  apu_pha, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x2C-0x2F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x30-0x33
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x34-0x37
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x38-0x3B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x3C-0x3F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x40-0x43
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x44-0x47
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x48-0x4B
    .word apu_fallback, 0,  apu_phx, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x4C-0x4F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x50-0x53
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x54-0x57
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x58-0x5B
    .word apu_fallback, 0,  apu_movxa, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x5C-0x5F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x60-0x63
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x64-0x67
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x68-0x6B
    .word apu_fallback, 0,  apu_phy, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x6C-0x6F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x70-0x73
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x74-0x77
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x78-0x7B
    .word apu_fallback, 0,  apu_movax, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x7C-0x7F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x80-0x83
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x84-0x87
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x88-0x8B
    .word apu_fallback, 0,  apu_imm, apu_movy,  apu_ppp, 0,  apu_dri, apu_movm // 0x8C-0x8F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x90-0x93
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x94-0x97
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x98-0x9B
    .word apu_fallback, 0,  apu_movxs, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x9C-0x9F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xA0-0xA3
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xA4-0xA7
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xA8-0xAB
    .word apu_fallback, 0,  apu_fallback, 0,  apu_ppa, 0,  apu_bxpa, apu_amov // 0xAC-0xAF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xB0-0xB3
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xB4-0xB7
    .word apu_fallback, 0,  apu_fallback, 0,  apu_dirr, apu_movwya,  apu_fallback, 0 // 0xB8-0xBB
    .word apu_fallback, 0,  apu_movsx, 0,  apu_fallback, 0,  apu_bxpr, apu_mova // 0xBC-0xBF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xC0-0xC3
    .word apu_dira, apu_amov,  apu_absa, apu_amov,  apu_brxa, apu_amov,  apu_idxa, apu_amov // 0xC4-0xC7
    .word apu_fallback, 0,  apu_absa, apu_xmov,  apu_fallback, 0,  apu_dira, apu_ymov // 0xC8-0xCB
    .word apu_absa, apu_ymov,  apu_imm, apu_movx,  apu_ppx, 0,  apu_fallback, 0 // 0xCC-0xCF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xD0-0xD3
    .word apu_drxa, apu_amov,  apu_abxa, apu_amov,  apu_abya, apu_amov,  apu_idya, apu_amov // 0xD4-0xD7
    .word apu_dira, apu_xmov,  apu_drya, apu_xmov,  apu_dira, apu_movway,  apu_drxa, apu_ymov // 0xD8-0xDB
    .word apu_fallback, 0,  apu_movay, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xDC-0xDF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xE0-0xE3
    .word apu_dirr, apu_mova,  apu_absr, apu_mova,  apu_brxr, apu_mova,  apu_idxr, apu_mova // 0xE4-0xE7
    .word apu_imm, apu_mova,  apu_absr, apu_movx,  apu_fallback, 0,  apu_dirr, apu_movy // 0xE8-0xEB
    .word apu_absr, apu_movy,  apu_fallback, 0,  apu_ppy, 0,  apu_fallback, 0 // 0xEC-0xEF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xF0-0xF3
    .word apu_drxr, apu_mova,  apu_abxr, apu_mova,  apu_abyr, apu_mova,  apu_idyr, apu_mova // 0xF4-0xF7
    .word apu_dirr, apu_movx,  apu_dryr, apu_movx,  apu_dr2, apu_movm,  apu_drxr, apu_movy // 0xF8-0xFB
    .word apu_fallback, 0,  apu_movya, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xFC-0xFF

.text

jit_read8: // a0: address - v0: value
    // Read a byte from memory, count cycles, and increment the address
    srl t0, a0, 6
    lbu t1, apu_map(t0)
    addi s2, s2, -APU_CYCLE
    add t0, a0, t1
    lbu v0, apu_ram(t0)
    addi a0, a0, 1
    jr ra


compile_block:
    // Round the JIT pointer to nearest cache line, offset by header size
    lw t0, jit_pointer
    addi t0, t0, 0x1F + 12
    andi t1, t0, 0x1F
    sub a1, t0, t1 // Pointer
    addi t0, a1, -12
    sw t0, jit_pointer

    // Initialize values for tracking JIT block state
    move s1, zero // Status
    move s2, zero // Cycles
    move a0, s0 // PC
    addi t9, a0, BLOCK_SIZE // Limit

    // Check JIT bounds and invalidate data cache for the header
    li a2, ROM_BUFFER // Bounds
    bge a1, a2, reset_buffer
    cache 0x11, CACHED(0)(t0)

    // Set the start memory block and tag in the JIT header
    srl t1, a0, 6
    sll t1, t1, 2
    sh t1, 0(t0)
    lw t1, jit_tags(t1)
    sw t1, 4(t0)

next_opcode:
    // Read an opcode from memory and jump to its functions
    jal jit_read8
    sll t0, v0, 3
    lw t1, jit_opcodes + 0(t0)
    lw gp, jit_opcodes + 4(t0)
    jr t1


finish_opcode:
    // Compile another opcode if the limit hasn't been reached
    blt a0, t9, next_opcode

finish_block:
    // Update NZ flags at the end of a block
    jal update_nz

    // Emit code to store register X if enabled
    andi t0, s1, FLAG_SX
    beqz t0, skip_sx
    li t3, T9
    la t4, apu_reg_x
    la t5, emit_sb
    jal full_address

skip_sx:
    // Emit code to store register Y if enabled
    andi t0, s1, FLAG_SY
    beqz t0, skip_sy
    li t3, T8
    la t4, apu_reg_y
    la t5, emit_sb
    jal full_address

skip_sy:
    // Emit code to store the accumulator if enabled
    andi t0, s1, FLAG_SA
    beqz t0, skip_sa
    li t3, T7
    la t4, apu_accum
    la t5, emit_sb
    jal full_address

skip_sa:
    // Emit code to store the stack pointer if enabled
    andi t0, s1, FLAG_SS
    beqz t0, skip_ss
    li t3, S2
    la t4, apu_stack + 1
    la t5, emit_sb
    jal full_address

skip_ss:
    // Emit code to store the flags if enabled
    andi t0, s1, FLAG_SF
    beqz t0, skip_sf
    li t3, S1
    la t4, apu_flags
    la t5, emit_sb
    jal full_address

skip_sf:
    // Emit code to load the program counter value unless disabled
    andi t0, s1, FLAG_PC
    bnez t0, skip_pc
    li t0, S0
    li t1, ZERO
    move t2, a0
    jal emit_ori

skip_pc:
    // Emit code to store the program counter
    li t3, S0
    la t4, apu_count
    la t5, emit_sh
    jal full_address

    // Emit code to adjust APU cycle count and return to the main loop
    la t0, cpu_execute
    jal emit_j
finish_fallback:
    li t0, S3
    li t1, S3
    move t2, s2
    jal emit_addi

    // Update the JIT pointer and use its old value for block lookup
    lw t0, jit_pointer
    sw a1, jit_pointer
    sll t1, s0, 2
    lui t2, 0x2000
    sub t2, t0, t2 // Cached
    sw t2, jit_lookup(t1)

    // Set the end memory block and tag in the JIT header
    srl t1, a0, 6
    sll t1, t1, 2
    sh t1, 2(t0)
    lw t1, jit_tags(t1)
    sw t1, 8(t0)

    // Jump to the finished JIT block's code
    addi t0, t0, 12
    jr t0


reset_buffer:
    // Clear all block lookup pointers
    la t0, jit_lookup
    la t1, jit_pointer
reset_loop:
    sw zero, (t0)
    addi t0, t0, 4
    bne t0, t1, reset_loop

    // Reset the JIT pointer and restart compilation
    li t0, JIT_BUFFER
    sw t0, jit_pointer
    j compile_block


apu_fallback:
    // Compile a jump to an interpreter function as a fallback
    addi a0, a0, -1
    bne a0, s0, not_alone
    addi a0, a0, 3
    sll t0, v0, 2
    lw t0, apu_opcodes(t0)
    la ra, finish_fallback
    j emit_j

not_alone:
    // Exclude fallback from the block unless it's the only opcode
    addi s2, s2, APU_CYCLE
    j finish_block


full_address: // t3: rt, t4: address, t5: function
    // Adjust the address for signed offsets
    andi t0, t4, 0x8000
    sll t0, t0, 1
    add t4, t4, t0

    // Emit code for accessing a 32-bit memory address
    move t6, ra
    li t0, AT_
    srl t1, t4, 16
    jal emit_lui
    move t0, t3
    li t1, AT_
    andi t2, t4, 0xFFFF
    move ra, t6
    jr t5


load_reg_x:
    // Check if register X has already been loaded
    andi t0, s1, FLAG_LX
    beqz t0, do_lx
    jr ra

do_lx:
    // Emit code to load register X if needed
    ori s1, s1, FLAG_LX
    li t3, T9
    la t4, apu_reg_x
    la t5, emit_lbu
    j full_address


load_reg_y:
    // Check if register Y has already been loaded
    andi t0, s1, FLAG_LY
    beqz t0, do_ly
    jr ra

do_ly:
    // Emit code to load register Y if needed
    ori s1, s1, FLAG_LY
    li t3, T8
    la t4, apu_reg_y
    la t5, emit_lbu
    j full_address


load_accum:
    // Check if the accumulator has already been loaded
    andi t0, s1, FLAG_LA
    beqz t0, do_la
    jr ra

do_la:
    // Emit code to load the accumulator if needed
    ori s1, s1, FLAG_LA
    li t3, T7
    la t4, apu_accum
    la t5, emit_lbu
    j full_address


load_stack:
    // Check if the stack pointer has already been loaded
    andi t0, s1, FLAG_LS
    beqz t0, do_ls
    jr ra

do_ls:
    // Emit code to load the stack pointer if needed
    ori s1, s1, FLAG_LS
    li t3, S2
    la t4, apu_stack
    la t5, emit_lhu
    j full_address


load_flags:
    // Check if the flags have already been loaded
    andi t0, s1, FLAG_LF
    beqz t0, do_lf
    jr ra

do_lf:
    // Emit code to load the flags if needed
    ori s1, s1, FLAG_LF
    li t3, S1
    la t4, apu_flags
    la t5, emit_lbu
    j full_address


queue_nz: // t1: value
    // Emit code to save a value for setting NZ flags later
    ori s1, s1, FLAG_NZ
    li t0, A2
    li t2, 0xFF
    j emit_andi


update_nz:
    // Check if a value is queued for setting NZ flags
    andi t0, s1, FLAG_NZ
    bnez t0, do_nz
    jr ra

do_nz:
    // Emit code to update NZ flags if needed
    xori s1, s1, FLAG_NZ
    ori s1, s1, FLAG_SF
    move t7, ra
    jal load_flags
    li t0, S1
    li t1, S1
    li t2, 0x7D
    jal emit_andi
    li t0, T6
    li t1, ZERO
    li t2, A2
    jal emit_slt
    li t0, T6
    li t1, T6
    li t2, 0x1
    jal emit_xori
    li t0, T6
    li t1, T6
    li t2, 1
    jal emit_sll
    li t0, S1
    li t1, S1
    li t2, T6
    jal emit_or
    li t0, T6
    li t1, A2
    li t2, 0x80
    jal emit_andi
    li t0, S1
    li t1, S1
    li t2, T6
    move ra, t7
    j emit_or


emit_op: // t0: opcode
    // Write to the JIT buffer, invalidate caches, and reset on overflow
    sw t0, (a1)
    cache 0x10, CACHED(0)(a1)
    cache 0x11, CACHED(0)(a1)
    addi a1, a1, 4
    beq a1, a2, reset_buffer
    jr ra


emit_add: // t0: rd, t1: rs, t2: rt
    // Emit an "add" opcode for the JIT
    sll t0, t0, 11
    sll t1, t1, 21
    sll t2, t2, 16
    or t0, t0, t1
    or t0, t0, t2
    li t1, 0x0020
    or t0, t0, t1
    j emit_op


emit_addi: // t0: rt, t1: rs, t2: immediate
    // Emit an "addi" opcode for the JIT
    sll t0, t0, 16
    sll t1, t1, 21
    andi t2, t2, 0xFFFF
    or t0, t0, t1
    or t0, t0, t2
    lui t1, 0x2000
    or t0, t0, t1
    j emit_op


emit_andi: // t0: rt, t1: rs, t2: immediate
    // Emit an "andi" opcode for the JIT
    sll t0, t0, 16
    sll t1, t1, 21
    andi t2, t2, 0xFFFF
    or t0, t0, t1
    or t0, t0, t2
    lui t1, 0x3000
    or t0, t0, t1
    j emit_op


emit_j: // t0: target
    // Emit a "j" opcode for the JIT
    srl t0, t0, 2
    li t1, 0x3FFFFFF
    and t0, t0, t1
    lui t1, 0x0800
    or t0, t0, t1
    j emit_op


emit_jal: // t0: target
    // Emit a "jal" opcode for the JIT
    srl t0, t0, 2
    li t1, 0x3FFFFFF
    and t0, t0, t1
    lui t1, 0x0C00
    or t0, t0, t1
    j emit_op


emit_lbu: // t0: rt, t1: base, t2: offset
    // Emit an "lbu" opcode for the JIT
    sll t0, t0, 16
    sll t1, t1, 21
    andi t2, t2, 0xFFFF
    or t0, t0, t1
    or t0, t0, t2
    lui t1, 0x9000
    or t0, t0, t1
    j emit_op


emit_lhu: // t0: rt, t1: base, t2: offset
    // Emit an "lhu" opcode for the JIT
    sll t0, t0, 16
    sll t1, t1, 21
    andi t2, t2, 0xFFFF
    or t0, t0, t1
    or t0, t0, t2
    lui t1, 0x9400
    or t0, t0, t1
    j emit_op


emit_lui: // t0: rt, t1: immediate
    // Emit an "lui" opcode for the JIT
    sll t0, t0, 16
    andi t1, t1, 0xFFFF
    or t0, t0, t1
    lui t1, 0x3C00
    or t0, t0, t1
    j emit_op


emit_nop:
    // Emit a "nop" opcode for the JIT
    move t0, zero
    j emit_op


emit_or: // t0: rd, t1: rs, t2: rt
    // Emit an "or" opcode for the JIT
    sll t0, t0, 11
    sll t1, t1, 21
    sll t2, t2, 16
    or t0, t0, t1
    or t0, t0, t2
    li t1, 0x0025
    or t0, t0, t1
    j emit_op


emit_ori: // t0: rt, t1: rs, t2: immediate
    // Emit an "ori" opcode for the JIT
    sll t0, t0, 16
    sll t1, t1, 21
    andi t2, t2, 0xFFFF
    or t0, t0, t1
    or t0, t0, t2
    lui t1, 0x3400
    or t0, t0, t1
    j emit_op


emit_sb: // t0: rt, t1: base, t2: offset
    // Emit an "sb" opcode for the JIT
    sll t0, t0, 16
    sll t1, t1, 21
    andi t2, t2, 0xFFFF
    or t0, t0, t1
    or t0, t0, t2
    lui t1, 0xA000
    or t0, t0, t1
    j emit_op


emit_sh: // t0: rt, t1: base, t2: offset
    // Emit an "sh" opcode for the JIT
    sll t0, t0, 16
    sll t1, t1, 21
    andi t2, t2, 0xFFFF
    or t0, t0, t1
    or t0, t0, t2
    lui t1, 0xA400
    or t0, t0, t1
    j emit_op


emit_sll: // t0: rd, t1: rt, t2: sa
    // Emit an "sll" opcode for the JIT
    sll t0, t0, 11
    sll t1, t1, 16
    sll t2, t2, 6
    or t0, t0, t1
    or t0, t0, t2
    j emit_op


emit_slt: // t0: rd, t1: rs, t2: rt
    // Emit an "slt" opcode for the JIT
    sll t0, t0, 11
    sll t1, t1, 21
    sll t2, t2, 16
    or t0, t0, t1
    or t0, t0, t2
    li t1, 0x002A
    or t0, t0, t1
    j emit_op


emit_xori: // t0: rt, t1: rs, t2: immediate
    // Emit an "xori" opcode for the JIT
    sll t0, t0, 16
    sll t1, t1, 21
    andi t2, t2, 0xFFFF
    or t0, t0, t1
    or t0, t0, t2
    lui t1, 0x3800
    or t0, t0, t1
    j emit_op
