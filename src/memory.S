#include <regdef.h>

.globl memory_init
.globl memory_read8
.globl memory_read16
.globl memory_write8
.globl memory_write16

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
    beq  t0, zero, io_read // I/O register fallback

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

    // Read from I/O registers twice
io_read16:
    move s0, ra
    jal  io_read
    move s1, v0
    addi a0, a0, 1
    jal  io_read
    addi a0, a0, -1
    sll  v0, v0, 8
    or   v0, v0, s1
    jr   s0


memory_write8: // a0: address, a1: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    beq  t0, zero, io_write // I/O register fallback

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
    srl  a1, a1, 8
    sb   a1, 1(t0)
    addi s5, s5, -8 * 2
    jr   ra

    // Write to I/O registers twice
io_write16:
    move s0, ra
    jal  io_write
    addi a0, a0, 1
    srl  a1, a1, 8
    jal  io_write
    addi a0, a0, -1
    jr   s0


io_read: // a0: address - v0: value
    // Read from an I/O register if it exists and decrease the cycle count
    // TODO: convert to lookup table
    addi s5, s5, -6
    beq  a0, 0x4212, read_hvbjoy
    li   v0, 0
    jr   ra


io_write: // a0: address, a1: value
    // Write to an I/O register if it exists and decrease the cycle count
    // TODO: convert to lookup table
    addi s5, s5, -6
    beq  a0, 0x2105, write_bgmode
    beq  a0, 0x2107, write_bg1sc
    beq  a0, 0x210B, write_bg12nba
    beq  a0, 0x210E, write_bg1vofs
    beq  a0, 0x2116, write_vmaddl
    beq  a0, 0x2117, write_vmaddh
    beq  a0, 0x2118, write_vmdatal
    beq  a0, 0x2119, write_vmdatah
    beq  a0, 0x2121, write_cgadd
    beq  a0, 0x2122, write_cgdata
    beq  a0, 0x4200, write_nmitimen
    jr   ra
