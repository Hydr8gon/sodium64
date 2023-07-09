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

.globl fps_toggle

.globl input_init
.globl input_update
.globl read_joyx
.globl read_joyxl
.globl read_joyxh

.data

// Command that reads controller status when copied to PIF RAM
joybus_cmd:
    .dword 0xFF010401FFFFFFFF // Read controller 1
    .dword 0xFF010401FFFFFFFF // Read controller 2
    .dword 0xFF010401FFFFFFFF // Read controller 3
    .dword 0xFF010401FFFFFFFF // Read controller 4
    .dword 0xFE00000000000000 // Finish execution
    .dword 0x0000000000000000 // Nothing
    .dword 0x0000000000000000 // Nothing
    .dword 0x0000000000000001 // Run command

start_hold: .byte 0x01
fps_toggle: .byte 0x00

.text

input_init:
    // Send the initial joybus command to PIF RAM via DMA
    lui  t0, 0xA480     // SI register upper address
    la   t1, joybus_cmd // Input buffer
    sw   t1, 0x0000(t0) // SI_DRAM_ADDR
    li   t1, 0x0FC0     // PIF RAM
    sw   t1, 0x0010(t0) // SI_PIF_AD_WR64B
    jr   ra


input_update:
    // Check if controller 1's start button was pressed
    la   k0, 0x20000002 + joybus_cmd
    lbu  k1, 0(k0)
    andi k1, k1, 0xC0 // Error bits
    bnez k1, start_release
    lbu  k1, 2(k0)
    andi k1, k1, 0x10
    beqz k1, start_release

    // Check if the start button was previously held, and hold it
    la   k0, start_hold
    lbu  k1, (k0)
    bnez k1, joybus_dma
    li   k1, 1
    sb   k1, (k0)

    // Toggle the FPS counter if the start button was newly pressed
    la   k0, fps_toggle
    lbu  k1, (k0)
    xori k1, k1, 0x01
    sb   k1, (k0)
    b    joybus_dma

start_release:
    // Release the start button so it can be pressed again
    la   k0, start_hold
    sb   zero, (k0)

joybus_dma:
    // Read the output of the joybus command via DMA
    lui  k0, 0xA480     // SI register upper address
    la   k1, joybus_cmd // Output buffer
    sw   k1, 0x0000(k0) // SI_DRAM_ADDR
    li   k1, 0x0FC0     // PIF RAM
    sw   k1, 0x0004(k0) // SI_PIF_AD_RD64B
    eret


read_joyx: // a0: address
    // Stub to fix input in games like Donkey Kong Country
    // TODO: actually implement manual controller ports
    li   v0, 0x01
    jr   ra


read_joyxl: // a0: address
    // Check if the controller is connected, and return 0 if not
    andi t2, a0, 0x0006
    sll  t2, t2, 2
    lbu  t0, 0x20000002 + joybus_cmd(t2)
    andi t0, t0, 0xC0 // Error bits
    beqz t0, joyxl_conn
    li   v0, 0
    jr   ra

joyxl_conn:
    // Read the uncached button data for the controller
    lhu  t0, 0x20000004 + joybus_cmd(t2)

    // Map N64 LR to SNES LR
    andi v0, t0, 0x3 << 4

    // Map N64 C-up to SNES X
    andi t1, t0, 0x1 << 3
    sll  t1, t1, 3
    or   v0, v0, t1

    // Map N64 C-right to SNES A
    andi t1, t0, 0x1
    sll  t1, t1, 7
    or   v0, v0, t1
    jr   ra


read_joyxh: // a0: address
    // Check if the controller is connected, and return 0 if not
    andi t2, a0, 0x0006
    sll  t2, t2, 2
    lbu  t0, 0x20000002 + joybus_cmd(t2)
    andi t0, t0, 0xC0 // Error bits
    beqz t0, joyxh_conn
    li   v0, 0
    jr   ra

joyxh_conn:
    // Read the uncached button data for the controller
    lhu  t0, 0x20000004 + joybus_cmd(t2)

    // Map N64 Dpad to SNES Dpad
    srl  t1, t0, 8
    andi v0, t1, 0xF

    // Map N64 A to SNES Start
    andi t1, t0, 0x1 << 15
    srl  t1, t1, 11
    or   v0, v0, t1

    // Map N64 B to SNES Select
    andi t1, t0, 0x1 << 14
    srl  t1, t1, 9
    or   v0, v0, t1

    // Map N64 C-left and C-down to SNES Y and B
    andi t1, t0, 0x3 << 1
    sll  t1, t1, 5
    or   v0, v0, t1
    jr   ra
