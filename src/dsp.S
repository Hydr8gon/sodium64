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

// Approximate master cycle count for DSP samples
#define DSP_SAMPLE 672 // 21477000Hz / 32000Hz = 671.15625

.globl dsp_sample
.globl read_dspaddr
.globl read_dspdata
.globl write_dspaddr
.globl write_dspdata

.data

dsp_buffer: .word 0:0x800
dsp_pointer: .hword 0

dsp_regs: .byte 0:0x100
dsp_addr: .byte 0

enabled: .byte 0
counters: .hword 0:8
cur_addrs: .hword 0:8
cur_samples: .dword 0:8

filter_jumps: .word filter_end, filter_1, filter_2, filter_3

.text

dsp_sample:
    // Set initial values for the sample
    li   t6, -1 // Voice count
    li   t5, 0 // Left sample
    li   t4, 0 // Right sample

next_voice:
    // Check if a voice is enabled
    lbu  t7, enabled
    addi t6, t6, 1
    srl  t0, t7, t6
    beqz t0, write_sample
    andi t0, t0, 1
    beqz t0, next_voice

    // Get the pitch scaler for the current voice
    sll  t8, t6, 4
    lhu  t0, dsp_regs + 0x02(t8) // VxPITCH(L/H)
    sll  t1, t0, 8
    srl  t0, t0, 8
    or   t0, t0, t1
    andi t0, t0, 0x3FFF

    // Increase the voice's position counter by the scaler
    sll  t1, t6, 1
    lhu  t9, counters(t1)
    addu t2, t9, t0
    sh   t2, counters(t1)

    // Skip decoding if still within the last 4-sample chunk
    xor  t9, t9, t2
    srl  t9, t9, 14
    beqz t9, mix_sample

    // Stay in the same BRR block until the counter overflows
    lhu  t0, cur_addrs(t1)
    srl  t3, t2, 16
    beqz t3, decode_samples

    // Move to the next 9-byte BRR block based on current flags
    lbu  t9, apu_ram(t0) // Header
    andi t3, t9, 0x1 // End
    addi t0, t0, 9
    beqz t3, decode_samples
    andi t3, t9, 0x2 // Loop
    beqz t3, end_voice

    // Get the address of the voice's sample table entry
    lbu  t0, dsp_regs + 0x5D // DIR
    lbu  t3, dsp_regs + 0x04(t8) // VxSRCN
    sll  t0, t0, 8
    sll  t3, t3, 2
    add  t0, t0, t3

    // Load the loop address and start decoding from there
    lhu  t0, apu_ram + 0x2(t0)
    sll  t3, t0, 8
    srl  t0, t0, 8
    or   t0, t0, t3
    andi t0, t0, 0xFFFF
    b    decode_samples

end_voice:
    // Disable the voice if it ends without loop
    li   t0, 1
    sll  t0, t0, t6
    xori t0, t0, 0xFF
    and  t7, t7, t0
    sb   t7, enabled
    b    next_voice

decode_samples:
    // Get the address of the voice's sample buffer
    la   t3, cur_samples
    sll  v1, t6, 3
    add  v1, v1, t3

    // Configure things based on the BRR block header
    sh   t0, cur_addrs(t1)
    lbu  t9, apu_ram(t0) // Header
    srl  t1, t9, 4 // Shift
    andi t9, t9, 0xC // Filter
    lw   t9, filter_jumps(t9)

    // Load 4 4-bit BRR samples at once to be decoded
    srl  t3, t2, 13
    andi t3, t3, 0x6
    add  t0, t0, t3
    lbu  t3, apu_ram + 1(t0)
    lbu  s0, apu_ram + 2(t0)
    sll  t3, t3, 8
    or   s0, s0, t3
    li   s1, 8

next_sample:
    // Pass the next sample, sign-extended and shifted, to the filter
    addi s1, s1, -2
    sll  t3, s1, 1
    srl  t0, s0, t3
    sll  t0, t0, 28
    sra  t0, t0, 28
    sll  t0, t0, t1
    sra  t0, t0, 1
    jr   t9

filter_1:
    // Apply the old sample, multiplied by 0.9375
    addi t7, s1, 2
    andi t7, t7, 0x6
    add  t3, v1, t7
    lh   t7, (t3)
    add  t0, t0, t7
    sra  t7, t7, 4
    sub  t0, t0, t7
    b    filter_end

filter_2:
    // Apply the old sample, multiplied by 1.90625
    addi t7, s1, 2
    andi t7, t7, 0x6
    add  t3, v1, t7
    lh   t7, (t3)
    sll  t3, t7, 1
    add  t0, t0, t3
    sll  t3, t7, 1
    add  t3, t3, t7
    sra  t3, t3, 5
    sub  t0, t0, t3

    // Apply the older sample, multiplied by -0.9375
    addi t7, s1, 4
    andi t7, t7, 0x6
    add  t3, v1, t7
    lh   t7, (t3)
    sub  t0, t0, t7
    sra  t3, t7, 4
    add  t0, t0, t3
    b    filter_end

filter_3:
    // Apply the old sample, multiplied by 1.796875
    addi t7, s1, 2
    andi t7, t7, 0x6
    add  t3, v1, t7
    lh   t7, (t3)
    sll  t3, t7, 1
    add  t0, t0, t3
    sll  t3, t7, 3
    add  t3, t3, t7
    sll  t7, t7, 2
    add  t3, t3, t7
    sra  t3, t3, 6
    sub  t0, t0, t3

    // Apply the older sample, multiplied by -0.8125
    addi t7, s1, 4
    andi t7, t7, 0x6
    add  t3, v1, t7
    lh   t7, (t3)
    sub  t0, t0, t7
    sll  t3, t7, 1
    add  t3, t3, t7
    sra  t3, t3, 4
    add  t0, t0, t3

filter_end:
    // Store the sample and loop until all 4 are done
    add  t3, v1, s1
    sh   t0, (t3)
    bnez s1, next_sample

mix_sample:
    // Load the current sample from the voice's buffer
    sll  t1, t6, 3
    srl  t3, t2, 11
    andi t3, t3, 0x6
    xori t3, t3, 0x6
    add  t1, t1, t3
    lh   t0, cur_samples(t1)

    // Mix the sample on the left channel
    lb   t1, dsp_regs + 0x00(t8) // VxVOLL
    mult t0, t1
    mflo t1
    sra  t1, t1, 7
    addu t5, t5, t1

    // Mix the sample on the right channel
    lb   t1, dsp_regs + 0x01(t8) // VxVOLR
    mult t0, t1
    mflo t1
    sra  t1, t1, 7
    addu t4, t4, t1
    b    next_voice

write_sample:
    // Write a sample to the buffer
    andi t4, t4, 0xFFFF
    sll  t5, t5, 16
    or   t0, t4, t5
    lhu  t1, dsp_pointer
    sw   t0, UNCACHED(dsp_buffer)(t1)

    // Increment the sample pointer
    addi a0, t1, 4
    andi t0, a0, 0x1FFF
    sh   t0, dsp_pointer

    // Schedule the next sample and check if a buffer is ready
    andi t0, a0, 0xFFF
    addi a3, a3, -DSP_SAMPLE
    beqz t0, submit_buffer
    j    apu_execute

submit_buffer:
    // Submit a buffer to the AI when one is ready
    lui  t0, 0xA450 // AI register upper address
    la   t1, dsp_buffer - 0x1000
    add  t1, t1, a0 // Buffer address
    sw   t1, 0x0000(t0) // AI_DRAM_ADDR
    li   t1, 0x00001000 // Buffer length
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
    lbu  t1, dsp_regs + 0x04(t1) // VxSRCN
    sll  t0, t0, 8
    sll  t1, t1, 2
    add  t0, t0, t1

    // Load the start address and reset the voice
    lhu  t0, apu_ram(t0)
    sll  t1, t0, 8
    srl  t0, t0, 8
    or   t0, t0, t1
    sll  t1, t6, 1
    sh   t0, cur_addrs(t1)
    sh   zero, counters(t1)
    sll  t1, t6, 3
    sd   zero, cur_samples(t1)
    b    next_on


write_koff: // a1: value
    // Set voices to disabled
    lbu  t0, enabled
    xori t1, a1, 0xFF
    and  t0, t0, t1
    sb   t0, enabled
kon_end:
    jr   ra
