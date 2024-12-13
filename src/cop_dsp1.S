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

#include <regdef.h>

.globl read_dsp1sr
.globl read_dsp1dr
.globl write_dsp1dr

.data

.align 4
input_buf: .hword 0:8
output_buf: .hword 0:8

.align 4
cmd_func: .word 0
cmd_count: .word 0
dsp1_sr: .hword 0x8400
dsp1_dr: .hword 0x80
sr_toggle: .byte 0

.align 4
dsp1_cmds: // Lookup table for DSP1 command functions and parameter counts
    .word dsp1_unimp, 0x20001,  dsp1_unimp, 0x40000,  dsp1_unimp, 0x70004,  dsp1_unimp, 0x30003 // 0x00-0x03
    .word dsp1_unimp, 0x20002,  dsp1_unimp, 0x40000,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x10001 // 0x04-0x07
    .word dsp1_unimp, 0x30002,  dsp1_unimp, 0x30003,  dsp1_raster, 0x10004,  dsp1_unimp, 0x30001 // 0x08-0x0B
    .word dsp1_unimp, 0x30002,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x20002,  dsp1_unimp, 0x10001 // 0x0C-0x0F
    .word dsp1_unimp, 0x20002,  dsp1_unimp, 0x40000,  dsp1_unimp, 0x70004,  dsp1_unimp, 0x30003 // 0x10-0x13
    .word dsp1_unimp, 0x60003,  dsp1_unimp, 0x40000,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x10400 // 0x14-0x17
    .word dsp1_unimp, 0x40001,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x00000,  dsp1_unimp, 0x30001 // 0x18-0x1B
    .word dsp1_unimp, 0x60003,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x20002,  dsp1_unimp, 0x10400 // 0x1C-0x1F
    .word dsp1_unimp, 0x20001,  dsp1_unimp, 0x40000,  dsp1_unimp, 0x70004,  dsp1_unimp, 0x30003 // 0x20-0x23
    .word dsp1_unimp, 0x20002,  dsp1_unimp, 0x40000,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x10001 // 0x24-0x27
    .word dsp1_unimp, 0x30001,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x00000,  dsp1_unimp, 0x30001 // 0x28-0x2B
    .word dsp1_unimp, 0x30002,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x20002,  dsp1_unimp, 0x10001 // 0x2C-0x2F
    .word dsp1_unimp, 0x20002,  dsp1_unimp, 0x40000,  dsp1_unimp, 0x70004,  dsp1_unimp, 0x30003 // 0x30-0x33
    .word dsp1_unimp, 0x60003,  dsp1_unimp, 0x40000,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x10400 // 0x34-0x37
    .word dsp1_unimp, 0x40001,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x00000,  dsp1_unimp, 0x30001 // 0x38-0x3B
    .word dsp1_unimp, 0x60003,  dsp1_unimp, 0x30003,  dsp1_unimp, 0x20002,  dsp1_unimp, 0x10400 // 0x3C-0x3F

.text
.set noreorder

.align 5
dsp1_execute: // a0: status
    // Check if the data register is in 8-bit mode, waiting for a command
    andi t0, a0, 0x400 // DRC
    beqz t0, check_input
    move v1, ra

    // Look up and reload a DSP1 command function and its parameter counts
    lbu t0, dsp1_dr + 1
    andi t1, t0, 0xC0
    bnez t1, skip_cmd
    sll t0, t0, 3
    ld t0, dsp1_cmds(t0)
    xori a0, a0, 0x400 // DRC
    sd t0, cmd_func
    sh a0, dsp1_sr
    jr v1

check_input:
    // Do nothing unless the upper byte was accessed
    xori a0, a0, 0x1000 // DRS
    sh a0, dsp1_sr
    andi t0, a0, 0x1000 // DRS
    bnez t0, skip_cmd
    nop

    // Write a value to the input buffer if there's anything to send
    lhu t0, cmd_count + 0
    beqz t0, check_output
    addi t0, t0, -1
    sh t0, cmd_count + 0
    lhu t1, dsp1_dr
    sll t0, t0, 1
    sh t1, input_buf(t0)

    // Execute a command once all input has been sent
    bnez t0, skip_cmd
    nop
loop_cmd:
    lw t0, cmd_func
    jalr t0
    nop

check_output:
    // Read a value from the output buffer if there's anything to receive
    lhu t0, cmd_count + 2
    beqz t0, check_cmd
    addi t0, t0, -1
    sh t0, cmd_count + 2
    sll t0, t0, 1
    andi t0, t0, 0xE
    lhu t1, output_buf(t0)
    sh t1, dsp1_dr
    jr v1
    nop

check_cmd:
    // Check if running a raster command, or if an end value was sent
    lw t0, cmd_func
    la t1, dsp1_raster
    bne t0, t1, finish_cmd
    li t1, 0x8000
    lhu t0, dsp1_dr
    beq t0, t1, finish_cmd
    nop

    // Increment the input and loop the raster command
    lhu t0, input_buf + 0
    li t1, 4
    addi t0, t0, 1
    sh t0, input_buf + 0
    sh t1, cmd_count + 2
    b loop_cmd
    nop

finish_cmd:
    // Report command completion and wait for the next one
    li t0, 0x80
    sh t0, dsp1_dr
    ori a0, a0, 0x400 // DRC
    sh a0, dsp1_sr
skip_cmd:
    jr v1
    nop

.align 5
dsp1_raster:
    // Stub the raster command just to differentiate it
    jr ra
    nop

.align 5
dsp1_unimp:
    // Do nothing for unimplemented DSP1 commands
    jr ra
    nop

.align 5
read_dsp1sr: // v0: value
    // Alternate between reading the status register's low and high bytes
    lbu t0, sr_toggle
    xori t0, t0, 0x1
    sb t0, sr_toggle
    lbu v0, dsp1_sr(t0)
    jr ra
    nop

.align 5
read_dsp1dr: // v0: value
    // Read from the data register's low or high byte and run the DSP1
    lhu a0, dsp1_sr
    andi t0, a0, 0x1000 // DRS
    srl t0, t0, 12
    xori t0, t0, 0x1
    lbu v0, dsp1_dr(t0)
    j dsp1_execute
    nop


.align 5
write_dsp1dr: // a1: value
    // Write to the data register's low or high byte and run the DSP1
    lhu a0, dsp1_sr
    andi t0, a0, 0x1000 // DRS
    srl t0, t0, 12
    xori t0, t0, 0x1
    sb a1, dsp1_dr(t0)
    j dsp1_execute
    nop
