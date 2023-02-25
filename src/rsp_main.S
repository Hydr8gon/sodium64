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

#include <rsp.inc>

.set reorder

.data

texture:   .byte 0:0x200
oam:       .byte 0:0x220
scrn_data: .byte 0:0x80
char_data: .byte 0:0x40

vec_data:
    .hword 0x8000, 0x4000, 0x2000, 0x1000, 0x0800, 0x0400, 0x0200, 0x0100 // Mask
    .hword 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100 // Shift 1
    .hword 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200 // Shift 2
    .hword 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400 // Shift 3
    .hword 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400, 0x0800 // Shift 4
    .hword 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010 // Shift 5
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 // Zero

rdp_init:
    // RDP commands that only need to run once
    .dword 0x3C080E10001C8241 // Set Combine
    .dword 0x3510810000000000 // Set Tile (palette)
    .dword 0x3548800001000090 // Set Tile (texture)

rdp_frame:
    // RDP commands that run at the start of a frame
    .dword 0x3F100117A03AE600 // Set Color Image
    .dword 0x2D030020004303A0 // Set Scissor
    .dword 0x3700000000000000 // Set Fill Color
    .dword 0x2F3888FF00040001 // Set Other Modes (fill)
    .dword 0x3642F3C000030000 // Fill Rectangle
    .dword 0x2F0888FF00040001 // Set Other Modes (1 cycle)
    .dword 0x3D100000A038C000 // Set Texture Image (palette)
    .dword 0x3300000000400000 // Load Block (palette)
    .dword 0x3D480000A038C800 // Set Texture Image (texture)

rdp_tile:
    // RDP commands that run when a tile is being drawn
    .dword 0x3100000000000000 // Sync Load
    .dword 0x3300000001200000 // Load Block (texture)
    .dword 0x0A81000000000000 // Texture Triangle 1
    .dword 0x0100000000000000 // Texture Triangle 2
    .dword 0x0000000000000000 // Texture Triangle 3
    .dword 0x0000000000000000 // Texture Triangle 4
    .dword 0x0010000040000000 // Texture Triangle 5
    .dword 0x0020000000000000 // Texture Triangle 6
    .dword 0x0000000000000000 // Texture Triangle 7
    .dword 0x0000000000000000 // Texture Triangle 8
    .dword 0x0200000000000000 // Texture Triangle 9
    .dword 0x0000000000000000 // Texture Triangle 10
    .dword 0x0000000000000000 // Texture Triangle 11
    .dword 0x0000000000000000 // Texture Triangle 12

bg_params:
    // S-coordinate, gradient along X, gradient along Y
    .hword 0x0010, 0x0020, 0x0100, 0 // No mirror
    .hword 0x00F0, 0xFFE0, 0x0100, 0 // X-mirror
    .hword 0x0710, 0x0020, 0xFF00, 0 // Y-mirror
    .hword 0x07F0, 0xFFE0, 0xFF00, 0 // XY-mirror

obj_params:
    // S-coordinate, gradient along X, gradient along Y
    .hword 0x0010, 0x0020, 0x0200, 0 // No mirror, small
    .hword 0x0010, 0x0020, 0x0200, 0 // No mirror, big
    .hword 0x00F0, 0xFFE0, 0x0200, 0 // X-mirror, small
    .hword 0x01F0, 0xFFE0, 0x0200, 0 // X-mirror, big
    .hword 0x0E10, 0x0020, 0xFE00, 0 // Y-mirror, small
    .hword 0x1E10, 0x0020, 0xFE00, 0 // Y-mirror, big
    .hword 0x0EF0, 0xFFE0, 0xFE00, 0 // XY-mirror, small
    .hword 0x1FF0, 0xFFE0, 0xFE00, 0 // XY-mirror, big

tile_jumps: .word decode_tile4, decode_tile16, decode_tile256

.space 0x8FC

// Values updated by CPU; addresses 0xF88-0xFFF
fb_border:   .word 0x08
obj_enable:  .word 0x00
bg_order:    .word 0x1B
bg_type:     .word 0x00
objcharbase: .word 0x0000
bgscrnbase:  .word 0x0000:4
bgbaseofsh:  .word 0x0000:4
bgbaseofsv:  .word 0x0000:4
bgcharbase:  .word 0x0000:4
bghofs:      .word 0x0000:4
bgvofs:      .word 0x0000:4
fill_color:  .word 0x0000

.text

main:
    // Load the constants for vector math
    la   t0, vec_data
    lqv  $v25, 0, 0x00, t0
    lqv  $v26, 0, 0x10, t0
    lqv  $v27, 0, 0x20, t0
    lqv  $v28, 0, 0x30, t0
    lqv  $v29, 0, 0x40, t0
    lqv  $v30, 0, 0x50, t0
    lqv  $v31, 0, 0x60, t0

    // Run the RDP initialization commands
    li   t0, 0x2 // Use DMEM
    mtc0 t0, COP0_DP_STATUS
    la   a0, rdp_init
    la   a1, rdp_tile
    jal  rdp_send

draw_frame:
    // Set the Y bound based on 224 or 239-line mode
    lw   t0, fb_border
    li   s7, 224
    sll  t0, t0, 1
    xori t0, t0, 0x10
    add  s7, s7, t0

    // Initialize the current BG shift
    li   s3, 0

draw_bg:
    // Get the index for the current BG
    lw   t1, bg_order
    srl  t1, t1, s3
    andi t1, t1, 0x3
    sll  t1, t1, 1

    // Get the BG type or skip if disabled
    lw   s4, bg_type
    srl  s4, s4, t1
    andi s4, s4, 0x3
    beqz s4, next_bg
    sll  t0, s4, 2
    lw   t9, tile_jumps - 4(t0) // Code path
    addi s4, s4, 3              // Character shift

    // Get the horizontal and vertical offsets within the BG
    sll  s2, t1, 1
    lw   s6, bghofs(s2)
    lw   s5, bgvofs(s2)

    // Set the initial tile Y-coordinate and character number
    andi t0, s5, 0x7
    sub  s1, zero, t0
    li   v1, 0xFFFF

draw_row:
    // Set the initial tile X-coordinate
    andi t0, s6, 0x7
    sub  s0, zero, t0

    // Get the base screen address for the BG
    la   a0, scrn_data
    la   a1, 0xA03F0000 // VRAM
    lw   t0, bgscrnbase(s2)
    add  a1, a1, t0

    // Apply the vertical base offset if past the bounds of the first screen
    add  t1, s5, s1
    andi t0, t1, 0x100
    beqz t0, load_screen
    lw   t0, bgbaseofsv(s2)
    add  a1, a1, t0

load_screen:
    // Load a row of BG entries from the first horizontal screen
    andi t0, t1, 0xFF
    sll  t0, t0, 3
    add  a1, a1, t0
    li   a2, 0x3F
    jal  dma_read

    // Load a row of BG entries from the second horizontal screen
    addi a0, a0, 0x40
    lw   t0, bgbaseofsh(s2)
    add  a1, a1, t0
    jal  dma_read

    // Update the RDP draw command with the tile's Y-coordinate
    lw   t0, fb_border
    add  t0, t0, s1
    sll  t0, t0, 2
    addi t1, t0, 8 << 2
    sh   t1, 18 + rdp_tile // y3
    sll  t1, t0, 16
    or   t0, t0, t1
    sw   t0, 20 + rdp_tile // y2, y1

next_tile:
    // Get the BG entry for the current tile
    add  t4, s6, s0
    andi t6, t4, 0x1FF
    srl  t6, t6, 2
    lhu  t6, scrn_data(t6)

    // Update the RDP draw command with the tile's X-coordinate
    addi t0, s0, 20
    sh   t0, 24 + rdp_tile // x1
    addi t1, s0, 12
    sh   t1, 32 + rdp_tile // x3
    sh   t1, 40 + rdp_tile // x2

    // Update the RDP texture parameters based on mirroring
    srl  t5, t6, 11
    andi t5, t5, 0x18
    lw   t4, 0 + bg_params(t5)
    lh   t3, 4 + bg_params(t5)
    srl  t5, t4, 16
    sh   t5, 48 + rdp_tile // S-coordinate
    sh   t4, 56 + rdp_tile // Gradient along X
    sh   t3, 80 + rdp_tile // Gradient along Y

    // Skip decoding if the last tile's character number was the same
    andi t0, t6, 0x3FF
    beq  t0, v1, skip_tile

    // Load the tile's character data from VRAM
    la   a0, char_data
    la   a1, 0xA03F0000 // VRAM
    lw   t0, bgcharbase(s2)
    add  a1, a1, t0
    andi v1, t6, 0x3FF  // Character number
    sll  t0, v1, s4
    add  a1, a1, t0
    li   a2, 0x3F
    jal  dma_read

    // Set initial values and jump to the tile decoder
    li   t7, 0x80
    li   t8, 0x10
    jr   t9

decode_tile4:
    // Set the 4-color palette offset
    srl  t0, t6, 8
    andi t0, t0, 0x7 << 2
    mtc2 t0, $v05, 0 // Palette offset

loop_tile4:
    // Prepare 4-color tile data for decoding
    lhu  t4, -2 + char_data(t8)
    mtc2 t4, $v03, 0 // Upper byte 1 to lane 0, bits 8-15
    mtc2 t4, $v03, 1 // Lower byte 1 to lane 1, bits 8-15

    // Decode the palette indices
    vand  $v01, $v25, $v03, 9 // Mask out other lower bits
    vand  $v02, $v25, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form indices

    // Add the palette offset to non-zero indices
    // In parallel, move to the next line of the tile
    veq  $v00, $v02, $v31, 0
        addi t7, t7, -0x10
    vmrg $v00, $v02, $v05, 8
        addi t8, t8, -0x2
    vadd $v02, $v02, $v00, 0

    // Write the line to the texture buffer and loop until complete
    sqv  $v02, 0, 0, t7
    bnez t8, loop_tile4
    b    draw_tile

decode_tile16:
    // Set the 16-color palette offset
    srl  t0, t6, 6
    andi t0, t0, 0x7 << 4
    mtc2 t0, $v05, 0 // Palette offset

loop_tile16:
    // Prepare 16-color tile data for decoding
    lhu  t4, 0x00 - 2 + char_data(t8)
    lhu  t5, 0x10 - 2 + char_data(t8)
    mtc2 t4, $v03, 0 // Upper byte 1 to lane 0, bits 8-15
    mtc2 t4, $v03, 1 // Lower byte 1 to lane 1, bits 8-15
    mtc2 t5, $v13, 0 // Upper byte 2 to lane 0, bits 8-15
    mtc2 t5, $v13, 1 // Lower byte 2 to lane 1, bits 8-15

    // Decode the palette indices
    vand  $v01, $v25, $v03, 9 // Mask out other lower bits
    vand  $v02, $v25, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v25, $v13, 9 // Mask out other lower bits
    vand  $v12, $v25, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices

    // Add the palette offset to non-zero indices
    // In parallel, move to the next line of the tile
    veq  $v00, $v01, $v31, 0
        addi t7, t7, -0x10
    vmrg $v00, $v01, $v05, 8
        addi t8, t8, -0x2
    vadd $v02, $v01, $v00, 0

    // Write the line to the texture buffer and loop until complete
    sqv  $v02, 0, 0, t7
    bnez t8, loop_tile16
    b    draw_tile

decode_tile256:
    // Prepare 256-color tile data for decoding
    lhu  t2, 0x00 - 2 + char_data(t8)
    lhu  t3, 0x10 - 2 + char_data(t8)
    lhu  t4, 0x20 - 2 + char_data(t8)
    lhu  t5, 0x30 - 2 + char_data(t8)
    mtc2 t2, $v03, 0 // Upper byte 1 to lane 0, bits 8-15
    mtc2 t2, $v03, 1 // Lower byte 1 to lane 1, bits 8-15
    mtc2 t3, $v13, 0 // Upper byte 2 to lane 0, bits 8-15
    mtc2 t3, $v13, 1 // Lower byte 2 to lane 1, bits 8-15
    mtc2 t4, $v08, 0 // Upper byte 3 to lane 0, bits 8-15
    mtc2 t4, $v08, 1 // Lower byte 3 to lane 1, bits 8-15
    mtc2 t5, $v18, 0 // Upper byte 4 to lane 0, bits 8-15
    mtc2 t5, $v18, 1 // Lower byte 4 to lane 1, bits 8-15

    // Decode the palette indices
    vand  $v01, $v25, $v03, 9 // Mask out other lower bits
    vand  $v02, $v25, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v25, $v13, 9 // Mask out other lower bits
    vand  $v12, $v25, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v06, $v12, $v02, 0 // Combine partial indices
    vand  $v01, $v25, $v08, 9 // Mask out other lower bits
    vand  $v02, $v25, $v08, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v25, $v18, 9 // Mask out other lower bits
    vand  $v12, $v25, $v18, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v07, $v12, $v02, 0 // Combine partial indices
    vmudn $v07, $v07, $v30, 0 // Shift upper indices left
    vor   $v00, $v06, $v07, 0 // Combine indices

    // Write the line to the texture buffer and loop until complete
    addi t7, t7, -0x10
    sqv  $v00, 0, 0, t7
    addi t8, t8, -0x2
    bnez t8, decode_tile256

draw_tile:
    // DMA the tile texture to RDRAM
    la   a0, texture
    la   a1, 0xA038C800
    li   a2, 0x7F
    jal  dma_write

    // Run the RDP to draw a tile
    la   a0, rdp_tile
    la   a1, bg_params
    jal  rdp_send

finish_tile:
    // Move to the next tile of the row until finished
    addi s0, s0, 8
    blt  s0, 256, next_tile

    // Move to the next row of the BG until finished
    addi s1, s1, 8
    blt  s1, s7, draw_row
    b    next_bg

skip_tile:
    la   a0, 0x10 + rdp_tile
    la   a1, bg_params
    jal  rdp_send
    b    finish_tile

next_bg:
    // Move to the next BG until all have been drawn
    addi s3, s3, 2
    andi s3, s3, 0x7
    bnez s3, draw_bg

    // Check if objects are enabled
    lw   t0, obj_enable
    beqz t0, end_frame
    li   t9, 0

check_object:
    // Read the 4 object bytes and additional 2 bits
    lw   t1, oam(t9)
    srl  t2, t9, 4
    lbu  t2, 0x200 + oam(t2)
    srl  t3, t9, 1
    andi t3, t3, 0x6
    srl  t2, t2, t3

    // Get the object's Y-coordinate, wrapped past line 240
    srl  t3, t1, 24
    addi t3, t3, 1
    li   t4, 0xF1
    slt  t4, t4, t3
    sll  t4, t4, 31
    sra  t4, t4, 23
    or   t3, t3, t4

    // Skip the object if it doesn't occupy any visible scanlines
    addi t4, t3, 8
    andi v0, t2, 0x2 // Large
    sll  v1, v0, 2
    add  t4, t4, v1
    and  t5, t4, t3
    sra  t5, t5, 8
    bnez t5, next_object

    // Get the object's X-coordinate, wrapped past pixel 256
    srl  t5, t1, 16
    andi t5, t5, 0xFF
    sll  t6, t2, 31 // Upper X
    sra  t6, t6, 23
    or   t5, t5, t6

    // Skip the object if it doesn't occupy any visible pixels
    addi t6, t5, 8
    add  t6, t6, v1
    and  t7, t6, t5
    sra  t7, t7, 8
    bnez t7, next_object

    // Update the RDP draw command with the object's coordinates
    addi t7, t6, 12
    sh   t7, 24 + rdp_tile // x1
    addi t7, t5, 12
    sh   t7, 32 + rdp_tile // x3
    sh   t7, 40 + rdp_tile // x2
    lw   t7, fb_border
    add  t4, t4, t7
    sll  t4, t4, 2
    sh   t4, 18 + rdp_tile // y3
    add  t3, t3, t7
    sll  t3, t3, 2
    sll  t4, t3, 16
    or   t3, t3, t4
    sw   t3, 20 + rdp_tile // y2, y1

    // Update the RDP texture parameters based on size and mirroring
    srl  t5, t1, 10
    andi t5, t5, 0x30
    add  t5, t5, v1
    lw   t4, 0 + obj_params(t5)
    lh   t3, 4 + obj_params(t5)
    srl  t5, t4, 16
    sh   t5, 48 + rdp_tile // S-coordinate
    sh   t4, 56 + rdp_tile // Gradient along X
    sh   t3, 80 + rdp_tile // Gradient along Y

    // Set the object's palette offset
    srl  t3, t1, 5
    andi t3, t3, 0x70
    addi t3, t3, 0x80
    mtc2 t3, $v05, 0

    // Set initial values for drawing the object
    li   t8, 0
    li   t7, 0
    li   t6, 0

load_object:
    // Load the tile's character data from VRAM
    la   a0, char_data
    la   a1, 0xA03F0000 // VRAM
    lw   t4, objcharbase
    add  a1, a1, t4
    andi t4, t1, 0x1FF
    sll  t4, t4, 5
    add  a1, a1, t4
    add  a1, a1, t6
    li   a2, 0x3F
    jal  dma_read

decode_object:
    // Prepare 16-color tile data for decoding
    lhu  t4, 0x00 + char_data(t8)
    lhu  t5, 0x10 + char_data(t8)
    mtc2 t4, $v03, 0 // Upper byte 1 to lane 0, bits 8-15
    mtc2 t4, $v03, 1 // Lower byte 1 to lane 1, bits 8-15
    mtc2 t5, $v13, 0 // Upper byte 2 to lane 0, bits 8-15
    mtc2 t5, $v13, 1 // Lower byte 2 to lane 1, bits 8-15

    // Decode the palette indices
    vand  $v01, $v25, $v03, 9 // Mask out other lower bits
    vand  $v02, $v25, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v25, $v13, 9 // Mask out other lower bits
    vand  $v12, $v25, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices

    // Add the palette offset to non-zero indices
    // In parallel, move to the next line of the tile
    veq  $v00, $v01, $v31, 0
        addi t7, t7, 0x20
    vmrg $v00, $v01, $v05, 8
        addi t8, t8, 0x2
    vadd $v02, $v01, $v00, 0

    // Write the line to the texture buffer and loop until complete
    andi t5, t8, 0xF
    sqv  $v02, 0, -0x20, t7
    bnez t5, decode_object

    // Move to the next tile if the object is large
    or   t5, v0, v1
    beqz t5, draw_object
    beqz v1, object_row
    li   t8, 0x20
    addi t7, t7, -0xF0
    li   v1, 0
    b    decode_object

object_row:
    // Move to the next row of tiles if the object is large
    li   t8, 0x00
    li   t7, 0x100
    li   t6, 0x200
    li   v0, 0
    li   v1, 1
    b    load_object

draw_object:
    // DMA the object texture to RDRAM
    la   a0, texture
    la   a1, 0xA038C800
    li   a2, 0x1FF
    jal  dma_write

    // Run the RDP to draw an object
    la   a0, rdp_tile
    la   a1, bg_params
    jal  rdp_send

next_object:
    // Move to the next object until all are drawn
    addi t9, t9, 4
    andi t9, t9, 0x1FF
    bnez t9, check_object

end_frame:
    // Halt until the next frame can be drawn
    li   t0, 0x0002 // Set halt
    mtc0 t0, COP0_SP_STATUS

    // Update the RDP color buffer command with the next buffer address
    lw   t0, rdp_frame + 4
    li   t1, 0x20D00 // Buffer size
    add  t0, t0, t1
    li   t1, 0xA03F0000
    bne  t0, t1, set_buffer
    li   t0, 0xA038D900
set_buffer:
    sw   t0, rdp_frame + 4

    // Update the RDP scissor command for 224 or 239-line mode
    lw   t0, fb_border
    li   t1, 0x0020
    li   t2, 0x03A0
    bnez t0, set_border
    li   t1, 0x0000
    li   t2, 0x03C0
set_border:
    sh   t1, rdp_frame + 10
    sh   t2, rdp_frame + 14

    // Update the RDP fill color command with palette color 0
    lw   t0, fill_color
    sh   t0, rdp_frame + 20
    sh   t0, rdp_frame + 22

    // Run the RDP to prepare the next frame
    la   a0, rdp_frame
    la   a1, rdp_tile
    jal  rdp_send
    j    draw_frame


dma_write: // a0: RSP address, a1: DRAM address, a2: size
    // Wait until a texture isn't being loaded to TMEM
    mfc0 t0, COP0_DP_STATUS
    andi t0, t0, 0x10 // TMEM busy
    bnez t0, dma_write

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
    bnez t0, dma_wait
    jr   ra


rdp_send: // a0: start address, a1: end address
    // Wait for the RDP to be ready and then send commands
    mfc0 t0, COP0_DP_STATUS
    andi t0, t0, 0x40 // Command busy
    bnez t0, rdp_send
    mtc0 a0, COP0_DP_START
    mtc0 a1, COP0_DP_END
    jr   ra
