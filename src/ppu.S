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

.globl frame_count

.globl ppu_event
.globl read_mpyl
.globl read_mpym
.globl read_mpyh
.globl read_rdnmi
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
.globl write_m7a
.globl write_m7b
.globl write_cgadd
.globl write_cgdata
.globl write_tm
.globl write_ts
.globl write_setini
.globl write_nmitimen

.data

cgram: .hword 0:0x100
oam:   .byte  0:0x220
vram:  .byte  0:0x10000

frame_count: .byte 0x00
brightness:  .byte 0x00
bg_type:     .byte 0x55
vram_incl:   .byte 0x00
vram_inch:   .byte 0x00

oam_reload: .hword 0x0000
oam_lsb:    .byte  0x00
bg_old:     .byte  0x00
m7_old:     .byte  0x00
cg_lsb:     .byte  0x00

mpy:      .word  0x000000
oamadd:   .hword 0x0000
vmadd:    .hword 0x0000
cgadd:    .hword 0x0000
m7a:      .hword 0x0000
m7b:      .byte  0x00
tm:       .byte  0x00
ts:       .byte  0x00
nmitimen: .byte  0x00
rdnmi:    .byte  0x00
hvbjoy:   .byte  0x00

// Mirrors of RSP values
fb_border:   .word 0x1000   // 0xF88-0xF8B
obj_enable:  .word 0x00     // 0xF8C-0xF8F
bg_order:    .word 0x1B     // 0xF90-0xF93
bg_type2:    .word 0x00     // 0xF94-0xF97
objcharbase: .word 0x0000   // 0xF98-0xF9B
bgscrnbase:  .word 0x0000:4 // 0xF9C-0xFAB
bgbaseofsh:  .word 0x0000:4 // 0xFAC-0xFBB
bgbaseofsv:  .word 0x0000:4 // 0xFBC-0xFCB
bgcharbase:  .word 0x0000:4 // 0xFCC-0xFDB
bghofs:      .word 0x0000:4 // 0xFDC-0xFEB
bgvofs:      .word 0x0000:4 // 0xFEC-0xFFB

// 2 bits per BG; the order they should be drawn in
bg_orders: .byte 0x1B, 0x87

// 2 bits per BG: 0 = none, 1 = 4-color, 2 = 16-color, 3 = 256-color
// TODO: offset-per-tile, hi-res, rotscale
bg_types:
    .byte 0x55, 0x1A, 0x0A, 0x0B, 0x07, 0x00, 0x00, 0x00

// Masks for the BG type to disable certain layers
bg_masks:
    .byte 0x00, 0x03, 0x0C, 0x0F, 0x30, 0x33, 0x3C, 0x3F
    .byte 0xC0, 0xC3, 0xCC, 0xCF, 0xF0, 0xF3, 0xFC, 0xFF

// Possible offsets for additional screens past the base
scrn_ofsh: .hword 0x0000, 0x0800, 0x0000, 0x0800
scrn_ofsv: .hword 0x0000, 0x0000, 0x0800, 0x1000

// Possible address increments for VRAM access
vram_incrs: .byte 1, 32, 128, 128

.text

ppu_event:
    // Check the current V-blank flag
    lbu  t0, hvbjoy
    bge  t0, 0x80, vblank_end

vblank_start:
    // Set the V-blank and NMI flags
    or   t0, t0, 0x80
    sb   t0, hvbjoy
    li   t0, 0x80
    sb   t0, rdnmi

rsp_wait:
    // Wait until the RSP is finished rendering
    lw   t0, 0xA4040010 // SP_STATUS_REG
    andi t0, t0, 0x0001 // Halt
    beqz t0, rsp_wait

    // Increment the frame counter with VI interrupts disabled
    li   t0, 1 << 6     // Clear VI mask
    sw   t0, 0xA430000C // MI_INTR_MASK_REG
    lbu  t0, frame_count
    addi t0, t0, 1
    sb   t0, frame_count
    li   t0, 1 << 7     // Set VI mask
    sw   t0, 0xA430000C // MI_INTR_MASK_REG

    // Prepare to update the RSP's palette in DMEM
    lbu  t0, brightness
    li   t9, 0x200

update_dpal:
    // Move to the next palette color
    addi t9, t9, -2
    lhu  t1, cgram(t9)
    li   t3, 0x0001

    // Apply brightness to the red component and shift for N64 format
    andi t2, t1, 0x1F
    mult t2, t0
    mflo t2
    srl  t2, t2, 4
    sll  t2, t2, 11
    or   t3, t3, t2

    // Apply brightness to the green component and shift for N64 format
    srl  t2, t1, 5
    andi t2, t2, 0x1F
    mult t2, t0
    mflo t2
    srl  t2, t2, 4
    sll  t2, t2, 6
    or   t3, t3, t2

    // Apply brightness to the blue component and shift for N64 format
    srl  t2, t1, 10
    andi t2, t2, 0x1F
    mult t2, t0
    mflo t2
    srl  t2, t2, 4
    sll  t2, t2, 1
    or   t3, t3, t2

    // DMEM access from the main CPU is 32-bit, so check if this is a low or high half-word
    andi t7, t9, 0x1FF & ~3
    la   t8, 0xA4000220 // Palette in DMEM
    add  t8, t8, t7
    bne  t7, t9, dpal_high

    // Change the low half-word and loop until the palette is finished
    lw   t7, (t8)
    andi t7, t7, 0xFFFF
    sll  t3, t3, 16
    or   t3, t3, t7
    sw   t3, (t8)
    bnez t9, update_dpal
    b    update_oam

dpal_high:
    // Change the high half-word and loop until the palette is finished
    lw   t7, (t8)
    lui  t6, 0xFFFF
    and  t7, t7, t6
    or   t3, t3, t7
    sw   t3, (t8)
    bnez t9, update_dpal

update_oam:
    // Update the RSP's copy of OAM in DMEM
    la   t0, oam
    la   t1, oam + 0x220
    la   t2, 0xA4000420
oam_loop:
    lw   t3, (t0)
    addi t0, t0, 4
    sw   t3, (t2)
    addi t2, t2, 4
    bne  t0, t1, oam_loop

update_vram:
    // Update the RSP's copy of VRAM
    la   t0, vram
    la   t1, vram + 0x10000
    la   t2, 0xA03F0000
vram_loop:
    lw   t3, (t0)
    addi t0, t0, 4
    sw   t3, (t2)
    addi t2, t2, 4
    bne  t0, t1, vram_loop

    // Update the RSP's register values in DMEM
    la   t0, fb_border
    la   t1, bg_orders
    la   t2, 0xA4000F88
reg_loop:
    lw   t3, (t0)
    addi t0, t0, 4
    sw   t3, (t2)
    addi t2, t2, 4
    bne  t0, t1, reg_loop

frame_wait:
    // Wait for a framebuffer to be available
    lbu  t0, frame_count
    beq  t0, 2, frame_wait

    // Unhalt the RSP so it can render the next frame
    li   t0, 0x0001     // Clear halt
    sw   t0, 0xA4040010 // SP_STATUS_REG

    // Schedule the V-blank end and trigger an NMI if enabled
    li   t0, 341 * 37 * 4 // V-blank period
    add  s5, s5, t0
    add  s3, s3, t0
    lbu  t0, nmitimen
    blt  t0, 0x80, cpu_execute
    j    trigger_nmi

vblank_end:
    // Clear the V-blank and NMI flags
    andi t0, t0, ~0x80 & 0xFF
    sb   t0, hvbjoy
    sb   zero, rdnmi

    // Schedule the V-blank start or skip to it if halted
    bge  s4, 0x200, vblank_start
    li   t0, 341 * 225 * 4
    add  s5, s5, t0
    add  s3, s3, t0
    j    cpu_execute


read_mpyl: // v0: value
    // Read the low byte of the signed multiply result
    lbu  v0, mpy + 3
    jr   ra


read_mpym: // v0: value
    // Read the middle byte of the signed multiply result
    lbu  v0, mpy + 2
    jr   ra


read_mpyh: // v0: value
    // Read the high byte of the signed multiply result
    lbu  v0, mpy + 1
    jr   ra


read_rdnmi: // v0: value
    // Read from the RDNMI register, resetting its flag
    lbu  v0, rdnmi
    sb   zero, rdnmi
    jr   ra


read_hvbjoy: // v0: value
    // Read from the HVBJOY register
    lbu  v0, hvbjoy
    jr   ra


write_inidisp: // a1: value
    // Check for zero values and the force blank bit
    beqz a1, blank
    andi t0, a1, 0x80
    beqz t0, no_blank

blank:
    // Force the screen blank
    sb   zero, brightness
    jr   ra

no_blank:
    // Set the master brightness
    addi t0, a1, 1
    sb   t0, brightness
    jr   ra


write_obsel: // a1: value
    // Update the OBJ character base address in DMEM
    // TODO: OBJ size, gap
    andi t0, a1, 0x3
    sll  t0, t0, 14
    sw   t0, objcharbase
    jr   ra


write_oamaddl: // a1: value
    // Set the low byte of the OAM reload and reload the address
    sb   a1, oam_reload + 1
    lhu  t0, oam_reload
    sll  t0, t0, 1
    sh   t0, oamadd
    jr   ra


write_oamaddh: // a1: value
    // Set the high bit of the OAM reload and reload the address
    andi t0, a1, 0x01
    sb   t0, oam_reload
    lhu  t0, oam_reload
    sll  t0, t0, 1
    sh   t0, oamadd
    jr   ra


write_oamdata: // a1: value
    // Increment the OAM address, wrapping around on overflow
    lhu  t0, oamadd
    blt  t0, 0x220, no_wrap
    addi t0, t0, -0x220
no_wrap:
    addi t1, t0, 1
    sh   t1, oamadd

    // Check if writing to the last 32 bytes, otherwise check for first/second access
    andi t1, t0, 0x200
    bnez t1, oam_end
    andi t1, t0, 1
    bnez t1, oam_high

    // Save the low byte on first access
    sb   a1, oam_lsb
    jr   ra

oam_high:
    // Form a 16-bit value with the low byte and store it in OAM
    andi t0, t0, 0x3FF & ~1
    lbu  t1, oam_lsb
    sll  t2, a1, 8
    or   t3, t1, t2
    sh   t3, oam(t0)
    jr   ra

oam_end:
    // Store an 8-bit value in the last 32 bytes of OAM
    sb   a1, oam(t0)
    jr   ra


write_bgmode: // a1: value
    // Set the appropriate BG type from the mode bits
    // TODO: tile size
    andi t0, a1, 0x07
    lbu  t0, bg_types(t0)
    sb   t0, bg_type

    // Update the masked BG type in DMEM
    lbu  t1, tm
    lbu  t2, ts
    or   t1, t1, t2
    andi t1, t1, 0x0F
    lbu  t1, bg_masks(t1)
    and  t0, t0, t1
    sw   t0, bg_type2

    // Update the BG order in DMEM (BG3 is top priority if bit 3 is set in mode 1)
    andi t0, a1, 0x0F
    seq  t0, t0, 0x09
    lbu  t0, bg_orders(t0)
    sw   t0, bg_order
    jr   ra


write_bg1sc: // a1: value
    // Update BG1's screen base address in DMEM
    andi t0, a1, 0x7C
    sll  t0, t0, 9
    sw   t0, bgscrnbase + 0

    // Update BG1's horizontal base offset in DMEM
    andi t1, a1, 0x03
    sll  t1, t1, 1
    lhu  t0, scrn_ofsh(t1)
    sw   t0, bgbaseofsh + 0

    // Update BG1's vertical base offset in DMEM
    lhu  t0, scrn_ofsv(t1)
    sw   t0, bgbaseofsv + 0
    jr   ra


write_bg2sc: // a1: value
    // Update BG2's screen base address in DMEM
    andi t0, a1, 0x7C
    sll  t0, t0, 9
    sw   t0, bgscrnbase + 4

    // Update BG2's horizontal base offset in DMEM
    andi t1, a1, 0x03
    sll  t1, t1, 1
    lhu  t0, scrn_ofsh(t1)
    sw   t0, bgbaseofsh + 4

    // Update BG2's vertical base offset in DMEM
    lhu  t0, scrn_ofsv(t1)
    sw   t0, bgbaseofsv + 4
    jr   ra


write_bg3sc: // a1: value
    // Update BG3's screen base address in DMEM
    andi t0, a1, 0x7C
    sll  t0, t0, 9
    sw   t0, bgscrnbase + 8

    // Update BG3's horizontal base offset in DMEM
    andi t1, a1, 0x03
    sll  t1, t1, 1
    lhu  t0, scrn_ofsh(t1)
    sw   t0, bgbaseofsh + 8

    // Update BG3's vertical base offset in DMEM
    lhu  t0, scrn_ofsv(t1)
    sw   t0, bgbaseofsv + 8
    jr   ra


write_bg4sc: // a1: value
    // Update BG4's screen base address in DMEM
    andi t0, a1, 0x7C
    sll  t0, t0, 9
    sw   t0, bgscrnbase + 12

    // Update BG4's horizontal base offset in DMEM
    andi t1, a1, 0x03
    sll  t1, t1, 1
    lhu  t0, scrn_ofsh(t1)
    sw   t0, bgbaseofsh + 12

    // Update BG4's vertical base offset in DMEM
    lhu  t0, scrn_ofsv(t1)
    sw   t0, bgbaseofsv + 12
    jr   ra


write_bg12nba: // a1: value
    // Update BG1's character base address in DMEM
    andi t0, a1, 0x07
    sll  t0, t0, 13
    sw   t0, bgcharbase + 0

    // Update BG2's character base address in DMEM
    andi t0, a1, 0x70
    sll  t0, t0, 9
    sw   t0, bgcharbase + 4
    jr   ra


write_bg34nba: // a1: value
    // Update BG3's character base address in DMEM
    andi t0, a1, 0x07
    sll  t0, t0, 13
    sw   t0, bgcharbase + 8

    // Update BG4's character base address in DMEM
    andi t0, a1, 0x70
    sll  t0, t0, 9
    sw   t0, bgcharbase + 12
    jr   ra


write_bg1hofs: // a1: value
    // Update BG1HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, bghofs + 0
    jr   ra


write_bg1vofs: // a1: value
    // Update BG1VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, bgvofs + 0
    jr   ra


write_bg2hofs: // a1: value
    // Update BG2HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, bghofs + 4
    jr   ra


write_bg2vofs: // a1: value
    // Update BG2VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, bgvofs + 4
    jr   ra


write_bg3hofs: // a1: value
    // Update BG3HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, bghofs + 8
    jr   ra


write_bg3vofs: // a1: value
    // Update BG3VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, bgvofs + 8
    jr   ra


write_bg4hofs: // a1: value
    // Update BG4HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, bghofs + 12
    jr   ra


write_bg4vofs: // a1: value
    // Update BG4VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, bgvofs + 12
    jr   ra


write_vmain: // a1: value
    // Get the VRAM increment and check if it applies to high or low access
    // TODO: address translation
    andi t0, a1, 0x03
    lbu  t0, vram_incrs(t0)
    andi t1, a1, 0x80
    bnez t1, vmain_high

    // Set the VRAM increment for low access
    sb   t0, vram_incl
    sb   zero, vram_inch
    jr   ra

vmain_high:
    // Set the VRAM increment for high access
    sb   zero, vram_incl
    sb   t0, vram_inch
    jr   ra


write_vmaddl: // a1: value
    // Set the low byte of the VRAM address
    sb   a1, vmadd + 1
    jr   ra


write_vmaddh: // a1: value
    // Set the high byte of the VRAM address
    andi t0, a1, 0x7F
    sb   t0, vmadd
    jr   ra


write_vmdatal: // a1: value
    // Write to the low VRAM byte at the current address
    lhu  t0, vmadd
    sll  t1, t0, 1
    sb   a1, 1 + vram(t1)

    // Increment the VRAM address
    lbu  t1, vram_incl
    add  t0, t0, t1
    andi t0, t0, 0x7FFF
    sh   t0, vmadd
    jr   ra


write_vmdatah: // a1: value
    // Write to the high VRAM byte at the current address
    lhu  t0, vmadd
    sll  t1, t0, 1
    sb   a1, vram(t1)

    // Increment the VRAM address
    lbu  t1, vram_inch
    add  t0, t0, t1
    andi t0, t0, 0x7FFF
    sh   t0, vmadd
    jr   ra


write_m7a: // a1: value
    // Update M7A with a 16-bit value from the old and new bytes
    lbu  t0, m7_old
    sll  t1, a1, 8
    or   t0, t0, t1
    sb   a1, m7_old
    sh   t0, m7a

    // Update the signed multiply result
    lh   t0, m7a
    lb   t1, m7b
    mult t0, t1
    mflo t0
    sw   t0, mpy
    jr   ra


write_m7b: // a1: value
    // Update M7B and the old byte
    sb   a1, m7_old
    sb   a1, m7b

    // Update the signed multiply result
    lh   t0, m7a
    lb   t1, m7b
    mult t0, t1
    mflo t0
    sw   t0, mpy
    jr   ra


write_cgadd: // a1: value
    // Set the palette address, resetting to first access
    sll  t0, a1, 1
    sh   t0, cgadd
    jr   ra


write_cgdata: // a1: value
    // Increment the palette address and check bit 0 for first/second access
    lhu  t0, cgadd
    addi t1, t0, 1
    sh   t1, cgadd
    andi t1, t0, 1
    bnez t1, cg_high

    // Save the low byte on first access
    sb   a1, cg_lsb
    jr   ra

cg_high:
    // Form a 16-bit value with the low byte and write it to CGRAM
    andi t0, t0, 0x1FF & ~1
    lbu  t1, cg_lsb
    sll  t2, a1, 8
    or   t1, t1, t2
    sh   t1, cgram(t0)
    jr   ra


write_tm: // a1: value
    // Set the main layer mask and apply the BG type mask to disable layers
    sb   a1, tm
    lbu  t0, ts
    or   t0, t0, a1
    srl  t4, t0, 4
    andi t0, t0, 0x0F
    lbu  t0, bg_masks(t0)
    lbu  t1, bg_type
    and  t0, t0, t1

    // Update the masked BG type and OBJ enable in DMEM
    sw   t0, bg_type2
    sw   t4, obj_enable
    jr   ra


write_ts: // a1: value
    // Set the sub layer mask and apply the BG type mask to disable layers
    // The sub screen isn't implemented yet, so the main and sub masks are combined
    sb   a1, ts
    lbu  t0, tm
    or   t0, t0, a1
    srl  t4, t0, 4
    andi t0, t0, 0x0F
    lbu  t0, bg_masks(t0)
    lbu  t1, bg_type
    and  t0, t0, t1

    // Update the masked BG type and OBJ enable in DMEM
    sw   t0, bg_type2
    sw   t4, obj_enable
    jr   ra


write_setini: // a1: value
    // Set an 8-pixel border if 224-line mode is set
    // TODO: use the rest of the bits
    andi t0, a1, 0x04
    sll  t0, t0, 10
    xori t0, t0, 0x1000
    sw   t0, fb_border
    jr   ra


write_nmitimen: // a1: value
    // Write to the NMITIMEN register
    sb   a1, nmitimen
    jr   ra
