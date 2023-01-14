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

.globl sram

.globl memory_init
.globl memory_read8
.globl memory_read16
.globl memory_write8
.globl memory_write16
.globl io_read8
.globl io_write8

.data

sram:       .byte 0:0x2000
wram:       .byte 0:0x20000
empty:      .byte 0:0x2000
memory_map: .word 0:0x800
wmadd:      .word 0x00000

read_iomap:
    .word read_unk:(0x2133 - 0x20FF)                          // 0x2100-0x2133
    .word read_mpyl,   read_mpym,   read_mpyh,   read_unk     // 0x2134-0x2137
    .word read_unk,    read_unk,    read_unk,    read_unk     // 0x2138-0x213B
    .word rand,        rand,        read_unk,    read_unk     // 0x213C-0x213F
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2140-0x2143
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2144-0x2147
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2148-0x214B
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x214C-0x214F
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2150-0x2153
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2154-0x2157
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2158-0x215B
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x215C-0x215F
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2160-0x2163
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2164-0x2167
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2168-0x216B
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x216C-0x216F
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2170-0x2173
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2174-0x2177
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x2178-0x217B
    .word read_apuio0, read_apuio1, read_apuio2, read_apuio3  // 0x217C-0x217F
    .word read_unk:(0x420F - 0x217F)                          // 0x2180-0x420F
    .word read_rdnmi,  read_unk,    read_hvbjoy, read_unk     // 0x4210-0x4213
    .word read_rddivl, read_rddivh, read_rdmpyl, read_rdmpyh  // 0x4214-0x4217
    .word read_joyxl,  read_joyxh,  read_joyxl,  read_joyxh   // 0x4218-0x421B
    .word read_joyxl,  read_joyxh,  read_joyxl,  read_joyxh   // 0x421C-0x421F
    .word read_unk:(0x437F - 0x421F)                          // 0x4220-0x437F

write_iomap:
    .word write_inidisp,  write_obsel,   write_oamaddl, write_oamaddh // 0x2100-0x2103
    .word write_oamdata,  write_bgmode,  write_unk,     write_bg1sc   // 0x2104-0x2107
    .word write_bg2sc,    write_bg3sc,   write_bg4sc,   write_bg12nba // 0x2108-0x210B
    .word write_bg34nba,  write_bg1hofs, write_bg1vofs, write_bg2hofs // 0x210C-0x210F
    .word write_bg2vofs,  write_bg3hofs, write_bg3vofs, write_bg4hofs // 0x2110-0x2113
    .word write_bg4vofs,  write_vmain,   write_vmaddl,  write_vmaddh  // 0x2114-0x2117
    .word write_vmdatal,  write_vmdatah, write_unk,     write_m7a     // 0x2118-0x211B
    .word write_m7b,      write_unk,     write_unk,     write_unk     // 0x211C-0x211F
    .word write_unk,      write_cgadd,   write_cgdata,  write_unk     // 0x2120-0x2123
    .word write_unk:(0x212B - 0x2123)                                 // 0x2124-0x212B
    .word write_tm,       write_ts,      write_unk,     write_unk     // 0x212C-0x212F
    .word write_unk,      write_unk,     write_unk,     write_setini  // 0x2130-0x2133
    .word write_unk:(0x213F - 0x2133)                                 // 0x2134-0x213F
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2140-0x2143
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2144-0x2147
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2148-0x214B
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x214C-0x214F
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2150-0x2153
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2154-0x2157
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2158-0x215B
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x215C-0x215F
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2160-0x2163
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2164-0x2167
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2168-0x216B
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x216C-0x216F
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2170-0x2173
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2174-0x2177
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x2178-0x217B
    .word write_apuio0,   write_apuio1,  write_apuio2,  write_apuio3  // 0x217C-0x217F
    .word write_wmdata,   write_wmaddl,  write_wmaddm,  write_wmaddh  // 0x2180-0x2183
    .word write_unk:(0x41FF - 0x2183)                                 // 0x2184-0x41FF
    .word write_nmitimen, write_unk,     write_wrmpya,  write_wrmpyb  // 0x4200-0x4203
    .word write_wrdivl,   write_wrdivh,  write_wrdivb,  write_unk     // 0x4204-0x4207
    .word write_unk,      write_unk,     write_unk,     write_mdmaen  // 0x4208-0x420B
    .word write_unk:(0x42FF - 0x420B)                                 // 0x420C-0x42FF
    .word write_dmapx,    write_bbadx,   write_a1txl,   write_a1txh   // 0x4300-0x4303
    .word write_a1bx,     write_dasxl,   write_dasxh,   write_unk     // 0x4304-0x4307
    .word write_unk:(0x430F - 0x4307)                                 // 0x4308-0x430F
    .word write_dmapx,    write_bbadx,   write_a1txl,   write_a1txh   // 0x4310-0x4313
    .word write_a1bx,     write_dasxl,   write_dasxh,   write_unk     // 0x4314-0x4317
    .word write_unk:(0x431F - 0x4317)                                 // 0x4318-0x431F
    .word write_dmapx,    write_bbadx,   write_a1txl,   write_a1txh   // 0x4320-0x4323
    .word write_a1bx,     write_dasxl,   write_dasxh,   write_unk     // 0x4324-0x4327
    .word write_unk:(0x432F - 0x4327)                                 // 0x4328-0x432F
    .word write_dmapx,    write_bbadx,   write_a1txl,   write_a1txh   // 0x4330-0x4333
    .word write_a1bx,     write_dasxl,   write_dasxh,   write_unk     // 0x4334-0x4337
    .word write_unk:(0x433F - 0x4337)                                 // 0x4338-0x433F
    .word write_dmapx,    write_bbadx,   write_a1txl,   write_a1txh   // 0x4340-0x4343
    .word write_a1bx,     write_dasxl,   write_dasxh,   write_unk     // 0x4344-0x4347
    .word write_unk:(0x434F - 0x4347)                                 // 0x4348-0x434F
    .word write_dmapx,    write_bbadx,   write_a1txl,   write_a1txh   // 0x4350-0x4353
    .word write_a1bx,     write_dasxl,   write_dasxh,   write_unk     // 0x4354-0x4357
    .word write_unk:(0x435F - 0x4357)                                 // 0x4358-0x435F
    .word write_dmapx,    write_bbadx,   write_a1txl,   write_a1txh   // 0x4360-0x4363
    .word write_a1bx,     write_dasxl,   write_dasxh,   write_unk     // 0x4364-0x4367
    .word write_unk:(0x436F - 0x4367)                                 // 0x4368-0x436F
    .word write_dmapx,    write_bbadx,   write_a1txl,   write_a1txh   // 0x4370-0x4373
    .word write_a1bx,     write_dasxl,   write_dasxh,   write_unk     // 0x4374-0x4377
    .word write_unk:(0x437F - 0x4377)                                 // 0x4378-0x437F

.text

memory_init:
    // Copy a ROM appended to the file into memory
    // TODO: support more than 3MB
    la   t0, 0xB0104000 // ROM appended to file
    la   t1, 0x80090000 // ROM buffer start
    la   t2, 0x80390000 // ROM buffer end
rom_loop:
    lw   t3, (t0)
    addi t0, t0, 4
    sw   t3, (t1)
    addi t1, t1, 4
    bne  t1, t2, rom_loop

    // Detect HiROM headers with a rudimentary checksum check
    // TODO: improve this?
    lhu  t0, 0x8009FFDC
    lhu  t1, 0x8009FFDE
    xor  t0, t0, t1
    xori t0, t0, 0xFFFF
    beqz t0, map_hirom
    b    map_lorom


map_lorom:
    // Set initial values for building the memory map
    li   t0, 0x000000 // Current address
    li   t1, 0xFFFFFF // Maximum address
    li   t2, 0x002000 // Block size (8KB)

build_lomap:
    // Determine the LoROM memory area from the address bank
    li   t3, 0x400000
    blt  t0, t3, losys_area  // 0x00-0x3F: System, WS1 LoROM
    li   t3, 0x700000
    blt  t0, t3, lorom_area  // 0x40-0x6F: WS1 LoROM
    li   t3, 0x7E0000
    blt  t0, t3, losram_area // 0x70-0x7D: 8KB SRAM, WS1 LoROM
    li   t3, 0x800000
    li   t4, 0x1FFFF         // WRAM mask
    blt  t0, t3, lowram_area // 0x7E-0x7F: 128KB WRAM
    li   t3, 0xC00000
    blt  t0, t3, losys_area  // 0x80-0xBF: System, WS2 LoROM
    li   t3, 0xF00000
    blt  t0, t3, lorom_area  // 0xC0-0xEF: WS2 LoROM
    b    losram_area         // 0xF0-0xFF: 8KB SRAM, WS2 LoROM

losys_area:
    // Further break down the 16-bit system area address
    andi t3, t0, 0xFFFF
    li   t4, 0x1FFF          // WRAM mask
    blt  t3, t2, lowram_area // 0x0000-0x1FFF: 8KB WRAM mirror
    li   t4, 0x8000
    bge  t3, t4, lorom_area  // 0x8000-0xFFFF: WS1/WS2 LoROM
    b    loio_area           // 0x2000-0x7FFF: I/O registers

lowram_area:
    // Get a pointer to a WRAM block, with bit 0 set to indicate writability
    la   t3, wram
    and  t4, t4, t0 // Apply mask
    add  t3, t3, t4 
    ori  t3, t3, 1  // Write bit
    b    map_loblock

lorom_area:
    // Get a pointer to a ROM block mapped as LoROM
    la   t3, 0x80090000 // ROM buffer
    li   t4, 0x7F0000
    and  t4, t4, t0     // Mirrored bank
    srl  t4, t4, 1      // 32KB every 64KB bank
    add  t3, t3, t4
    li   t4, 0x7FFF
    and  t4, t4, t0     // Offset within 32KB
    add  t3, t3, t4
    la   t4, 0x80390000 // ROM bounds
    bge  t3, t4, loempty_area
    b    map_loblock

losram_area:
    // Get a pointer to a SRAM block mapped as LoROM
    andi t4, t0, 0xFFFF
    li   t5, 0x8000
    bge  t4, t5, lorom_area // 0x8000-0xFFFF: WS1/WS2 LoROM
    andi t4, t4, 0x1FFF
    la   t3, sram
    add  t3, t3, t4         // 0x0000-0x7FFF: 8KB SRAM
    ori  t3, t3, 1          // Write bit
    b    map_loblock

loio_area:
    // Set no pointer; this will fall back to I/O registers
    li   t3, 0
    b    map_loblock

loempty_area:
    // Get a pointer to the empty placeholder block
    la   t3, empty

map_loblock:
    // Store the pointer to the block in the memory map
    la   t4, memory_map
    srl  t5, t0, 11 // Pointer offset
    add  t4, t4, t5
    sw   t3, (t4)

    // Move to the next address until the map is complete
    add  t0, t0, t2
    ble  t0, t1, build_lomap
    jr   ra


map_hirom:
    // Set initial values for building the memory map
    li   t0, 0x000000 // Current address
    li   t1, 0xFFFFFF // Maximum address
    li   t2, 0x002000 // Block size (8KB)

build_himap:
    // Determine the HiROM memory area from the address bank
    li   t3, 0x400000
    blt  t0, t3, hisys_area  // 0x00-0x3F: System, WS1 HiROM
    li   t3, 0x7E0000
    blt  t0, t3, hirom_area  // 0x40-0x7D: WS1 HiROM
    li   t3, 0x800000
    li   t4, 0x1FFFF         // WRAM mask
    blt  t0, t3, hiwram_area // 0x7E-0x7F: 128KB WRAM
    li   t3, 0xC00000
    blt  t0, t3, hisys_area  // 0x80-0xBF: System, WS2 HiROM
    b    hirom_area          // 0xC0-0xFF: WS2 HiROM

hisys_area:
    // Further break down the 16-bit system area address
    andi t3, t0, 0xFFFF
    li   t4, 0x1FFF          // WRAM mask
    blt  t3, t2, hiwram_area // 0x0000-0x1FFF: 8KB WRAM mirror
    li   t4, 0x8000
    bge  t3, t4, hirom_area  // 0x8000-0xFFFF: WS1/WS2 HiROM
    li   t4, 0x6000
    bge  t3, t4, hisram_area // 0x6000-0x7FFF: 8KB SRAM
    b    hiio_area           // 0x2000-0x5FFF: I/O registers

hiwram_area:
    // Get a pointer to a WRAM block, with bit 0 set to indicate writability
    la   t3, wram
    and  t4, t4, t0 // Apply mask
    add  t3, t3, t4
    ori  t3, t3, 1  // Write bit
    b    map_hiblock

hirom_area:
    // Get a pointer to a ROM block mapped as HiROM
    la   t3, 0x80090000 // ROM buffer
    li   t4, 0x3FFFFF   // ROM mask
    and  t4, t4, t0
    add  t3, t3, t4
    la   t4, 0x80390000 // ROM bounds
    bge  t3, t4, hiempty_area
    b    map_hiblock

hisram_area:
    // Get a pointer to a SRAM block mapped as HiROM
    andi t4, t0, 0x1FFF
    la   t3, sram
    add  t3, t3, t4 // 8KB SRAM
    ori  t3, t3, 1  // Write bit
    b    map_hiblock

hiio_area:
    // Set no pointer; this will fall back to I/O registers
    li   t3, 0
    b    map_hiblock

hiempty_area:
    // Get a pointer to the empty placeholder block
    la   t3, empty

map_hiblock:
    // Store the pointer to the block in the memory map
    la   t4, memory_map
    srl  t5, t0, 11 // Pointer offset
    add  t4, t4, t5
    sw   t3, (t4)

    // Move to the next address until the map is complete
    add  t0, t0, t2
    ble  t0, t1, build_himap
    jr   ra


memory_read8: // a0: address - v0: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    addi s5, s5, -6   // Base cycle decrement
    beqz t0, io_read8 // I/O register fallback

    // Clear the write bit before using the pointer
    li   t1, ~1
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Read a byte from memory and decrease the cycle count
    lbu  v0, 0(t0)
    addi s5, s5, -2
    jr   ra


memory_read16: // a0: address - v0: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    addi s5, s5, -6 * 2 // Base cycle decrement
    beqz t0, io_read16  // I/O register fallback

    // Clear the write bit before using the pointer
    li   t1, ~1
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Read two bytes from memory and decrease the cycle count
    lbu  v0, 0(t0)
    lbu  t0, 1(t0)
    addi s5, s5, -2 * 2
    sll  t0, t0, 8
    or   v0, v0, t0
    jr   ra

io_read16:
    // Backup the return address
    addi sp, sp, -8
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
    addi sp, sp, 8
    jr   ra


memory_write8: // a0: address, a1: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    addi s5, s5, -6    // Base cycle decrement
    beqz t0, io_write8 // I/O register fallback

    // Ensure the block is writable
    andi t1, t0, 1
    bnez t1, can_write8
    jr   ra

can_write8:
    // Clear the write bit before using the pointer
    li   t1, ~1
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Write a byte to memory and decrease the cycle count
    sb   a1, 0(t0)
    addi s5, s5, -2
    jr   ra


memory_write16: // a0: address, a1: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    addi s5, s5, -6 * 2 // Base cycle decrement
    beqz t0, io_write16 // I/O register fallback

    // Ensure the block is writable
    andi t1, t0, 1
    bnez t1, can_write16
    jr   ra

can_write16:
    // Clear the write bit before using the pointer
    li   t1, ~1
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Write two bytes to memory and decrease the cycle count
    sb   a1, 0(t0)
    srl  t1, a1, 8
    sb   t1, 1(t0)
    addi s5, s5, -2 * 2
    jr   ra

io_write16:
    // Backup the return address and value
    addi sp, sp, -16
    sw   ra, 8(sp)
    sw   a1, 0(sp)

    // Write two 8-bit values to the I/O registers
    jal  io_write8
    addi a0, a0, 1
    srl  a1, a1, 8
    jal  io_write8
    addi a0, a0, -1

    // Restore the return address and value
    lw   a1, 0(sp)
    lw   ra, 8(sp)
    addi sp, sp, 16
    jr   ra


io_read8: // a0: address - v0: value
    // Read from an I/O register in the lookup table
    andi a0, a0, 0xFFFF
    addi t0, a0, -0x2100
    bgeu t0, 0x4380 - 0x2100, read_unk
    sll  t0, t0, 2 // Word offset
    lw   t0, read_iomap(t0)
    jr   t0

read_unk:
    // Unknown I/O register read; do nothing
    li   v0, 0
    jr   ra


io_write8: // a0: address, a1: value
    // Write to an I/O register in the lookup table
    andi a0, a0, 0xFFFF
    addi t0, a0, -0x2100
    bgeu t0, 0x4380 - 0x2100, write_unk
    sll  t0, t0, 2 // Word offset
    lw   t0, write_iomap(t0)
    jr   t0

write_unk:
    // Unknown I/O register write; do nothing
    jr   ra


write_wmdata: // a1: value
    // Increment the WRAM address
    lw   t0, wmadd
    addi t1, t0, 1
    li   t2, 0x1FFFF
    and  t1, t1, t2
    sw   t1, wmadd

    // Write a byte to WRAM
    sb   a1, wram(t0)
    jr   ra


write_wmaddl: // a1: value
    // Set the low byte of the WRAM address
    sb   a1, wmadd + 3
    jr   ra


write_wmaddm: // a1: value
    // Set the middle byte of the WRAM address
    sb   a1, wmadd + 2
    jr   ra


write_wmaddh: // a1: value
    // Set the high bit of the WRAM address
    andi t0, a1, 0x01
    sb   t0, wmadd + 1
    jr   ra
