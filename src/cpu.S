#include <regdef.h>

.globl cpu_init
.globl cpu_execute

.data

accumulator: .hword 0x0000
register_x:  .hword 0x0000
register_y:  .hword 0x0000
stack_ptr:   .hword 0x01FF
status_flgs: .hword 0x0100
direct_ofs:  .hword 0x0000
data_bank:   .byte  0x00

opcodes_emu: // Lookup table for 6502 emulation mode
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x00-0x0F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x10-0x1F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x20-0x2F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x30-0x3F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x40-0x4F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x50-0x5F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x60-0x6F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x70-0x7F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x80-0x8F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xA0-0xAF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xC0-0xCF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xE0-0xEF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xF0-0xFF

opcodes_8: // Lookup table for full 8-bit mode
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x00-0x0F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x10-0x1F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x20-0x2F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x30-0x3F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x40-0x4F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x50-0x5F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x60-0x6F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x70-0x7F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x80-0x8F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xA0-0xAF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xC0-0xCF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xE0-0xEF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xF0-0xFF

opcodes_r8: // Lookup table for 8-bit register mode
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x00-0x0F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x10-0x1F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x20-0x2F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x30-0x3F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x40-0x4F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x50-0x5F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x60-0x6F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x70-0x7F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x80-0x8F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xA0-0xAF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xC0-0xCF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xE0-0xEF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xF0-0xFF

opcodes_a8: // Lookup table for 8-bit accumulator mode
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x00-0x0F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x10-0x1F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x20-0x2F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x30-0x3F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x40-0x4F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x50-0x5F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x60-0x6F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x70-0x7F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x80-0x8F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xA0-0xAF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xC0-0xCF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xE0-0xEF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xF0-0xFF

opcodes_16: // Lookup table for 16-bit mode
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x00-0x0F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x10-0x1F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x20-0x2F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x30-0x3F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x40-0x4F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x50-0x5F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x60-0x6F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x70-0x7F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x80-0x8F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xA0-0xAF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xC0-0xCF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xE0-0xEF
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp // 0xF0-0xFF

.text

cpu_init:
    // Set the initial program counter value (s7)
    move s0, ra     // Backup return address
    li   a0, 0xFFFC // RESET vector
    li   a1, 1
    jal  memory_read
    move s7, v0

    // Set the initial opcode lookup table (s6) and cycle count (s5)
    la   s6, opcodes_emu
    li   s5, 0
    jr   s0


cpu_execute:
    // Fetch the current opcode
    move a0, s7
    li   a1, 0
    jal  memory_read

    // Jump to the opcode's function in the lookup table
    sll  t0, v0, 2 // Table offset
    add  t0, t0, s6
    lw   t0, (t0)
    jr   t0


update_mode:
    // Check if the emulation flag is set
    lhu  t0, status_flgs
    andi t1, t0, 0x100
    beq  t1, zero, not_emu

    // Switch to emulation mode
    la   s6, opcodes_emu
    andi s7, 0xFFFF       // Clear PC bank
    li   t1, 0x01
    sb   t1, stack_ptr    // Reset SP bank
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    sh   zero, direct_ofs
    sb   zero, data_bank
    jr   ra

    // Check if both 8-bit flags are set
not_emu:
    li   t2, 0x30
    and  t1, t0, t2
    bne  t1, t2, not_8

    // Switch to full 8-bit mode
    la   s6, opcodes_8
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    jr   ra

    // Check if the 8-bit register flag is set
not_8:
    andi t1, t0, 0x10
    beq  t1, zero, not_r8

    // Switch to 8-bit register mode
    la   s6, opcodes_r8
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    jr   ra

    // Check if the 8-bit accumulator flag is set
not_r8:
    andi t1, t0, 0x20
    beq  t1, zero, not_a8

    // Switch to 8-bit accumulator mode
    la   s6, opcodes_a8
    jr   ra

    // Switch to 16-bit mode
not_a8:
    la   s6, opcodes_16
    jr   ra


unimp:
    // Placeholder for unimplemented opcodes
    j unimp
