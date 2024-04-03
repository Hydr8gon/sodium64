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

#include <limits.h>
#include "defines.h"

.globl apu_map
.globl apu_ram
.globl apu_reg_x
.globl apu_reg_y
.globl apu_accum
.globl apu_stack
.globl apu_flags
.globl apu_count

.globl apu_execute
.globl apu_read8
.globl apu_write8
.globl offset_timers
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
apu_map: .byte 0:0x3FF, 0x40
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

apu_cycle1: .word 341 * 225 * 4
apu_cycle2: .word 341 * 225 * 4
apu_ocycles: .word INT_MIN:3
apu_timers: .byte 0:3
apu_tmdivs: .byte 0:3
apu_tmouts: .byte 0:3

apu_control: .byte 0xB0
apu_inputs: .hword 0:2
apu_outputs: .hword 0:2

apu_reg_x: .hword 0 // Aligned
apu_reg_y: .byte 0
apu_accum: .byte 0
apu_stack: .hword 0x1FF
apu_flags: .byte 0
apu_count: .hword 0xFFC0

.align 5
read_iomap:
    .word read_unk, read_unk, read_dspaddr, read_dspdata // 0xF0-0xF3
    .word read_cpuio0, read_cpuio1, read_cpuio2, read_cpuio3 // 0xF4-0xF7
    .word read_unk, read_unk, read_unk, read_unk // 0xF8-0xFB
    .word read_unk, read_t0out, read_t1out, read_t2out // 0xFC-0xFF

write_iomap:
    .word write_unk, write_control, write_dspaddr, write_dspdata // 0xF0-0xF3
    .word write_cpuio0, write_cpuio1, write_cpuio2, write_cpuio3 // 0xF4-0xF7
    .word write_unk, write_unk, write_t0div, write_t1div // 0xF8-0xFB
    .word write_t2div, write_unk, write_unk, write_unk // 0xFC-0xFF

.text

.align 5
apu_execute:
    // Generate a DSP sample once enough cycles have passed
    ble s3, a3, dsp_sample

    // Compile a new JIT block if one doesn't exist for the current PC
    lhu s0, apu_count
    sll t0, s0, 2
    lw t0, jit_lookup(t0)
    beqz t0, compile_block

    // Compile a new JIT block if memory changed at the start
    lhu t1, 0(t0)
    lw t1, jit_tags(t1)
    lw t2, 4(t0)
    bne t1, t2, compile_block

    // Compile a new JIT block if memory changed at the end
    lhu t2, 2(t0)
    lw t2, jit_tags(t2)
    lw t1, 8(t0)
    bne t1, t2, compile_block

    // Jump to a cached JIT block's code
    addi t0, t0, 12
    jr t0

.align 5
apu_read8: // a0: address - v0: value
    // Read a byte from memory and decrease the APU cycle count
    srl t0, a0, 6
    lbu t1, apu_map(t0)
    addi s3, s3, -APU_CYCLE
    add t0, a0, t1
    lbu v0, apu_ram(t0)

    // Check if the address is an I/O port
    andi t0, a0, 0xFFF0
    beq t0, 0xF0, io_read8
    jr ra

io_read8:
    // Read from an I/O register in the lookup table
    andi t0, a0, 0xF
    sll t0, t0, 2 // Word offset
    lw t0, read_iomap(t0)
    jr t0

read_unk:
    // Unknown I/O register read; do nothing
    jr ra

.align 5
apu_write8: // a0: address, a1: value
    // Write a byte to memory and decrease the APU cycle count
    sb a1, apu_ram(a0)
    addi s3, s3, -APU_CYCLE

    // Increment the memory block's tag to indicate change
    srl t0, a0, 6
    sll t0, t0, 2
    lw t1, jit_tags(t0)
    addi t1, t1, 1
    sw t1, jit_tags(t0)

    // Check if the address is an I/O port
    andi t0, a0, 0xFFF0
    beq t0, 0xF0, io_write8
    jr ra

io_write8:
    // Write to an I/O register in the lookup table
    andi t0, a0, 0xF
    sll t0, t0, 2 // Word offset
    lw t0, write_iomap(t0)
    jr t0

write_unk:
    // Unknown I/O register write; do nothing
    jr ra

.align 5
update_overflows:
    // Never overflow timer 0 if it's disabled
    lbu t0, apu_control
    andi t1, t0, 0x1
    bnez t1, stamp_timer0
    li t1, INT_MIN
    sw t1, apu_ocycles + 0
    b overflow_timer1

stamp_timer0:
    // Update the overflow timestamp for timer 0
    lbu t1, apu_timers + 0
    lbu t2, apu_tmdivs + 0
    addi t1, t1, 1
    sub t1, t2, t1
    andi t1, t1, 0xFF
    addi t1, t1, 1 // Ticks until overflow
    li t2, APU_TIMER1 // Cycles per timer tick
    mult t1, t2 // Cycles until overflow
    lw t1, apu_cycle1
    mflo t2
    sub t1, t1, t2
    sw t1, apu_ocycles + 0

overflow_timer1:
    // Never overflow timer 1 if it's disabled
    andi t1, t0, 0x2
    bnez t1, stamp_timer1
    li t1, INT_MIN
    sw t1, apu_ocycles + 4
    b overflow_timer2

stamp_timer1:
    // Update the overflow timestamp for timer 1
    lbu t1, apu_timers + 1
    lbu t2, apu_tmdivs + 1
    addi t1, t1, 1
    sub t1, t2, t1
    andi t1, t1, 0xFF
    addi t1, t1, 1 // Ticks until overflow
    li t2, APU_TIMER1 // Cycles per timer tick
    mult t1, t2 // Cycles until overflow
    lw t1, apu_cycle1
    mflo t2
    sub t1, t1, t2
    sw t1, apu_ocycles + 4

overflow_timer2:
    // Never overflow timer 2 if it's disabled
    andi t1, t0, 0x4
    bnez t1, stamp_timer2
    li t1, INT_MIN
    sw t1, apu_ocycles + 8
    jr ra

stamp_timer2:
    // Update the overflow timestamp for timer 2
    lbu t1, apu_timers + 2
    lbu t2, apu_tmdivs + 2
    addi t1, t1, 1
    sub t1, t2, t1
    andi t1, t1, 0xFF
    addi t1, t1, 1 // Ticks until overflow
    li t2, APU_TIMER2 // Cycles per timer tick
    mult t1, t2 // Cycles until overflow
    lw t1, apu_cycle2
    mflo t2
    sub t1, t1, t2
    sw t1, apu_ocycles + 8
    jr ra

.align 5
update_timers:
    // Get how many timer 2 ticks passed since the last update
    lw t1, apu_cycle2
    sub t0, t1, s3 // Cycles since last update
    li t1, APU_TIMER2 // Cycles per timer tick
    blt t0, t1, early_exit
    div t0, t1
    mflo t6 // Ticks passed
    mfhi t1 // Cycles since latest tick
    add t1, t1, s3
    sw t1, apu_cycle2

    // Check if timer 2 is enabled
    lbu t5, apu_control
    andi t0, t5, 0x4
    beqz t0, update_timer0
    move t4, t6 // Ticks left

loop_timer2:
    // Check if timer 2 will overflow
    lw t0, apu_ocycles + 8
    bgt s3, t0, inc_timer2

    // Adjust the ticks left for after overflow
    lbu t1, apu_timers + 2
    lbu t2, apu_tmdivs + 2
    addi t1, t1, 1
    sub t1, t2, t1
    andi t1, t1, 0xFF
    addi t1, t1, 1 // Ticks until overflow
    sub t4, t4, t1

    // Overflow timer 2
    lbu t1, apu_tmouts + 2
    addi t1, t1, 1
    andi t1, t1, 0xF
    sb t1, apu_tmouts + 2
    sb zero, apu_timers + 2

    // Update the overflow timestamp for next overflow
    addi t1, t2, -1
    andi t1, t1, 0xFF
    addi t1, t1, 1 // Ticks until overflow
    li t2, APU_TIMER2 // Cycles per timer tick
    mult t1, t2 // Cycles until overflow
    mflo t2
    sub t0, t0, t2
    sw t0, apu_ocycles + 8
    b loop_timer2

inc_timer2:
    // Increment timer 2 without overflow
    lbu t0, apu_timers + 2
    add t0, t0, t4
    sb t0, apu_timers + 2

update_timer0:
    // Get how many timer 0/1 ticks passed since the last update
    lw t1, apu_cycle1
    sub t0, t1, s3 // Cycles since last update
    li t1, APU_TIMER1 // Cycles per timer tick
    blt t0, t1, early_exit
    div t0, t1
    mflo t6 // Ticks passed
    mfhi t1 // Cycles since latest tick
    add t1, t1, s3
    sw t1, apu_cycle1

    // Check if timer 0 is enabled
    andi t0, t5, 0x1
    beqz t0, update_timer1
    move t4, t6 // Ticks left

loop_timer0:
    // Check if timer 0 will overflow
    lw t0, apu_ocycles + 0
    bgt s3, t0, inc_timer0

    // Adjust the ticks left for after overflow
    lbu t1, apu_timers + 0
    lbu t2, apu_tmdivs + 0
    addi t1, t1, 1
    sub t1, t2, t1
    andi t1, t1, 0xFF
    addi t1, t1, 1 // Ticks until overflow
    sub t4, t4, t1

    // Overflow timer 0
    lbu t1, apu_tmouts + 0
    addi t1, t1, 1
    andi t1, t1, 0xF
    sb t1, apu_tmouts + 0
    sb zero, apu_timers + 0

    // Update the overflow timestamp for next overflow
    addi t1, t2, -1
    andi t1, t1, 0xFF
    addi t1, t1, 1 // Ticks until overflow
    li t2, APU_TIMER1 // Cycles per timer tick
    mult t1, t2 // Cycles until overflow
    mflo t2
    sub t0, t0, t2
    sw t0, apu_ocycles + 0
    b loop_timer0

inc_timer0:
    // Increment timer 0 without overflow
    lbu t0, apu_timers + 0
    add t0, t0, t4
    sb t0, apu_timers + 0

update_timer1:
    // Check if timer 1 is enabled
    andi t0, t5, 0x2
    beqz t0, early_exit
    move t4, t6 // Ticks left

loop_timer1:
    // Check if timer 1 will overflow
    lw t0, apu_ocycles + 4
    bgt s3, t0, inc_timer1

    // Adjust the ticks left for after overflow
    lbu t1, apu_timers + 1
    lbu t2, apu_tmdivs + 1
    addi t1, t1, 1
    sub t1, t2, t1
    andi t1, t1, 0xFF
    addi t1, t1, 1 // Ticks until overflow
    sub t4, t4, t1

    // Overflow timer 1
    lbu t1, apu_tmouts + 1
    addi t1, t1, 1
    andi t1, t1, 0xF
    sb t1, apu_tmouts + 1
    sb zero, apu_timers + 1

    // Update the overflow timestamp for next overflow
    addi t1, t2, -1
    andi t1, t1, 0xFF
    addi t1, t1, 1 // Ticks until overflow
    li t2, APU_TIMER1 // Cycles per timer tick
    mult t1, t2 // Cycles until overflow
    mflo t2
    sub t0, t0, t2
    sw t0, apu_ocycles + 4
    b loop_timer1

inc_timer1:
    // Increment timer 1 without overflow
    lbu t0, apu_timers + 1
    add t0, t0, t4
    sb t0, apu_timers + 1
early_exit:
    jr ra

.align 5
offset_timers: // a0: cycles
    // Offset timer update timestamps for the next event
    lw t0, apu_cycle1
    lw t1, apu_cycle2
    add t0, t0, a0
    add t1, t1, a0
    sw t0, apu_cycle1
    sw t1, apu_cycle2

    // Offset timer 0's overflow timestamp if enabled
    la t0, apu_ocycles
    li t1, INT_MIN
    lw t2, 0(t0)
    beq t2, t1, offset1
    add t2, t2, a0
    sw t2, 0(t0)

offset1:
    // Offset timer 1's overflow timestamp if enabled
    lw t3, 4(t0)
    beq t3, t1, offset2
    add t3, t3, a0
    sw t3, 4(t0)

offset2:
    // Offset timer 2's overflow timestamp if enabled
    lw t4, 8(t0)
    beq t4, t1, offset3
    add t4, t4, a0
    sw t4, 8(t0)
offset3:
    jr ra

.align 5
read_cpuio0: // v0: value
    // Read APU input communication value 0
    lbu v0, apu_inputs + 0
    jr ra

.align 5
read_cpuio1: // v0: value
    // Read APU input communication value 1
    lbu v0, apu_inputs + 1
    jr ra

.align 5
read_cpuio2: // v0: value
    // Read APU input communication value 2
    lbu v0, apu_inputs + 2
    jr ra

.align 5
read_cpuio3: // v0: value
    // Read APU input communication value 3
    lbu v0, apu_inputs + 3
    jr ra

.align 5
read_t0out: // v0: value
    // Update timers if timer 0 should overflow
    lw t0, apu_ocycles + 0
    bgt s3, t0, end_t0out
    move gp, ra
    jal update_timers
    move ra, gp

end_t0out:
    // Read timer 0's overflow count and reset it
    lbu v0, apu_tmouts + 0
    sb zero, apu_tmouts + 0
    jr ra

.align 5
read_t1out: // v0: value
    // Update timers if timer 1 should overflow
    lw t0, apu_ocycles + 4
    bgt s3, t0, end_t1out
    move gp, ra
    jal update_timers
    move ra, gp

end_t1out:
    // Read timer 1's overflow count and reset it
    lbu v0, apu_tmouts + 1
    sb zero, apu_tmouts + 1
    jr ra

.align 5
read_t2out: // v0: value
    // Update timers if timer 2 should overflow
    lw t0, apu_ocycles + 8
    bgt s3, t0, end_t2out
    move gp, ra
    jal update_timers
    move ra, gp

end_t2out:
    // Read timer 2's overflow count and reset it
    lbu v0, apu_tmouts + 2
    sb zero, apu_tmouts + 2
    jr ra

.align 5
write_control: // a1: value
    // Update timers and write to the APU control register
    move gp, ra
    jal update_timers
    lbu t0, apu_control
    move ra, gp
    sb a1, apu_control

    // Update the APU ROM mapping
    andi t1, a1, 0x80 // ROM enabled
    srl t1, t1, 1
    sb t1, apu_map + 0x3FF
    lw t1, jit_tags + 0xFFC
    addi t1, t1, 1
    sw t1, jit_tags + 0xFFC

    // Reset timers 0-2 if bit 0-2 turns from 0 to 1
    xor t1, t0, a1
    and t1, t1, a1
    andi t0, t1, 0x1
    beqz t0, timer1
    sb zero, apu_timers + 0
    sb zero, apu_tmouts + 0
timer1:
    andi t0, t1, 0x2
    beqz t0, timer2
    sb zero, apu_timers + 1
    sb zero, apu_tmouts + 1
timer2:
    andi t0, t1, 0x4
    beqz t0, reset0
    sb zero, apu_timers + 2
    sb zero, apu_tmouts + 2

reset0:
    // Clear the first/last 2 input latches if bit 4/5 is set
    andi t0, a1, 0x10
    beqz t0, reset1
    sh zero, apu_inputs + 0
reset1:
    andi t0, a1, 0x20
    beqz t0, reset2
    sh zero, apu_inputs + 2
reset2:
    j update_overflows

.align 5
write_cpuio0: // a1: value
    // Write APU output communication value 0
    sb a1, apu_outputs + 0
    jr ra

.align 5
write_cpuio1: // a1: value
    // Write APU output communication value 1
    sb a1, apu_outputs + 1
    jr ra

.align 5
write_cpuio2: // a1: value
    // Write APU output communication value 2
    sb a1, apu_outputs + 2
    jr ra

.align 5
write_cpuio3: // a1: value
    // Write APU output communication value 3
    sb a1, apu_outputs + 3
    jr ra

.align 5
write_t0div: // a1: value
    // Update timers and write timer 0's divider value
    move gp, ra
    jal update_timers
    sb a1, apu_tmdivs + 0
    move ra, gp
    j update_overflows

.align 5
write_t1div: // a1: value
    // Update timers and write timer 1's divider value
    move gp, ra
    jal update_timers
    sb a1, apu_tmdivs + 1
    move ra, gp
    j update_overflows

.align 5
write_t2div: // a1: value
    // Update timers and write timer 2's divider value
    move gp, ra
    jal update_timers
    sb a1, apu_tmdivs + 2
    move ra, gp
    j update_overflows

.align 5
read_apuio0: // v0: value
    // Read APU output communication value 0
    lbu v0, apu_outputs + 0
    jr ra

.align 5
read_apuio1: // v0: value
    // Read APU output communication value 0
    lbu v0, apu_outputs + 1
    jr ra

.align 5
read_apuio2: // v0: value
    // Read APU output communication value 0
    lbu v0, apu_outputs + 2
    jr ra

.align 5
read_apuio3: // v0: value
    // Read APU output communication value 0
    lbu v0, apu_outputs + 3
    jr ra

.align 5
write_apuio0: // a1: value
    // Write APU input communication value 0
    sb a1, apu_inputs + 0
    jr ra

.align 5
write_apuio1: // a1: value
    // Write APU input communication value 1
    sb a1, apu_inputs + 1
    jr ra

.align 5
write_apuio2: // a1: value
    // Write APU input communication value 2
    sb a1, apu_inputs + 2
    jr ra

.align 5
write_apuio3: // a1: value
    // Write APU input communication value 3
    sb a1, apu_inputs + 3
    jr ra
