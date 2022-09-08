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

scanline:  .byte 0:0x220
palette:   .byte 0:0x200
oam:       .byte 0:0x220
scrn_data: .byte 0:0x80
char_data: .byte 0:0x40

vec_data:
    .hword 0x8000, 0x4000, 0x2000, 0x1000, 0x0800, 0x0400, 0x0200, 0x0100 // Mask
    .hword 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200 // Shift 1
    .hword 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400 // Shift 2
    .hword 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400, 0x0800 // Shift 3
    .hword 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400, 0x0800, 0x1000 // Shift 4
    .hword 0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000, 0x4000, 0x8000 // Mask (Mirror)
    .hword 0x0200, 0x0100, 0x0080, 0x0040, 0x0020, 0x0010, 0x0008, 0x0004 // Shift 1 (Mirror)
    .hword 0x0400, 0x0200, 0x0100, 0x0080, 0x0040, 0x0020, 0x0010, 0x0008 // Shift 2 (Mirror)
    .hword 0x0800, 0x0400, 0x0200, 0x0100, 0x0080, 0x0040, 0x0020, 0x0010 // Shift 3 (Mirror)
    .hword 0x1000, 0x0800, 0x0400, 0x0200, 0x0100, 0x0080, 0x0040, 0x0020 // Shift 4 (Mirror)
    .hword 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010 // Shift 5
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 // Zero

.space 0x7CC

obj_enable:  .word 0x00       // 0xF8C-0xF8F
bg_order:    .word 0x1B       // 0xF90-0xF93
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

    // Load the constants for vector math
    la   t0, vec_data
    lqv  $v20, 0, 0x00, t0
    lqv  $v21, 0, 0x10, t0
    lqv  $v22, 0, 0x20, t0
    lqv  $v23, 0, 0x30, t0
    lqv  $v24, 0, 0x40, t0
    lqv  $v25, 0, 0x50, t0
    lqv  $v26, 0, 0x60, t0
    lqv  $v27, 0, 0x70, t0
    lqv  $v28, 0, 0x80, t0
    lqv  $v29, 0, 0x90, t0
    lqv  $v30, 0, 0xA0, t0
    lqv  $v31, 0, 0xB0, t0

draw_frame:
    // Set initial values for the frame
    li   s0, 0   // Current X coordinate (x2)
    li   s1, 0   // Current Y coordinate
    li   s2, 512 // Maximum X coordinate (x2)
    li   s3, 224 // Maximum Y coordinate
    li   a3, 0   // Current BG shift

draw_line:
    // Clear the scanline with palette index 0
    li   t0, 0x10
    addi t1, t0, 0x200
clear_line:
    sqv  $v31, 0, 0, t0
    addi t0, t0, 0x10
    bne  t0, t1, clear_line

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
    b    load_tile

draw_tile:
    // Copy 8 pixels to the scanline, but only if they're visible
    lqv  $v02, 0, 0x00, v1
    lrv  $v02, 0, 0x10, v1
    vne  $v01, $v00, $v05, 8
    vmrg $v01, $v00, $v02, 0
    sqv  $v01, 0, 0x00, v1
    srv  $v01, 0, 0x10, v1

skip_tile:
    // Move to the next tile
    move s0, v1

load_tile:
    // Move to the next BG once the scanline is complete
    bge  s0, s2, next_bg

    // Get the BG entry for the current tile
    // TODO: priority
    srl  t4, s0, 1
    add  t4, t4, s6
    andi t6, t4, 0x1FF & ~7
    srl  t6, t6, 2
    lhu  t6, scrn_data(t6)

    // Set the tile bounds based on fine X offset
    li   v1, 8
    andi t9, t4, 0x7
    sub  v1, v1, t9
    sll  v1, v1, 1
    add  v1, v1, s0

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

    // Set horizontal mirroring
    andi s7, t6, 0x4000

    // DMA aligns to 64-bit words, so adjust the data offset accordingly
    andi t5, a1, 7

prepare_data:
    // Branch based on the tile type
    beq  s4, 5, prepare_data16
    beq  s4, 4, prepare_data4
    b    prepare_data256

same_tile:
    // Take the fast path for equal tiles
    beq  k0, zero, skip_tile
    b    draw_tile

prepare_data4:
    // Load data for a 4-color tile, and skip if it's empty
    lhu  k0, char_data + 0x00(t5)
    beq  k0, zero, skip_tile
    srl  t7, t6, 7
    andi t7, t7, 0x7 << 3
    mtc2 k0, $v03, 0 // Upper byte to lane 0, bits 8-15
    mtc2 k0, $v03, 1 // Lower byte to lane 1, bits 8-15
    mtc2 t7, $v05, 0 // Palette offset
    bne  s7, zero, mirror_x4

    // Decode the palette indices
    vand  $v01, $v20, $v03, 9 // Mask out other lower bits
    vand  $v02, $v20, $v03, 8 // Mask out other upper bits
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form indices
    vadd  $v00, $v02, $v05, 8 // Add palette offset
    b     draw_tile

mirror_x4:
    // Decode the palette indices, mirrored horizontally
    vand  $v01, $v25, $v03, 9 // Mask out other lower bits
    vand  $v02, $v25, $v03, 8 // Mask out other upper bits
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form indices
    vadd  $v00, $v02, $v05, 8 // Add palette offset
    b     draw_tile

prepare_data16:
    // Load data for a 16-color tile, and skip if it's empty
    lhu  t0, char_data + 0x00(t5)
    lhu  t1, char_data + 0x10(t5)
    or   k0, t0, t1
    beq  k0, zero, skip_tile
    srl  t7, t6, 5
    andi t7, t7, 0x7 << 5
    mtc2 t0, $v03, 0 // Upper byte 1 to lane 0, bits 8-15
    mtc2 t0, $v03, 1 // Lower byte 1 to lane 1, bits 8-15
    mtc2 t1, $v13, 0 // Upper byte 2 to lane 0, bits 8-15
    mtc2 t1, $v13, 1 // Lower byte 2 to lane 1, bits 8-15
    mtc2 t7, $v05, 0 // Palette offset
    bne  s7, zero, mirror_x16

    // Decode the palette indices
    vand  $v01, $v20, $v03, 9 // Mask out other lower bits
    vand  $v02, $v20, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v20, $v13, 9 // Mask out other lower bits
    vand  $v12, $v20, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v23, $v11, 0 // Shift lower bits to bit 3
    vmudl $v14, $v24, $v12, 0 // Shift upper bits to bit 4
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices
    vadd  $v00, $v01, $v05, 8 // Add palette offset
    b     draw_tile

mirror_x16:
    // Decode the palette indices, mirrored horizontally
    vand  $v01, $v25, $v03, 9 // Mask out other lower bits
    vand  $v02, $v25, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v25, $v13, 9 // Mask out other lower bits
    vand  $v12, $v25, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 3
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 4
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices
    vadd  $v00, $v01, $v05, 8 // Add palette offset
    b     draw_tile

prepare_data256:
    // Load data for a 256-color tile, and skip if it's empty
    lhu  t0, char_data + 0x00(t5)
    lhu  t1, char_data + 0x10(t5)
    lhu  t2, char_data + 0x20(t5)
    lhu  t3, char_data + 0x30(t5)
    or   k0, t0, t1
    or   k0, k0, t2
    or   k0, k0, t3
    beq  k0, zero, skip_tile
    mtc2 t0, $v03, 0 // Upper byte 1 to lane 0, bits 8-15
    mtc2 t0, $v03, 1 // Lower byte 1 to lane 1, bits 8-15
    mtc2 t1, $v13, 0 // Upper byte 2 to lane 0, bits 8-15
    mtc2 t1, $v13, 1 // Lower byte 2 to lane 1, bits 8-15
    mtc2 t2, $v08, 0 // Upper byte 3 to lane 0, bits 8-15
    mtc2 t2, $v08, 1 // Lower byte 3 to lane 1, bits 8-15
    mtc2 t3, $v18, 0 // Upper byte 4 to lane 0, bits 8-15
    mtc2 t3, $v18, 1 // Lower byte 4 to lane 1, bits 8-15
    bne  s7, zero, mirror_x256

    // Decode the palette indices
    vand  $v01, $v20, $v03, 9 // Mask out other lower bits
    vand  $v02, $v20, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v20, $v13, 9 // Mask out other lower bits
    vand  $v12, $v20, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v23, $v11, 0 // Shift lower bits to bit 3
    vmudl $v14, $v24, $v12, 0 // Shift upper bits to bit 4
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v06, $v12, $v02, 0 // Combine partial indices
    vand  $v01, $v20, $v08, 9 // Mask out other lower bits
    vand  $v02, $v20, $v08, 8 // Mask out other upper bis
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v20, $v18, 9 // Mask out other lower bits
    vand  $v12, $v20, $v18, 8 // Mask out other upper bits
    vmudl $v13, $v23, $v11, 0 // Shift lower bits to bit 3
    vmudl $v14, $v24, $v12, 0 // Shift upper bits to bit 4
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v07, $v12, $v02, 0 // Combine partial indices
    vmudn $v07, $v07, $v30, 0 // Shift upper indices left
    vor   $v00, $v06, $v07, 0 // Combine indices
    b     draw_tile

mirror_x256:
    // Decode the palette indices, mirrored horizontally
    vand  $v01, $v25, $v03, 9 // Mask out other lower bits
    vand  $v02, $v25, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v25, $v13, 9 // Mask out other lower bits
    vand  $v12, $v25, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 3
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 4
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v06, $v12, $v02, 0 // Combine partial indices
    vand  $v01, $v25, $v08, 9 // Mask out other lower bits
    vand  $v02, $v25, $v08, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v25, $v18, 9 // Mask out other lower bits
    vand  $v12, $v25, $v18, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 3
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 4
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v07, $v12, $v02, 0 // Combine partial indices
    vmudn $v07, $v07, $v30, 0 // Shift upper indices left
    vor   $v00, $v06, $v07, 0 // Combine indices
    b     draw_tile

next_bg:
    // Move to the next BG until all have been drawn
    li   s0, 0
    addi a3, a3, 2
    andi a3, a3, 7
    bne  a3, zero, draw_bg

    // Check if objects are enabled
    lw   t0, obj_enable
    beq  t0, zero, end_line
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
    li   s6, 7 << 1
    li   s7, -2
    lhu  t9, oam + 2(t3)
    andi t8, t9, 0x4000
    beq  t8, zero, objmir_notx
    li   s6, 0
    li   s7, 2

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
    addi t8, t8, 0x100
    sll  t1, t1, 1
    addi t2, t1, 8 << 1

    // Get the DMA offset, adjusted for the current tile
    andi a1, a1, 7
    beq  v1, zero, load_objtile
    bne  s6, zero, load_objtile
    addi a1, a1, 0x20

load_objtile:
    // Load data for a 16-color tile
    lhu  t6, char_data + 0x00(a1)
    lhu  t7, char_data + 0x10(a1)
    mtc2 t6, $v03, 0 // Upper byte 1 to lane 0, bits 8-15
    mtc2 t6, $v03, 1 // Lower byte 1 to lane 1, bits 8-15
    mtc2 t7, $v13, 0 // Upper byte 2 to lane 0, bits 8-15
    mtc2 t7, $v13, 1 // Lower byte 2 to lane 1, bits 8-15
    mtc2 t8, $v05, 0 // Palette offset
    beq  s6, zero, objmir_x

    // Decode the palette indices
    vand  $v01, $v20, $v03, 9 // Mask out other lower bits
    vand  $v02, $v20, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v20, $v13, 9 // Mask out other lower bits
    vand  $v12, $v20, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v23, $v11, 0 // Shift lower bits to bit 3
    vmudl $v14, $v24, $v12, 0 // Shift upper bits to bit 4
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices
    vadd  $v02, $v01, $v05, 8 // Add palette offset
    b     draw_objtile

objmir_x:
    // Decode the palette indices, mirrored horizontally
    vand  $v01, $v25, $v03, 9 // Mask out other lower bits
    vand  $v02, $v25, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 1
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 2
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v25, $v13, 9 // Mask out other lower bits
    vand  $v12, $v25, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 3
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 4
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices
    vadd  $v02, $v01, $v05, 8 // Add palette offset

draw_objtile:
    // Don't draw outside of scanline bounds
    bge  t1, 0x200, next_object

    // Copy 8 pixels to the scanline, but only if they're visible
    lqv   $v03, 0, 0x10, t1
    lrv   $v03, 0, 0x20, t1
    vne   $v01, $v02, $v05, 8
    vmrg  $v01, $v02, $v03, 0
    sqv   $v01, 0, 0x10, t1
    srv   $v01, 0, 0x20, t1
    addi  t1, t1, 16

    // Move to the next tile in the object if there is one
    beq  v1, zero, next_object
    li   v1, 0
    sll  t4, s7, 4
    sub  a1, a1, t4
    addi t2, t2, 8 << 1
    andi s6, s6, 0x7 << 1
    b    load_objtile

next_object:
    // Move to the next object until all are drawn
    addi t3, t3, 4
    andi t3, t3, 0x1FF
    bne  t3, zero, draw_object

end_line:
    // Replace palette indices with palette entries
    la   t0, scanline + 0x10
    addi t1, t0, 0x200
pal_loop:
    lw   t2, (t0)
    srl  t3, t2, 16
    lhu  t3, palette(t3)
    andi t2, t2, 0xFFFF
    lhu  t2, palette(t2)
    sll  t3, t3, 16
    or   t2, t2, t3
    sw   t2, (t0)
    addi t0, t0, 4
    bne  t0, t1, pal_loop

    // DMA the scanline to the framebuffer
    la   a0, scanline + 0x10
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
