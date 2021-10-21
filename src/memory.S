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

.globl memory_init
.globl memory_read8
.globl memory_read16
.globl memory_write8
.globl memory_write16
.globl io_read8
.globl io_write8

.data

rom: .incbin "rom.sfc"
wram: .byte 0:0x20000
memory_map: .word 0:0x800

.text

memory_init:
    // Set initial values for building the memory map
    li   t0, 0x000000 // Current address
    li   t1, 0xFFFFFF // Maximum address
    li   t2, 0x002000 // Block size (8KB)

    // Determine the memory area from the address bank
build_map:
    li   t3, 0x400000
    blt  t0, t3, system_area // 0x00-0x3F: System, WS1 LoROM
    li   t3, 0x7E0000
    blt  t0, t3, hirom_area  // 0x40-0x7D: WS1 HiROM
    li   t3, 0x800000
    li   t4, 0x1FFFF         // WRAM mask
    blt  t0, t3, wram_area   // 0x7E-0x7F: 128KB WRAM
    li   t3, 0xC00000
    blt  t0, t3, system_area // 0x80-0xBF: System, WS2 LoROM
    b    hirom_area          // 0xC0-0xFF: WS2 HiROM

    // Further break down the 16-bit system area address
system_area:
    andi t3, t0, 0xFFFF
    li   t4, 0x1FFF         // WRAM mask
    blt  t3, t2, wram_area  // 0x0000-0x1FFF: 8KB WRAM mirror
    li   t4, 0x8000
    bge  t3, t4, lorom_area // 0x8000-0xFFFF: WS1/WS2 LoROM
    b    empty_area         // Fallback for I/O registers

    // Get a pointer to a WRAM block, with bit 0 set to indicate writability
wram_area:
    la   t3, wram
    and  t4, t4, t0 // Apply mask
    add  t3, t3, t4 
    ori  t3, t3, 1  // Write bit
    b    map_block

    // Get a pointer to a ROM block mapped as LoROM
lorom_area:
    la   t3, rom
    li   t4, 0x3F0000
    and  t4, t4, t0 // Mirrored bank
    srl  t4, t4, 1  // 32KB every 64KB bank
    add  t3, t3, t4
    li   t4, 0x7FFF
    and  t4, t4, t0 // Offset within 32KB
    add  t3, t3, t4
    la   t4, wram   // ROM bounds
    bge  t3, t4, empty_area
    b    map_block

hirom_area: // TODO
empty_area:
    li   t3, 0

map_block:
    // Store the pointer to the block in the memory map
    la   t4, memory_map
    srl  t5, t0, 11 // Pointer offset
    add  t4, t4, t5
    sw   t3, (t4)

    // Move to the next address until the map is complete
    add  t0, t0, t2
    ble  t0, t1, build_map
    jr   ra


memory_read8: // a0: address - v0: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    beq  t0, zero, io_read8 // I/O register fallback

    // Clear the write bit before using the pointer
    li   t1, ~1
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Read a byte from memory and decrease the cycle count
    lbu  v0, 0(t0)
    addi s5, s5, -8
    jr   ra


memory_read16: // a0: address - v0: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    beq  t0, zero, io_read16 // I/O register fallback

    // Clear the write bit before using the pointer
    li   t1, ~1
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Read two bytes from memory and decrease the cycle count
    lbu  v0, 0(t0)
    lbu  t0, 1(t0)
    sll  t0, t0, 8
    or   v0, v0, t0
    addi s5, s5, -8 * 2
    jr   ra

io_read16:
    // Backup the return address
    addi sp, sp, -4
    sw   ra, (sp)

    // Read two 8-bit values from the I/O registers
    jal  io_read8
    move s1, v0
    addi a0, a0, 1
    jal  io_read8
    addi a0, a0, -1
    sll  v0, v0, 8
    or   v0, v0, s1

    // Restore the return address
    lw   ra, (sp)
    addi sp, sp, 4
    jr   ra


memory_write8: // a0: address, a1: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    beq  t0, zero, io_write8 // I/O register fallback

    // Ensure the block is writable
    andi t1, t0, 1
    bne  t1, zero, can_write8
    addi s5, s5, -6
    jr   ra

    // Clear the write bit before using the pointer
can_write8:
    li   t1, ~1
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Write a byte to memory and decrease the cycle count
    sb   a1, 0(t0)
    addi s5, s5, -8
    jr   ra


memory_write16: // a0: address, a1: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    beq  t0, zero, io_write16 // I/O register fallback

    // Ensure the block is writable
    andi t1, t0, 1
    bne  t1, zero, can_write16
    addi s5, s5, -6 * 2
    jr   ra

    // Clear the write bit before using the pointer
can_write16:
    li   t1, ~1
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Write two bytes to memory and decrease the cycle count
    sb   a1, 0(t0)
    srl  t1, a1, 8
    sb   t1, 1(t0)
    addi s5, s5, -8 * 2
    jr   ra

io_write16:
    // Backup the return address and value
    addi sp, sp, -8
    sw   ra, 4(sp)
    sw   a1, 0(sp)

    // Write two 8-bit values to the I/O registers
    jal  io_write8
    addi a0, a0, 1
    srl  a1, a1, 8
    jal  io_write8
    addi a0, a0, -1

    // Restore the return address and value
    lw   a1, 0(sp)
    lw   ra, 4(sp)
    addi sp, sp, 8
    jr   ra


io_read8: // a0: address - v0: value
    // Read from an I/O register if it exists and decrease the cycle count
    // TODO: convert to lookup table
    addi s5, s5, -6
    andi a0, a0, 0xFFFF
    beq  a0, 0x2140, rand // APUI00 "stub"
    beq  a0, 0x2141, rand // APUI01 "stub"
    beq  a0, 0x2142, rand // APUI02 "stub"
    beq  a0, 0x2143, rand // APUI03 "stub"
    beq  a0, 0x4210, read_rdnmi
    beq  a0, 0x4212, read_hvbjoy
    beq  a0, 0x4218, read_joy1l
    beq  a0, 0x4219, read_joy1h
    li   v0, 0
    jr   ra


io_write8: // a0: address, a1: value
    // Write to an I/O register if it exists and decrease the cycle count
    // TODO: convert to lookup table
    addi s5, s5, -6
    andi a0, a0, 0xFFFF
    beq  a0, 0x2105, write_bgmode
    beq  a0, 0x2107, write_bg1sc
    beq  a0, 0x2108, write_bg2sc
    beq  a0, 0x2109, write_bg3sc
    beq  a0, 0x210A, write_bg4sc
    beq  a0, 0x210B, write_bg12nba
    beq  a0, 0x210C, write_bg34nba
    beq  a0, 0x210D, write_bg1hofs
    beq  a0, 0x210E, write_bg1vofs
    beq  a0, 0x210F, write_bg2hofs
    beq  a0, 0x2110, write_bg2vofs
    beq  a0, 0x2111, write_bg3hofs
    beq  a0, 0x2112, write_bg3vofs
    beq  a0, 0x2113, write_bg4hofs
    beq  a0, 0x2114, write_bg4vofs
    beq  a0, 0x2115, write_vmain
    beq  a0, 0x2116, write_vmaddl
    beq  a0, 0x2117, write_vmaddh
    beq  a0, 0x2118, write_vmdatal
    beq  a0, 0x2119, write_vmdatah
    beq  a0, 0x2121, write_cgadd
    beq  a0, 0x2122, write_cgdata
    beq  a0, 0x212C, write_tm
    beq  a0, 0x212D, write_ts
    beq  a0, 0x4200, write_nmitimen
    beq  a0, 0x420B, write_mdmaen
    andi t0, a0, 0xFF8F
    beq  t0, 0x4300, write_dmapx
    beq  t0, 0x4301, write_bbadx
    beq  t0, 0x4302, write_a1txl
    beq  t0, 0x4303, write_a1txh
    beq  t0, 0x4304, write_a1bx
    beq  t0, 0x4305, write_dasxl
    beq  t0, 0x4306, write_dasxh
    jr   ra
