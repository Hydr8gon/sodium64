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

.globl btn_toggle

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

btn_state: .byte 0x30
btn_toggle: .byte 0

.text

.align 5
input_init:
    // Send the initial joybus command to PIF RAM via DMA
    lui t0, 0xA480 // SI register upper address
    la t1, joybus_cmd // Input buffer
    sw t1, 0x0000(t0) // SI_DRAM_ADDR
    li t1, 0x000007C0 // PIF RAM
    sw t1, 0x0010(t0) // SI_PIF_AD_WR64B
    jr ra

.align 5
input_update:
    // Check if controller 1 is connected
    la k0, UNCACHED(joybus_cmd + 2)
    lbu k1, 0(k0)
    andi k1, k1, 0xC0 // Error bits
    bnez k1, joybus_dma

    // Get the newly-pressed state for button toggles
    lbu k1, 2(k0)
    la k0, btn_state
    lbu k0, (k0)
    xori k0, k0, 0x30
    and k0, k0, k1

    // Toggle bits whose buttons were newly pressed
    la k1, btn_toggle
    lbu k1, (k1)
    xor k0, k0, k1
    la k1, btn_toggle
    sb k0, (k1)

    // Save the current pressed state for next frame
    la k0, UNCACHED(joybus_cmd + 2)
    lbu k1, 2(k0)
    la k0, btn_state
    andi k1, k1, 0x30
    sb k1, (k0)

joybus_dma:
    // Read the output of the joybus command via DMA
    lui k0, 0xA480 // SI register upper address
    la k1, joybus_cmd // Output buffer
    sw k1, 0x0000(k0) // SI_DRAM_ADDR
    li k1, 0x000007C0 // PIF RAM
    sw k1, 0x0004(k0) // SI_PIF_AD_RD64B
    eret

.align 5
read_joyx: // a0: address
    // Stub to fix input in games like Donkey Kong Country
    // TODO: actually implement manual controller ports
    li v0, 0x1
    jr ra

.align 5
read_joyxl: // a0: address
    // Check if the controller is connected, and return 0 if not
    andi t2, a0, 0x6
    sll t2, t2, 2
    lbu t0, UNCACHED(joybus_cmd + 2)(t2)
    andi t0, t0, 0xC0 // Error bits
    beqz t0, joyxl_conn
    li v0, 0
    jr ra

joyxl_conn:
    // Read button data for the controller
    lhu t0, UNCACHED(joybus_cmd + 4)(t2)

    // Map N64 LR to SNES LR
    andi v0, t0, 0x30

    // Map N64 C-up to SNES X
    andi t1, t0, 0x8
    sll t1, t1, 3
    or v0, v0, t1

    // Map N64 C-right to SNES A
    andi t1, t0, 0x1
    sll t1, t1, 7
    or v0, v0, t1
    jr ra

.align 5
read_joyxh: // a0: address
    // Check if the controller is connected, and return 0 if not
    andi t2, a0, 0x6
    sll t2, t2, 2
    lbu t0, UNCACHED(joybus_cmd + 2)(t2)
    andi t0, t0, 0xC0 // Error bits
    beqz t0, joyxh_conn
    li v0, 0
    jr ra

joyxh_conn:
    // Read button data for the controller
    lhu t0, UNCACHED(joybus_cmd + 4)(t2)

    // Map N64 D-pad to SNES D-pad
    srl t1, t0, 8
    andi v0, t1, 0xF

    // Map N64 A to SNES Start
    andi t1, t0, 0x8000
    srl t1, t1, 11
    or v0, v0, t1

    // Map N64 B to SNES Select
    andi t1, t0, 0x4000
    srl t1, t1, 9
    or v0, v0, t1

    // Map N64 C-left and C-down to SNES Y and B
    andi t1, t0, 0x6
    sll t1, t1, 5
    or v0, v0, t1
    jr ra
