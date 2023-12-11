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
#include <limits.h>

// Approximate master cycle counts for APU components (underclocked)
#define APU_CYCLE 21 * 2 // 21477000Hz / 1024000Hz = 20.973632812
#define APU_TIMER1 2688 // 21477000Hz / 8000Hz = 2684.625
#define APU_TIMER2 336 // 21477000Hz / 64000Hz = 335.578125

.globl apu_ram
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

apu_opcodes:
    .word apu_nop, apu_tcall0, apu_set0, apu_bbs0, apu_ordir, apu_orabs, apu_orbrx, apu_oridx // 0x00-0x07
    .word apu_orimm, apu_ordr2, apu_or1a, apu_asldir, apu_aslabs, apu_php, apu_tset1, apu_brk // 0x08-0x0F
    .word apu_bpl, apu_tcall1, apu_clr0, apu_bbc0, apu_ordrx, apu_orabx, apu_oraby, apu_oridy // 0x10-0x17
    .word apu_ordri, apu_orbxy, apu_decw, apu_asldrx, apu_asla, apu_decx, apu_cpxabs, apu_jmpabx // 0x18-0x1F
    .word apu_clrp, apu_tcall2, apu_set1, apu_bbs1, apu_anddir, apu_andabs, apu_andbrx, apu_andidx // 0x20-0x27
    .word apu_andimm, apu_anddr2, apu_or1b, apu_roldir, apu_rolabs, apu_pha, apu_cbnea, apu_bra // 0x28-0x2F
    .word apu_bmi, apu_tcall3, apu_clr1, apu_bbc1, apu_anddrx, apu_andabx, apu_andaby, apu_andidy // 0x30-0x37
    .word apu_anddri, apu_andbxy, apu_incw, apu_roldrx, apu_rola, apu_incx, apu_cpxdir, apu_call // 0x38-0x3F
    .word apu_setp, apu_tcall4, apu_set2, apu_bbs2, apu_eordir, apu_eorabs, apu_eorbrx, apu_eoridx // 0x40-0x47
    .word apu_eorimm, apu_eordr2, apu_and1a, apu_lsrdir, apu_lsrabs, apu_phx, apu_tclr1, apu_pcall // 0x48-0x4F
    .word apu_bvc, apu_tcall5, apu_clr2, apu_bbc2, apu_eordrx, apu_eorabx, apu_eoraby, apu_eoridy // 0x50-0x57
    .word apu_eordri, apu_eorbxy, apu_cmpw, apu_lsrdrx, apu_lsra, apu_movxa, apu_cpyabs, apu_jmpabs // 0x58-0x5F
    .word apu_clrc, apu_tcall6, apu_set3, apu_bbs3, apu_cmpdir, apu_cmpabs, apu_cmpbrx, apu_cmpidx // 0x60-0x67
    .word apu_cmpimm, apu_cmpdr2, apu_and1b, apu_rordir, apu_rorabs, apu_phy, apu_dbnza, apu_ret // 0x68-0x6F
    .word apu_bvs, apu_tcall7, apu_clr3, apu_bbc3, apu_cmpdrx, apu_cmpabx, apu_cmpaby, apu_cmpidy // 0x70-0x77
    .word apu_cmpdri, apu_cmpbxy, apu_addw, apu_rordrx, apu_rora, apu_movax, apu_cpydir, apu_ret1 // 0x78-0x7F
    .word apu_setc, apu_tcall8, apu_set4, apu_bbs4, apu_adcdir, apu_adcabs, apu_adcbrx, apu_adcidx // 0x80-0x87
    .word apu_adcimm, apu_adcdr2, apu_eor1, apu_decdir, apu_decabs, apu_mvyimm, apu_ppp, apu_movdri // 0x88-0x8F
    .word apu_bcc, apu_tcall9, apu_clr4, apu_bbc4, apu_adcdrx, apu_adcabx, apu_adcaby, apu_adcidy // 0x90-0x97
    .word apu_adcdri, apu_adcbxy, apu_subw, apu_decdrx, apu_deca, apu_movxs, apu_div, apu_xcn // 0x98-0x9F
    .word apu_ei, apu_tcallA, apu_set5, apu_bbs5, apu_sbcdir, apu_sbcabs, apu_sbcbrx, apu_sbcidx // 0xA0-0xA7
    .word apu_sbcimm, apu_sbcdr2, apu_mov1b, apu_incdir, apu_incabs, apu_cpyimm, apu_ppa, apu_amvbxp // 0xA8-0xAF
    .word apu_bcs, apu_tcallB, apu_clr5, apu_bbc5, apu_sbcdrx, apu_sbcabx, apu_sbcaby, apu_sbcidy // 0xB0-0xB7
    .word apu_sbcdri, apu_sbcbxy, apu_movwya, apu_incdrx, apu_inca, apu_movsx, apu_unk, apu_mvabxp // 0xB8-0xBF
    .word apu_di, apu_tcallC, apu_set6, apu_bbs6, apu_amvdir, apu_amvabs, apu_amvbrx, apu_amvidx // 0xC0-0xC7
    .word apu_cpximm, apu_xmvabs, apu_mov1a, apu_ymvdir, apu_ymvabs, apu_mvximm, apu_ppx, apu_mul // 0xC8-0xCF
    .word apu_bne, apu_tcallD, apu_clr6, apu_bbc6, apu_amvdrx, apu_amvabx, apu_amvaby, apu_amvidy // 0xD0-0xD7
    .word apu_xmvdir, apu_xmvdry, apu_movway, apu_ymvdrx, apu_decy, apu_movay, apu_cbnex, apu_unk // 0xD8-0xDF
    .word apu_clrv, apu_tcallE, apu_set7, apu_bbs7, apu_mvadir, apu_mvaabs, apu_mvabrx, apu_mvaidx // 0xE0-0xE7
    .word apu_mvaimm, apu_mvxabs, apu_not1, apu_mvydir, apu_mvyabs, apu_notc, apu_ppy, apu_unk // 0xE8-0xEF
    .word apu_beq, apu_tcallF, apu_clr7, apu_bbc7, apu_mvadrx, apu_mvaabx, apu_mvaaby, apu_mvaidy // 0xF0-0xF7
    .word apu_mvxdir, apu_mvxdry, apu_movdr2, apu_mvydrx, apu_incy, apu_movya, apu_dbnzy, apu_unk // 0xF8-0xFF

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

apu_execute:
    // Generate a DSP sample once enough cycles have passed
    ble s3, a3, dsp_sample

    // Fetch the current opcode
    lhu a0, apu_count
    move s0, a0 // Save PC
    jal apu_read8

    // Jump to the opcode's function in the lookup table
    sll t0, v0, 2 // Word offset
    lw t0, apu_opcodes(t0)
    jr t0


apu_set_nz: // a0: value
    // Set the NZ flags and finish executing an APU opcode
    lbu t0, apu_flags
    andi a0, a0, 0xFF
    andi t0, t0, 0x7D
    seq t1, a0, zero
    sll t1, t1, 1 // Z
    or t0, t0, t1
    andi t1, a0, 0x80 // N
    or t0, t0, t1
    sb t0, apu_flags
    j cpu_execute


apu_unk:
    // Do nothing for unimplemented opcodes; this essentially hangs the APU
    j cpu_execute


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


apu_write8: // a0: address, a1: value
    // Write a byte to memory and decrease the APU cycle count
    sb a1, apu_ram(a0)
    addi s3, s3, -APU_CYCLE

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


update_timers:
    // Get how many timer 2 ticks passed since the last update
    lw t7, apu_cycle2
    sub t0, t7, s3 // Cycles since last update
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
    lw t7, apu_cycle1
    sub t0, t7, s3 // Cycles since last update
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


read_cpuio0: // v0: value
    // Read APU input communication value 0
    lbu v0, apu_inputs + 0
    jr ra


read_cpuio1: // v0: value
    // Read APU input communication value 1
    lbu v0, apu_inputs + 1
    jr ra


read_cpuio2: // v0: value
    // Read APU input communication value 2
    lbu v0, apu_inputs + 2
    jr ra


read_cpuio3: // v0: value
    // Read APU input communication value 3
    lbu v0, apu_inputs + 3
    jr ra


read_t0out: // v0: value
    // Update timers if timer 0 should overflow
    lw t0, apu_ocycles + 0
    bgt s3, t0, end_t0out
    move t9, ra
    jal update_timers
    move ra, t9

end_t0out:
    // Read timer 0's overflow count and reset it
    lbu v0, apu_tmouts + 0
    sb zero, apu_tmouts + 0
    jr ra


read_t1out: // v0: value
    // Update timers if timer 1 should overflow
    lw t0, apu_ocycles + 4
    bgt s3, t0, end_t1out
    move t9, ra
    jal update_timers
    move ra, t9

end_t1out:
    // Read timer 1's overflow count and reset it
    lbu v0, apu_tmouts + 1
    sb zero, apu_tmouts + 1
    jr ra


read_t2out: // v0: value
    // Update timers if timer 2 should overflow
    lw t0, apu_ocycles + 8
    bgt s3, t0, end_t2out
    move t9, ra
    jal update_timers
    move ra, t9

end_t2out:
    // Read timer 2's overflow count and reset it
    lbu v0, apu_tmouts + 2
    sb zero, apu_tmouts + 2
    jr ra


write_control: // a1: value
    // Update timers and write to the APU control register
    move t9, ra
    jal update_timers
    lbu t0, apu_control
    move ra, t9
    sb a1, apu_control

    // Update the APU ROM mapping
    andi t1, a1, 0x80 // ROM enabled
    srl t1, t1, 1
    sb t1, apu_map + 0x3FF

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


write_cpuio0: // a1: value
    // Write APU output communication value 0
    sb a1, apu_outputs + 0
    jr ra


write_cpuio1: // a1: value
    // Write APU output communication value 1
    sb a1, apu_outputs + 1
    jr ra


write_cpuio2: // a1: value
    // Write APU output communication value 2
    sb a1, apu_outputs + 2
    jr ra


write_cpuio3: // a1: value
    // Write APU output communication value 3
    sb a1, apu_outputs + 3
    jr ra


write_t0div: // a1: value
    // Update timers and write timer 0's divider value
    move t9, ra
    jal update_timers
    sb a1, apu_tmdivs + 0
    move ra, t9
    j update_overflows


write_t1div: // a1: value
    // Update timers and write timer 1's divider value
    move t9, ra
    jal update_timers
    sb a1, apu_tmdivs + 1
    move ra, t9
    j update_overflows


write_t2div: // a1: value
    // Update timers and write timer 2's divider value
    move t9, ra
    jal update_timers
    sb a1, apu_tmdivs + 2
    move ra, t9
    j update_overflows


read_apuio0: // v0: value
    // Read APU output communication value 0
    lbu v0, apu_outputs + 0
    jr ra


read_apuio1: // v0: value
    // Read APU output communication value 0
    lbu v0, apu_outputs + 1
    jr ra


read_apuio2: // v0: value
    // Read APU output communication value 0
    lbu v0, apu_outputs + 2
    jr ra


read_apuio3: // v0: value
    // Read APU output communication value 0
    lbu v0, apu_outputs + 3
    jr ra


write_apuio0: // a1: value
    // Write APU input communication value 0
    sb a1, apu_inputs + 0
    jr ra


write_apuio1: // a1: value
    // Write APU input communication value 1
    sb a1, apu_inputs + 1
    jr ra


write_apuio2: // a1: value
    // Write APU input communication value 2
    sb a1, apu_inputs + 2
    jr ra


write_apuio3: // a1: value
    // Write APU input communication value 3
    sb a1, apu_inputs + 3
    jr ra
