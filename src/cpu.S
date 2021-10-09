#include <regdef.h>

.globl accumulator
.globl register_x
.globl stack_ptr

.globl cpu_init
.globl cpu_execute
.globl update_mode

.data

accumulator: .hword 0x0000
register_x:  .hword 0x0000
register_y:  .hword 0x0000
stack_ptr:   .hword 0x01FF
direct_ofs:  .hword 0x0000
data_bank:   .byte  0x00

opcodes_emu: // Lookup table for 6502 emulation mode
    .word brk_e, unimp, cop_e, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,    unimp, unimp, unimp // 0x00-0x0F
    .word bpl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clc,   unimp, unimp, unimp, unimp,    unimp, unimp, unimp // 0x10-0x1F
    .word jsr,   unimp, jsl_e, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,    unimp, unimp, unimp // 0x20-0x2F
    .word bmi,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sec,   unimp, unimp, unimp, unimp,    unimp, unimp, unimp // 0x30-0x3F
    .word rti_e, unimp, wdm,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, jmp,      unimp, unimp, unimp // 0x40-0x4F
    .word bvc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cli,   unimp, unimp, unimp, jml_e,    unimp, unimp, unimp // 0x50-0x5F
    .word rts,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, rtl_e, jmpind,   unimp, unimp, unimp // 0x60-0x6F
    .word bvs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sei,   unimp, unimp, unimp, jmpidx,   unimp, unimp, unimp // 0x70-0x7F
    .word bra,   unimp, brl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,    unimp, unimp, unimp // 0x80-0x8F
    .word bcc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,    unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,    unimp, unimp, unimp // 0xA0-0xAF
    .word bcs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clv,   unimp, unimp, unimp, unimp,    unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, rep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, wai,   unimp,    unimp, unimp, unimp // 0xC0-0xCF
    .word bne,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cld,   unimp, unimp, stp,   jmlind_e, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, sep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, nop,   xba,   unimp,    unimp, unimp, unimp // 0xE0-0xEF
    .word beq,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sed,   unimp, unimp, xce,   jsridx,   unimp, unimp, unimp // 0xF0-0xFF

opcodes_8: // Lookup table for full 8-bit mode
    .word brk,   unimp, cop,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x00-0x0F
    .word bpl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clc,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x10-0x1F
    .word jsr,   unimp, jsl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x20-0x2F
    .word bmi,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sec,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x30-0x3F
    .word rti,   unimp, wdm,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, jmp,    unimp, unimp, unimp // 0x40-0x4F
    .word bvc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cli,   unimp, unimp, unimp, jml,    unimp, unimp, unimp // 0x50-0x5F
    .word rts,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, rtl,   jmpind, unimp, unimp, unimp // 0x60-0x6F
    .word bvs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sei,   unimp, unimp, unimp, jmpidx, unimp, unimp, unimp // 0x70-0x7F
    .word bra,   unimp, brl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x80-0x8F
    .word bcc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0xA0-0xAF
    .word bcs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clv,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, rep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, wai,   unimp,  unimp, unimp, unimp // 0xC0-0xCF
    .word bne,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cld,   unimp, unimp, stp,   jmlind, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, sep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, nop,   xba,   unimp,  unimp, unimp, unimp // 0xE0-0xEF
    .word beq,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sed,   unimp, unimp, xce,   jsridx, unimp, unimp, unimp // 0xF0-0xFF

opcodes_r8: // Lookup table for 8-bit register mode
    .word brk,   unimp, cop,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x00-0x0F
    .word bpl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clc,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x10-0x1F
    .word jsr,   unimp, jsl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x20-0x2F
    .word bmi,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sec,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x30-0x3F
    .word rti,   unimp, wdm,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, jmp,    unimp, unimp, unimp // 0x40-0x4F
    .word bvc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cli,   unimp, unimp, unimp, jml,    unimp, unimp, unimp // 0x50-0x5F
    .word rts,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, rtl,   jmpind, unimp, unimp, unimp // 0x60-0x6F
    .word bvs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sei,   unimp, unimp, unimp, jmpidx, unimp, unimp, unimp // 0x70-0x7F
    .word bra,   unimp, brl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x80-0x8F
    .word bcc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0xA0-0xAF
    .word bcs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clv,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, rep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, wai,   unimp,  unimp, unimp, unimp // 0xC0-0xCF
    .word bne,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cld,   unimp, unimp, stp,   jmlind, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, sep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, nop,   xba,   unimp,  unimp, unimp, unimp // 0xE0-0xEF
    .word beq,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sed,   unimp, unimp, xce,   jsridx, unimp, unimp, unimp // 0xF0-0xFF

opcodes_a8: // Lookup table for 8-bit accumulator mode
    .word brk,   unimp, cop,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x00-0x0F
    .word bpl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clc,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x10-0x1F
    .word jsr,   unimp, jsl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x20-0x2F
    .word bmi,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sec,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x30-0x3F
    .word rti,   unimp, wdm,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, jmp,    unimp, unimp, unimp // 0x40-0x4F
    .word bvc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cli,   unimp, unimp, unimp, jml,    unimp, unimp, unimp // 0x50-0x5F
    .word rts,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, rtl,   jmpind, unimp, unimp, unimp // 0x60-0x6F
    .word bvs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sei,   unimp, unimp, unimp, jmpidx, unimp, unimp, unimp // 0x70-0x7F
    .word bra,   unimp, brl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x80-0x8F
    .word bcc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0xA0-0xAF
    .word bcs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clv,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, rep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, wai,   unimp,  unimp, unimp, unimp // 0xC0-0xCF
    .word bne,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cld,   unimp, unimp, stp,   jmlind, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, sep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, nop,   xba,   unimp,  unimp, unimp, unimp // 0xE0-0xEF
    .word beq,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sed,   unimp, unimp, xce,   jsridx, unimp, unimp, unimp // 0xF0-0xFF

opcodes_16: // Lookup table for 16-bit mode
    .word brk,   unimp, cop,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x00-0x0F
    .word bpl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clc,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x10-0x1F
    .word jsr,   unimp, jsl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x20-0x2F
    .word bmi,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sec,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x30-0x3F
    .word rti,   unimp, wdm,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, jmp,    unimp, unimp, unimp // 0x40-0x4F
    .word bvc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cli,   unimp, unimp, unimp, jml,    unimp, unimp, unimp // 0x50-0x5F
    .word rts,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, rtl,   jmpind, unimp, unimp, unimp // 0x60-0x6F
    .word bvs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sei,   unimp, unimp, unimp, jmpidx, unimp, unimp, unimp // 0x70-0x7F
    .word bra,   unimp, brl,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x80-0x8F
    .word bcc,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0x90-0x9F
    .word unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0xA0-0xAF
    .word bcs,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, clv,   unimp, unimp, unimp, unimp,  unimp, unimp, unimp // 0xB0-0xBF
    .word unimp, unimp, rep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, unimp, wai,   unimp,  unimp, unimp, unimp // 0xC0-0xCF
    .word bne,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, cld,   unimp, unimp, stp,   jmlind, unimp, unimp, unimp // 0xD0-0xDF
    .word unimp, unimp, sep,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, nop,   xba,   unimp,  unimp, unimp, unimp // 0xE0-0xEF
    .word beq,   unimp, unimp, unimp, unimp, unimp, unimp, unimp, sed,   unimp, unimp, xce,   jsridx, unimp, unimp, unimp // 0xF0-0xFF

.text

cpu_init:
    // Set the initial program counter value (s7)
    move s0, ra     // Backup return address
    li   a0, 0xFFFC // RESET vector
    li   a1, 1
    jal  memory_read
    move s7, v0

    // Set the initial lookup table (s6), cycle count (s5), and status flags (s4)
    la   s6, opcodes_emu
    li   s5, 0
    li   s4, 0x100
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
    andi t0, s4, 0x100
    beq  t0, zero, not_emu

    // Switch to emulation mode
    la   s6, opcodes_emu
    andi s7, 0xFFFF       // Clear PC bank
    li   t0, 0x01
    sb   t0, stack_ptr    // Reset SP bank
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    sh   zero, direct_ofs
    sb   zero, data_bank
    j    cpu_execute

    // Check if both 8-bit flags are set
not_emu:
    li   t1, 0x30
    and  t0, s4, t1
    bne  t0, t1, not_8

    // Switch to full 8-bit mode
    la   s6, opcodes_8
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    j    cpu_execute

    // Check if the 8-bit register flag is set
not_8:
    andi t0, s4, 0x10
    beq  t0, zero, not_r8

    // Switch to 8-bit register mode
    la   s6, opcodes_r8
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    j    cpu_execute

    // Check if the 8-bit accumulator flag is set
not_r8:
    andi t0, s4, 0x20
    beq  t0, zero, not_a8

    // Switch to 8-bit accumulator mode
    la   s6, opcodes_a8
    j    cpu_execute

    // Switch to 16-bit mode
not_a8:
    la   s6, opcodes_16
    j    cpu_execute


unimp:
    // Placeholder for unimplemented opcodes
    j unimp
