/*
    Copyright 2021-2025 Hydr8gon

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

.globl input_init
.globl input_update
.globl input_flush
.globl get_pressed
.globl read_joya
.globl read_joyb
.globl read_joyxl
.globl read_joyxh
.globl write_joywr

.data

.align 4
joyxlh: .hword 0:4
joy_shifts: .hword 0
btn_state: .byte 0xFF

.align 4
joybus_cmd: // Reads controller status when copied to PIF RAM
    .dword 0xFF010401FFFFFFFF // Read controller 1
    .dword 0xFF010401FFFFFFFF // Read controller 2
    .dword 0xFF010401FFFFFFFF // Read controller 3
    .dword 0xFF010401FFFFFFFF // Read controller 4
    .dword 0xFE00000000000000 // Finish execution
    .dword 0x0000000000000000 // Nothing
    .dword 0x0000000000000000 // Nothing
    .dword 0x0000000000000001 // Run command

.text
.set noreorder

.align 5
input_init:
    // Send the initial joybus command to PIF RAM via DMA
    lui t0, 0xA480 // SI register upper address
    la t1, joybus_cmd // Input buffer
    sw t1, 0x0000(t0) // SI_DRAM_ADDR
    li t1, 0x000007C0 // PIF RAM
    jr ra
    sw t1, 0x0010(t0) // SI_PIF_AD_WR64B

.align 5
input_update:
    // Read the output of the joybus command via DMA
    lui k0, 0xA480 // SI register upper address
    la k1, joybus_cmd // Output buffer
    sw k1, 0x0000(k0) // SI_DRAM_ADDR
    li k1, 0x000007C0 // PIF RAM
    sw k1, 0x0004(k0) // SI_PIF_AD_RD64B
    eret

.align 5
input_flush:
    // Prepare to loop through 4 controllers
    li a0, 6

flush_loop:
    // Check if a controller is connected, and skip it if not
    sll t2, a0, 2
    lbu t0, UNCACHED(joybus_cmd + 2)(t2)
    andi t0, t0, 0xC0 // Error bits
    beqz t0, joyx_conn
    nop
    sh zero, joyxlh(a0)
    b flush_next
    nop

joyx_conn:
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

    // Map N64 D-pad to SNES D-pad
    andi t1, t0, 0xF00
    or v0, v0, t1

    // Map N64 A to SNES Start
    andi t1, t0, 0x8000
    srl t1, t1, 3
    or v0, v0, t1

    // Map N64 B to SNES Select
    andi t1, t0, 0x4000
    srl t1, t1, 1
    or v0, v0, t1

    // Map N64 C-left and C-down to SNES Y and B
    andi t1, t0, 0x6
    sll t1, t1, 13
    or v0, v0, t1

    // Write mapped data to the SNES registers
    sh v0, joyxlh(a0)

flush_next:
    // Move to the next controller or return if finished
    beqz a0, flush_end
    addi a0, a0, -2
    b flush_loop
    nop
flush_end:
    jr ra
    nop

.align 5
get_pressed: // v0: button mask
    // Check if controller 1 is connected
    lbu t1, UNCACHED(joybus_cmd + 2)
    andi t1, t1, 0xC0 // Error bits
    bnez t1, end_pressed
    li v0, 0

    // Get the newly-pressed state of certain buttons
    lbu t0, btn_state
    lbu t1, UNCACHED(joybus_cmd + 4)
    xori t0, t0, 0xFF
    and v0, t0, t1
    sb t1, btn_state
end_pressed:
    jr ra
    nop

.align 5
read_done: // v0: value
    // Return high bits once manual reading is done to indicate a connected controller
    jr ra
    li v0, 0x3

.align 5
read_joya: // v0: value
    // Get the controller 1 and 3 states and increment their shift
    lbu t0, joy_shifts + 0
    lhu t1, joyxlh + 0
    lhu t2, joyxlh + 4
    slti t3, t0, 16
    beqz t3, read_done
    add t0, t0, t3
    sb t0, joy_shifts + 0

    // Shift out one bit for each controller and return them
    sll t1, t1, t0
    srl t1, t1, 16
    andi t1, t1, 0x1
    sll t2, t2, t0
    srl t2, t2, 15
    andi t2, t2, 0x2
    jr ra
    or v0, t1, t2

read_joyb: // v0: value
    // Get the controller 2 and 4 states and increment their shift
    lbu t0, joy_shifts + 1
    lhu t1, joyxlh + 2
    lhu t2, joyxlh + 6
    slti t3, t0, 16
    beqz t3, read_done
    add t0, t0, t3
    sb t0, joy_shifts + 1

    // Shift out one bit for each controller and return them
    sll t1, t1, t0
    srl t1, t1, 16
    andi t1, t1, 0x1
    sll t2, t2, t0
    srl t2, t2, 15
    andi t2, t2, 0x2
    jr ra
    or v0, t1, t2

.align 5
read_joyxl: // a0: address - v0: value
    // Read from one of the JOYxL registers
    andi t0, a0, 0x6
    lbu v0, joyxlh + 1(t0)
    jr ra
    nop

.align 5
read_joyxh: // a0: address - v0: value
    // Read from one of the JOYxH registers
    andi t0, a0, 0x6
    lbu v0, joyxlh + 0(t0)
    jr ra
    nop

write_joywr: // a1: value
    // Reset manual controller reads if the strobe bit is set
    andi t0, a1, 0x1
    beqz t0, joywr_skip
    nop
    sh zero, joy_shifts
joywr_skip:
    jr ra
    nop
