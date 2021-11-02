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

.globl frame_ready

.globl ppu_event
.globl read_rdnmi
.globl read_hvbjoy
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
.globl write_cgadd
.globl write_cgdata
.globl write_tm
.globl write_ts
.globl write_nmitimen

.data

cgram: .hword 0:0x100

frame_ready: .byte 0x00
bg_type:     .byte 0x55
vram_incl:   .byte 0x00
vram_inch:   .byte 0x00

oam_reload: .hword 0x0000
oam_lsb:    .byte  0x00
bg_old:     .byte  0x00
cg_lsb:     .byte  0x00

oamadd:   .hword 0x0000
vmadd:    .hword 0x0000
cgadd:    .hword 0x0000
tm:       .byte  0x00
ts:       .byte  0x00
nmitimen: .byte  0x00
rdnmi:    .byte  0x00
hvbjoy:   .byte  0x00

// 2 bits per BG; the order they should be drawn in
bg_orders: .byte 0xE4, 0xD2

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

    // Wait until the RSP is finished rendering
rsp_wait:
    lw   t0, 0xA4040010 // SP_STATUS_REG
    andi t0, t0, 0x0001 // Halt
    beq  t0, zero, rsp_wait

    // Indicate a new frame is ready
    li   t0, 0x01
    sb   t0, frame_ready

    // Schedule the V-blank end and trigger an NMI if enabled
    add  s5, 341 * 36 * 4 // V-blank period
    lbu  t0, nmitimen
    blt  t0, 0x80, no_nmi
    j    trigger_nmi

vblank_end:
    // Clear the V-blank and NMI flags
    andi t0, t0, ~0x80 & 0xFF
    sb   t0, hvbjoy
    sb   zero, rdnmi

    // Wait for the last frame to be displayed
frame_wait:
    lbu  t0, frame_ready
    bne  t0, zero, frame_wait

    // Unhalt the RSP so it can render the next frame
    li   t0, 0x0001     // Clear halt
    sw   t0, 0xA4040010 // SP_STATUS_REG

    // Schedule the V-blank start or skip to it if halted
    bge  s4, 0x200, vblank_start
    add  s5, 341 * 225 * 4
no_nmi:
    j    cpu_execute


read_rdnmi: // v0: value
    // Read from the RDNMI register, resetting its flag
    lbu  v0, rdnmi
    sb   zero, rdnmi
    jr   ra


read_hvbjoy: // v0: value
    // Read from the HVBJOY register
    lbu  v0, hvbjoy
    jr   ra


write_obsel: // a1: value
    // Update the OBJ character base address in DMEM
    // TODO: OBJ size, gap
    andi t0, a1, 0x3
    sll  t0, t0, 14
    sw   t0, 0xA4000F98
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
    bne  t1, zero, oam_end
    andi t1, t0, 1
    bne  t1, zero, oam_high

    // Save the low byte on first access
    sb   a1, oam_lsb
    jr   ra

oam_high:
    // Form a 16-bit value with the low byte
    andi t0, t0, 0x3FF & ~1
    lbu  t1, oam_lsb
    sll  t2, a1, 8
    or   t3, t1, t2

    // Update the OAM data in DMEM
    // DMEM access from the main CPU is 32-bit, so check if this is a low or high half-word
    andi t1, t0, 0x3FF & ~3
    la   t2, 0xA4000400 // OAM in DMEM
    add  t2, t2, t1
    bne  t1, t0, doam_high

    // Change the low half-word and write the value back
    lw   t0, (t2)
    andi t0, t0, 0xFFFF
    sll  t3, t3, 16
    or   t3, t3, t0
    sw   t3, (t2)
    jr   ra

doam_high:
    // Change the high half-word and write the value back
    lw   t0, (t2)
    lui  t1, 0xFFFF
    and  t0, t0, t1
    or   t3, t3, t0
    sw   t3, (t2)
    jr   ra

oam_end:
    // Create a mask and shift the value based on which byte is being written
    andi t1, t0, 0x3
    xori t1, t1, 0x3
    sll  t1, t1, 3
    li   t2, 0xFF
    sll  t2, t2, t1
    not  t2, t2
    sll  t3, a1, t1

    // Update the DMEM word containing the byte
    andi t0, t0, 0x3FF & ~3
    la   t4, 0xA4000400 // OAM in DMEM
    add  t0, t0, t4
    lw   t4, (t0)
    and  t4, t4, t2
    or   t4, t4, t3
    sw   t4, (t0)
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
    sw   t0, 0xA4000F94

    // Update the BG order in DMEM (BG3 is top priority if bit 3 is set in mode 1)
    andi t0, a1, 0x0F
    seq  t0, t0, 0x09
    lbu  t0, bg_orders(t0)
    sw   t0, 0xA4000F90
    jr   ra


write_bg1sc: // a1: value
    // Update BG1's screen base address in DMEM
    andi t0, a1, 0x7C
    sll  t0, t0, 9
    sw   t0, 0xA4000F9C

    // Update BG1's horizontal base offset in DMEM
    andi t1, a1, 0x03
    sll  t1, t1, 1
    lhu  t0, scrn_ofsh(t1)
    sw   t0, 0xA4000FAC

    // Update BG1's vertical base offset in DMEM
    lhu  t0, scrn_ofsv(t1)
    sw   t0, 0xA4000FBC
    jr   ra


write_bg2sc: // a1: value
    // Update BG2's screen base address in DMEM
    andi t0, a1, 0x7C
    sll  t0, t0, 9
    sw   t0, 0xA4000FA0

    // Update BG2's horizontal base offset in DMEM
    andi t1, a1, 0x03
    sll  t1, t1, 1
    lhu  t0, scrn_ofsh(t1)
    sw   t0, 0xA4000FB0

    // Update BG2's vertical base offset in DMEM
    lhu  t0, scrn_ofsv(t1)
    sw   t0, 0xA4000FC0
    jr   ra


write_bg3sc: // a1: value
    // Update BG3's screen base address in DMEM
    andi t0, a1, 0x7C
    sll  t0, t0, 9
    sw   t0, 0xA4000FA4

    // Update BG3's horizontal base offset in DMEM
    andi t1, a1, 0x03
    sll  t1, t1, 1
    lhu  t0, scrn_ofsh(t1)
    sw   t0, 0xA4000FB4

    // Update BG3's vertical base offset in DMEM
    lhu  t0, scrn_ofsv(t1)
    sw   t0, 0xA4000FC4
    jr   ra


write_bg4sc: // a1: value
    // Update BG4's screen base address in DMEM
    andi t0, a1, 0x7C
    sll  t0, t0, 9
    sw   t0, 0xA4000FA8

    // Update BG4's horizontal base offset in DMEM
    andi t1, a1, 0x03
    sll  t1, t1, 1
    lhu  t0, scrn_ofsh(t1)
    sw   t0, 0xA4000FB8

    // Update BG4's vertical base offset in DMEM
    lhu  t0, scrn_ofsv(t1)
    sw   t0, 0xA4000FC8
    jr   ra


write_bg12nba: // a1: value
    // Update BG1's character base address in DMEM
    andi t0, a1, 0x07
    sll  t0, t0, 13
    sw   t0, 0xA4000FCC

    // Update BG2's character base address in DMEM
    andi t0, a1, 0x70
    sll  t0, t0, 9
    sw   t0, 0xA4000FD0
    jr   ra


write_bg34nba: // a1: value
    // Update BG3's character base address in DMEM
    andi t0, a1, 0x07
    sll  t0, t0, 13
    sw   t0, 0xA4000FD4

    // Update BG4's character base address in DMEM
    andi t0, a1, 0x70
    sll  t0, t0, 9
    sw   t0, 0xA4000FD8
    jr   ra


write_bg1hofs: // a1: value
    // Update BG1HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, 0xA4000FDC
    jr   ra


write_bg1vofs: // a1: value
    // Update BG1VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, 0xA4000FEC
    jr   ra


write_bg2hofs: // a1: value
    // Update BG2HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, 0xA4000FE0
    jr   ra


write_bg2vofs: // a1: value
    // Update BG2VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, 0xA4000FF0
    jr   ra


write_bg3hofs: // a1: value
    // Update BG3HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, 0xA4000FE4
    jr   ra


write_bg3vofs: // a1: value
    // Update BG3VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, 0xA4000FF4
    jr   ra


write_bg4hofs: // a1: value
    // Update BG4HOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, 0xA4000FE8
    jr   ra


write_bg4vofs: // a1: value
    // Update BG4VOFS in DMEM with a 10-bit value from the old and new bytes
    lbu  t0, bg_old
    andi t1, a1, 0x3
    sll  t1, t1, 8
    or   t0, t0, t1
    sb   a1, bg_old
    sw   t0, 0xA4000FF8
    jr   ra


write_vmain: // a1: value
    // Get the VRAM increment and check if it applies to high or low access
    // TODO: address translation
    andi t0, a1, 0x03
    lbu  t0, vram_incrs(t0)
    andi t1, a1, 0x80
    bne  t1, zero, vmain_high

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
    sb   a1, 0xA03F0001(t1)

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
    sb   a1, 0xA03F0000(t1)

    // Increment the VRAM address
    lbu  t1, vram_inch
    add  t0, t0, t1
    andi t0, t0, 0x7FFF
    sh   t0, vmadd
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
    bne  t1, zero, cg_high

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

    // Rearrange the RGB components to be N64 format
    andi t2, t1, 0x1F << 0  // R
    sll  t3, t2, 11
    andi t2, t1, 0x1F << 5  // G
    sll  t2, t2, 1
    or   t3, t3, t2
    andi t2, t1, 0x1F << 10 // B
    srl  t2, t2, 9
    or   t3, t3, t2
    ori  t3, t3, 0x0001 // A

    // Update the RSP's converted palette in DMEM
    // DMEM access from the main CPU is 32-bit, so check if this is a low or high half-word
    andi t1, t0, 0x1FF & ~3
    la   t2, 0xA4000200 // Palette in DMEM
    add  t2, t2, t1
    bne  t1, t0, dpal_high

    // Change the low half-word and write the value back
    lw   t0, (t2)
    andi t0, t0, 0xFFFF
    sll  t3, t3, 16
    or   t3, t3, t0
    sw   t3, (t2)
    jr   ra

dpal_high:
    // Change the high half-word and write the value back
    lw   t0, (t2)
    lui  t1, 0xFFFF
    and  t0, t0, t1
    or   t3, t3, t0
    sw   t3, (t2)
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
    sw   t0, 0xA4000F94
    sw   t4, 0xA4000F8C
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
    sw   t0, 0xA4000F94
    sw   t4, 0xA4000F8C
    jr   ra


write_nmitimen: // a1: value
    // Write to the NMITIMEN register
    sb   a1, nmitimen
    jr   ra
