/*
    Copyright 2021 Hydr8gon

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

.globl write_mdmaen
.globl write_dmapx
.globl write_bbadx
.globl write_a1txl
.globl write_a1txh
.globl write_a1bx
.globl write_dasxl
.globl write_dasxh

.data

dmapx: .byte  0x00:8
bbadx: .hword 0x2100:8
a1tbx: .word  0x000000:8
dasx:  .hword 0x0000:8

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

.text

write_mdmaen: // a1: value
    // Backup the return address
    addi sp, sp, -4
    sw   ra, (sp)

    // Set the initial enabled channels (s0) and current channel (s1)
    move s0, a1
    li   s1, 0

dma_start:
    // Check if the current DMA channel is enabled
    andi t0, s0, 1
    beq  t0, zero, dma_end
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
    bne  t0, zero, io_cpu

cpu_io:
    // Read a value from the CPU address and adjust
    sll  t0, s1, 2
    lw   a0, a1tbx(t0)
    jal  memory_read8
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
    sll  t0, s1, 1
    lhu  t1, dasx(t0)
    addi t1, t1, -1
    sh   t1, dasx(t0)
    bne  t1, zero, cpu_io
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
    jal  memory_write8
    add  a0, a0, s2
    sll  t0, s1, 2
    sh   a0, a1tbx + 2(t0)

    // Decrement byte counter and continue until it hits zero
    sll  t0, s1, 1
    lhu  t1, dasx(t0)
    addi t1, t1, -1
    sh   t1, dasx(t0)
    bne  t1, zero, io_cpu
    b    dma_end

dma_end:
    // Move to the next channel until no more are enabled
    srl  s0, s0, 1
    addi s1, s1, 1
    bne  s0, zero, dma_start

    // Restore the return address
    lw   ra, (sp)
    addi sp, sp, 4
    jr   ra


write_dmapx: // a0: address, a1: value
    // Write to one of the DMAPx registers
    srl  t0, a0, 4
    andi t0, t0, 0x7
    sb   a1, dmapx(t0)
    jr   ra


write_bbadx: // a0: address, a1: value
    // Set the low byte of one of the I/O addresses
    srl  t0, a0, 4
    andi t0, t0, 0x7
    sb   a1, bbadx + 1(t0)
    jr   ra


write_a1txl: // a0: address, a1: value
    // Set the low byte of one of the CPU addresses
    srl  t0, a0, 2
    andi t0, t0, 0x7 << 2
    sb   a1, a1tbx + 3(t0)
    jr   ra


write_a1txh: // a0: address, a1: value
    // Set the high byte of one of the CPU addresses
    srl  t0, a0, 2
    andi t0, t0, 0x7 << 2
    sb   a1, a1tbx + 2(t0)
    jr   ra


write_a1bx: // a0: address, a1: value
    // Set the bank of one of the CPU addresses
    srl  t0, a0, 2
    andi t0, t0, 0x7 << 2
    sb   a1, a1tbx + 1(t0)
    jr   ra


write_dasxl: // a0: address, a1: value
    // Set the low byte of one of the byte counters
    srl  t0, a0, 3
    andi t0, t0, 0x7 << 1
    sb   a1, dasx + 1(t0)
    jr   ra


write_dasxh: // a0: address, a1: value
    // Set the high byte of one of the byte counters
    srl  t0, a0, 3
    andi t0, t0, 0x7 << 1
    sb   a1, dasx + 0(t0)
    jr   ra
