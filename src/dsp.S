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

.globl dsp_sample
.globl read_dspaddr
.globl read_dspdata
.globl write_dspaddr
.globl write_dspdata

.data

.align 4
dsp_buffer: .word 0:0x800
dsp_regs: .byte 0:0x100

.align 4
dsp_timer: .hword 0
dsp_pointer: .hword 0
dsp_addr: .byte 0
enabled: .byte 0

.align 4
mode_funcs: .word 0
cached_vols: .word 0
counters: .hword 0
envelopes: .hword 0
next_steps: .hword 0
cur_addrs: .hword 0

.align 4
voice_dups: .dword 0:14
cur_samples: .dword 0:8

.align 4
filter_jumps: .word filter_end, filter_1, filter_2, filter_3

.align 4
write_iomap:
    .word write_vol, write_vol, write_reg, write_reg // 0x00-0x03
    .word write_reg:(0x0F - 0x03) // 0x04-0x0F
    .word write_vol, write_vol, write_reg, write_reg // 0x10-0x13
    .word write_reg:(0x1F - 0x13) // 0x14-0x1F
    .word write_vol, write_vol, write_reg, write_reg // 0x20-0x23
    .word write_reg:(0x2F - 0x23) // 0x24-0x2F
    .word write_vol, write_vol, write_reg, write_reg // 0x30-0x33
    .word write_reg:(0x3F - 0x33) // 0x34-0x3F
    .word write_vol, write_vol, write_reg, write_reg // 0x40-0x43
    .word write_reg:(0x4B - 0x43) // 0x44-0x4B
    .word write_kon, write_reg, write_reg, write_reg // 0x4C-0x4F
    .word write_vol, write_vol, write_reg, write_reg // 0x50-0x53
    .word write_reg:(0x5B - 0x53) // 0x54-0x5B
    .word write_koff, write_reg, write_reg, write_reg // 0x5C-0x5F
    .word write_vol, write_vol, write_reg, write_reg // 0x60-0x63
    .word write_reg:(0x6F - 0x63) // 0x64-0x6F
    .word write_vol, write_vol, write_reg, write_reg // 0x70-0x73
    .word write_reg:(0xFF - 0x73) // 0x74-0xFF

.align 4
timer_rates: // Lookup table for timer rates and offsets
    .hword 0x8000, 1,  2048, 0,  1536, 1040
    .hword 1280, 536,  1024, 0,  768, 1040
    .hword 640, 536,  512, 0,  384, 1040
    .hword 320, 536,  256, 0,  192, 1040
    .hword 160, 536,  128, 0,  96, 1040
    .hword 80, 536,  64, 0,  48, 1040
    .hword 40, 536,  32, 0,  24, 1040
    .hword 20, 536,  16, 0,  12, 1040
    .hword 10, 536,  8, 0,  6, 1040
    .hword 5, 536,  4, 0,  3, 1040
    .hword 2, 0,  1, 0

.text

.align 5
dsp_sample:
    // Decrement the global timer every sample
    lhu t0, dsp_timer
    addi gp, t0, -1
    bnez t0, not_zero
    addi gp, gp, 0x7800
not_zero:
    sh gp, dsp_timer

    // Set initial values for the sample
    li t6, -1 // Voice count
    li t5, 0 // Left sample
    li t4, 0 // Right sample
    lbu sp, enabled

next_voice:
    // Check if a voice is enabled
    addi t6, t6, 1
    srl t0, sp, t6
    beqz t0, write_sample
    andi t0, t0, 1
    beqz t0, next_voice

    // Handle an envelope step if the timer matches
    sll t8, t6, 4
    lhu t0, next_steps(t8)
    bne t0, gp, get_pitch
    lw t0, mode_funcs(t8)
    jalr t0

get_pitch:
    // Get the pitch scaler for the current voice
    lhu t0, dsp_regs + 0x2(t8) // VxPITCH(L/H)
    sll t1, t0, 8
    srl t0, t0, 8
    or t0, t0, t1
    andi t0, t0, 0x3FFF

    // Increase the voice's position counter by the scaler
    lhu t9, counters(t8)
    addu t2, t9, t0
    sh t2, counters(t8)

    // Decode a new 4-sample BRR chunk if the counter overflows
    xor t9, t9, t2
    srl t9, t9, 14
    bnez t9, decode_chunk

mix_sample:
    // Load the current sample from the voice's buffer
    sll t1, t6, 3
    srl t3, t2, 11
    andi t3, t3, 0x6
    xori t3, t3, 0x6
    add t1, t1, t3
    lh t0, cur_samples(t1)
    beqz t0, next_voice

    // Get the cached volumes for each channel
    lh t2, cached_vols + 0(t8)
    lh t3, cached_vols + 2(t8)

    // Mix the sample on the left channel
    mult t0, t2
    mflo t1
    sra t1, t1, 14
    addu t5, t5, t1

    // Mix the sample on the right channel
    beq t2, t3, same_volume
    mult t0, t3
    mflo t1
    sra t1, t1, 14
same_volume:
    addu t4, t4, t1
    b next_voice

.align 5
write_sample: // t4: left, t5: right
    // Write a sample to the buffer
    andi t4, t4, 0xFFFF
    sll t5, t5, 16
    or t0, t4, t5
    lhu t1, dsp_pointer
    sw t0, UNCACHED(dsp_buffer)(t1)

    // Increment the sample pointer
    addi a0, t1, 4
    andi t0, a0, 0x1FFF
    sh t0, dsp_pointer

    // Schedule the next sample and check if a buffer is ready
    andi t0, a0, 0xFFF
    addi a3, a3, -DSP_SAMPLE
    bnez t0, apu_execute

    // Submit a buffer to the AI when one is ready
    lui t0, 0xA450 // AI register upper address
    la t1, dsp_buffer - 0x1000
    add t1, t1, a0 // Buffer address
    sw t1, 0x0000(t0) // AI_DRAM_ADDR
    li t1, 0x00001000 // Buffer length
    sw t1, 0x0004(t0) // AI_LENGTH
    j apu_execute

.align 5
decode_chunk: // t2: counter, t6: voice, t8: offset
    // Stay in the same BRR block until the counter overflows
    lhu t0, cur_addrs(t8)
    srl t3, t2, 16
    beqz t3, decode_samples

    // Move to the next 9-byte BRR block based on current flags
    lbu t9, apu_ram(t0) // Header
    andi t3, t9, 0x1 // End
    addi t0, t0, 9
    beqz t3, decode_samples
    andi t3, t9, 0x2 // Loop
    beqz t3, end_voice

    // Get the address of the voice's sample table entry
    lbu t0, dsp_regs + 0x5D // DIR
    lbu t3, dsp_regs + 0x4(t8) // VxSRCN
    sll t0, t0, 8
    sll t3, t3, 2
    add t0, t0, t3

    // Load the loop address and start decoding from there
    lhu t0, apu_ram + 0x2(t0)
    sll t3, t0, 8
    srl t0, t0, 8
    or t0, t0, t3
    andi t0, t0, 0xFFFF

decode_samples:
    // Get the address of the voice's sample buffer
    la t3, cur_samples
    sll v1, t6, 3
    add v1, v1, t3

    // Configure things based on the BRR block header
    sh t0, cur_addrs(t8)
    lbu t9, apu_ram(t0) // Header
    srl t1, t9, 4 // Shift
    andi t9, t9, 0xC // Filter
    lw t9, filter_jumps(t9)

    // Load 4 4-bit BRR samples at once to be decoded
    srl t3, t2, 13
    andi t3, t3, 0x6
    add t0, t0, t3
    lbu t3, apu_ram + 1(t0)
    lbu s0, apu_ram + 2(t0)
    sll t3, t3, 8
    or s0, s0, t3
    li s1, 8

next_sample:
    // Pass the next sample, sign-extended and shifted, to the filter
    addi s1, s1, -2
    sll t3, s1, 1
    srl t0, s0, t3
    sll t0, t0, 28
    sra t0, t0, 28
    sll t0, t0, t1
    sra t0, t0, 1
    jr t9

filter_1:
    // Apply the old sample, multiplied by 0.9375
    addi t7, s1, 2
    andi t7, t7, 0x6
    add t3, v1, t7
    lh t7, (t3)
    add t0, t0, t7
    sra t7, t7, 4
    sub t0, t0, t7
    b filter_end

filter_2:
    // Apply the old sample, multiplied by 1.90625
    addi t7, s1, 2
    andi t7, t7, 0x6
    add t3, v1, t7
    lh t7, (t3)
    sll t3, t7, 1
    add t0, t0, t3
    sll t3, t7, 1
    add t3, t3, t7
    sra t3, t3, 5
    sub t0, t0, t3

    // Apply the older sample, multiplied by -0.9375
    addi t7, s1, 4
    andi t7, t7, 0x6
    add t3, v1, t7
    lh t7, (t3)
    sub t0, t0, t7
    sra t3, t7, 4
    add t0, t0, t3
    b filter_end

filter_3:
    // Apply the old sample, multiplied by 1.796875
    addi t7, s1, 2
    andi t7, t7, 0x6
    add t3, v1, t7
    lh t7, (t3)
    sll t3, t7, 1
    add t0, t0, t3
    sll t3, t7, 3
    add t3, t3, t7
    sll t7, t7, 2
    add t3, t3, t7
    sra t3, t3, 6
    sub t0, t0, t3

    // Apply the older sample, multiplied by -0.8125
    addi t7, s1, 4
    andi t7, t7, 0x6
    add t3, v1, t7
    lh t7, (t3)
    sub t0, t0, t7
    sll t3, t7, 1
    add t3, t3, t7
    sra t3, t3, 4
    add t0, t0, t3

filter_end:
    // Store the sample and loop until all 4 are done
    add t3, v1, s1
    sh t0, (t3)
    bnez s1, next_sample
    j mix_sample

end_voice:
    // Disable the voice if it ends without loop
    li t0, 1
    sll t0, t0, t6
    xori t0, t0, 0xFF
    and sp, sp, t0
    sb sp, enabled
    j next_voice

.align 5
attack_mode: // t6: voice, t8: offset
    // Increase the envelope by 32
    lhu t0, envelopes(t8)
    addi t0, t0, 32
    sh t0, envelopes(t8)

    // Switch to decay mode at level 0x7E0 and clip to 0x7FF
    blt t0, 0x7E0, attack_time
    la t3, decay_mode
    sw t3, mode_funcs(t8)
    blt t0, 0x7FF, decay_time
    li t0, 0x7FF
    sh t0, envelopes(t8)
    j decay_time

.align 5
attack_time: // t6: voice
    // Schedule the next step using the attack rate
    sll t1, t6, 4
    lbu t0, dsp_regs + 0x5(t1) // VxADSR1
    andi a0, t0, 0xF
    sll a0, a0, 3
    addi a0, a0, 4
    j update_step

.align 5
decay_mode: // t6: voice, t8: offset
    // Decrease the envelope by an exponential amount
    lhu t0, envelopes(t8)
    addi t2, t0, -1
    srl t2, t2, 8
    addi t2, t2, 1
    sub t0, t0, t2
    sh t0, envelopes(t8)

    // Calculate the sustain level boundary
    lbu t1, dsp_regs + 0x6(t8) // VxADSR2
    andi t1, t1, 0xE0
    sll t1, t1, 3
    addi t1, t1, 0x100

    // Switch to sustain mode at the boundary and clip to 0
    bgt t0, t1, decay_time
    la t3, sustain_mode
    sw t3, mode_funcs(t8)
    bgtz t0, sustain_time
    sh zero, envelopes(t8)
    j sustain_time

.align 5
decay_time: // t6: voice
    // Schedule the next step using the decay rate
    sll t1, t6, 4
    lbu t0, dsp_regs + 0x5(t1) // VxADSR1
    andi a0, t0, 0x70
    srl a0, a0, 1
    addi a0, a0, 64
    j update_step

.align 5
sustain_mode: // t6: voice, t8: offset
    // Decrease the envelope by an exponential amount
    lhu t0, envelopes(t8)
    addi t2, t0, -1
    srl t2, t2, 8
    addi t2, t2, 1
    sub t0, t0, t2
    sh t0, envelopes(t8)

    // Disable the voice if its envelope decreases to zero
    bgtz t0, sustain_time
    li t0, 1
    sll t0, t0, t6
    xori t0, t0, 0xFF
    and sp, sp, t0
    sb sp, enabled
    jr ra

.align 5
sustain_time: // t6: voice
    // Schedule the next step using the sustain rate
    sll t1, t6, 4
    lbu t0, dsp_regs + 0x6(t1) // VxADSR2
    andi a0, t0, 0x1F
    sll a0, a0, 2
    j update_step

.align 5
gain_mode: // t6: voice
gain_time: // t6: voice
    // Stub gain mode by fixing the volume to max
    // TODO: actually implement gain mode
    sll t1, t6, 4
    li t0, 0x7FF
    sh t0, envelopes(t1)
    li t0, 0xFFFF
    sh t0, next_steps(t1)
    j update_vols

.align 5
update_step: // a0: rate, t6: voice
    // Get values for updating a step timer
    lhu t2, dsp_timer
    lw t0, timer_rates(a0)
    addi t2, t2, -1 // Base
    srl t1, t0, 16 // Rate
    andi t0, t0, 0xFFFF // Offset
    bgez t2, calc_step
    addi t2, t2, 0x7800

calc_step:
    // Calculate the timer value of the next step
    add t0, t0, t2
    div t0, t1
    mfhi t3
    sub t2, t2, t3
    bgez t2, set_step
    addi t2, t2, 0x7800

set_step:
    // Update a voice's step timer and cached volume
    sll t1, t6, 4
    sh t2, next_steps(t1)
    j update_vols

.align 5
update_vols: // t6: voice
    // Get a voice's envelope and channel volumes
    sll t1, t6, 4
    lhu t0, envelopes(t1)
    lb t2, dsp_regs + 0x0(t1) // VxVOLL
    lb t3, dsp_regs + 0x1(t1) // VxVOLR
    srl t0, t0, 4

    // Cache the multiplied volumes to save a step during mixing
    mult t2, t0
    mflo t2
    sh t2, cached_vols + 0(t1)
    mult t3, t0
    mflo t3
    sh t3, cached_vols + 2(t1)
    jr ra

.align 5
read_dspaddr: // v0: value
    // Read the DSP register address
    lbu v0, dsp_addr
    jr ra

.align 5
read_dspdata: // v0: value
    // Read a value from the DSP registers
    lbu t0, dsp_addr
    andi t0, t0, 0x7F // Mirror
    lbu v0, dsp_regs(t0)
    jr ra

.align 5
write_dspaddr: // a1: value
    // Write the DSP register address
    sb a1, dsp_addr
    jr ra

.align 5
write_dspdata: // a1: value
    // Write a value to a DSP register
    lbu t0, dsp_addr
    sb a1, dsp_regs(t0)

    // Jump to the register's handler function
    sll t1, t0, 2
    lw t1, write_iomap(t1)
    jr t1

write_reg:
    // Do nothing extra for regular register writes
    jr ra

.align 5
write_vol: // t0: address
    // Update a voice's cached volumes when changed
    srl t6, t0, 4
    j update_vols

.align 5
write_kon: // a1: value
    // Set voices to enabled
    lbu t0, enabled
    move t5, ra
    or t0, t0, a1
    sb t0, enabled
    li t6, -1

next_on:
    // Check if a voice was just enabled
    addi t6, t6, 1
    srl t0, a1, t6
    beqz t0, kon_end
    andi t0, t0, 1
    beqz t0, next_on

    // Get the address of the voice's sample table entry
    lbu t0, dsp_regs + 0x5D // DIR
    sll t4, t6, 4
    lbu t1, dsp_regs + 0x04(t4) // VxSRCN
    sll t0, t0, 8
    sll t1, t1, 2
    add t0, t0, t1

    // Load the start address and reset the voice
    lhu t0, apu_ram(t0)
    sll t1, t0, 8
    srl t0, t0, 8
    or t0, t0, t1
    sh t0, cur_addrs(t4)
    sh zero, counters(t4)
    sh zero, envelopes(t4)
    sll t1, t6, 3
    sd zero, cur_samples(t1)

    // Check whether the voice uses ADSR or gain
    lbu t1, dsp_regs + 0x5(t4) // VxADSR1
    la ra, next_on
    andi t1, t1, 0x80
    beqz t1, use_gain

    // Set the voice to attack mode and schedule the first step
    la t0, attack_mode
    sw t0, mode_funcs(t4)
    j attack_time

use_gain:
    // Set the voice to gain mode and schedule the first step
    la t0, gain_mode
    sw t0, mode_funcs(t4)
    j gain_time

kon_end:
    // Return from the function
    jr t5

.align 5
write_koff: // a1: value
    // Set voices to disabled
    lbu t0, enabled
    xori t1, a1, 0xFF
    and t0, t0, t1
    sb t0, enabled
    jr ra
