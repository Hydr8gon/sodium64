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

// Approximate master cycle count for each APU cycle
#define APU_CYCLE 21 // 21477000Hz / 1024000Hz = 20.973632812

.globl apu_reg_x
.globl apu_reg_y
.globl apu_accum
.globl apu_stack
.globl apu_flags
.globl apu_count

.globl apu_execute
.globl apu_set_nz
.globl apu_read8
.globl apu_write8
.globl read_apuio0
.globl read_apuio1
.globl read_apuio2
.globl read_apuio3
.globl write_apuio0
.globl write_apuio1
.globl write_apuio2
.globl write_apuio3

.data

// The APU boot ROM allows uploading code from the CPU
apu_ram: .byte 0:0x10000
apu_rom:
    .byte 0xCD, 0xEF, 0xBD, 0xE8, 0x00, 0xC6, 0x1D, 0xD0 // 0xFFC0-0xFFC7
    .byte 0xFC, 0x8F, 0xAA, 0xF4, 0x8F, 0xBB, 0xF5, 0x78 // 0xFFC8-0xFFCF
    .byte 0xCC, 0xF4, 0xD0, 0xFB, 0x2F, 0x19, 0xEB, 0xF4 // 0xFFD0-0xFFD7
    .byte 0xD0, 0xFC, 0x7E, 0xF4, 0xD0, 0x0B, 0xE4, 0xF5 // 0xFFD8-0xFFDF
    .byte 0xCB, 0xF4, 0xD7, 0x00, 0xFC, 0xD0, 0xF3, 0xAB // 0xFFE0-0xFFE7
    .byte 0x01, 0x10, 0xEF, 0x7E, 0xF4, 0x10, 0xEB, 0xBA // 0xFFE8-0xFFEF
    .byte 0xF6, 0xDA, 0x00, 0xBA, 0xF4, 0xC4, 0xF4, 0xDD // 0xFFF0-0xFFF7
    .byte 0x5D, 0xD0, 0xDB, 0x1F, 0x00, 0x00, 0xC0, 0xFF // 0xFFF8-0xFFFF

apu_control: .byte 0xB0
apu_inputs:  .byte 0:4
apu_outputs: .byte 0:4

apu_reg_x: .byte 0x00
apu_reg_y: .byte 0x00
apu_accum: .byte 0x00
apu_stack: .hword 0x01FF
apu_flags: .byte 0x00
apu_count: .hword 0xFFC0

apu_opcodes:
    .word apu_unk,    apu_tcall0, apu_unk,    apu_bbs0,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x00-0x07
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_php,    apu_unk,    apu_brk    // 0x08-0x0F
    .word apu_bpl,    apu_tcall1, apu_unk,    apu_bbc0,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x10-0x17
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_jmpabx // 0x18-0x1F
    .word apu_clrp,   apu_tcall2, apu_unk,    apu_bbs1,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x20-0x27
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_pha,    apu_cbnea,  apu_bra    // 0x28-0x2F
    .word apu_bmi,    apu_tcall3, apu_unk,    apu_bbc1,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x30-0x37
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_call   // 0x38-0x3F
    .word apu_setp,   apu_tcall4, apu_unk,    apu_bbs2,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x40-0x47
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_phx,    apu_unk,    apu_pcall  // 0x48-0x4F
    .word apu_bvc,    apu_tcall5, apu_unk,    apu_bbc2,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x50-0x57
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_movxa,  apu_unk,    apu_jmpabx // 0x58-0x5F
    .word apu_unk,    apu_tcall6, apu_unk,    apu_bbs3,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x60-0x67
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_phy,    apu_dbnza,  apu_ret    // 0x68-0x6F
    .word apu_bvs,    apu_tcall7, apu_unk,    apu_bbc3,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x70-0x77
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_movax,  apu_unk,    apu_ret1   // 0x78-0x7F
    .word apu_unk,    apu_tcall8, apu_unk,    apu_bbs4,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x80-0x87
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_mvyimm, apu_ppp,    apu_movdri // 0x88-0x8F
    .word apu_bcc,    apu_tcall9, apu_unk,    apu_bbc4,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0x90-0x97
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_movxs,  apu_unk,    apu_unk    // 0x98-0x9F
    .word apu_ei,     apu_tcallA, apu_unk,    apu_bbs5,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0xA0-0xA7
    .word apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_unk,    apu_ppa,    apu_amvbxp // 0xA8-0xAF
    .word apu_bcs,    apu_tcallB, apu_unk,    apu_bbc5,   apu_unk,    apu_unk,    apu_unk,    apu_unk    // 0xB0-0xB7
    .word apu_unk,    apu_unk,    apu_movwya, apu_unk,    apu_unk,    apu_movsx,  apu_unk,    apu_mvabxp // 0xB8-0xBF
    .word apu_di,     apu_tcallC, apu_unk,    apu_bbs6,   apu_amvdir, apu_amvabs, apu_amvbrx, apu_amvidx // 0xC0-0xC7
    .word apu_unk,    apu_xmvabs, apu_unk,    apu_ymvdir, apu_ymvabs, apu_mvximm, apu_ppx,    apu_unk    // 0xC8-0xCF
    .word apu_bne,    apu_tcallD, apu_unk,    apu_bbc6,   apu_amvdrx, apu_amvabx, apu_amvaby, apu_amvidy // 0xD0-0xD7
    .word apu_xmvdir, apu_xmvdry, apu_movway, apu_ymvdrx, apu_unk,    apu_movay,  apu_cbnex,  apu_unk    // 0xD8-0xDF
    .word apu_unk,    apu_tcallE, apu_unk,    apu_bbs7,   apu_mvadir, apu_mvaabs, apu_mvabrx, apu_mvaidx // 0xE0-0xE7
    .word apu_mvaimm, apu_unk,    apu_mvxabs, apu_mvydir, apu_mvyabs, apu_unk,    apu_ppy,    apu_unk    // 0xE8-0xEF
    .word apu_beq,    apu_tcallF, apu_unk,    apu_bbc7,   apu_mvadrx, apu_mvaabx, apu_mvaaby, apu_mvaidy // 0xF0-0xF7
    .word apu_mvxdir, apu_mvxdry, apu_movdr2, apu_mvydrx, apu_unk,    apu_movya,  apu_dbnzy,  apu_unk    // 0xF8-0xFF

.text

apu_execute:
    // Fetch the current opcode
    lhu  a0, apu_count
    move s0, a0 // Save PC
    jal  apu_read8

    // Jump to the opcode's function in the lookup table
    sll  t0, v0, 2 // Word offset
    lw   t0, apu_opcodes(t0)
    jr   t0


apu_set_nz: // a0: value
    // Set the NZ flags and finish executing an APU opcode
    lbu  t0, apu_flags
    andi t0, t0, 0xFF & ~0x82
    seq  t1, a0, zero
    sll  t1, t1, 1    // Z
    or   t0, t0, t1
    andi t1, a0, 0x80 // N
    or   t0, t0, t1
    sb   t0, apu_flags
    j    cpu_execute


apu_unk:
    // Do nothing for unimplemented opcodes; this essentially hangs the APU
    j    cpu_execute


apu_read8: // a0: address - v0: value
    // Check if the APU ROM is enabled
    lbu  t0, apu_control
    andi t0, t0, 0x80
    beqz t0, read_ram

    // Add an offset to the top 0x40 bytes, redirecting to ROM
    li   t0, 0xFFBF
    slt  t0, t0, a0
    sll  t0, t0, 6
    add  a0, a0, t0

read_ram:
    // Read a byte from memory and decrease the APU cycle count
    lbu  v0, apu_ram(a0)
    addi s3, s3, -APU_CYCLE

    // Check if the address is an I/O port
    andi t0, a0, 0xFFF0
    beq  t0, 0x00F0, io_read8
    jr   ra

io_read8:
    // Read from an APU I/O register
    beq  a0, 0x00F4, read_cpuio0
    beq  a0, 0x00F5, read_cpuio1
    beq  a0, 0x00F6, read_cpuio2
    beq  a0, 0x00F7, read_cpuio3
    jr   ra


apu_write8: // a0: address, a1: value
    // Write a byte to memory and decrease the APU cycle count
    sb   a1, apu_ram(a0)
    addi s3, s3, -APU_CYCLE

    // Check if the address is an I/O port
    andi t0, a0, 0xFFF0
    beq  t0, 0x00F0, io_write8
    jr   ra

io_write8:
    // Write to an APU I/O register
    beq  a0, 0x00F1, write_control
    beq  a0, 0x00F4, write_cpuio0
    beq  a0, 0x00F5, write_cpuio1
    beq  a0, 0x00F6, write_cpuio2
    beq  a0, 0x00F7, write_cpuio3
    jr   ra


read_cpuio0: // v0: value
    // Read APU input communication value 0
    lbu  v0, apu_inputs + 0
    jr   ra


read_cpuio1: // v0: value
    // Read APU input communication value 1
    lbu  v0, apu_inputs + 1
    jr   ra


read_cpuio2: // v0: value
    // Read APU input communication value 2
    lbu  v0, apu_inputs + 2
    jr   ra


read_cpuio3: // v0: value
    // Read APU input communication value 3
    lbu  v0, apu_inputs + 3
    jr   ra


write_control: // a1: value
    // Write to the APU control register
    // TODO: implement bits 0-2
    sb   a1, apu_control

    // Clear the first 2 input latches if bit 4 is set
    andi t0, a1, 0x10
    beqz t0, reset1
    sh   zero, apu_inputs + 0

reset1:
    // Clear the last 2 input latches if bit 5 is set
    andi t0, a1, 0x20
    beqz t0, reset2
    sh   zero, apu_inputs + 2

reset2:
    jr   ra


write_cpuio0: // a1: value
    // Write APU output communication value 0
    sb   a1, apu_outputs + 0
    jr   ra


write_cpuio1: // a1: value
    // Write APU output communication value 1
    sb   a1, apu_outputs + 1
    jr   ra


write_cpuio2: // a1: value
    // Write APU output communication value 2
    sb   a1, apu_outputs + 2
    jr   ra


write_cpuio3: // a1: value
    // Write APU output communication value 3
    sb   a1, apu_outputs + 3
    jr   ra


read_apuio0: // v0: value
    // Read APU output communication value 0
    b    rand // TODO: remove once APU works
    lbu  v0, apu_outputs + 0
    jr   ra


read_apuio1: // v0: value
    // Read APU output communication value 0
    b    rand // TODO: remove once APU works
    lbu  v0, apu_outputs + 1
    jr   ra


read_apuio2: // v0: value
    // Read APU output communication value 0
    b    rand // TODO: remove once APU works
    lbu  v0, apu_outputs + 2
    jr   ra


read_apuio3: // v0: value
    // Read APU output communication value 0
    b    rand // TODO: remove once APU works
    lbu  v0, apu_outputs + 3
    jr   ra


write_apuio0: // a1: value
    // Write APU input communication value 0
    sb   a1, apu_inputs + 0
    jr   ra


write_apuio1: // a1: value
    // Write APU input communication value 1
    sb   a1, apu_inputs + 1
    jr   ra


write_apuio2: // a1: value
    // Write APU input communication value 2
    sb   a1, apu_inputs + 2
    jr   ra


write_apuio3: // a1: value
    // Write APU input communication value 3
    sb   a1, apu_inputs + 3
    jr   ra
