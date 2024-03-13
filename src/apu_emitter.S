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

#include <regdef.h>
#include "addresses.h"

#define APU_CYCLE 21 * 2

.globl jit_tags
.globl jit_lookup

.globl compile_block
.globl finish_block
.globl emit_j
.globl emit_nop

.data

jit_tags: .word 0:0x400
jit_lookup: .word 0:0x10000
jit_pointer: .word JIT_BUFFER

jit_opcodes: // Lookup table for addressing and operation functions
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x00-0x03
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x04-0x07
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x08-0x0B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x0C-0x0F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x10-0x13
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x14-0x17
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x18-0x1B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x1C-0x1F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x20-0x23
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x24-0x27
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x28-0x2B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x2C-0x2F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x30-0x33
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x34-0x37
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x38-0x3B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x3C-0x3F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x40-0x43
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x44-0x47
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x48-0x4B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x4C-0x4F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x50-0x53
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x54-0x57
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x58-0x5B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x5C-0x5F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x60-0x63
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x64-0x67
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x68-0x6B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x6C-0x6F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x70-0x73
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x74-0x77
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x78-0x7B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x7C-0x7F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x80-0x83
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x84-0x87
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x88-0x8B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x8C-0x8F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x90-0x93
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x94-0x97
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x98-0x9B
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0x9C-0x9F
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xA0-0xA3
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xA4-0xA7
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xA8-0xAB
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xAC-0xAF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xB0-0xB3
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xB4-0xB7
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xB8-0xBB
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xBC-0xBF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xC0-0xC3
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xC4-0xC7
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xC8-0xCB
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xCC-0xCF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xD0-0xD3
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xD4-0xD7
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xD8-0xDB
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xDC-0xDF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xE0-0xE3
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xE4-0xE7
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xE8-0xEB
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xEC-0xEF
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xF0-0xF3
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xF4-0xF7
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xF8-0xFB
    .word apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0,  apu_fallback, 0 // 0xFC-0xFF

.text

compile_block:
    // Round the JIT pointer to nearest cache line, offset by header size
    lw t0, jit_pointer
    addi t0, t0, 0x1F + 12
    andi t1, t0, 0x1F
    sub a1, t0, t1 // Pointer
    addi t0, a1, -12
    sw t0, jit_pointer

    // Check JIT bounds and invalidate data cache for the header
    move a0, s0 // PC
    li a2, ROM_BUFFER // Bounds
    bge a1, a2, reset_buffer
    cache 0x11, CACHED(0)(t0)

    // Set the start memory block and tag in the JIT header
    srl t1, a0, 6
    sll t1, t1, 2
    sh t1, 0(t0)
    lw t1, jit_tags(t1)
    sw t1, 4(t0)

    // Look up functions for the current opcode and jump to them
    jal apu_read8
    addi s3, s3, APU_CYCLE
    sll t0, v0, 3
    lw t1, jit_opcodes + 0(t0)
    lw gp, jit_opcodes + 4(t0)
    jr t1


finish_block:
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
    addi s3, s3, -APU_CYCLE
    jr t0


apu_fallback:
    // Compile a jump to an interpreter function as a fallback
    sll t0, v0, 2
    lw t0, apu_opcodes(t0)
    jal emit_j
    jal emit_nop
    addi a0, a0, 3
    j finish_block


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
    b compile_block


emit_op: // t0: opcode
    // Write to the JIT buffer, invalidate caches, and reset on overflow
    sw t0, (a1)
    cache 0x10, CACHED(0)(a1)
    cache 0x11, CACHED(0)(a1)
    addi a1, a1, 4
    beq a1, a2, reset_buffer
    jr ra


emit_j: // t0: address
    // Emit a "j" opcode for the JIT
    srl t0, t0, 2
    li t1, 0x3FFFFFF
    and t0, t0, t1
    lui t1, 0x0800
    or t0, t0, t1
    b emit_op


emit_nop:
    // Emit a "nop" opcode for the JIT
    move t0, zero
    b emit_op
