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

#include <rsp.inc>

.set reorder

.data

scanline:  .byte 0:0x200
palette:   .byte 0:0x200
oam:       .byte 0:0x220
scrn_data: .byte 0:0x80
char_data: .byte 0:0x40

.space 0x8AC

obj_enable:  .word 0x00       // 0xF8C-0xF8F
bg_order:    .word 0xE4       // 0xF90-0xF93
bg_type:     .word 0x00       // 0xF94-0xF97
objcharbase: .word 0x0000     // 0xF98-0xF9B
bgscrnbase:  .word 0x0000:4   // 0xF9C-0xFAB
bgbaseofsh:  .word 0x0000:4   // 0xFAC-0xFBB
bgbaseofsv:  .word 0x0000:4   // 0xFBC-0xFCB
bgcharbase:  .word 0x0000:4   // 0xFCC-0xFDB
bghofs:      .word 0x0000:4   // 0xFDC-0xFEB
bgvofs:      .word 0x0000:4   // 0xFEC-0xFFB
framebuffer: .word 0xA0320000 // 0xFFC-0xFFF

.text

draw_frame:
    // Set initial values for the frame
    li   s0, 0   // Current X coordinate
    li   s1, 0   // Current Y coordinate
    li   s2, 256 // Maximum X coordinate
    li   s3, 224 // Maximum Y coordinate
    li   a3, 0   // Current BG shift

draw_line:
    // Clear the scanline with the backdrop color
    lhu  t0, palette
    andi t0, t0, 0xFFFE
    sll  t1, t0, 16
    or   t0, t0, t1
    li   t1, 0
    li   t2, 0x200
clear_line:
    sw   t0, scanline(t1)
    addi t1, t1, 4
    bne  t1, t2, clear_line

    // Check if objects are enabled
    lw   t0, obj_enable
    beq  t0, zero, draw_bg
    li   t3, 0

    // Set the character offset for objects
    la   a0, char_data
    la   s5, 0xA0340000
    lw   t1, objcharbase
    add  s5, s5, t1
    li   a2, 0x001F

draw_object:
    // Get the object's Y coordinate and test bounds
    lhu  t1, oam(t3)
    srl  t2, t1, 8
    blt  s1, t2, next_object
    addi t2, t2, 8
    bge  s1, t2, next_object

    // Get the object's X coordinate, including the high bit
    andi t1, t1, 0xFF
    srl  t4, t3, 4
    lbu  t4, oam + 0x200(t4)
    srl  t5, t3, 1
    andi t5, t5, 0x3 << 1
    srl  t4, t4, t5
    andi t4, t4, 0x1
    sll  t4, t4, 8
    or   t1, t1, t4

    // Set the initial tile shift and step based on horizontal mirroring
    li   s6, 7
    li   s7, -1
    lhu  t9, oam + 2(t3)
    andi t8, t9, 0x4000
    beq  t8, zero, objmir_notx
    li   s6, 0
    li   s7, 1

objmir_notx:
    // Load the tile's character data based on fine Y offset and vertical mirroring
    // TODO: priority, size
    andi t8, t9, 0x01FF
    sll  t8, t8, 5
    add  a1, s5, t8
    sub  t2, s1, t2
    andi t2, t2, 0x7
    sll  t2, t2, 1
    add  a1, a1, t2
    andi t8, t9, 0x8000
    beq  t8, zero, objmir_noty
    xori a1, a1, 7 << 1
objmir_noty:
    jal  dma_read

    // DMA aligns to 64-bit words, so adjust the data offset accordingly
    andi t5, a1, 7

    // Prepare data for 16-color tiles
    lhu  t6, char_data + 0x00(t5)
    lhu  t7, char_data + 0x10(t5)
    sll  t7, t7, 2
    srl  t8, t9, 4
    andi t8, t8, 0x7 << 5 // Palette offset
    sll  t1, t1, 1
    addi t2, t1, 8 << 1

draw_objpix:
    // Don't draw outside of scanline bounds
    bge  t1, 0x200, next_object
    li   t4, 0

    // Decode bits 2-3 of the palette index
    srl  s4, t7, s6
    andi t5, s4, 0x04
    or   t4, t4, t5
    srl  t5, s4, 7
    andi t5, t5, 0x08
    or   t4, t4, t5

    // Decode bits 0-1 of the palette index
    srl  s4, t6, s6
    andi t5, s4, 0x01
    or   t4, t4, t5
    srl  t5, s4, 7
    andi t5, t5, 0x02
    or   t4, t4, t5

    // Draw a pixel with the palette color
    beq  t4, zero, skip_objpix
    sll  t4, t4, 1
    add  t4, t4, t8
    lhu  t4, palette + 0x100(t4)
    sh   t4, scanline(t1)

skip_objpix:
    // Move to the next pixel until the object bounds
    addi t1, t1, 2
    add  s6, s6, s7
    bne  t1, t2, draw_objpix

next_object:
    // Move to the next object until all are drawn
    addi t3, t3, 4
    andi t3, t3, 0x1FF
    bne  t3, zero, draw_object

draw_bg:
    // Get the index for the current BG
    lw   t1, bg_order
    srl  t1, t1, a3
    andi t1, t1, 0x3
    sll  t1, t1, 1

    // Get the character data shift from the BG type
    lw   s4, bg_type
    srl  s4, s4, t1
    andi s4, s4, 0x3
    beq  s4, zero, next_bg
    addi s4, s4, 3

    // Get the vertical and horizontal offsets within the BG
    sll  t1, t1, 1
    lw   s5, bgvofs(t1)
    add  s5, s5, s1
    lw   s6, bghofs(t1)

    // Get the base screen address for the BG
    la   a0, scrn_data
    la   a1, 0xA0340000 // VRAM
    lw   t0, bgscrnbase(t1)
    add  a1, a1, t0

    // Apply the vertical base offset if past the bounds of the first screen
    andi t0, s5, 0x100
    beq  t0, zero, load_screen
    lw   t0, bgbaseofsv(t1)
    add  a1, a1, t0

load_screen:
    // Load the BG entries for the first horizontal screen
    andi t0, s5, 0xFF & ~7
    sll  t0, t0, 3
    add  a1, a1, t0
    li   a2, 0x003F
    jal  dma_read

    // Load the BG entries for the second horizontal screen
    addi a0, a0, 0x40
    lw   t0, bgbaseofsh(t1)
    add  a1, a1, t0
    jal  dma_read

    // Calculate the character offset for the current line
    la   a0, char_data
    andi s5, s5, 7
    sll  s5, s5, 1
    la   t0, 0xA0340000 // VRAM
    add  s5, s5, t0
    lw   t0, bgcharbase(t1)
    add  s5, s5, t0

draw_tile:
    // Get the BG entry for the current tile
    // TODO: priority
    add  t0, s6, s0
    andi t6, t0, 0x1FF & ~7
    srl  t6, t6, 2
    lhu  t6, scrn_data(t6)

    // Set the initial tile shift based on fine X offset and horizontal mirroring
    andi s7, t6, 0x4000
    bne  s7, zero, mirror_x
    not  t0, t0
mirror_x:
    andi t9, t0, 7

    // Load the tile's character data based on fine Y offset and vertical mirroring
    andi t0, t6, 0x03FF
    sll  t0, t0, s4
    add  a1, s5, t0
    andi t0, t6, 0x8000
    beq  t0, zero, mirror_noty
    xori a1, a1, 7 << 1
mirror_noty:
    jal  dma_read

    // DMA aligns to 64-bit words, so adjust the data offset accordingly
    andi t5, a1, 7

    // Prepare data for 4-color tiles
    lhu  t0, char_data + 0x00(t5)
    bne  s4, 4, prepare_data16
    srl  t6, t6, 7
    andi t6, t6, 0x7 << 3 // Palette offset
    la   t7, draw_pixel4
    b    check_pixel

prepare_data16:
    // Prepare data for 16-color tiles
    lhu  t1, char_data + 0x10(t5)
    sll  t1, t1, 2
    bne  s4, 5, prepare_data256
    srl  t6, t6, 5
    andi t6, t6, 0x7 << 5 // Palette offset
    la   t7, draw_pixel16
    b    check_pixel

prepare_data256:
    // Prepare data for 256-color tiles
    lhu  t2, char_data + 0x20(t5)
    sll  t2, t2, 4
    lhu  t3, char_data + 0x30(t5)
    sll  t3, t3, 6
    li   t6, 0
    la   t7, draw_pixel256
    b    check_pixel

draw_pixel256:
    // Decode bits 6-7 of the palette index
    srl  t8, t3, t9
    andi t5, t8, 0x40
    or   t4, t4, t5
    srl  t5, t8, 7
    andi t5, t5, 0x80
    or   t4, t4, t5

    // Decode bits 4-5 of the palette index
    srl  t8, t2, t9
    andi t5, t8, 0x10
    or   t4, t4, t5
    srl  t5, t8, 7
    andi t5, t5, 0x20
    or   t4, t4, t5

draw_pixel16:
    // Decode bits 2-3 of the palette index
    srl  t8, t1, t9
    andi t5, t8, 0x04
    or   t4, t4, t5
    srl  t5, t8, 7
    andi t5, t5, 0x08
    or   t4, t4, t5

draw_pixel4:
    // Decode bits 0-1 of the palette index
    srl  t8, t0, t9
    andi t5, t8, 0x01
    or   t4, t4, t5
    srl  t5, t8, 7
    andi t5, t5, 0x02
    or   t4, t4, t5

    // Draw a pixel with the palette color
    beq  t4, zero, skip_pixel
    sll  t4, t4, 1
    add  t4, t4, t6
    lhu  t4, palette(t4)
    sll  t5, s0, 1
    sh   t4, scanline(t5)
    li   t4, 0

skip_pixel:
    // Move to the next pixel until the scanline is complete
    addi s0, s0, 1
    beq  s0, s2, next_bg

    // Adjust the shift for horizontally non-mirrored tiles
    bne  s7, zero, mirror_shift
    beq  t9, zero, draw_tile
    addi t9, t9, -1

check_pixel:
    // Check if a pixel has already been drawn, and skip it if so
    sll  t5, s0, 1
    lhu  t8, scanline(t5)
    andi t8, t8, 0x0001
    bne  t8, zero, skip_pixel
    jr   t7

mirror_shift:
    // Adjust the shift for horizontally mirrored tiles
    addi t9, t9, 1
    andi t9, t9, 7
    beq  t9, zero, draw_tile
    b    check_pixel

next_bg:
    // Move to the next BG until all have been drawn
    li   s0, 0
    addi a3, a3, 2
    andi a3, a3, 7
    bne  a3, zero, draw_bg

    // DMA the scanline to the framebuffer
    la   a0, scanline
    lw   a1, framebuffer
    sll  t0, s1, 9 // Scanline offset
    add  a1, a1, t0
    li   a2, 0x01FF
    jal  dma_write

    // Move to the next line until the frame is complete
    addi s1, s1, 1
    bne  s1, s3, draw_line

    // Halt until the next frame needs to be drawn
    li   t0, 0x0002 // Set halt
    mtc0 t0, COP0_SP_STATUS

    // Swap the framebuffer with the previously-rendered one
    lw   t0, framebuffer
    li   t1, 0xA0300000
    bne  t0, t1, set_buffer
    li   t1, 0xA0320000
set_buffer:
    sw   t1, framebuffer
    j    draw_frame


dma_read: // a0: RSP address, a1: DRAM address, a2: size
    // Transfer data to the RSP via DMA
    mtc0 a0, COP0_DMA_SPADDR
    mtc0 a1, COP0_DMA_RAMADDR
    mtc0 a2, COP0_DMA_READ
    b    dma_wait

dma_write: // a0: RSP address, a1: DRAM address, a2: size
    // Transfer data from the RSP via DMA
    mtc0 a0, COP0_DMA_SPADDR
    mtc0 a1, COP0_DMA_RAMADDR
    mtc0 a2, COP0_DMA_WRITE

    // Wait for the DMA to complete
dma_wait:
    mfc0 t0, COP0_DMA_BUSY
    bne  t0, zero, dma_wait
    jr   ra
