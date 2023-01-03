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

// Approximate master cycle count for each APU cycle
#define APU_CYCLE 21 // 21477000Hz / 1024000Hz = 20.973632812

.globl apu_execute
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
apu_ram: .byte 0:0xFFC0
apu_rom:
    .byte 0xCD, 0xEF, 0xBD, 0xE8, 0x00, 0xC6, 0x1D, 0xD0 // 0xFFC0-0xFFC7
    .byte 0xFC, 0x8F, 0xAA, 0xF4, 0x8F, 0xBB, 0xF5, 0x78 // 0xFFC8-0xFFCF
    .byte 0xCC, 0xF4, 0xD0, 0xFB, 0x2F, 0x19, 0xEB, 0xF4 // 0xFFD0-0xFFD7
    .byte 0xD0, 0xFC, 0x7E, 0xF4, 0xD0, 0x0B, 0xE4, 0xF5 // 0xFFD8-0xFFDF
    .byte 0xCB, 0xF4, 0xD7, 0x00, 0xFC, 0xD0, 0xF3, 0xAB // 0xFFE0-0xFFE7
    .byte 0x01, 0x10, 0xEF, 0x7E, 0xF4, 0x10, 0xEB, 0xBA // 0xFFE8-0xFFEF
    .byte 0xF6, 0xDA, 0x00, 0xBA, 0xF4, 0xC4, 0xF4, 0xDD // 0xFFF0-0xFFF7
    .byte 0x5D, 0xD0, 0xDB, 0x1F, 0x00, 0x00, 0xC0, 0xFF // 0xFFF8-0xFFFF

apu_inputs:  .byte 0:4
apu_outputs: .byte 0:4

apu_reg_x: .byte 0x00
apu_reg_y: .byte 0x00
apu_accum: .byte 0x00
apu_stack: .hword 0x01FF
apu_flags: .byte 0x00
apu_count: .hword 0xFFC0

apu_opcodes:
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x00-0x0F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x10-0x1F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x20-0x2F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x30-0x3F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x40-0x4F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x50-0x5F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x60-0x6F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x70-0x7F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x80-0x8F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0x90-0x9F
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0xA0-0xAF
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0xB0-0xBF
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0xC0-0xCF
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0xD0-0xDF
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0xE0-0xEF
    .word apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk, apu_unk // 0xF0-0xFF

.text

apu_execute:
    // Fetch the current opcode
    lhu  a0, apu_count
    jal  apu_read8

    // Jump to the opcode's function in the lookup table
    sll  t0, v0, 2 // Word offset
    lw   t0, apu_opcodes(t0)
    jr   t0


apu_unk:
    // Do nothing for unimplemented opcodes; this essentially hangs the APU
    j    cpu_execute


apu_read8: // a0: address - v0: value
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
