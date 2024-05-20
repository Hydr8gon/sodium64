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

#include "defines.h"

.globl ppu_event
.globl section_init
.globl read_mpyl
.globl read_mpym
.globl read_mpyh
.globl read_slhv
.globl read_rdvraml
.globl read_rdvramh
.globl read_ophct
.globl read_opvct
.globl read_stat78
.globl read_rdnmi
.globl read_timeup
.globl read_hvbjoy
.globl write_inidisp
.globl write_obsel
.globl write_oamaddl
.globl write_oamaddh
.globl write_oamdata
.globl write_bgmode
.globl write_bg1sc
.globl write_bg2sc
.globl write_bg3sc
.globl write_bg4sc
.globl write_bg12nba
.globl write_bg34nba
.globl write_bg1hofs
.globl write_bg1vofs
.globl write_bg2hofs
.globl write_bg2vofs
.globl write_bg3hofs
.globl write_bg3vofs
.globl write_bg4hofs
.globl write_bg4vofs
.globl write_vmain
.globl write_vmaddl
.globl write_vmaddh
.globl write_vmdatal
.globl write_vmdatah
.globl write_m7sel
.globl write_m7a
.globl write_m7b
.globl write_m7c
.globl write_m7d
.globl write_m7x
.globl write_m7y
.globl write_cgadd
.globl write_cgdata
.globl write_tm
.globl write_ts
.globl write_cgadsub
.globl write_coldata
.globl write_setini
.globl write_nmitimen
.globl write_vtimel
.globl write_vtimeh

.data

.align 4
vram: .hword 0:0x8000
cgram: .hword 0:0x100
oam: .byte 0:0x220
vram_table: .byte 0:0x400

.align 4
section_ptr: .word SECTION_QUEUE1
sect_status: .hword 0
cur_line: .hword 0
vblank_line: .byte 0xE1
cooldown: .byte 0
queue_id: .byte 0
frame_done: .byte 0
fb_border: .byte 0
brightness: .byte 0

.align 4
vram_fetch: .hword 0
oam_addr: .hword 0
vram_incl: .byte 0
vram_inch: .byte 0
oam_lsb: .byte 0
oph_low: .byte 0
opv_low: .byte 0
bg_old: .byte 0
m7_old: .byte 0
cg_lsb: .byte 0

.align 4
mpy: .word 0
ophct: .hword 0
opvct: .hword 0
coldata: .hword 0
vmadd: .hword 0
cgadd: .hword 0
vtime: .hword 0
stat78: .byte 0x1
tm: .byte 0
ts: .byte 0
cgadsub: .byte 0
nmitimen: .byte 0
rdnmi: .byte 0
timeup: .byte 0
hvbjoy: .byte 0

.align 4
// RSP values that are saved for each section (0x50 bytes)
obj_size: .word 0x10100808
objcharbase: .hword 0
oamadd: .hword 0
bgscrnbase: .hword 0:4
bgbaseofsh: .hword 0:4
bgbaseofsv: .hword 0:4
bgcharbase: .hword 0:4
bghofs: .hword 0:4
bgvofs: .hword 0:4
m7hofs: .hword 0
m7vofs: .hword 0
m7a: .hword 0
m7b: .hword 0
m7c: .hword 0
m7d: .hword 0
m7x: .hword 0
m7y: .hword 0
fill_color: .hword 0
force_blank: .byte 0
bg_mode: .byte 0
sub_mask: .byte 0
main_mask: .byte 0
m7_nowrap: .byte 0
split_line: .byte 0

.align 4
// Double-buffered addresses for queued frame data
pal_queues: .word PALETTE_QUEUE1, PALETTE_QUEUE2
oam_queues: .word OAM_QUEUE1, OAM_QUEUE2
dirty_queues: .word DIRTY_QUEUE1, DIRTY_QUEUE2
sect_queues: .word SECTION_QUEUE1, SECTION_QUEUE2

.align 4
obj_sizes: // Possible object sizes; bytes are small X, small Y, large X, large Y
    .word 0x08081010, 0x08082020, 0x08084040, 0x10102020
    .word 0x10104040, 0x20204040, 0x10202040, 0x10202020

.align 4
scrn_ofsh: .hword 0x0000, 0x0800, 0x0000, 0x0800 // Horizontal screen address offsets
scrn_ofsv: .hword 0x0000, 0x0000, 0x0800, 0x1000 // Vertical screen address offsets
vram_incrs: .byte 1, 32, 128, 128 // VRAM access address increments

.text

.align 5
ppu_event:
    // Increment the line counter
    lhu s0, cur_line
    addi s0, s0, 1
    sh s0, cur_line

    // Check if a V-blank start or end event should occur
    lbu t0, vblank_line
    beq s0, t0, vblank_start
    beq s0, 262, vblank_end

vcount_check:
    // Check if a V-count IRQ event should occur
    lhu t0, vtime
    lhu s0, cur_line
    beq s0, t0, vcount_irq

run_line:
    // Skip sections and HDMA if currently in V-blank
    lbu t0, hvbjoy
    andi t0, t0, 0x80
    bnez t0, next_line

    // Decrement the section cooldown if non-zero
    lhu t0, sect_status
    andi t1, t0, 0xFF
    sltu t1, zero, t1
    sub t0, t0, t1

    // Make a new section if dirty and increase the cooldown
    bne t0, 0x100, skip_section
    lhu a0, cur_line
    jal make_section
    lbu t0, cooldown
    addi t1, t0, SECTION_INC
    sb t1, cooldown

skip_section:
    // Update the section status and trigger HDMA
    sh t0, sect_status
    jal trigger_hdma

next_line:
    // Offset all cycle counts for the next event
    li a0, 341 * 4
    add s5, s5, a0 // CPU
    add s3, s3, a0 // APU
    add a3, a3, a0 // DSP
    jal offset_timers

    // Don't let the CPU run if it's halted
    andi t0, s4, 0x200 // Halted
    beqz t0, cpu_execute
    li s5, 0
    j cpu_execute

.align 5
vblank_start:
    // Set the V-blank and NMI flags
    lbu t0, hvbjoy
    ori t0, t0, 0x80
    sb t0, hvbjoy
    li t0, 0x80
    sb t0, rdnmi

    // Skip handling the frame if it was already done
    lbu t0, frame_done
    bnez t0, skip_frame
    jal rsp_frame
skip_frame:
    sb zero, frame_done

    // Reload the OAM address
    lhu t1, oamadd
    sll t0, t1, 1
    andi t0, t0, 0x3FE
    sh t0, oam_addr

    // Trigger an NMI if enabled
    lbu t0, nmitimen
    andi t0, t0, 0x80 // NMI enable
    beqz t0, vcount_check
    andi s4, s4, 0xFDFF // Unhalt CPU
    li a1, 0
    la ra, vcount_check
    j trigger_nmi

.align 5
vblank_end:
    // Clear the V-blank and NMI flags
    lbu t0, hvbjoy
    andi t0, t0, 0x7F
    sb t0, hvbjoy
    sb zero, rdnmi

    // Reset the frame status and start the first section
    li t0, SECTION_MIN
    sb t0, cooldown
    sh zero, sect_status
    sh zero, cur_line
    jal reload_hdma
    la ra, vcount_check
    j section_init

.align 5
vcount_irq:
    // Trigger a V-count IRQ if enabled
    lbu t0, nmitimen
    andi t0, t0, 0x30 // H/V-IRQ enable
    beqz t0, run_line
    andi t1, s4, 0x4 // IRQ disable
    andi s4, s4, 0xFDFF // Unhalt CPU
    bnez t1, run_line
    li a1, 4
    jal trigger_nmi

    // Set the V-count IRQ flag
    li t0, 0x80
    sb t0, timeup
    j run_line

.align 5
make_section: // a0: line
    // Set bounds for the current frame section
    lw t1, section_ptr
    addi t1, t1, -1
    addi a0, a0, -1
    sb a0, (t1)

section_init:
    // Copy values for the next frame section
    la t0, obj_size
    lw t1, section_ptr
    addi t2, t0, 0x50
section_loop:
    ld t3, (t0)
    addi t0, t0, 8
    sd t3, (t1)
    addi t1, t1, 8
    bne t0, t2, section_loop
    sw t1, section_ptr
    jr ra

.align 5
update_frame:
    // Mark the current frame section as dirty
    li t0, 0x1
    sb t0, sect_status
    jr ra

.align 5
update_fill:
    // Choose between main or sub backdrop color with some guesswork
    lbu t0, cgadsub
    lhu t1, cgram
    andi t0, t0, 0x20 // Backdrop math
    beqz t0, set_fill
    lhu t2, coldata
    beqz t2, set_fill
    move t1, t2

set_fill:
    // Space out the color's components and multiply with current brightness
    lbu t0, brightness
    andi t2, t1, 0x1F // R
    andi t3, t1, 0x3E0 // G
    sll t3, t3, 5
    or t2, t2, t3
    andi t3, t1, 0x7C00 // B
    sll t3, t3, 10
    or t2, t2, t3
    mult t2, t0
    mflo t1

    // Pack the components back together in N64 format
    andi t2, t1, 0x1F0 // R
    sll t2, t2, 7
    srl t1, t1, 14
    andi t3, t1, 0x1F // G
    sll t3, t3, 6
    or t2, t2, t3
    andi t3, t1, 0x7C00 // B
    srl t3, t3, 9
    or t2, t2, t3

    // Update the fill color and the frame if the color changed
    lhu t1, fill_color
    sh t2, fill_color
    bne t1, t2, update_frame
    jr ra

.align 5
rsp_frame:
    // Alternate indices for queued frame values each frame
    lbu t5, queue_id // Next
    xori t6, t5, 4 // Current
    sb t6, queue_id

    // Set initial values for palette conversion
    lbu t0, brightness
    lw t4, pal_queues(t5)
    addi t4, t4, 0x7F8
    li t6, 0x1FE

update_dpal:
    // Space out a color's components and multiply with current brightness
    lhu t1, cgram(t6)
    andi t2, t1, 0x1F // R
    andi t3, t1, 0x3E0 // G
    sll t3, t3, 5
    or t2, t2, t3
    andi t3, t1, 0x7C00 // B
    sll t3, t3, 10
    or t2, t2, t3
    mult t2, t0
    mflo t1

    // Pack the components back together in N64 format
    andi t2, t1, 0x1F0 // R
    sll t2, t2, 7
    srl t1, t1, 14
    andi t3, t1, 0x1F // G
    sll t3, t3, 6
    or t2, t2, t3
    andi t3, t1, 0x7C00 // B
    srl t3, t3, 9
    or t2, t2, t3
    ori t2, t2, 0x1 // A

    // Set a color in the palette queue and loop until finished
    sll t3, t2, 16
    or t2, t2, t3
    sw t2, 0(t4)
    sw t2, 4(t4)
    addi t6, t6, -2
    addi t4, t4, -8
    bnez t6, update_dpal

    // Copy OAM to the queue for the next frame
    la t0, oam
    lw t1, oam_queues(t5)
    li t2, 0x220
oam_loop:
    addi t2, t2, -8
    ld t3, (t0)
    addi t0, t0, 8
    sd t3, (t1)
    addi t1, t1, 8
    bnez t2, oam_loop

    // Reset and copy the VRAM dirty table to the queue for the next frame
    la t0, vram_table
    lw t1, dirty_queues(t5)
    li t2, 0x400
dirty_loop:
    addi t2, t2, -8
    ld t3, (t0)
    sd zero, (t0)
    addi t0, t0, 8
    sd t3, (t1)
    addi t1, t1, 8
    bnez t2, dirty_loop

    // Ensure cached VRAM is written back to memory
    la t0, vram
    add t1, t0, 0x10000
vram_loop:
    cache 0x19, 0x00(t0)
    cache 0x19, 0x10(t0)
    addi t0, t0, 0x20
    bne t0, t1, vram_loop

    // Make a final frame section and reset the pointer
    lhu a0, cur_line
    move t4, ra
    jal make_section
    xori t6, t5, 4
    lw t0, sect_queues(t6)
    sw t0, section_ptr

rsp_wait:
    // Wait until the RSP is finished rendering
    lw t0, 0xA4040010 // SP_STATUS
    andi t0, t0, 0x1 // Halt
    beqz t0, rsp_wait

    // Draw an FPS counter on the current frame if toggled
    lbu t0, btn_toggle
    andi t0, t0, 0x10
    beqz t0, count_frame
    lbu a0, fps_display
    lw t0, DMEM(FRAMEBUFFER)(t6)
    addi a1, t0, 24 * 560 + 44 * 2
    jal draw_value

count_frame:
    // Increment the frame counters with VI interrupts disabled
    li t0, 0x40 // Clear VI mask
    sw t0, 0xA430000C // MI_MASK
    lbu t0, frame_count
    lbu t1, fps_emulate
    addi t0, t0, 1
    sb t0, frame_count
    addi t1, t1, 1
    sb t1, fps_emulate
    li t0, 0x80 // Set VI mask
    sw t0, 0xA430000C // MI_MASK

    // Update/reset values for the next frame
    lbu t0, btn_toggle
    lbu t1, fb_border
    lhu t2, cur_line
    lw t3, sect_queues(t5)
    srl t0, t0, 5 // Z toggle
    addi t2, t2, -1
    sw t0, DMEM(MASK_OFS)(t5)
    sw t1, DMEM(FB_BORDER)(t5)
    sw t2, DMEM(FRAME_END)(t5)
    sw t3, DMEM(SECTION_PTR)(t5)

    // Get the address of the next of three framebuffers
    lw t0, DMEM(FRAMEBUFFER)(t6)
    li t1, FRAMEBUFFER2 - FRAMEBUFFER1
    add t0, t0, t1
    li t1, MODE7_TEXTURE
    bne t0, t1, set_buffer
    li t0, FRAMEBUFFER1
set_buffer:
    sw t0, DMEM(FRAMEBUFFER)(t5)

    // Provide an address and set the semaphore for copying VRAM
    la t0, UNCACHED(vram)
    sw t0, DMEM(VRAM_ADDRS + 4)
    lw t0, 0xA404001C

frame_wait:
    // Wait for a framebuffer to be available
    lbu t0, frame_count
    beq t0, 2, frame_wait

    // Unhalt the RSP so it can render the next frame
    li t0, 0x1 // Clear halt
    sw t0, 0xA4040010 // SP_STATUS
    jr t4

.align 5
read_mpyl: // v0: value
    // Read the low byte of the signed multiply result
    lbu v0, mpy + 3
    jr ra

.align 5
read_mpym: // v0: value
    // Read the middle byte of the signed multiply result
    lbu v0, mpy + 2
    jr ra

.align 5
read_mpyh: // v0: value
    // Read the high byte of the signed multiply result
    lbu v0, mpy + 1
    jr ra

.align 5
read_slhv: // a0: address - v0: value
    // Latch the vertical counter
    lhu t0, cur_line
    sh t0, opvct

    // Latch the horizontal counter based on cycles until next line
    li t0, 341
    srl t1, s5, 2
    sub t0, t0, t1
    sh t0, ophct

    // Set the latch flag and return approximate open bus
    lbu t0, stat78
    ori t0, t0, 0x40
    sb t0, stat78
    srl v0, a0, 8
    jr ra

.align 5
read_rdvraml: // v0: value
    // Read the low byte of the prefetched VRAM data
    lbu v0, vram_fetch + 1
    lbu t2, vram_incl
    beqz t2, vraml_end

    // Prefetch a new 16-bit value before increment
    lhu t0, vmadd
    sll t1, t0, 1
    lhu t1, vram(t1)
    sh t1, vram_fetch

    // Increment the VRAM address
    add t0, t0, t2
    andi t0, t0, 0x7FFF
    sh t0, vmadd
vraml_end:
    jr ra

.align 5
read_rdvramh: // v0: value
    // Read the low byte of the prefetched VRAM data
    lbu v0, vram_fetch
    lbu t2, vram_inch
    beqz t2, vramh_end

    // Prefetch a new 16-bit value before increment
    lhu t0, vmadd
    sll t1, t0, 1
    lhu t1, vram(t1)
    sh t1, vram_fetch

    // Increment the VRAM address
    add t0, t0, t2
    andi t0, t0, 0x7FFF
    sh t0, vmadd
vramh_end:
    jr ra

.align 5
read_ophct: // v0: value
    // Read from the OPHCT register's low or high byte
    lhu v0, ophct
    lbu t0, oph_low
    beqz t0, oph_toggle
    srl v0, v0, 8

oph_toggle:
    // Toggle which byte to read next
    andi v0, v0, 0xFF
    xori t0, t0, 0x1
    sb t0, oph_low
    jr ra

.align 5
read_opvct: // v0: value
    // Read from the OPVCT register's low or high byte
    lhu v0, opvct
    lbu t0, opv_low
    beqz t0, opv_toggle
    srl v0, v0, 8

opv_toggle:
    // Toggle which byte to read next
    andi v0, v0, 0xFF
    xori t0, t0, 0x1
    sb t0, opv_low
    jr ra

.align 5
read_stat78: // v0: value
    // Read from the STAT78 register and reset the latch flag
    lbu v0, stat78
    andi t0, v0, 0xBF
    sb t0, stat78

    // Reset the latched counter byte toggles
    sb zero, oph_low
    sb zero, opv_low
    jr ra

.align 5
read_rdnmi: // v0: value
    // Read from the RDNMI register, resetting its flag
    lbu v0, rdnmi
    sb zero, rdnmi
    jr ra

.align 5
read_timeup: // v0: value
    // Read from the TIMEUP register, resetting its flag
    lbu v0, timeup
    sb zero, timeup
    jr ra

.align 5
read_hvbjoy: // v0: value
    // Read from the HVBJOY register with H-blank based on cycles until next line
    lbu v0, hvbjoy
    slti t0, s5, (341 - 274) * 4
    sll t0, t0, 6
    or v0, v0, t0
    jr ra

.align 5
write_inidisp: // a1: value
    // Set the force blank bit
    andi t0, a1, 0x80
    sb t0, force_blank

    // Some games use mid-frame events to achieve a longer V-blank period
    // If force blank is set after a certain line, handle the frame now
    beqz t0, set_bright
    lbu t1, hvbjoy
    andi t1, t1, 0x80
    bnez t1, set_bright
    lhu t1, cur_line
    ble t1, 210, set_bright
    lbu t1, frame_done
    bnez t1, set_bright
    sb t0, frame_done
    b rsp_frame

set_bright:
    // Set the master brightness
    andi t0, a1, 0xF
    sgtu t1, t0, zero
    add t0, t0, t1
    sb t0, brightness
    j update_fill

.align 5
write_obsel: // a1: value
    // Update the OBJ character base address in DMEM
    // TODO: use the gap setting
    andi t0, a1, 0x3
    sll t0, t0, 14
    sh t0, objcharbase

    // Update the OBJ small and large sizes in DMEM
    andi t0, a1, 0xE0
    srl t0, t0, 3
    lw t0, obj_sizes(t0)
    sw t0, obj_size
    j update_frame

.align 5
write_oamaddl: // a1: value
    // Set the low byte of the OAM address reload
    lhu t0, oamadd
    andi t1, a1, 0xFF
    andi t0, t0, 0x8100
    or t0, t0, t1
    sh t0, oamadd

    // Reload the OAM address
    sll t0, t0, 1
    andi t0, t0, 0x3FE
    sh t0, oam_addr
    j update_frame

.align 5
write_oamaddh: // a1: value
    // Set the high bits of the OAM address reload
    lhu t0, oamadd
    sll t1, a1, 8
    andi t1, t1, 0x8100
    andi t0, t0, 0xFF
    or t0, t0, t1
    sh t0, oamadd

    // Reload the OAM address
    sll t0, t0, 1
    andi t0, t0, 0x3FE
    sh t0, oam_addr
    j update_frame

.align 5
write_oamdata: // a1: value
    // Increment the OAM address, wrapping around on overflow
    lhu t0, oam_addr
    blt t0, 0x220, no_wrap
    addi t0, t0, -0x220
no_wrap:
    addi t1, t0, 1
    sh t1, oam_addr

    // Check if writing to the last 32 bytes, otherwise check for first/second access
    andi t1, t0, 0x200
    bnez t1, oam_end
    andi t1, t0, 1
    bnez t1, oam_high

    // Save the low byte on first access
    sb a1, oam_lsb
    jr ra

oam_high:
    // Form a 16-bit value with the low byte and store it in OAM
    andi t0, t0, 0x3FE
    lbu t1, oam_lsb
    sll t2, a1, 8
    or t3, t1, t2
    sh t3, oam(t0)
    jr ra

oam_end:
    // Store an 8-bit value in the last 32 bytes of OAM
    sb a1, oam(t0)
    jr ra

.align 5
write_bgmode: // a1: value
    // Set the BG screen mode from 0 to 7
    andi t0, a1, 0xF
    beq t0, 0x9, high_prio
    andi t0, a1, 0xF7
    sb t0, bg_mode
    j update_frame

high_prio:
    // Set a special mode when mode 1 is set with the BG3 priority bit
    andi t0, a1, 0xF0
    ori t0, t0, 8
    sb t0, bg_mode
    j update_frame

.align 5
write_bg1sc: // a1: value
    // Update BG1's screen base address in DMEM
    andi t0, a1, 0x7C
    sll t0, t0, 9
    sh t0, bgscrnbase + 0

    // Update BG1's horizontal base offset in DMEM
    andi t1, a1, 0x3
    sll t1, t1, 1
    lhu t0, scrn_ofsh(t1)
    sh t0, bgbaseofsh + 0

    // Update BG1's vertical base offset in DMEM
    lhu t0, scrn_ofsv(t1)
    sh t0, bgbaseofsv + 0
    j update_frame

.align 5
write_bg2sc: // a1: value
    // Update BG2's screen base address in DMEM
    andi t0, a1, 0x7C
    sll t0, t0, 9
    sh t0, bgscrnbase + 2

    // Update BG2's horizontal base offset in DMEM
    andi t1, a1, 0x3
    sll t1, t1, 1
    lhu t0, scrn_ofsh(t1)
    sh t0, bgbaseofsh + 2

    // Update BG2's vertical base offset in DMEM
    lhu t0, scrn_ofsv(t1)
    sh t0, bgbaseofsv + 2
    j update_frame

.align 5
write_bg3sc: // a1: value
    // Update BG3's screen base address in DMEM
    andi t0, a1, 0x7C
    sll t0, t0, 9
    sh t0, bgscrnbase + 4

    // Update BG3's horizontal base offset in DMEM
    andi t1, a1, 0x3
    sll t1, t1, 1
    lhu t0, scrn_ofsh(t1)
    sh t0, bgbaseofsh + 4

    // Update BG3's vertical base offset in DMEM
    lhu t0, scrn_ofsv(t1)
    sh t0, bgbaseofsv + 4
    j update_frame

.align 5
write_bg4sc: // a1: value
    // Update BG4's screen base address in DMEM
    andi t0, a1, 0x7C
    sll t0, t0, 9
    sh t0, bgscrnbase + 6

    // Update BG4's horizontal base offset in DMEM
    andi t1, a1, 0x3
    sll t1, t1, 1
    lhu t0, scrn_ofsh(t1)
    sh t0, bgbaseofsh + 6

    // Update BG4's vertical base offset in DMEM
    lhu t0, scrn_ofsv(t1)
    sh t0, bgbaseofsv + 6
    j update_frame

.align 5
write_bg12nba: // a1: value
    // Update BG1's character base address in DMEM
    andi t0, a1, 0x7
    sll t0, t0, 13
    sh t0, bgcharbase + 0

    // Update BG2's character base address in DMEM
    andi t0, a1, 0x70
    sll t0, t0, 9
    sh t0, bgcharbase + 2
    j update_frame

.align 5
write_bg34nba: // a1: value
    // Update BG3's character base address in DMEM
    andi t0, a1, 0x7
    sll t0, t0, 13
    sh t0, bgcharbase + 4

    // Update BG4's character base address in DMEM
    andi t0, a1, 0x70
    sll t0, t0, 9
    sh t0, bgcharbase + 6
    j update_frame

.align 5
write_bg1hofs: // a1: value
    // Update BG1HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu t0, bg_old
    andi t1, a1, 0x3
    sll t1, t1, 8
    or t0, t0, t1
    sb a1, bg_old
    sh t0, bghofs + 0

    // Update M7HOFS with a 13-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sll t0, t0, 18
    sra t0, t0, 18
    sh t0, m7hofs
    j update_frame

.align 5
write_bg1vofs: // a1: value
    // Update BG1VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu t0, bg_old
    andi t1, a1, 0x3
    sll t1, t1, 8
    or t0, t0, t1
    sb a1, bg_old
    sh t0, bgvofs + 0

    // Update M7VOFS with a 13-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sll t0, t0, 18
    sra t0, t0, 18
    sh t0, m7vofs
    j update_frame

.align 5
write_bg2hofs: // a1: value
    // Update BG2HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu t0, bg_old
    andi t1, a1, 0x3
    sll t1, t1, 8
    or t0, t0, t1
    sb a1, bg_old
    sh t0, bghofs + 2
    j update_frame

.align 5
write_bg2vofs: // a1: value
    // Update BG2VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu t0, bg_old
    andi t1, a1, 0x3
    sll t1, t1, 8
    or t0, t0, t1
    sb a1, bg_old
    sh t0, bgvofs + 2
    j update_frame

.align 5
write_bg3hofs: // a1: value
    // Update BG3HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu t0, bg_old
    andi t1, a1, 0x3
    sll t1, t1, 8
    or t0, t0, t1
    sb a1, bg_old
    sh t0, bghofs + 4
    j update_frame

.align 5
write_bg3vofs: // a1: value
    // Update BG3VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu t0, bg_old
    andi t1, a1, 0x3
    sll t1, t1, 8
    or t0, t0, t1
    sb a1, bg_old
    sh t0, bgvofs + 4
    j update_frame

.align 5
write_bg4hofs: // a1: value
    // Update BG4HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu t0, bg_old
    andi t1, a1, 0x3
    sll t1, t1, 8
    or t0, t0, t1
    sb a1, bg_old
    sh t0, bghofs + 6
    j update_frame

.align 5
write_bg4vofs: // a1: value
    // Update BG4VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu t0, bg_old
    andi t1, a1, 0x3
    sll t1, t1, 8
    or t0, t0, t1
    sb a1, bg_old
    sh t0, bgvofs + 6
    j update_frame

.align 5
write_vmain: // a1: value
    // Get the VRAM increment and check if it applies to high or low access
    // TODO: address translation
    andi t0, a1, 0x3
    lbu t0, vram_incrs(t0)
    andi t1, a1, 0x80
    bnez t1, vmain_high

    // Set the VRAM increment for low access
    sb t0, vram_incl
    sb zero, vram_inch
    jr ra

vmain_high:
    // Set the VRAM increment for high access
    sb zero, vram_incl
    sb t0, vram_inch
    jr ra

.align 5
write_vmaddl: // a1: value
    // Set the low byte of the VRAM address
    sb a1, vmadd + 1

    // Prefetch a 16-bit value for reading
    lhu t0, vmadd
    sll t1, t0, 1
    lhu t0, vram(t1)
    sh t0, vram_fetch
    jr ra

.align 5
write_vmaddh: // a1: value
    // Set the high byte of the VRAM address
    andi t0, a1, 0x7F
    sb t0, vmadd

    // Prefetch a 16-bit value for reading
    lhu t0, vmadd
    sll t1, t0, 1
    lhu t0, vram(t1)
    sh t0, vram_fetch
    jr ra

.align 5
write_vmdatal: // a1: value
    // Wait for the RSP semaphore to ensure VRAM copying is done
    lw t0, 0xA404001C
    bnez t0, write_vmdatal
    sw zero, 0xA404001C

    // Write to the low VRAM byte at the current address
    lhu t0, vmadd
    sll t1, t0, 1
    sb a1, vram + 1(t1)

    // Set each layer's dirty bit for the modified VRAM block
    srl t1, t1, 6
    li t2, 0x1F
    sb t2, vram_table(t1)

    // Increment the VRAM address
    lbu t1, vram_incl
    add t0, t0, t1
    andi t0, t0, 0x7FFF
    sh t0, vmadd
    jr ra

.align 5
write_vmdatah: // a1: value
    // Wait for the RSP semaphore to ensure VRAM copying is done
    lw t0, 0xA404001C
    bnez t0, write_vmdatah
    sw zero, 0xA404001C

    // Write to the high VRAM byte at the current address
    lhu t0, vmadd
    sll t1, t0, 1
    sb a1, vram(t1)

    // Set each layer's dirty bit for the modified VRAM block
    srl t1, t1, 6
    li t2, 0x1F
    sb t2, vram_table(t1)

    // Increment the VRAM address
    lbu t1, vram_inch
    add t0, t0, t1
    andi t0, t0, 0x7FFF
    sh t0, vmadd
    jr ra

.align 5
write_m7sel: // a1: value
    // Set whether mode 7 should wrap out of bounds or not
    // TODO: use the rest of the bits
    srl t0, a1, 7
    sb t0, m7_nowrap
    j update_frame

.align 5
write_m7a: // a1: value
    // Update M7A with a 16-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sh t0, m7a

    // Update the signed multiply result
    lh t0, m7a
    lb t1, m7b
    mult t0, t1
    mflo t0
    sw t0, mpy
    j update_frame

.align 5
write_m7b: // a1: value
    // Update M7B with a 16-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sh t0, m7b

    // Update the signed multiply result
    lh t0, m7a
    lb t1, m7b
    mult t0, t1
    mflo t0
    sw t0, mpy
    j update_frame

.align 5
write_m7c: // a1: value
    // Update M7C with a 16-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sh t0, m7c
    j update_frame

.align 5
write_m7d: // a1: value
    // Update M7D with a 16-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sh t0, m7d
    j update_frame

.align 5
write_m7x: // a1: value
    // Update M7X with a 13-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sll t0, t0, 18
    sra t0, t0, 18
    sh t0, m7x
    j update_frame

.align 5
write_m7y: // a1: value
    // Update M7Y with a 13-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sll t0, t0, 18
    sra t0, t0, 18
    sh t0, m7y
    j update_frame

.align 5
write_cgadd: // a1: value
    // Set the palette address, resetting to first access
    sll t0, a1, 1
    sh t0, cgadd
    jr ra

.align 5
write_cgdata: // a1: value
    // Increment the palette address and check bit 0 for first/second access
    lhu t0, cgadd
    addi t1, t0, 1
    sh t1, cgadd
    andi t1, t0, 1
    bnez t1, cg_high

    // Save the low byte on first access
    sb a1, cg_lsb
    jr ra

cg_high:
    // Form a 16-bit value with the low byte and write it to CGRAM
    andi t0, t0, 0x1FE
    lbu t1, cg_lsb
    sll t2, a1, 8
    or t1, t1, t2
    sh t1, cgram(t0)
    beqz t0, update_fill
    jr ra

.align 5
write_tm: // a1: value
    // Set the main screen layer mask and mask out layers on the sub screen
    sb a1, tm
    lbu t0, ts
    xori t1, a1, 0x1F
    sb a1, main_mask
    and t0, t0, t1
    sb t0, sub_mask
    j update_frame

.align 5
write_ts: // a1: value
    // Set the sub screen layer mask with main layers masked out
    sb a1, ts
    lbu t0, tm
    xori t0, t0, 0x1F
    and t0, t0, a1
    sb t0, sub_mask
    j update_frame

.align 5
write_cgadsub: // a1: value
    // Write to the CGADSUB register
    // TODO: use for more than approximations
    sb a1, cgadsub
    j update_fill

.align 5
write_coldata: // a1: value
    // Prepare to update the sub screen background color
    lhu t0, coldata
    andi t1, a1, 0x1F // Intensity
    li t2, 0x1F // Mask
    li t3, 3 // Count

next_channel:
    // Update a channel's intensity if its bit is set
    sll t4, a1, t3
    andi t4, t4, 0x100
    beqz t4, skip_channel
    not t4, t2
    and t0, t0, t4
    or t0, t0, t1

skip_channel:
    // Move to the next of the RGB channels
    sll t1, t1, 5
    sll t2, t2, 5
    addi t3, t3, -1
    bnez t3, next_channel
    sh t0, coldata
    j update_fill

.align 5
write_setini: // a1: value
    // Set an 8-pixel border if 224-line mode is set
    // TODO: use the rest of the bits
    andi t0, a1, 0x4
    sll t0, t0, 1
    xori t0, t0, 0x8
    sb t0, fb_border

    // Set the line to trigger V-blank on based on border
    li t1, 240
    beqz t0, no_border
    addi t1, t1, -15
no_border:
    sb t1, vblank_line
    jr ra

.align 5
write_nmitimen: // a1: value
    // Write to the NMITIMEN register
    sb a1, nmitimen
    jr ra

.align 5
write_vtimel: // a1: value
    // Write the low byte of the V-count timer value
    sb a1, vtime + 1
    jr ra

.align 5
write_vtimeh: // a1: value
    // Write the high bit of the V-count timer value
    andi t0, a1, 0x1
    sb t0, vtime
    jr ra
