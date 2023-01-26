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

// Approximate master cycle count for DSP samples
#define DSP_SAMPLE 672 // 21477000Hz / 32000Hz = 671.15625

.globl dsp_sample
.globl read_dspaddr
.globl read_dspdata
.globl write_dspaddr
.globl write_dspdata

.data

dsp_buffer:  .word 0:0x400
dsp_pointer: .hword 0x000

dsp_regs: .byte 0:0x100
dsp_addr: .byte 0x00

enabled:    .byte  0x00
cur_addrs:  .hword 0x0000:8
loop_addrs: .hword 0x0000:8
counters:   .hword 0x0000:8

.text

dsp_sample:
    // Set initial values for the sample
    lbu  t7, enabled
    li   t6, -1 // Voice count
    li   t5,  0 // Sample

next_voice:
    // Check if a voice is enabled
    addi t6, t6, 1
    srl  t0, t7, t6
    beqz t0, write_sample
    andi t0, t0, 1
    beqz t0, next_voice

    // Get the pitch scaler for the current voice
    sll  t0, t6, 4
    addi t0, t0, 2
    lhu  t0, dsp_regs(t0) // VxPITCH(L/H)
    sll  t1, t0, 8
    srl  t0, t0, 8
    or   t0, t0, t1
    andi t0, t0, 0x3FFF

    // Increase the voice's position counter by the scaler
    sll  t1, t6, 1
    lhu  t2, counters(t1)
    addu t2, t2, t0
    sh   t2, counters(t1)

    // Check if the counter overflowed
    lhu  t0, cur_addrs(t1)
    srl  t3, t2, 16
    beqz t3, decode_sample

    // Move to the next BRR block when the counter overflows
    lbu  t3, apu_ram(t0) // Header
    andi t3, t3, 0x1     // End
    beqz t3, not_end
    lhu  t0, loop_addrs(t1)
    b    decode_sample
not_end:
    addi t0, t0, 9       // Block size

decode_sample:
    // Read the BRR block header and current sample byte
    sh   t0, cur_addrs(t1)
    lbu  t1, apu_ram(t0) // Header
    srl  t1, t1, 4       // Shift
    srl  t3, t2, 13
    andi t3, t3, 0x7
    addi t3, t3, 1       // Block offset
    add  t0, t0, t3
    lbu  t0, apu_ram(t0) // Sample byte

    // Get the appropriate nibble, sign-extend it, and mix it
    srl  t2, t2, 10
    andi t2, t2, 0x4
    xori t2, t2, 0x4
    srl  t0, t0, t2
    sll  t0, t0, 28
    sra  t0, t0, 28
    sll  t0, t0, t1
    sra  t0, t0, 1
    addu t5, t5, t0
    b    next_voice

write_sample:
    // Write a sample to the buffer
    andi t5, t5, 0xFFFF
    sll  t0, t5, 16
    or   t0, t0, t5
    lhu  t1, dsp_pointer
    sw   t0, 0x20000000 + dsp_buffer(t1) // Uncached

    // Increment the sample pointer
    addi a0, t1, 4
    andi t0, a0, 0xFFF
    sh   t0, dsp_pointer

    // Schedule the next sample and check if a buffer is ready
    andi t0, a0, 0x7FF
    addi a3, a3, -DSP_SAMPLE
    beqz t0, submit_buffer
    j    apu_execute


submit_buffer: // a0: buffer end
    // Submit a buffer to the AI when one is ready
    lui  t0, 0xA450     // AI register upper address
    la   t1, dsp_buffer - 0x800
    add  t1, t1, a0     // Buffer address
    sw   t1, 0x0000(t0) // AI_DRAM_ADDR
    li   t1, 0x800      // Buffer length
    sw   t1, 0x0004(t0) // AI_LENGTH
    j    apu_execute


read_dspaddr: // v0: value
    // Read the DSP register address
    lbu  v0, dsp_addr
    jr   ra


read_dspdata: // v0: value
    // Read a value from the DSP registers
    lbu  t0, dsp_addr
    andi t0, t0, 0x7F // Mirror
    lbu  v0, dsp_regs(t0)
    jr   ra


write_dspaddr: // a1: value
    // Write the DSP register address
    sb   a1, dsp_addr
    jr   ra


write_dspdata: // a1: value
    // Write a value to the DSP registers
    lbu  t0, dsp_addr
    sb   a1, dsp_regs(t0)

    // Handle special registers
    beq  t0, 0x4C, write_kon
    beq  t0, 0x5C, write_koff
    jr   ra


write_kon: // a1: value
    // Set voices to enabled
    lbu  t0, enabled
    or   t0, t0, a1
    sb   t0, enabled
    li   t6, -1

next_on:
    // Check if a voice was just enabled
    addi t6, t6, 1
    srl  t0, a1, t6
    beqz t0, kon_end
    andi t0, t0, 1
    beqz t0, next_on

    // Get the address of the voice's sample table entry
    lbu  t0, dsp_regs + 0x5D // DIR
    sll  t1, t6, 4
    addi t1, t1, 4
    lbu  t1, dsp_regs(t1)    // VxSRCN
    sll  t0, t0, 8
    sll  t1, t1, 2
    add  t0, t0, t1

    // Read the voice's start and loop addresses
    lw   t0, apu_ram(t0)
    srl  t1, t0, 16
    sll  t2, t1, 8
    srl  t1, t1, 8
    or   t1, t1, t2 // Start
    andi t0, t0, 0xFFFF
    sll  t2, t0, 8
    srl  t0, t0, 8
    or   t0, t0, t2 // Loop

    // Reload the voice's addresses and counter
    sll  t2, t6, 1 // Half-word offset
    sh   t1, cur_addrs(t2)
    sh   t0, loop_addrs(t2)
    sh   zero, counters(t2)
kon_end:
    jr   ra


write_koff: // a1: value
    // Set voices to disabled
    lbu  t0, enabled
    xori t1, a1, 0xFF
    and  t0, t0, t1
    sb   t0, enabled
    jr   ra
