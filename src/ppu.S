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
.globl menu_return
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
.globl write_w12sel
.globl write_w34sel
.globl write_wobjsel
.globl write_wh0
.globl write_wh1
.globl write_wh2
.globl write_wh3
.globl write_wbglog
.globl write_wobjlog
.globl write_tm
.globl write_ts
.globl write_tmw
.globl write_tsw
.globl write_cgwsel
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
vram_trans: .word 0
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
nmitimen: .byte 0
rdnmi: .byte 0
timeup: .byte 0
hvbjoy: .byte 0

.align 4
// Values that are saved for each frame section (0x40 bytes)
bghofs: .hword 0:4
bgvofs: .hword 0:4
bgnba: .hword 0
oamadd: .hword 0
m7hofs: .hword 0
m7vofs: .hword 0
m7a: .hword 0
m7b: .hword 0
m7c: .hword 0
m7d: .hword 0
m7x: .hword 0
m7y: .hword 0
wbgsel: .hword 0
sub_color: .hword 0
main_color: .hword 0
bgxsc: .byte 0:4
whx: .byte 0:4
obsel: .byte 0
m7sel: .byte 0
wobjsel: .byte 0
wbglog: .byte 0
wobjlog: .byte 0
cgwsel: .byte 0
cgadsub: .byte 0
ts: .byte 0
tm: .byte 0
tsw: .byte 0
tmw: .byte 0
bg_mode: .byte 0
force_blank: .byte 0
split_line: .byte 0

.align 4
// Double-buffered addresses for queued frame data
pal_queues: .word PALETTE_QUEUE1, PALETTE_QUEUE2
oam_queues: .word OAM_QUEUE1, OAM_QUEUE2
dirty_queues: .word DIRTY_QUEUE1, DIRTY_QUEUE2
sect_queues: .word SECTION_QUEUE1, SECTION_QUEUE2

.align 4
// Values that control the cooldown between frame sections (shift, minimum, increment)
section_vals: .word 0x000401, 0x010801, 0x021001, 0x000400, 0x000200, 0x000100

.align 4
vram_funcs: .word 0, vram_trans8, vram_trans9, vram_trans10 // VRAM address translation functions
vram_incrs: .byte 1, 32, 128, 128 // VRAM access address increments

.text
.set noreorder

.align 5
ppu_event:
    // Increment the line counter
    lhu s0, cur_line
    addi s0, s0, 1
    sh s0, cur_line

    // Check if a V-blank start or end event should occur
    lbu t0, vblank_line
    beq s0, t0, vblank_start
    addi t1, t0, -1
    beq s0, t1, pre_vblank
    li t0, 262
    beq s0, t0, vblank_end
    nop

vcount_check:
    // Check if a V-count IRQ event should occur
    lhu t0, vtime
    lhu s0, cur_line
    beq s0, t0, vcount_irq
    nop

run_line:
    // Skip sections and HDMA if currently in V-blank
    lbu t0, hvbjoy
    andi t0, t0, 0x80
    bnez t0, next_line
    nop

    // Decrement the section cooldown if non-zero
    lhu t0, sect_status
    andi t1, t0, 0xFF
    sltu t1, zero, t1
    sub t0, t0, t1

    // Make a new section if dirty and increase the cooldown
    bne t0, 0x100, skip_section
    nop
    lhu a0, cur_line
    jal make_section
    nop
    lbu t2, precision_set
    lbu t0, cooldown
    lbu t1, section_vals + 3(t2) // Increment
    lbu t2, section_vals + 1(t2) // Shift
    add t1, t1, t0
    sb t1, cooldown
    srl t0, t0, t2

skip_section:
    // Update the section status and trigger HDMA
    sh t0, sect_status
    jal trigger_hdma
    nop

next_line:
    // Offset all cycle counts for the next event
    li a0, 341 * 4
    add s5, s5, a0 // CPU
    add s3, s3, a0 // APU
    jal offset_timers
    add a3, a3, a0 // DSP

    // Don't let the CPU run if it's halted
    andi t0, s4, 0x200 // Halted
    beqz t0, cpu_execute
    nop
    li s5, 0
    j cpu_execute
    nop

.align 5
pre_vblank:
    // Set the NMI flag slightly before V-blank to fake interrupt delay
    // This isn't accurate, but it fixes issues in games like Chrono Trigger
    li t0, 0x80
    sb t0, rdnmi
    b vcount_check
    nop

.align 5
vblank_start:
    // Set the V-blank flag
    lbu t0, hvbjoy
    ori t0, t0, 0x80
    sb t0, hvbjoy

    // Skip handling the frame if it was already done
    lbu t0, frame_done
    bnez t0, skip_frame
    nop
    jal rsp_frame
    nop
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
    li a1, 0
    andi s4, s4, 0xFDFF // Unhalt CPU
    la ra, vcount_check
    j trigger_nmi
    nop

.align 5
vblank_end:
    // Clear the V-blank and NMI flags
    lbu t0, hvbjoy
    andi t0, t0, 0x7F
    sb t0, hvbjoy
    sb zero, rdnmi

    // Reset the frame status and start the first section
    lbu t0, precision_set
    lbu t0, section_vals + 2(t0) // Minimum
    sb t0, cooldown
    sh zero, sect_status
    sh zero, cur_line
    jal reload_hdma
    nop
    la ra, vcount_check
    j section_init
    nop

.align 5
vcount_irq:
    // Trigger a V-count IRQ if enabled
    lbu t0, nmitimen
    andi t0, t0, 0x30 // H/V-IRQ enable
    beqz t0, run_line
    andi t1, s4, 0x4 // IRQ disable
    bnez t1, run_line
    andi s4, s4, 0xFDFF // Unhalt CPU
    jal trigger_nmi
    li a1, 4

    // Set the V-count IRQ flag
    li t0, 0x80
    sb t0, timeup
    j run_line
    nop

.align 5
make_section: // a0: line
    // Set bounds for the current frame section
    lw t1, section_ptr
    addi t1, t1, -1
    addi a0, a0, -1
    sb a0, (t1)

section_init:
    // Copy values for the next frame section
    la t0, bghofs
    lw t1, section_ptr
    addi t2, t0, SECTION_SIZE
section_loop:
    ld t3, (t0)
    addi t0, t0, 8
    sd t3, (t1)
    bne t0, t2, section_loop
    addi t1, t1, 8
    sw t1, section_ptr
    jr ra
    nop

.align 5
update_frame:
    // Mark the current frame section as dirty
    li t0, 0x1
    sb t0, sect_status
    jr ra
    nop

.align 5
update_fill:
    // Load the first fill color and both destinations
    lhu t1, coldata
    la t4, sub_color
    la t5, main_color

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

    // Set the fill color and update the frame if changed
    lhu t1, (t4)
    beq t1, t2, next_fill
    li t1, 0x1
    sh t2, (t4)
    sb t1, sect_status

next_fill:
    // Move to the next color until both are done
    beq t4, t5, end_fill
    move t4, t5
    lhu t1, cgram
    b set_fill
    nop
end_fill:
    jr ra
    nop

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
    bnez t6, update_dpal
    addi t4, t4, -8

    // Copy OAM to the queue for the next frame
    la t0, oam
    lw t1, oam_queues(t5)
    li t2, 0x220
oam_loop:
    addi t2, t2, -8
    ld t3, (t0)
    addi t0, t0, 8
    sd t3, (t1)
    bnez t2, oam_loop
    addi t1, t1, 8

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
    bnez t2, dirty_loop
    addi t1, t1, 8

    // Ensure cached VRAM is written back to memory
    la t0, vram
    add t1, t0, 0xFFE0
vram_loop:
    cache 0x19, 0x00(t0)
    cache 0x19, 0x10(t0)
    bne t0, t1, vram_loop
    addi t0, t0, 0x20

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
    nop

    // Update the software-rendered UI
    lw a0, DMEM(FRAMEBUFFER)(t6)
    j update_menu
    nop

menu_return:
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
    lbu t0, layer_set
    lbu t1, fb_border
    lhu t2, cur_line
    lw t3, sect_queues(t5)
    srl t0, t0, 2
    addi t1, t1, 8
    addi t2, t2, -1
    sw t0, DMEM(MASK_SEL)(t5)
    sw t1, DMEM(FB_OFFSET)(t5)
    sw t2, DMEM(FRAME_END)(t5)
    sw t3, DMEM(SECTION_PTR)(t5)

    // Get the address of the next of three framebuffers
    lw t0, DMEM(FRAMEBUFFER)(t6)
    li t1, FRAMEBUFFER2 - FRAMEBUFFER1
    add t0, t0, t1
    li t1, MODE7_TEXTURE
    bne t0, t1, set_buffer
    nop
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
    lui t1, 0xA404
    jr t4
    sw t0, 0x0010(t1) // SP_STATUS

.align 5
vram_trans8: // t0: address, t6: return - t1: output
    // Perform 8-bit translation on a VRAM address
    andi t2, t0, 0x7F00
    sll t3, t0, 3
    andi t3, t3, 0xF8
    or t2, t2, t3
    srl t3, t0, 5
    andi t3, t3, 0x7
    or t1, t2, t3
    jr t6
    sll t1, t1, 1

.align 5
vram_trans9: // t0: address, t6: return - t1: output
    // Perform 9-bit translation on a VRAM address
    andi t2, t0, 0x7E00
    sll t3, t0, 3
    andi t3, t3, 0x1F8
    or t2, t2, t3
    srl t3, t0, 6
    andi t3, t3, 0x7
    or t1, t2, t3
    jr t6
    sll t1, t1, 1

.align 5
vram_trans10: // t0: address, t6: return - t1: output
    // Perform 10-bit translation on a VRAM address
    andi t2, t0, 0x7C00
    sll t3, t0, 3
    andi t3, t3, 0x3F8
    or t2, t2, t3
    srl t3, t0, 7
    andi t3, t3, 0x7
    or t1, t2, t3
    jr t6
    sll t1, t1, 1

.align 5
read_mpyl: // v0: value
    // Read the low byte of the signed multiply result
    lbu v0, mpy + 3
    jr ra
    nop

.align 5
read_mpym: // v0: value
    // Read the middle byte of the signed multiply result
    lbu v0, mpy + 2
    jr ra
    nop

.align 5
read_mpyh: // v0: value
    // Read the high byte of the signed multiply result
    lbu v0, mpy + 1
    jr ra
    nop

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
    jr ra
    srl v0, a0, 8

.align 5
read_rdvraml: // v0: value
    // Read the low byte of the prefetched VRAM data
    lbu v0, vram_fetch + 1
    lbu t2, vram_incl
    beqz t2, vraml_end
    nop

    // Prefetch a new 16-bit value before increment
    lhu t0, vmadd
    lw t3, vram_trans
    sll t1, t0, 1
    bnez t3, vraml_trans
    nop
vraml_ret:
    lhu t1, vram(t1)
    sh t1, vram_fetch

    // Increment the VRAM address
    add t0, t0, t2
    andi t0, t0, 0x7FFF
    sh t0, vmadd
vraml_end:
    jr ra
    nop

vraml_trans:
    // Call the VRAM address translation function if it's set
    la t6, vraml_ret
    jr t3
    nop

.align 5
read_rdvramh: // v0: value
    // Read the low byte of the prefetched VRAM data
    lbu v0, vram_fetch
    lbu t2, vram_inch
    beqz t2, vramh_end
    nop

    // Prefetch a new 16-bit value before increment
    lhu t0, vmadd
    lw t3, vram_trans
    bnez t3, vramh_trans
    sll t1, t0, 1
vramh_ret:
    lhu t1, vram(t1)
    sh t1, vram_fetch

    // Increment the VRAM address
    add t0, t0, t2
    andi t0, t0, 0x7FFF
    sh t0, vmadd
vramh_end:
    jr ra
    nop

vramh_trans:
    // Call the VRAM address translation function if it's set
    la t6, vramh_ret
    jr t3
    nop

.align 5
read_ophct: // v0: value
    // Read from the OPHCT register's low or high byte
    lhu v0, ophct
    lbu t0, oph_low
    beqz t0, oph_toggle
    nop
    srl v0, v0, 8

oph_toggle:
    // Toggle which byte to read next
    xori t0, t0, 0x1
    sb t0, oph_low
    jr ra
    andi v0, v0, 0xFF

.align 5
read_opvct: // v0: value
    // Read from the OPVCT register's low or high byte
    lhu v0, opvct
    lbu t0, opv_low
    beqz t0, opv_toggle
    nop
    srl v0, v0, 8

opv_toggle:
    // Toggle which byte to read next
    xori t0, t0, 0x1
    sb t0, opv_low
    jr ra
    andi v0, v0, 0xFF

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
    nop

.align 5
read_rdnmi: // v0: value
    // Read from the RDNMI register, resetting its flag
    lbu v0, rdnmi
    sb zero, rdnmi
    jr ra
    nop

.align 5
read_timeup: // v0: value
    // Read from the TIMEUP register, resetting its flag
    lbu v0, timeup
    sb zero, timeup
    jr ra
    nop

.align 5
read_hvbjoy: // v0: value
    // Read from the HVBJOY register with H-blank based on cycles until next line
    lbu v0, hvbjoy
    slti t0, s5, (341 - 274) * 4
    sll t0, t0, 6
    jr ra
    or v0, v0, t0

.align 5
write_inidisp: // a1: value
    // Set the force blank bit and update the frame if changed
    lbu t1, force_blank
    andi t0, a1, 0x80
    beq t1, t0, set_bright
    li t1, 0x1
    sb t0, force_blank
    sb t1, sect_status

    // Some games use mid-frame events to achieve a longer V-blank period
    // If force blank is set after a certain line, handle the frame now
    beqz t0, set_bright
    nop
    lbu t1, hvbjoy
    andi t1, t1, 0x80
    bnez t1, set_bright
    li t2, 210
    lhu t1, cur_line
    ble t1, t2, set_bright
    nop
    lbu t1, frame_done
    bnez t1, set_bright
    nop
    sb t0, frame_done
    b rsp_frame

set_bright:
    // Set the master brightness
    andi t0, a1, 0xF
    sgtu t1, t0, zero
    add t0, t0, t1
    sb t0, brightness
    j update_fill
    nop

.align 5
write_obsel: // a1: value
    // Write to the OBSEL register and update the frame if changed
    la t1, obsel
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_oamaddl: // a1: value
    // Set the low byte of the OAM address reload
    lhu t2, oamadd
    andi t1, a1, 0xFF
    andi t0, t2, 0x8100
    or t1, t1, t0
    sh t1, oamadd

    // Reload the OAM address and update the frame if changed
    sll t0, t1, 1
    andi t0, t0, 0x3FE
    sh t0, oam_addr
    bne t2, t1, update_frame
    nop
    jr ra
    nop

.align 5
write_oamaddh: // a1: value
    // Set the high bits of the OAM address reload
    lhu t2, oamadd
    sll t1, a1, 8
    andi t1, t1, 0x8100
    andi t0, t2, 0xFF
    or t1, t1, t0
    sh t1, oamadd

    // Reload the OAM address and update the frame if changed
    sll t0, t1, 1
    andi t0, t0, 0x3FE
    sh t0, oam_addr
    bne t2, t1, update_frame
    nop
    jr ra
    nop

.align 5
write_oamdata: // a1: value
    // Increment the OAM address, wrapping around on overflow
    lhu t0, oam_addr
    blt t0, 0x220, no_wrap
    nop
    addi t0, t0, -0x220
no_wrap:
    addi t1, t0, 1
    sh t1, oam_addr

    // Check if writing to the last 32 bytes, otherwise check for first/second access
    andi t1, t0, 0x200
    bnez t1, oam_end
    andi t1, t0, 0x1
    bnez t1, oam_high
    nop

    // Save the low byte on first access
    sb a1, oam_lsb
    jr ra
    nop

oam_high:
    // Form a 16-bit value with the low byte and store it in OAM
    andi t0, t0, 0x3FE
    lbu t1, oam_lsb
    sll t2, a1, 8
    or t3, t1, t2
    sh t3, oam(t0)
    jr ra
    nop

oam_end:
    // Store an 8-bit value in the last 32 bytes of OAM
    sb a1, oam(t0)
    jr ra
    nop

.align 5
write_bgmode: // a1: value
    // Set the BG screen mode from 0 to 7
    lbu t1, bg_mode
    andi t0, a1, 0xF
    beq t0, 0x9, high_prio
    andi t0, a1, 0xF7

set_mode:
    // Update the frame if changed
    sb t0, bg_mode
    bne t1, t0, update_frame
    nop
    jr ra

high_prio:
    // Set a special mode when mode 1 is set with the BG3 priority bit
    andi t0, a1, 0xF0
    b set_mode
    ori t0, t0, 8

.align 5
write_bg1sc: // a1: value
    // Write to the BG1SC register and update the frame if changed
    la t1, bgxsc + 0
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_bg2sc: // a1: value
    // Write to the BG2SC register and update the frame if changed
    la t1, bgxsc + 1
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_bg3sc: // a1: value
    // Write to the BG3SC register and update the frame if changed
    la t1, bgxsc + 2
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_bg4sc: // a1: value
    // Write to the BG4SC register and update the frame if changed
    la t1, bgxsc + 3
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_bg12nba: // a1: value
    // Set the low byte of the combined BGNBA register and update the frame if changed
    la t1, bgnba + 1
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_bg34nba: // a1: value
    // Set the high byte of the combined BGNBA register and update the frame if changed
    la t1, bgnba + 0
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

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
    nop

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
    nop

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
    nop

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
    nop

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
    nop

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
    nop

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
    nop

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
    nop

.align 5
write_vmain: // a1: value
    // Set the VRAM address translation function
    andi t0, a1, 0xC
    lw t0, vram_funcs(t0)
    sw t0, vram_trans

    // Get the VRAM increment and check if it applies to high or low access
    andi t0, a1, 0x3
    lbu t0, vram_incrs(t0)
    andi t1, a1, 0x80
    bnez t1, vmain_high
    nop

    // Set the VRAM increment for low access
    sb t0, vram_incl
    sb zero, vram_inch
    jr ra
    nop

vmain_high:
    // Set the VRAM increment for high access
    sb zero, vram_incl
    sb t0, vram_inch
    jr ra
    nop

.align 5
write_vmaddl: // a1: value
    // Set the low byte of the VRAM address
    sb a1, vmadd + 1
    b vmadd_prefetch
    nop

write_vmaddh: // a1: value
    // Set the high byte of the VRAM address
    andi t0, a1, 0x7F
    sb t0, vmadd

vmadd_prefetch:
    // Prefetch a 16-bit value for reading
    lhu t0, vmadd
    lw t3, vram_trans
    bnez t3, vmadd_trans
    sll t1, t0, 1
vmadd_ret:
    lhu t0, vram(t1)
    sh t0, vram_fetch
    jr ra
    nop

vmadd_trans:
    // Call the VRAM address translation function if it's set
    la t6, vmadd_ret
    jr t3
    nop

.align 5
write_vmdatal: // a1: value
    // Wait for the RSP semaphore to ensure VRAM copying is done
    lui t1, 0xA404
    lw t0, 0x001C(t1)
    bnez t0, write_vmdatal
    nop
    sw zero, 0x001C(t1)

    // Write to the low VRAM byte at the current address
    lhu t0, vmadd
    lw t3, vram_trans
    bnez t3, datal_trans
    sll t1, t0, 1
datal_ret:
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
    nop

datal_trans:
    // Call the VRAM address translation function if it's set
    la t6, datal_ret
    jr t3
    nop

.align 5
write_vmdatah: // a1: value
    // Wait for the RSP semaphore to ensure VRAM copying is done
    lui t1, 0xA404
    lw t0, 0x001C(t1)
    bnez t0, write_vmdatah
    nop
    sw zero, 0x001C(t1)

    // Write to the high VRAM byte at the current address
    lhu t0, vmadd
    lw t3, vram_trans
    bnez t3, datah_trans
    sll t1, t0, 1
datah_ret:
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
    nop

datah_trans:
    // Call the VRAM address translation function if it's set
    la t6, datah_ret
    jr t3
    nop

.align 5
write_m7sel: // a1: value
    // Write to the M7SEL register and update the frame if changed
    la t1, m7sel
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

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
    nop

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
    nop

.align 5
write_m7c: // a1: value
    // Update M7C with a 16-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sh t0, m7c
    j update_frame
    nop

.align 5
write_m7d: // a1: value
    // Update M7D with a 16-bit value from the old and new bytes
    lbu t0, m7_old
    sll t1, a1, 8
    or t0, t0, t1
    sb a1, m7_old
    sh t0, m7d
    j update_frame
    nop

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
    nop

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
    nop

.align 5
write_cgadd: // a1: value
    // Set the palette address, resetting to first access
    sll t0, a1, 1
    sh t0, cgadd
    jr ra
    nop

.align 5
write_cgdata: // a1: value
    // Increment the palette address and check bit 0 for first/second access
    lhu t0, cgadd
    addi t1, t0, 1
    sh t1, cgadd
    andi t1, t0, 0x1
    bnez t1, cg_high
    nop

    // Save the low byte on first access
    sb a1, cg_lsb
    jr ra
    nop

cg_high:
    // Form a 16-bit value with the low byte and write it to CGRAM
    andi t0, t0, 0x1FE
    lbu t1, cg_lsb
    sll t2, a1, 8
    or t1, t1, t2
    sh t1, cgram(t0)
    beqz t0, update_fill
    nop
    jr ra
    nop

.align 5
write_w12sel: // a1: value
    // Set the low byte of the combined WBGSEL register and update the frame if changed
    la t1, wbgsel + 1
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_w34sel: // a1: value
    // Set the high byte of the combined WBGSEL register and update the frame if changed
    la t1, wbgsel + 0
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_wobjsel: // a1: value
    // Write to the WOBJSEL register and update the frame if changed
    la t1, wobjsel
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_wh0: // a1: value
    // Write to the WH0 register and update the frame if changed
    la t1, whx + 0
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_wh1: // a1: value
    // Write to the WH1 register and update the frame if changed
    la t1, whx + 1
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_wh2: // a1: value
    // Write to the WH2 register and update the frame if changed
    la t1, whx + 2
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_wh3: // a1: value
    // Write to the WH3 register and update the frame if changed
    la t1, whx + 3
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_wbglog: // a1: value
    // Write to the WBGLOG register and update the frame if changed
    la t1, wbglog
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_wobjlog: // a1: value
    // Write to the WOBJLOG register and update the frame if changed
    la t1, wobjlog
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_tm: // a1: value
    // Write to the TM register and update the frame if changed
    la t1, tm
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_ts: // a1: value
    // Write to the TS register and update the frame if changed
    la t1, ts
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_tmw: // a1: value
    // Write to the TMW register and update the frame if changed
    la t1, tmw
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_tsw: // a1: value
    // Write to the TSW register and update the frame if changed
    la t1, tsw
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_cgwsel: // a1: value
    // Write to the CGWSEL register and update the frame if changed
    la t1, cgwsel
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

.align 5
write_cgadsub: // a1: value
    // Write to the CGADSUB register and update the frame if changed
    la t1, cgadsub
    lbu t0, (t1)
    bne t0, a1, update_frame
    sb a1, (t1)
    jr ra
    nop

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
    addi t3, t3, -1
    bnez t3, next_channel
    sll t2, t2, 5
    sh t0, coldata
    j update_fill
    nop

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
    nop
    addi t1, t1, -15
no_border:
    sb t1, vblank_line
    jr ra
    nop

.align 5
write_nmitimen: // a1: value
    // Write to the NMITIMEN register
    sb a1, nmitimen
    jr ra
    nop

.align 5
write_vtimel: // a1: value
    // Write the low byte of the V-count timer value
    sb a1, vtime + 1
    jr ra
    nop

.align 5
write_vtimeh: // a1: value
    // Write the high bit of the V-count timer value
    andi t0, a1, 0x1
    sb t0, vtime
    jr ra
    nop
