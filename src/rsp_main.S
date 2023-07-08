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

texture:    .byte 0:0x80
oam:        .byte 0:0x220
scrn_data:  .byte 0:0x80
char_data:  .byte 0:0x40
tile_table: .byte 0:0x400

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

rdp_section:
    // RDP commands that run when changing the frame section
    .dword 0x2D030020004303A0 // Set Scissor

rdp_frame:
    // RDP commands that run at the start of a frame
    .dword 0x3F100117A03AE600 // Set Color Image
    .dword 0x3700000000000000 // Set Fill Color
    .dword 0x2F3888FF00040001 // Set Other Modes (fill)
    .dword 0x3642F3C000030000 // Fill Rectangle
    .dword 0x2F0888FF00040001 // Set Other Modes (1 cycle)
    .dword 0x3D100000A038C000 // Set Texture Image (palette)
    .dword 0x3300000000400000 // Load Block (palette)

rdp_tile:
    // RDP commands that run when a tile is being drawn
    .dword 0x3D480000A0360000 // Set Texture Image (texture)
    .dword 0x3300000001080000 // Load Block (texture)
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

layer_chart:
    // Bit 7: object, bit 6: BG priority, bits 3-2: BG type, bits 1-0: index
    // BG type: 0 = none, 1 = 4-color, 2 = 16-color, 3 = 256-color
    // Offset-per-tile, hi-res, and rotscale are unimplemented
    .byte 0x07, 0x06, 0x80, 0x47, 0x46, 0x81, 0x05, 0x04, 0x82, 0x45, 0x44, 0x83, 0, 0, 0, 0 // Mode 0
    .byte 0x06, 0x80, 0x46, 0x81, 0x09, 0x08, 0x82, 0x49, 0x48, 0x83, 0x00, 0x00, 0, 0, 0, 0 // Mode 1 (BG3 normal)
    .byte 0x09, 0x80, 0x08, 0x81, 0x49, 0x82, 0x48, 0x83, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 2
    .byte 0x09, 0x80, 0x0C, 0x81, 0x49, 0x82, 0x4C, 0x83, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 3
    .byte 0x05, 0x80, 0x0C, 0x81, 0x45, 0x82, 0x4C, 0x83, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 4
    .byte 0x05, 0x80, 0x08, 0x81, 0x45, 0x82, 0x48, 0x83, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 5
    .byte 0x80, 0x08, 0x81, 0x82, 0x48, 0x83, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 6
    .byte 0x80, 0x0C, 0x4C, 0x81, 0x82, 0x83, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 7
    .byte 0x06, 0x80, 0x81, 0x09, 0x08, 0x82, 0x49, 0x48, 0x83, 0x46, 0x00, 0x00, 0, 0, 0, 0 // Mode 1 (BG3 high)

tile_params:
    // S-coordinate, gradient along X, gradient along Y
    .hword 0x0010, 0x0020, 0x0100, 0 // No mirror
    .hword 0x00F0, 0xFFE0, 0x0100, 0 // X-mirror
    .hword 0x0710, 0x0020, 0xFF00, 0 // Y-mirror
    .hword 0x07F0, 0xFFE0, 0xFF00, 0 // XY-mirror

tile_jumps: .word decode_tile4, decode_tile16, decode_tile256

mask_ofs: .byte 0

.space 0x5A7

// Extra set of below values; used for mid-frame effects
split_line: .word  0x00 // 0xEFC-0xEFF
top_values: .space 0x80 // 0xF00-0xF7F

// Values updated by CPU; addresses 0xF80-0xFFF
fb_border:   .word 0x08
obj_rotate:  .word 0x000
bg_mode:     .word 0x00
sub_mask:    .word 0x00
main_mask:   .word 0x00
obj_size:    .word 0x10100808
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
    // Set the max Y-bound based on 224 or 239-line mode
    lw   t0, fb_border
    li   sp, 224
    sll  t0, t0, 1
    xori t0, t0, 0x10
    add  sp, sp, t0

    // Set values for the first frame section if split
    lw   t0, split_line
    beqz t0, full_frame
    bge  t0, sp, full_frame
    li   k0, 0         // Section start
    add  k1, t0, 2     // Section end
    addi s7, k0, -0x80 // Value offset
    b    draw_section

full_frame:
    // Set values for the full frame if not split
    li   k0, 0  // Section start
    move k1, sp // Section end
    li   s7, 0  // Value offset

draw_section:
    // Update the RDP scissor command for a frame section
    lw   t0, fb_border
    add  t1, t0, k0
    sll  t1, t1, 2
    sh   t1, rdp_section + 2
    add  t2, t0, k1
    sll  t2, t2, 2
    sh   t2, rdp_section + 6

    // Run the RDP to prepare the section
    la   a0, rdp_section
    la   a1, rdp_frame
    jal  rdp_send

    // Set the initial layer lookup offset
    lw   s3, bg_mode(s7)
    sll  s3, s3, 4
    sb   zero, mask_ofs

next_layer:
    // Look up the next layer and check if it's BG or OBJ
    // Layers are drawn in an order that mimics priority without slow depth testing
    // This isn't fully accurate; OBJ priority effects like SMB3 pipes won't work
    lbu  t0, layer_chart(s3)
    addi s3, s3, 1
    lbu  t1, mask_ofs
    bge  t0, 0x80, draw_obj
    bnez t0, draw_bg

    // After the sub screen layers are done, draw the main screen layers on top
    // Blending isn't implemented, but this at least allows using screens to reorder layers
    bnez t1, next_section
    lw   s3, bg_mode(s7)
    sll  s3, s3, 4
    li   t1, 4
    sb   t1, mask_ofs
    b    next_layer

next_section:
    // Set values for the second frame section if split
    beqz s7, next_frame
    move k0, k1 // Section start
    move k1, sp // Section end
    li   s7, 0  // Value offset
    b    draw_section

draw_bg:
    // Skip the layer if the BG is disabled
    add  t1, t1, s7
    lw   t1, sub_mask(t1)
    li   t2, 1
    andi t3, t0, 0x03 // Index
    sll  t2, t2, t3
    and  t1, t1, t2
    beqz t1, next_layer

    // Set parameters based on the BG type
    srl  t1, t0, 2
    andi s4, t1, 0x03
    sll  t1, s4, 2
    lw   t9, tile_jumps - 4(t1) // Code path
    addi s4, s4, 3              // Character shift
    andi gp, t0, 0x40           // Priority
    sll  gp, gp, 7

    // Reset the tile cache for a new BG
    la   t0, tile_table
    la   t2, vec_data
clear_cache:
    sqv  $v31, 0, 0x00, t0
    sqv  $v31, 0, 0x10, t0
    addi t0, t0, 0x20
    bne  t0, t2, clear_cache

    // Get the horizontal and vertical offsets within the BG
    sll  s2, t3, 2
    add  s2, s2, s7
    lw   s6, bghofs(s2)
    lw   s5, bgvofs(s2)

    // Set the initial tile Y-coordinate and character number
    andi t0, s5, 0x7
    andi t1, k0, 0x7
    sub  s1, k0, t0
    sub  s1, s1, t1
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

    // Skip the tile if its priority doesn't match the layer
    andi t0, t6, 0x2000
    xor  t0, t0, gp
    bnez t0, finish_tile

    // Update the RDP draw command with the tile's X-coordinate
    addi t0, s0, 20
    sh   t0, 24 + rdp_tile // x1
    addi t1, s0, 12
    sh   t1, 32 + rdp_tile // x3
    sh   t1, 40 + rdp_tile // x2

    // Update the RDP texture parameters based on mirroring
    srl  t5, t6, 11
    andi t5, t5, 0x18
    lw   t4, 0 + tile_params(t5)
    lh   t3, 4 + tile_params(t5)
    srl  t5, t4, 16
    sh   t5, 48 + rdp_tile // S-coordinate
    sh   t4, 56 + rdp_tile // Gradient along X
    sh   t3, 80 + rdp_tile // Gradient along Y

    // Skip uploading if the last tile's number and palette were the same
    andi t0, t6, 0x1FFF
    beq  t0, v1, skip_upload
    move v1, t0

    // Skip decoding if the tile is already cached with the same palette
    andi s8, t6, 0x3FF // Character number
    lbu  t1, tile_table(s8)
    srl  a3, t6, 5
    andi a3, a3, 0xE0  // Palette offset
    ori  a3, a3, 0x01  // Cache bit
    beq  a3, t1, skip_decode
    sb   a3, tile_table(s8)

    // Load the tile's character data from VRAM
    la   a0, char_data
    la   a1, 0xA03F0000 // VRAM
    lw   t0, bgcharbase(s2)
    add  a1, a1, t0
    sll  t0, s8, s4
    add  a1, a1, t0
    li   a2, 0x3F
    jal  dma_read

    // Set initial values and jump to the tile decoder
    li   t7, 0x80
    li   t8, 0x10
    jr   t9

decode_tile4:
    // Set the 4-color palette offset
    srl  t0, a3, 3
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
    b    cache_tile

decode_tile16:
    // Set the 16-color palette offset
    srl  t0, a3, 1
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
    b    cache_tile

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

cache_tile:
    // DMA the texture to the tile cache in RDRAM
    la   a0, texture
    la   a1, 0xA0360000
    sll  t0, s8, 7
    add  a1, a1, t0
    sw   a1, 4 + rdp_tile
    li   a2, 0x7F
    jal  dma_write

draw_tile:
    // Run the RDP to draw a tile
    la   a0, rdp_tile
    la   a1, layer_chart
    jal  rdp_send

finish_tile:
    // Move to the next tile of the row until finished
    addi s0, s0, 8
    blt  s0, 256, next_tile

    // Move to the next row of the BG until finished
    addi s1, s1, 8
    blt  s1, k1, draw_row
    b    next_layer

skip_decode:
    // Update the RDP texture address and draw a cached tile
    la   a1, 0xA0360000
    sll  t0, s8, 7
    add  a1, a1, t0
    sw   a1, 4 + rdp_tile
    b    draw_tile

skip_upload:
    // Run the RDP to draw a tile, skipping texture upload
    la   a0, 0x10 + rdp_tile
    la   a1, tile_params
    jal  rdp_send
    b    finish_tile

draw_obj:
    // Skip the layer if objects are disabled
    add  t1, t1, s7
    lw   t1, sub_mask(t1)
    andi a3, t0, 0x03 // Priority
    andi t1, t1, 0x10
    beqz t1, next_layer

    // Initialize the OAM count and RDP texture address
    lw   t9, obj_rotate
    la   a1, 0xA0360000
    sw   a1, 4 + rdp_tile

check_object:
    // Read the 4 object bytes and additional 2 bits
    lw   t1, oam(t9)
    srl  t2, t9, 4
    lbu  t2, 0x200 + oam(t2)
    srl  t3, t9, 1
    andi t3, t3, 0x6
    srl  t2, t2, t3

    // Skip the object if its priority doesn't match the layer
    srl  t0, t1, 12
    andi t0, t0, 0x3
    xor  t0, t0, a3
    bnez t0, next_object

    // Get the object's size based on the large bit
    andi t0, t2, 0x2  // Large
    lhu  s0, obj_size(t0)
    andi s1, s0, 0xFF // Y-size
    srl  s0, s0, 8    // X-size

    // Get the object's Y-coordinate, wrapped past line 240
    srl  t3, t1, 24
    addi t3, t3, 1
    li   t4, 0xF1
    slt  t4, t4, t3
    sll  t4, t4, 31
    sra  t4, t4, 23
    or   s8, t3, t4

    // Skip the object if it doesn't occupy any visible scanlines
    add  t4, s8, s1
    slt  t5, t4, k0
    sgt  t6, s8, k1
    or   t5, t5, t6
    bnez t5, next_object

    // Get the object's X-coordinate, wrapped past pixel 256
    srl  t5, t1, 16
    andi t5, t5, 0xFF
    sll  t6, t2, 31 // Upper X
    sra  t6, t6, 23
    or   s2, t5, t6

    // Skip the object if it doesn't occupy any visible pixels
    add  t6, s2, s0
    and  t7, t6, s2
    sra  t7, t7, 8
    bnez t7, next_object

    // Update the RDP texture parameters based on mirroring
    srl  t5, t1, 11
    andi t5, t5, 0x18
    lw   t4, 0 + tile_params(t5)
    lh   t3, 4 + tile_params(t5)
    srl  t5, t4, 16
    sh   t5, 48 + rdp_tile // S-coordinate
    sh   t4, 56 + rdp_tile // Gradient along X
    sh   t3, 80 + rdp_tile // Gradient along Y

    // Set initial values for drawing the object
    srl  t3, t1, 5
    andi t3, t3, 0x70
    addi t3, t3, 0x80
    mtc2 t3, $v05, 0 // Palette offset
    move s4, s0      // X-size reload
    li   s5, 0       // Character offset

    // Set initial values based on horizontal mirroring
    andi t7, t1, 0x4000 // X-mirror
    li   s6, 8
    move v0, s0
    beqz t7, object_ymir
    add  s2, s2, s0
    addi s2, s2, -8
    addi s6, zero, -8
    sub  v0, zero, s0

object_ymir:
    // Set initial values based on vertical mirroring
    andi t7, t1, 0x8000 // Y-mirror
    li   gp, 8
    beqz t7, next_objy
    add  s8, s8, s1
    addi s8, s8, -8
    addi gp, zero, -8

next_objy:
    // Update the RDP draw command with the object's Y-coordinate
    lw   t7, fb_border
    add  t7, t7, s8
    sll  t7, t7, 2
    addi t6, t7, 8 << 2
    sh   t6, 18 + rdp_tile // y3
    sll  t3, t7, 16
    or   t3, t3, t7
    sw   t3, 20 + rdp_tile // y2, y1

next_objx:
    // Update the RDP draw command with the object's X-coordinate
    addi t7, s2, 12 // Vertical border
    sh   t7, 32 + rdp_tile // x3
    sh   t7, 40 + rdp_tile // x2
    addi t7, t7, 8
    sh   t7, 24 + rdp_tile // x1

    // Load the tile's character data from VRAM
    la   a0, char_data
    la   a1, 0xA03F0000 // VRAM
    lw   t4, objcharbase
    add  a1, a1, t4
    andi t4, t1, 0x1FF
    sll  t4, t4, 5
    add  a1, a1, t4
    add  a1, a1, s5
    li   a2, 0x1F
    jal  dma_read

    // Set initial values for drawing the tile
    li   t8, 0 // Character offset
    li   t7, 0 // Texture offset

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
        addi t7, t7, 0x10
    vmrg $v00, $v01, $v05, 8
        addi t8, t8, 0x2
    vadd $v02, $v01, $v00, 0

    // Write the line to the texture buffer and loop until complete
    andi t5, t8, 0xF
    sqv  $v02, 0, -0x10, t7
    bnez t5, decode_object

    // DMA the object texture to RDRAM
    la   a0, texture
    la   a1, 0xA0360000
    li   a2, 0x7F
    jal  dma_write

    // Run the RDP to draw an object tile
    la   a0, rdp_tile
    la   a1, layer_chart
    jal  rdp_send

    // Loop through object tiles in the X-direction
    addi s0, s0, -8
    add  s2, s2, s6
    addi s5, s5, 0x20
    bnez s0, next_objx

    // Loop through object tiles in the Y-direction
    move s0, s4
    sub  s2, s2, v0
    sll  t7, s0, 2
    sub  s5, s5, t7
    addi s5, s5, 0x200
    addi s1, s1, -8
    add  s8, s8, gp
    bnez s1, next_objy

next_object:
    // Move to the next object until all have been drawn
    addi t9, t9, -4
    lw   t0, obj_rotate
    andi t9, t9, 0x1FC
    bne  t9, t0, check_object
    b    next_layer

next_frame:
    // Halt until the next frame can be drawn
    li   t0, 0x0002 // Set halt
    mtc0 t0, COP0_SP_STATUS

    // Update the RDP scissor command for 224 or 239-line mode
    lw   t0, fb_border
    li   t1, 0x0020
    li   t2, 0x03A0
    bnez t0, set_border
    li   t1, 0x0000
    li   t2, 0x03C0
set_border:
    sh   t1, rdp_section + 2
    sh   t2, rdp_section + 6

    // Update the RDP color buffer command with the next buffer address
    lw   t0, rdp_frame + 4
    li   t1, 0x20D00 // Buffer size
    add  t0, t0, t1
    li   t1, 0xA03F0000
    bne  t0, t1, set_buffer
    li   t0, 0xA038D900
set_buffer:
    sw   t0, rdp_frame + 4

    // Update the RDP fill color command with palette color 0
    lw   t0, fill_color
    sh   t0, rdp_frame + 12
    sh   t0, rdp_frame + 14

    // Run the RDP to prepare the next frame
    la   a0, rdp_section
    la   a1, rdp_tile
    jal  rdp_send
    b    draw_frame


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
