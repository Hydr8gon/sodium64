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

.globl reload_hdma
.globl trigger_hdma
.globl write_mdmaen
.globl read_dmapx
.globl read_bbadx
.globl read_a1txl
.globl read_a1txh
.globl read_a1bx
.globl read_dasxl
.globl read_dasxh
.globl read_dasbx
.globl read_a2axl
.globl read_a2axh
.globl read_ntrlx
.globl read_unusedx
.globl write_hdmaen
.globl write_dmapx
.globl write_bbadx
.globl write_a1txl
.globl write_a1txh
.globl write_a1bx
.globl write_dasxl
.globl write_dasxh
.globl write_dasbx
.globl write_a2axl
.globl write_a2axh
.globl write_ntrlx
.globl write_unusedx

.data

hdma_mask: .byte 0

hdmaen: .byte 0
dmapx: .byte 0:8
bbadx: .hword 0x2100:8
a1tbx: .word 0:8
dastbx: .word 0:8
a2abx: .word 0:8
ntrlx: .byte 0:8
unusedx: .byte 0:8

// Possible CPU address steps
address_steps: .byte 1, 0, -1, 0

// Possible I/O address offsets, repeated every 4 bytes
transfer_modes:
    .byte 0, 0, 0, 0
    .byte 0, 1, 0, 1
    .byte 0, 0, 0, 0
    .byte 0, 0, 1, 1
    .byte 0, 1, 2, 3
    .byte 0, 1, 0, 1
    .byte 0, 0, 0, 0
    .byte 0, 0, 1, 1

// Lengths of a unit for each transfer mode
unit_lengths: .byte 1, 2, 2, 4, 4, 4, 2, 4

.text

reload_hdma:
    // Reload the HDMA channel mask
    lbu  t0, hdmaen
    li   t1, 0
    sb   t0, hdma_mask

reload_start:
    // Check if the current HDMA channel is enabled
    andi t2, t0, 0x1
    beqz t2, reload_end

    // Reload the channel's table address and line counter
    sll  t2, t1, 2
    lw   t3, a1tbx(t2)
    li   t4, 1
    sw   t3, a2abx(t2)
    sb   t4, ntrlx(t1)

reload_end:
    // Move to the next channel until no more are enabled
    srl  t0, t0, 1
    addi t1, t1, 1
    bnez t0, reload_start
    jr   ra


trigger_hdma:
    // Set the initial enabled channels (s0) and current channel (s1)
    lbu  s0, hdma_mask
    li   s1, 0
    beqz s0, hdma_skip

    // Push non-temporary registers to the stack
    addi sp, sp, -12
    sw   ra, 8(sp)
    sw   s4, 4(sp)
    sw   s3, 0(sp)

hdma_start:
    // Check if the current HDMA channel is enabled
    andi t0, s0, 0x1
    beqz t0, hdma_end
    lbu  t0, dmapx(s1)

    // Get the channel's I/O transfer mode (s3) and unit length (s4)
    andi t1, t0, 0x7
    sll  t2, t1, 2
    la   s3, transfer_modes
    add  s3, s3, t2
    lbu  s4, unit_lengths(t1)

    // Decrement the line counter and check if finished
    lbu  v1, ntrlx(s1)
    sll  t1, s1, 2
    lw   s2, a2abx(t1)
    addi v1, v1, -1
    sb   v1, ntrlx(s1)
    andi t1, v1, 0x7F
    bnez t1, same_entry

    // Reload the line counter for the next table entry
    MEM_READ8 0(s2)
    sb   v0, ntrlx(s1)
    addi s2, s2, 1
    sll  t1, s1, 2
    sw   s2, a2abx(t1)
    beqz v0, hdma_disable
    ori  v1, v1, 0x80 // Do transfer

same_entry:
    // Check if a transfer should occur (repeat or first)
    andi t1, v1, 0x80
    beqz t1, hdma_end

    // Check for indirect mode
    lbu  t0, dmapx(s1)
    andi t0, t0, 0x40
    bnez t0, hdma_indir

    // Increment the direct address and start a transfer
    add  t0, s2, s4
    sll  t1, s1, 2
    sh   t0, a2abx + 2(t1)
    b    hdma_ready

hdma_indir:
    // Check if the indirect address should be reloaded
    andi t1, v1, 0x7F
    bnez t1, indir_ready

    // Read the value and increment the direct address
    MEM_READ16 0(s2)
    addi t0, s2, 2
    sll  t1, s1, 2
    sh   t0, a2abx + 2(t1)

    // Reload the indirect address
    lbu  t2, dastbx + 1(t1)
    sll  t2, t2, 16
    or   s2, t2, v0
    sw   s2, dastbx(t1)

indir_ready:
    // Increment the indirect address and start a transfer
    sll  t1, s1, 2
    lw   s2, dastbx(t1)
    add  t0, s2, s4
    sw   t0, dastbx(t1)

hdma_ready:
    // Check the channel's transfer direction
    lbu  t0, dmapx(s1)
    andi t0, t0, 0x80
    bnez t0, hio_cpu

hcpu_io:
    // Copy a value from memory to an I/O register
    MEM_READ8 0(s2)
    sll  t0, s1, 1
    lhu  a0, bbadx(t0)
    lbu  t0, (s3)
    add  a0, a0, t0
    move a1, v0
    jal  io_write8

    // Move to the next byte until a unit has been transferred
    addi s2, s2, 1
    addi s3, s3, 1
    addi s4, s4, -1
    bnez s4, hcpu_io
    b    hdma_end

hio_cpu:
    // Copy a value from an I/O register to memory
    sll  t0, s1, 1
    lhu  a0, bbadx(t0)
    lbu  t0, (s3)
    add  a0, a0, t0
    jal  io_read8
    move a1, v0
    MEM_WRITE8 0(s2)

    // Move to the next byte until a unit has been transferred
    addi s2, s2, 1
    addi s3, s3, 1
    addi s4, s4, -1
    bnez s4, hio_cpu
    b    hdma_end

hdma_disable:
    // Disable an HDMA channel for the rest of the frame
    lbu  t0, hdma_mask
    li   t1, 1
    sll  t1, t1, s1
    xori t1, t1, 0xFF
    and  t0, t0, t1
    sb   t0, hdma_mask

hdma_end:
    // Move to the next channel until no more are enabled
    srl  s0, s0, 1
    addi s1, s1, 1
    bnez s0, hdma_start

    // Pop non-temporary registers from the stack
    lw   ra, 8(sp)
    lw   s4, 4(sp)
    lw   s3, 0(sp)
    addi sp, sp, 12
hdma_skip:
    jr   ra


write_mdmaen: // a1: value
    // Push non-temporary registers to the stack
    addi sp, sp, -20
    sw   a1, 16(sp)
    sw   ra, 12(sp)
    sw   s3, 8(sp)
    sw   s1, 4(sp)
    sw   s0, 0(sp)

    // Set the initial enabled channels (s0) and current channel (s1)
    andi s0, a1, 0xFF
    li   s1, 0

dma_start:
    // Check if the current DMA channel is enabled
    andi t0, s0, 0x1
    beqz t0, dma_end
    lbu  t0, dmapx(s1)

    // Get the channel's CPU address step (s2)
    srl  t1, t0, 3
    andi t1, t1, 0x3
    lb   s2, address_steps(t1)

    // Get the channel's I/O transfer mode (s3)
    andi t1, t0, 0x7
    sll  t1, t1, 2
    la   s3, transfer_modes
    add  s3, s3, t1

    // Check the channel's transfer direction
    andi t0, t0, 0x80
    bnez t0, io_cpu

cpu_io:
    // Read a value from the CPU address and adjust
    sll  t0, s1, 2
    lw   a0, a1tbx(t0)
    MEM_READ8 0(a0)
    add  a0, a0, s2
    sll  t0, s1, 2
    sh   a0, a1tbx + 2(t0)

    // Write the value to the I/O address
    sll  t0, s1, 1
    lhu  a0, bbadx(t0)
    lbu  t0, (s3)
    add  a0, a0, t0
    move a1, v0
    jal  io_write8

    // Move to the next I/O offset in the transfer mode
    andi t0, s3, 0x3
    sub  s3, s3, t0
    addi t0, t0, 1
    andi t0, t0, 0x3
    add  s3, s3, t0

    // Decrement byte counter and continue until it hits zero
    sll  t0, s1, 2
    lhu  t1, dastbx + 2(t0)
    addi t1, t1, -1
    sh   t1, dastbx + 2(t0)
    bnez t1, cpu_io
    b    dma_end

io_cpu:
    // Read a value from the I/O address
    sll  t0, s1, 1
    lhu  a0, bbadx(t0)
    lbu  t0, (s3)
    add  a0, a0, t0
    jal  io_read8

    // Move to the next I/O offset in the transfer mode
    andi t0, s3, 0x3
    sub  s3, s3, t0
    addi t0, t0, 1
    andi t0, t0, 0x3
    add  s3, s3, t0

    // Write the value to the CPU address and adjust
    sll  t0, s1, 2
    lw   a0, a1tbx(t0)
    move a1, v0
    MEM_WRITE8 0(a0)
    add  a0, a0, s2
    sll  t0, s1, 2
    sh   a0, a1tbx + 2(t0)

    // Decrement byte counter and continue until it hits zero
    sll  t0, s1, 2
    lhu  t1, dastbx + 2(t0)
    addi t1, t1, -1
    sh   t1, dastbx + 2(t0)
    bnez t1, io_cpu

dma_end:
    // Move to the next channel until no more are enabled
    srl  s0, s0, 1
    addi s1, s1, 1
    bnez s0, dma_start

    // Pop non-temporary registers from the stack
    lw   a1, 16(sp)
    lw   ra, 12(sp)
    lw   s3, 8(sp)
    lw   s1, 4(sp)
    lw   s0, 0(sp)
    addi sp, sp, 20
    jr   ra


write_hdmaen: // a1: value
    // Write to the HDMAEN register
    sb   a1, hdmaen
    jr   ra


read_dmapx: // a0: address - v0: value
    // Read from one of the DMAPx registers
    srl  t0, a0, 4
    andi t0, t0, 0x7
    lbu  v0, dmapx(t0)
    jr   ra


read_bbadx: // a0: address - v0: value
    // Get the low byte of one of the I/O addresses
    srl  t0, a0, 3
    andi t0, t0, 0xE
    lbu  v0, bbadx + 1(t0)
    jr   ra


read_a1txl: // a0: address - v0: value
    // Get the low byte of one of the CPU addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    lbu  v0, a1tbx + 3(t0)
    jr   ra


read_a1txh: // a0: address - v0: value
    // Get the high byte of one of the CPU addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    lbu  v0, a1tbx + 2(t0)
    jr   ra


read_a1bx: // a0: address - v0: value
    // Get the bank of one of the CPU addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    lbu  v0, a1tbx + 1(t0)
    jr   ra


read_dasxl: // a0: address - v0: value
    // Get the low byte of one of the byte counters
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    lbu  v0, dastbx + 3(t0)
    jr   ra


read_dasxh: // a0: address - v0: value
    // Get the high byte of one of the byte counters
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    lbu  v0, dastbx + 2(t0)
    jr   ra


read_dasbx: // a0: address - v0: value
    // Get the bank of one of the indirect HDMA addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    lbu  v0, dastbx + 1(t0)
    jr   ra


read_a2axl: // a0: address - v0: value
    // Get the low byte of one of the HDMA current addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    lbu  v0, a2abx + 3(t0)
    jr   ra


read_a2axh: // a0: address - v0: value
    // Get the high byte of one of the HDMA current addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    lbu  v0, a2abx + 2(t0)
    jr   ra


read_ntrlx: // a0: address - v0: value
    // Get one of the HDMA line counters
    srl  t0, a0, 4
    andi t0, t0, 0x7
    lbu  v0, ntrlx(t0)
    jr   ra


read_unusedx: // a0: address - v0: value
    // Get one of the unused DMA values
    srl  t0, a0, 4
    andi t0, t0, 0x7
    lbu  v0, unusedx(t0)
    jr   ra


write_dmapx: // a0: address, a1: value
    // Write to one of the DMAPx registers
    srl  t0, a0, 4
    andi t0, t0, 0x7
    sb   a1, dmapx(t0)
    jr   ra


write_bbadx: // a0: address, a1: value
    // Set the low byte of one of the I/O addresses
    srl  t0, a0, 3
    andi t0, t0, 0xE
    sb   a1, bbadx + 1(t0)
    jr   ra


write_a1txl: // a0: address, a1: value
    // Set the low byte of one of the CPU addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    sb   a1, a1tbx + 3(t0)
    jr   ra


write_a1txh: // a0: address, a1: value
    // Set the high byte of one of the CPU addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    sb   a1, a1tbx + 2(t0)
    jr   ra


write_a1bx: // a0: address, a1: value
    // Set the bank of one of the CPU addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    sb   a1, a1tbx + 1(t0)
    jr   ra


write_dasxl: // a0: address, a1: value
    // Set the low byte of one of the byte counters
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    sb   a1, dastbx + 3(t0)
    jr   ra


write_dasxh: // a0: address, a1: value
    // Set the high byte of one of the byte counters
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    sb   a1, dastbx + 2(t0)
    jr   ra


write_dasbx: // a0: address, a1: value
    // Set the bank of one of the indirect HDMA addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    sb   a1, dastbx + 1(t0)
    jr   ra


write_a2axl: // a0: address, a1: value
    // Set the low byte of one of the HDMA current addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    sb   a1, a2abx + 3(t0)
    jr   ra


write_a2axh: // a0: address, a1: value
    // Set the high byte of one of the HDMA current addresses
    srl  t0, a0, 2
    andi t0, t0, 0x1C
    sb   a1, a2abx + 2(t0)
    jr   ra


write_ntrlx: // a0: address, a1: value
    // Set one of the HDMA line counters
    srl  t0, a0, 4
    andi t0, t0, 0x7
    sb   a1, ntrlx(t0)
    jr   ra


write_unusedx: // a0: address, a1: value
    // Set one of the unused DMA values
    srl  t0, a0, 4
    andi t0, t0, 0x7
    sb   a1, unusedx(t0)
    jr   ra
