#include <regdef.h>

.globl memory_init
.globl memory_read
.globl memory_write

.data
    rom: .incbin "rom.sfc"
    wram: .space 0x20000
    memory_map: .space 0x800 * 4

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


memory_read: // a0: address, a1: 16-bit toggle - v0: cycles, v1: value
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    beq  t0, zero, io_read // I/O register fallback

    // Clear the write bit before using the pointer
    li   t1, 0xFFFFFFFE
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Read a value from the resulting memory address
    lb   t1, 0(t0)
    beq  a1, zero, end_read // 8-bit
    lb   t2, 1(t0)
    sll  t2, t2, 8
    or   t1, t1, t2

    // Return the read value and cycle count
end_read:
    li   v0, 8
    move v1, t1
    jr   ra

io_read: // TODO
    li   v0, 6
    li   v1, 0
    jr   ra


memory_write: // a0: address, a1: 16-bit toggle, a2: value - v0: cycles
    // Get the pointer to the block from the memory map
    srl  t0, a0, 13
    sll  t0, t0, 2
    la   t1, memory_map
    add  t0, t0, t1
    lw   t0, (t0)
    beq  t0, zero, io_write // I/O register fallback

    // Ensure the block is writable
    andi t1, t0, 1
    bne  t1, zero, can_write
    li   v0, 6
    jr   ra

    // Clear the write bit before using the pointer
can_write:
    li   t1, 0xFFFFFFFE
    and  t0, t0, t1

    // Apply the offset within the 8KB block
    andi t1, a0, 0x1FFF
    add  t0, t0, t1

    // Write a value to the resulting memory address
    sb   a2, 0(t0)
    beq  a1, zero, end_write // 8-bit
    srl  a2, a2, 8
    sb   a2, 1(t0)

    // Return the cycle count
end_write:
    li   v0, 8
    jr   ra

io_write: // TODO
    li   v0, 6
    jr   ra
