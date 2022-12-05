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

.globl input_init
.globl input_update
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

.text

input_init:
    // Send the initial joybus command to PIF RAM via DMA
    lui  t0, 0xA480     // SI register upper address
    la   t1, joybus_cmd  // Input buffer
    sw   t1, 0x0000(t0) // SI_DRAM_ADDR
    li   t1, 0x0FC0     // PIF RAM
    sw   t1, 0x0010(t0) // SI_PIF_AD_WR64B
    jr   ra


input_update:
    // Read the output of the joybus command via DMA
    // TODO: fix input breaking after a while on console (???)
    lui  t0, 0xA480     // SI register upper address
    la   t1, joybus_cmd // Output buffer
    sw   t1, 0x0000(t0) // SI_DRAM_ADDR
    li   t1, 0x0FC0     // PIF RAM
    sw   t1, 0x0004(t0) // SI_PIF_AD_RD64B
    jr   ra


read_joyxl: // a0: address
    // Read the button data for the controller
    andi t2, a0, 0x0006
    sll  t2, t2, 2
    lhu  t0, joybus_cmd + 4(t2)

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
    // Read the button data for the controller
    andi t2, a0, 0x0006
    sll  t2, t2, 2
    lhu  t0, joybus_cmd + 4(t2)

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
