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
framebuffer: .word 0xA03B0000 // 0xFFC-0xFFF

.text

draw_frame:
    // Set initial values for the frame
    li   s0, 0   // Current X coordinate (x2)
    li   s1, 0   // Current Y coordinate
    li   s2, 512 // Maximum X coordinate (x2)
    li   s3, 224 // Maximum Y coordinate
    li   a3, 0   // Current BG shift

    // Fill a vector register with the backdrop color
    lhu  t0, palette
    andi t0, t0, 0xFFFE
    mtc2 t0, $v00, 0
    mtc2 t0, $v00, 2
    mtc2 t0, $v00, 4
    mtc2 t0, $v00, 6
    mtc2 t0, $v00, 8
    mtc2 t0, $v00, 10
    mtc2 t0, $v00, 12
    mtc2 t0, $v00, 14

draw_line:
    // Clear the scanline with the backdrop color
    li   t0, 0
    li   t1, 0x200
clear_line:
    sqv  $v00, 0, 0, t0
    addi t0, t0, 16
    bne  t0, t1, clear_line

    // Check if objects are enabled
    lw   t0, obj_enable
    beq  t0, zero, draw_bg
    li   t3, 0

    // Set the character offset for objects
    la   a0, char_data
    la   s5, 0xA03F0000 // VRAM
    lw   t1, objcharbase
    add  s5, s5, t1
    li   a2, 0x003F

draw_object:
    // Get the object's Y coordinate and test upper bounds
    lhu  t1, oam(t3)
    srl  t2, t1, 8
    ble  s1, t2, next_object

    // Get the 2 additional object bits
    srl  t4, t3, 4
    lbu  t4, oam + 0x200(t4)
    srl  t5, t3, 1
    andi t5, t5, 0x3 << 1
    srl  t4, t4, t5

    // Test lower bounds, based on object size
    addi t2, t2, 9
    andi v1, t4, 0x2
    sll  v1, v1, 2
    add  t2, t2, v1
    bge  s1, t2, next_object

    // Get the object's X coordinate, including the high bit
    andi t1, t1, 0xFF
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
    // Load the tile's character data based on Y offset and vertical mirroring
    // TODO: priority
    andi t8, t9, 0x01FF
    sll  t8, t8, 5
    add  a1, s5, t8
    sub  t2, s1, t2
    andi t8, t9, 0x8000
    beq  t8, zero, objmir_noty
    not  t2, t2
objmir_noty:
    and  t8, t2, v1
    sll  t8, t8, 6
    add  a1, a1, t8
    andi t2, t2, 0x7
    sll  t2, t2, 1
    add  a1, a1, t2
    jal  dma_read

    // Get the object's palette offset and scanline bounds
    srl  t8, t9, 4
    andi t8, t8, 0x7 << 5
    sll  t1, t1, 1
    addi t2, t1, 8 << 1

    // Get the DMA offset, adjusted for the current tile
    andi a1, a1, 7
    beq  v1, zero, draw_objtile
    bne  s6, zero, draw_objtile
    addi a1, a1, 0x20

draw_objtile:
    // Prepare data for 16-color tiles
    lhu  t6, char_data + 0x00(a1)
    lhu  t7, char_data + 0x10(a1)
    sll  t7, t7, 2

draw_objpix:
    // Don't draw outside of scanline bounds
    bge  t1, 0x200, next_object

    // Decode bits 2-3 of the palette index
    srl  s4, t7, s6
    andi t4, s4, 0x04
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

    // Move to the next tile in the object if there is one
    beq  v1, zero, next_object
    li   v1, 0
    sll  t4, s7, 5
    sub  a1, a1, t4
    addi t2, t2, 8 << 1
    andi s6, s6, 0x7
    b    draw_objtile

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
    la   a1, 0xA03F0000 // VRAM
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
    la   t0, 0xA03F0000 // VRAM
    add  s5, s5, t0
    lw   t0, bgcharbase(t1)
    add  s5, s5, t0

    // Calculate the amount of character data to load per tile
    li   a2, 1
    sll  a2, a2, s4
    addi a2, a2, -9
    lui  v0, 0xFFFF
    move v1, s0

skip_tile:
    // Skip the tile if all of its indices are empty
    move s0, v1

draw_tile:
    // Move to the next BG once the scanline is complete
    beq  s0, s2, next_bg

    // Get the BG entry for the current tile
    // TODO: priority
    srl  t4, s0, 1
    add  t4, t4, s6
    andi t6, t4, 0x1FF & ~7
    srl  t6, t6, 2
    lhu  t6, scrn_data(t6)
    andi t9, t4, 0x7

    // Set the tile bounds based on fine X offset
    li   v1, 8
    sub  v1, v1, t9
    sll  v1, v1, 1
    add  v1, v1, s0
    blt  v1, s2, check_tile
    move v1, s2

check_tile:
    // Skip loading if the tile is the same as the previous one
    beq  v0, t6, same_tile
    move v0, t6

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

    // Set the initial tile shift and step based on horizontal mirroring
    li   s7, 1
    andi t0, t6, 0x4000
    bne  t0, zero, prepare_data
    addi s7, s7, -2
    xori t9, t9, 0x7

prepare_data:
    // Branch based on the tile type
    beq  s4, 5, prepare_data16
    beq  s4, 4, prepare_data4
    b    prepare_data256

same_tile:
    // Take the fast path for equal tiles
    beq  k0, zero, skip_tile
    andi t4, t6, 0x4000
    bne  t4, zero, check_pixel
    xori t9, t9, 0x7

check_pixel:
    // Branch based on the tile type
    beq  s4, 5, check_pixel16
    beq  s4, 4, check_pixel4
    b    check_pixel256

prepare_data4:
    // Prepare data for 4-color tiles
    lhu  k0, char_data + 0x00(t5)
    srl  t7, t6, 7
    beq  k0, zero, skip_tile
    sll  t0, k0, 1
    andi t7, t7, 0x7 << 3 // Palette offset
    b    check_pixel4

draw_pixel4:
    // Decode bits 0-1 of the palette index
    srl  t8, t0, t9
    andi t4, t8, 0x01 << 1
    srl  t5, t8, 7
    andi t5, t5, 0x02 << 1
    or   t4, t4, t5

    // Draw a pixel with the palette color
    beq  t4, zero, skip_pixel4
    add  t4, t4, t7
    lhu  t4, palette(t4)
    sh   t4, scanline(s0)

skip_pixel4:
    // Move to the next pixel until the scanline is complete
    addi s0, s0, 2
    beq  s0, v1, draw_tile
    add  t9, t9, s7

check_pixel4:
    // Check if a pixel has already been drawn, and skip it if so
    lhu  t8, scanline(s0)
    andi t8, t8, 0x0001
    bne  t8, zero, skip_pixel4
    b    draw_pixel4

prepare_data16:
    // Prepare data for 16-color tiles
    lhu  t0, char_data + 0x00(t5)
    srl  t7, t6, 5
    lhu  t1, char_data + 0x10(t5)
    sll  t0, t0, 1
    or   k0, t0, t1
    beq  k0, zero, skip_tile
    sll  t1, t1, 3
    andi t7, t7, 0x7 << 5 // Palette offset
    b    check_pixel16

draw_pixel16:
    // Decode bits 2-3 of the palette index
    srl  t8, t1, t9
    andi t4, t8, 0x04 << 1
    srl  t5, t8, 7
    andi t5, t5, 0x08 << 1
    or   t4, t4, t5

    // Decode bits 0-1 of the palette index
    srl  t8, t0, t9
    andi t5, t8, 0x01 << 1
    or   t4, t4, t5
    srl  t5, t8, 7
    andi t5, t5, 0x02 << 1
    or   t4, t4, t5

    // Draw a pixel with the palette color
    beq  t4, zero, skip_pixel16
    add  t4, t4, t7
    lhu  t4, palette(t4)
    sh   t4, scanline(s0)

skip_pixel16:
    // Move to the next pixel until the scanline is complete
    addi s0, s0, 2
    beq  s0, v1, draw_tile
    add  t9, t9, s7

check_pixel16:
    // Check if a pixel has already been drawn, and skip it if so
    lhu  t8, scanline(s0)
    andi t8, t8, 0x0001
    bne  t8, zero, skip_pixel16
    b    draw_pixel16

prepare_data256:
    // Prepare data for 256-color tiles
    lhu  t0, char_data + 0x00(t5)
    lhu  t1, char_data + 0x10(t5)
    sll  t0, t0, 1
    or   k0, t0, t1
    lhu  t2, char_data + 0x20(t5)
    sll  t1, t1, 3
    or   k0, k0, t2
    lhu  t3, char_data + 0x30(t5)
    sll  t2, t2, 5
    or   k0, k0, t3
    beq  k0, zero, skip_tile
    sll  t3, t3, 7
    b    check_pixel256

draw_pixel256:
    // Decode bits 6-7 of the palette index
    srl  t8, t3, t9
    andi t4, t8, 0x40 << 1
    srl  t5, t8, 7
    andi t5, t5, 0x80 << 1
    or   t4, t4, t5

    // Decode bits 4-5 of the palette index
    srl  t8, t2, t9
    andi t5, t8, 0x10 << 1
    or   t4, t4, t5
    srl  t5, t8, 7
    andi t5, t5, 0x20 << 1
    or   t4, t4, t5

    // Decode bits 2-3 of the palette index
    srl  t8, t1, t9
    andi t5, t8, 0x04 << 1
    or   t4, t4, t5
    srl  t5, t8, 7
    andi t5, t5, 0x08 << 1
    or   t4, t4, t5

    // Decode bits 0-1 of the palette index
    srl  t8, t0, t9
    andi t5, t8, 0x01 << 1
    or   t4, t4, t5
    srl  t5, t8, 7
    andi t5, t5, 0x02 << 1
    or   t4, t4, t5

    // Draw a pixel with the palette color
    beq  t4, zero, skip_pixel256
    lhu  t4, palette(t4)
    sh   t4, scanline(s0)

skip_pixel256:
    // Move to the next pixel until the scanline is complete
    addi s0, s0, 2
    beq  s0, v1, draw_tile
    add  t9, t9, s7

check_pixel256:
    // Check if a pixel has already been drawn, and skip it if so
    lhu  t8, scanline(s0)
    andi t8, t8, 0x0001
    bne  t8, zero, skip_pixel256
    b    draw_pixel256

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

    // Halt until the next frame can be drawn
    li   t0, 0x0002 // Set halt
    mtc0 t0, COP0_SP_STATUS

    // Move to the next of three framebuffers
    lw   t0, framebuffer
    li   t1, 0x20000
    add  t0, t0, t1
    li   t1, 0xA03F0000
    bne  t0, t1, set_buffer
    li   t0, 0xA0390000
set_buffer:
    sw   t0, framebuffer
    j    draw_frame


dma_write: // a0: RSP address, a1: DRAM address, a2: size
    // Transfer data from the RSP via DMA
    mtc0 a0, COP0_DMA_SPADDR
    mtc0 a1, COP0_DMA_RAMADDR
    mtc0 a2, COP0_DMA_WRITE
    b    dma_wait

dma_read: // a0: RSP address, a1: DRAM address, a2: size
    // Transfer data to the RSP via DMA
    mtc0 a0, COP0_DMA_SPADDR
    mtc0 a1, COP0_DMA_RAMADDR
    mtc0 a2, COP0_DMA_READ

dma_wait:
    // Wait for the DMA to complete
    mfc0 t0, COP0_DMA_BUSY
    bne  t0, zero, dma_wait
    jr   ra
