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

scanline:  .byte 0:0x220
oam:       .byte 0:0x220
scrn_data: .byte 0:0x80 * 4
char_data: .byte 0:0x40

vec_data:
    .hword 0x8000, 0x4000, 0x2000, 0x1000, 0x0800, 0x0400, 0x0200, 0x0100 // Mask
    .hword 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100 // Shift 1
    .hword 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200 // Shift 2
    .hword 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400 // Shift 3
    .hword 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400, 0x0800 // Shift 4
    .hword 0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000, 0x4000, 0x8000 // Mask (Mirror)
    .hword 0x0100, 0x0080, 0x0040, 0x0020, 0x0010, 0x0008, 0x0004, 0x0002 // Shift 1 (Mirror)
    .hword 0x0200, 0x0100, 0x0080, 0x0040, 0x0020, 0x0010, 0x0008, 0x0004 // Shift 2 (Mirror)
    .hword 0x0400, 0x0200, 0x0100, 0x0080, 0x0040, 0x0020, 0x0010, 0x0008 // Shift 3 (Mirror)
    .hword 0x0800, 0x0400, 0x0200, 0x0100, 0x0080, 0x0040, 0x0020, 0x0010 // Shift 4 (Mirror)
    .hword 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010 // Shift 5
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 // Zero

rdp_init:
    // RDP commands that only need to run once
    .dword 0x3C080E10001C8241 // Set Combine
    .dword 0x3510810000000000 // Set Tile (palette)
    .dword 0x3548800001000090 // Set Tile (texture)

rdp_frame:
    // RDP commands that run at the start of a frame
    .dword 0x3F1000FFA03B0000 // Set Color Image
    .dword 0x2D000020004003A0 // Set Scissor
    .dword 0x3D100000A03EF000 // Set Texture Image (palette)
    .dword 0x3300000000400000 // Load Block (palette)
    .dword 0x3D480000A03EF800 // Set Texture Image (texture)

rdp_line:
    // RDP commands that run when a scanline is being drawn
    .dword 0x2F0888FF00000000 // Set Other Modes
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
    .dword 0x0000000000000000 // Texture Triangle 9
    .dword 0x0000000000000000 // Texture Triangle 10
    .dword 0x0000000000000000 // Texture Triangle 11
    .dword 0x0000000000000000 // Texture Triangle 12

rdp_tile:
    // RDP commands that run when a tile is being drawn
    .dword 0x2F0888FF00040001 // Set Other Modes
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

mirror_vals:
    // S coordinate, gradient along X, gradient along Y
    .hword 0x0010, 0x0020, 0x0200, 0 // No mirror, small
    .hword 0x0010, 0x0020, 0x0200, 0 // No mirror, big
    .hword 0x00F0, 0xFFE0, 0x0200, 0 // X-mirror, small
    .hword 0x01F0, 0xFFE0, 0x0200, 0 // X-mirror, big
    .hword 0x0E10, 0x0020, 0xFE00, 0 // Y-mirror, small
    .hword 0x1E10, 0x0020, 0xFE00, 0 // Y-mirror, big
    .hword 0x0EF0, 0xFFE0, 0xFE00, 0 // XY-mirror, small
    .hword 0x1FF0, 0xFFE0, 0xFE00, 0 // XY-mirror, big

tile_jumps: .word prepare_data4, prepare_data16, prepare_data256

.space 0x6D0

// Values updated by CPU; addresses 0xF8C-0xFFF
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

    // Run the RDP initialization commands
    li   t0, 0x2 // Use DMEM
    mtc0 t0, COP0_DP_STATUS
    la   a0, rdp_init
    la   a1, rdp_line
    jal  rdp_send

draw_frame:
    // Set initial values for the frame
    li   s0, 0   // Current X coordinate (x2)
    li   s2, 512 // Maximum X coordinate (x2)
    li   a3, 0   // Current BG shift

    // Set the Y bounds based on 224 or 239-line mode
    lw   t0, fb_border
    li   s1, 0      // Current Y coordinate
    li   s3, 224
    sll  t0, t0, 1
    xori t0, t0, 0x10
    add  s3, s3, t0 // Maximum Y coordinate

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

    // Prepare to draw the BG based on tile bitwidth
    lw   s4, bg_type
    srl  s4, s4, t1
    andi s4, s4, 0x3
    beqz s4, next_bg
    sll  t0, s4, 2
    lw   k1, tile_jumps - 4(t0) // Code path
    addi s4, s4, 3              // Character shift

    // Get the vertical and horizontal offsets within the BG
    sll  t1, t1, 1
    lw   s5, bgvofs(t1)
    add  s5, s5, s1
    lw   s6, bghofs(t1)

    // Only reload screen data when starting a new row of tiles
    sll  a3, a3, 6 // BG screen offset
    sltu t0, zero, s1
    sub  t0, zero, t0
    andi t0, t0, 0x7
    and  t0, t0, s5
    bnez t0, skip_screen

    // Get the base screen address for the BG
    la   a0, scrn_data
    add  a0, a0, a3
    la   a1, 0xA03F0000 // VRAM
    lw   t0, bgscrnbase(t1)
    add  a1, a1, t0

    // Apply the vertical base offset if past the bounds of the first screen
    andi t0, s5, 0x100
    beqz t0, load_screen
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

skip_screen:
    // Calculate the character offset for the current line
    la   a0, char_data
    andi s5, s5, 7
    sll  s5, s5, 1
    la   t0, 0xA03F0000 // VRAM
    add  s5, s5, t0
    lw   t0, bgcharbase(t1)
    add  s5, s5, t0

    // Set the initial tile bound based on fine X offset
    li   v1, 8
    andi t9, s6, 0x7
    sub  v1, v1, t9
    sll  v1, v1, 1
    add  v1, v1, s0

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
    addi v1, v1, 0x10

load_tile:
    // Move to the next BG once the scanline is complete
    bge  s0, s2, finish_bg

    // Get the BG entry for the current tile
    // TODO: priority
    srl  t4, s0, 1
    add  t4, t4, s6
    andi t6, t4, 0x1FF & ~7
    srl  t6, t6, 2
    add  t6, t6, a3
    lhu  t6, scrn_data(t6)

check_tile:
    // Skip loading if the tile is the same as the previous one
    beq  v0, t6, same_tile
    move v0, t6

    // Load the tile's character data based on fine Y offset and vertical mirroring
    andi t0, t6, 0x03FF
    sll  t0, t0, s4
    add  a1, s5, t0
    andi t0, t6, 0x8000
    beqz t0, mirror_noty
    xori a1, a1, 7 << 1
mirror_noty:
    jal  dma_read

    // Jump to prepare tile data based on bitwidth
    andi s7, t6, 0x4000 // Horizontal mirroring
    andi t5, a1, 0x0007 // DMA offset
    jr   k1

same_tile:
    // Take the fast path for equal tiles
    beqz k0, skip_tile
    b    draw_tile

prepare_data4:
    // Load data for a 4-color tile, and skip if it's empty
    lhu  k0, char_data + 0x00(t5)
    beqz k0, skip_tile
    srl  t7, t6, 8
    andi t7, t7, 0x7 << 2
    mtc2 k0, $v03, 0 // Upper byte to lane 0, bits 8-15
    mtc2 k0, $v03, 1 // Lower byte to lane 1, bits 8-15
    mtc2 t7, $v05, 0 // Palette offset
    bnez s7, mirror_x4

    // Decode the palette indices
    vand  $v01, $v20, $v03, 9 // Mask out other lower bits
    vand  $v02, $v20, $v03, 8 // Mask out other upper bits
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form indices
    vadd  $v00, $v02, $v05, 8 // Add palette offset
    b     draw_tile

mirror_x4:
    // Decode the palette indices, mirrored horizontally
    vand  $v01, $v25, $v03, 9 // Mask out other lower bits
    vand  $v02, $v25, $v03, 8 // Mask out other upper bits
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form indices
    vadd  $v00, $v02, $v05, 8 // Add palette offset
    b     draw_tile

prepare_data16:
    // Load data for a 16-color tile, and skip if it's empty
    lhu  t0, char_data + 0x00(t5)
    lhu  t1, char_data + 0x10(t5)
    or   k0, t0, t1
    beqz k0, skip_tile
    srl  t7, t6, 6
    andi t7, t7, 0x7 << 4
    mtc2 t0, $v03, 0 // Upper byte 1 to lane 0, bits 8-15
    mtc2 t0, $v03, 1 // Lower byte 1 to lane 1, bits 8-15
    mtc2 t1, $v13, 0 // Upper byte 2 to lane 0, bits 8-15
    mtc2 t1, $v13, 1 // Lower byte 2 to lane 1, bits 8-15
    mtc2 t7, $v05, 0 // Palette offset
    bnez s7, mirror_x16

    // Decode the palette indices
    vand  $v01, $v20, $v03, 9 // Mask out other lower bits
    vand  $v02, $v20, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v20, $v13, 9 // Mask out other lower bits
    vand  $v12, $v20, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v23, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v24, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices
    vadd  $v00, $v01, $v05, 8 // Add palette offset
    b     draw_tile

mirror_x16:
    // Decode the palette indices, mirrored horizontally
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
    beqz k0, skip_tile
    mtc2 t0, $v03, 0 // Upper byte 1 to lane 0, bits 8-15
    mtc2 t0, $v03, 1 // Lower byte 1 to lane 1, bits 8-15
    mtc2 t1, $v13, 0 // Upper byte 2 to lane 0, bits 8-15
    mtc2 t1, $v13, 1 // Lower byte 2 to lane 1, bits 8-15
    mtc2 t2, $v08, 0 // Upper byte 3 to lane 0, bits 8-15
    mtc2 t2, $v08, 1 // Lower byte 3 to lane 1, bits 8-15
    mtc2 t3, $v18, 0 // Upper byte 4 to lane 0, bits 8-15
    mtc2 t3, $v18, 1 // Lower byte 4 to lane 1, bits 8-15
    bnez s7, mirror_x256

    // Decode the palette indices
    vand  $v01, $v20, $v03, 9 // Mask out other lower bits
    vand  $v02, $v20, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v20, $v13, 9 // Mask out other lower bits
    vand  $v12, $v20, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v23, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v24, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v06, $v12, $v02, 0 // Combine partial indices
    vand  $v01, $v20, $v08, 9 // Mask out other lower bits
    vand  $v02, $v20, $v08, 8 // Mask out other upper bis
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v20, $v18, 9 // Mask out other lower bits
    vand  $v12, $v20, $v18, 8 // Mask out other upper bits
    vmudl $v13, $v23, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v24, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v07, $v12, $v02, 0 // Combine partial indices
    vmudn $v07, $v07, $v30, 0 // Shift upper indices left
    vor   $v00, $v06, $v07, 0 // Combine indices
    b     draw_tile

mirror_x256:
    // Decode the palette indices, mirrored horizontally
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
    b     draw_tile

finish_bg:
    // Convert the screen offset back to BG shift
    srl  a3, a3, 6

next_bg:
    // Move to the next BG until all have been drawn
    li   s0, 0
    addi a3, a3, 2
    andi a3, a3, 7
    bnez a3, draw_bg

    // DMA the scanline to RDRAM
    la   a0, 0x10 + scanline
    la   a1, 0xA03EF800
    li   a2, 0x1FF
    jal  dma_write

    // Update the RDP draw command for the current scanline
    lw   t0, fb_border
    add  t0, t0, s1
    sll  t0, t0, 2
    addi t1, t0, 4
    sh   t1, 26 + rdp_line // y3
    sll  t1, t0, 16
    or   t0, t0, t1
    sw   t0, 28 + rdp_line // y2, y1

    // Run the RDP to draw a scanline
    la   a0, rdp_line
    la   a1, rdp_tile
    jal  rdp_send

    // Move to the next line until the frame is complete
    addi s1, s1, 1
    bne  s1, s3, draw_line

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

    // Get the object's X coordinate, wrapped past pixel 256
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
    sh   t6, 32 + rdp_tile // x1
    sh   t5, 40 + rdp_tile // x3
    sh   t5, 48 + rdp_tile // x2
    lw   t7, fb_border
    add  t4, t4, t7
    sll  t4, t4, 2
    sh   t4, 26 + rdp_tile // y3
    add  t3, t3, t7
    sll  t3, t3, 2
    sll  t4, t3, 16
    or   t3, t3, t4
    sw   t3, 28 + rdp_tile // y2, y1

    // Update the RDP texture parameters based on size and mirroring
    srl  t5, t1, 10
    andi t5, t5, 0x30
    add  t5, t5, v1
    lw   t4, 0 + mirror_vals(t5)
    lh   t3, 4 + mirror_vals(t5)
    srl  t5, t4, 16
    sh   t5, 56 + rdp_tile // S coordinate
    sh   t4, 64 + rdp_tile // Gradient along X
    sh   t3, 88 + rdp_tile // Gradient along Y

    // Get the object's palette offset
    srl  t3, t1, 5
    andi t3, t3, 0x70
    addi t3, t3, 0x80
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
    mtc2 t3, $v05, 0 // Palette offset

    // Decode the palette indices
    vand  $v01, $v20, $v03, 9 // Mask out other lower bits
    vand  $v02, $v20, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v21, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v22, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v20, $v13, 9 // Mask out other lower bits
    vand  $v12, $v20, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v23, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v24, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices

    // Add the palette offset to non-zero indices
    veq  $v00, $v01, $v31, 0
    vmrg $v00, $v01, $v05, 8
    vadd $v02, $v01, $v00, 0

    // Loop through each line until the tile is complete
    sqv  $v02, 0, 0x10, t7
    addi t8, t8, 2
    addi t7, t7, 0x20
    andi t5, t8, 0xF
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
    la   a0, 0x10 + scanline
    la   a1, 0xA03EF800
    li   a2, 0x1FF
    jal  dma_write

    // Run the RDP to draw an object
    la   a0, rdp_tile
    la   a1, mirror_vals
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
    li   t1, 0x20000
    add  t0, t0, t1
    li   t1, 0xA03F0000
    bne  t0, t1, set_buffer
    li   t0, 0xA0390000
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

    // Run the RDP to prepare the next frame
    la   a0, rdp_frame
    la   a1, rdp_line
    jal  rdp_send
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
