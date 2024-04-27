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

#include <rsp.inc>
#include "defines.h"

.data

// Empty values that are defined as macros
.byte 0:PALETTE_PTR

// Frame values that aren't empty by default
palette_ptr: .word PALETTE_QUEUE1, PALETTE_QUEUE2
oam_ptr: .word OAM_QUEUE1, OAM_QUEUE2
dirty_ptr: .word DIRTY_QUEUE1, DIRTY_QUEUE2
vram_ptr: .word VRAM_QUEUE1, VRAM_QUEUE2
section_ptr: .word SECTION_QUEUE1, SECTION_QUEUE2
framebuffer: .word FRAMEBUFFER1, FRAMEBUFFER2

rdp_init:
    // RDP commands that only need to run once
    .dword 0x3C080E10001C8241 // Set Combine
    .dword 0x39000000FFFFFFFF // Set Blend Color
    .dword 0x3510810000000000 // Set Tile (palette)
    .dword 0x3550000002054150 // Set Tile (block)

rdp_mode7:
    // RDP commands that run when changing to/from mode 7
    .dword 0x2800000000000000 // Sync Tile
    .dword 0x3548020001054150 // Set Tile (texture)
    .dword 0x320000000101F01F // Set Tile Size

rdp_frame:
    // RDP commands that run at the start of a frame
    .dword 0x3F10011700000000 // Set Color Image
    .dword 0x3D10000000000000 // Set Texture Image (palette)
    .dword 0x3300000000400000 // Load Block (palette)

rdp_section:
    // RDP commands that run when changing the frame section
    .dword 0x2800000000000000 // Sync Tile
    .dword 0x2D030020004303A0 // Set Scissor
    .dword 0x3700000000000000 // Set Fill Color
    .dword 0x2F3888FF00040001 // Set Other Modes (fill)
    .dword 0x3642F3A000030020 // Fill Rectangle
    .dword 0x2F0888FF00040001 // Set Other Modes (1 cycle)

rdp_tile:
    // RDP commands that run when a tile is being drawn
    .dword 0x3D50000300000000 // Set Texture Image (texture)
    .dword 0x2800000000000000 // Sync Tile
    .dword 0x330000000201F800 // Load Block (texture)
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

// Possible code paths for tile decoding
tile_jumps: .word decode_tile4, decode_tile16, decode_tile256

tile_params:
    // S/T coordinates, gradients along X, gradients along Y
    .word 0x00000000, 0x00100000, 0x00000010, 0 // No mirror
    .word 0x00700000, 0xFFF00000, 0x00000010, 0 // X-mirror
    .word 0x00000070, 0x00100000, 0x0000FFF0, 0 // Y-mirror
    .word 0x00700070, 0xFFF00000, 0x0000FFF0, 0 // XY-mirror

layer_chart:
    // Bit 7: object, bit 6: BG priority, bits 3-2: BG type, bits 1-0: index
    // BG type: 0 = rotscale, 1 = 4-color, 2 = 16-color, 3 = 256-color
    // Offset-per-tile, hi-res, and EXTBG are unimplemented
    .byte 0x07, 0x06, 0x80, 0x47, 0x46, 0x81, 0x05, 0x04, 0x82, 0x45, 0x44, 0x83, 0, 0, 0, 0 // Mode 0
    .byte 0x06, 0x80, 0x46, 0x81, 0x09, 0x08, 0x82, 0x49, 0x48, 0x83, 0x00, 0x00, 0, 0, 0, 0 // Mode 1 (BG3 normal)
    .byte 0x09, 0x80, 0x08, 0x81, 0x49, 0x82, 0x48, 0x83, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 2
    .byte 0x09, 0x80, 0x0C, 0x81, 0x49, 0x82, 0x4C, 0x83, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 3
    .byte 0x05, 0x80, 0x0C, 0x81, 0x45, 0x82, 0x4C, 0x83, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 4
    .byte 0x05, 0x80, 0x08, 0x81, 0x45, 0x82, 0x48, 0x83, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 5
    .byte 0x80, 0x08, 0x81, 0x82, 0x48, 0x83, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 6
    .byte 0x80, 0x40, 0x81, 0x82, 0x83, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0, 0, 0, 0 // Mode 7
    .byte 0x06, 0x80, 0x81, 0x09, 0x08, 0x82, 0x49, 0x48, 0x83, 0x46, 0x00, 0x00, 0, 0, 0, 0 // Mode 1 (BG3 high)

// Gap to ensure vector data is aligned
.byte 0:(VEC_DATA - MAX_OBJECT)

vec_data:
    // Constants that are always kept in vector registers
    .hword 0x8000, 0x4000, 0x2000, 0x1000, 0x0800, 0x0400, 0x0200, 0x0100 // Mask
    .hword 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100 // Shift byte
    .hword 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100 // Shift 1
    .hword 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200 // Shift 2
    .hword 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400 // Shift 3
    .hword 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400, 0x0800 // Shift 4
    .hword 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010 // Shift 5
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 // Zero

.text

main:
    // Load the constants for vector math
    li t0, VEC_DATA
    lqv $v24, 0, 0x00, t0
    lqv $v25, 0, 0x10, t0
    lqv $v26, 0, 0x20, t0
    lqv $v27, 0, 0x30, t0
    lqv $v28, 0, 0x40, t0
    lqv $v29, 0, 0x50, t0
    lqv $v30, 0, 0x60, t0
    lqv $v31, 0, 0x70, t0

    // Run the RDP initialization commands
    li t0, 0x2 // Use DMEM
    mtc0 t0, COP0_DP_STATUS
    li a0, RDP_INIT
    jal rdp_send
    li a1, RDP_FRAME

    // Set the initial frame queue offset
    li sp, 0

draw_frame:
    // Set the initial section bound
    li k1, 0

    // Load OAM for the current frame
    li a0, OAM
    lw a1, OAM_PTR(sp)
    jal dma_read
    li a2, 0x21F

    // Load the VRAM dirty table for the current frame
    li a0, TILE_TABLE
    lw a1, DIRTY_PTR(sp)
    jal dma_read
    li a2, 0x3FF

    // Combine new dirty bits with the previous table
    li t1, VRAM_TABLE
    li t2, 0x400
table_loop:
    addi t2, t2, -16
    lqv $v00, 0, 0, t1
    lqv $v01, 0, 0, a0
    addi a0, a0, 16
    vor $v00, $v00, $v01, 0
    sqv $v00, 0, 0, t1
    bnez t2, table_loop
    addi t1, t1, 16

    // Update the RDP framebuffer and palette addresses
    lw t0, FRAMEBUFFER(sp)
    lw t1, PALETTE_PTR(sp)
    sw t0, RDP_FRAME + 4
    sw t1, RDP_FRAME + 12

    // Run the RDP to start the frame
    li a0, RDP_FRAME
    jal rdp_send
    li a1, RDP_SECTION

    // Initialize values for finding the first visible object
    li t9, 0x200 // Index
    li t8, 239
    lw t0, FB_BORDER(sp)
    sll t0, t0, 1
    sub t8, t8, t0 // Y-bound

next_visible:
    // Move to the next object until all have been checked
    beqz t9, set_visible
    nop
    addi t9, t9, -4

    // Read the 4 object bytes and additional 2 bits
    lw t1, OAM(t9)
    srl t2, t9, 4
    lbu t2, OAM + 0x200(t2)
    srl t3, t9, 1
    andi t3, t3, 0x6
    srl t2, t2, t3

    // Get the object's size based on the large bit
    andi t3, t2, 0x2 // Large
    lhu s0, OBJ_SIZE(t3)
    andi s1, s0, 0xFF // Y-size
    srl s0, s0, 8 // X-size

    // Get the object's Y-coordinate, wrapped past screen bounds
    srl t3, t1, 24
    slt t4, t8, t3
    sll t4, t4, 31
    sra t4, t4, 23
    or s8, t3, t4

    // Skip the object if it doesn't occupy any visible scanlines
    add t4, s8, s1
    sle t5, t4, zero
    bnez t5, next_visible

    // Get the object's X-coordinate, wrapped past pixel 256
    srl t5, t1, 16
    andi t5, t5, 0xFF
    sll t6, t2, 31 // Upper X
    sra t6, t6, 23
    or s2, t5, t6

    // Skip the object if it doesn't occupy any visible pixels
    add t6, s2, s0
    and t7, t6, s2
    sra t7, t7, 8
    bnez t7, next_visible

set_visible:
    // Save the first visible object index so objects past it can be skipped
    sh t9, MAX_OBJECT
    sh t8, WRAP_BOUND

next_section:
    // Finish the frame after the last section is done
    lw t0, FRAME_END(sp)
    beq k1, t0, next_frame

    // Load values for the next section
    li a0, OBJ_SIZE
    lw a1, SECTION_PTR(sp)
    jal dma_read
    li a2, 0x4F
    addi a1, a1, 0x50
    sw a1, SECTION_PTR(sp)

    // Set the section bounds
    move k0, k1
    lbu k1, SPLIT_LINE

    // Update the RDP scissor and fill bounds for the section
    lw t0, FB_BORDER(sp)
    add t1, t0, k0
    sll t1, t1, 2
    sh t1, RDP_SECTION + 10
    sh t1, RDP_SECTION + 38
    add t2, t0, k1
    sll t2, t2, 2
    sh t2, RDP_SECTION + 14
    ori t2, t2, 0xF000
    sh t2, RDP_SECTION + 34

    // Update the RDP fill color for the section
    lbu t1, FORCE_BLANK
    bnez t1, blank_set
    li t0, 0
    lw t0, FILL_COLOR(sp)
blank_set:
    sh t0, RDP_SECTION + 20
    sh t0, RDP_SECTION + 22

    // Run the RDP to prepare the section
    li a0, RDP_SECTION
    jal rdp_send
    li a1, RDP_TILE

    // Don't draw any layers if force blank is set
    bnez t1, next_section

    // Set the initial layer lookup offset
    lbu s3, BG_MODE
    sll s3, s3, 4
    lw s7, MASK_OFS(sp)

    // Reset the background priority status
    sw zero, PRIO_CHECKS + 0
    sw zero, PRIO_CHECKS + 4

next_layer:
    // Look up the next layer and check if it's BG or OBJ
    // Layers are drawn in an order that mimics priority without slow depth testing
    // This isn't fully accurate; OBJ priority effects like SMB3 pipes won't work
    lbu t0, LAYER_CHART(s3)
    bge t0, 0x80, draw_obj
    addi s3, s3, 1
    beq t0, 0x40, draw_mode7
    nop
    bnez t0, draw_bg

    // After the first screen's layers are done, draw the other screen's layers on top
    // As a workaround for lack of blending, the main and sub screens can be swapped
    lw t1, MASK_OFS(sp)
    bne t1, s7, next_section
    lbu s3, BG_MODE
    sll s3, s3, 4
    b next_layer
    xori s7, s7, 0x1


draw_bg:
    // Skip the layer if the BG is disabled
    lbu t1, SUB_MASK(s7)
    li t2, 1
    andi t3, t0, 0x3 // Index
    sll a3, t2, t3 // Mask
    and t1, t1, a3
    beqz t1, next_layer

    // Skip the priority pass if no tiles had high priority
    andi gp, t0, 0x40 // Priority
    sll gp, gp, 7
    sll s2, t3, 1
    lhu t1, PRIO_CHECKS(s2)
    xor t1, t1, gp
    bnez t1, next_layer

    // Set parameters based on the BG type
    srl t2, t0, 2
    andi s4, t2, 0x3
    sll t1, s4, 2
    lw t9, TILE_JUMPS - 4(t1) // Code path
    addi s4, s4, 3 // Character shift

    // Check if the BG type or character base changed
    lhu t0, BGCHARBASE(s2)
    or t0, t0, s4
    lhu t1, CACHE_BASES(s2)
    beq t0, t1, load_cache
    sh t0, CACHE_BASES(s2)

    // Reset the tile cache if something changed
    li t0, TILE_TABLE
    li t1, VRAM_TABLE
clear_cache:
    sqv $v31, 0, 0x00, t0
    addi t0, t0, 0x20
    bne t0, t1, clear_cache
    sqv $v31, 0, -0x10, t0
    b get_offsets

load_cache:
    // Load the previous cache status if it's still valid
    li a0, TILE_TABLE
    li a1, TILE_STATS_BG1
    sll t0, s2, 9
    add a1, a1, t0
    jal dma_read
    li a2, 0x3FF

get_offsets:
    // Get the horizontal and vertical offsets within the BG
    lhu s5, BGVOFS(s2)
    lhu s6, BGHOFS(s2)
    addi s5, s5, 1

    // Set the initial tile Y-coordinate and character number
    andi t0, s5, 0x7
    andi t1, k0, 0x7
    sub s1, k0, t0
    sub s1, s1, t1
    li v1, 0xFFFF

draw_row:
    // Set the initial tile X-coordinate
    andi t0, s6, 0x7
    sub s0, zero, t0

    // Get the base screen address for the BG
    li a0, SCRN_DATA
    lw a1, VRAM_PTR(sp)
    lhu t0, BGSCRNBASE(s2)
    add a1, a1, t0

    // Apply the vertical base offset if past the bounds of the first screen
    add t1, s5, s1
    andi t0, t1, 0x100
    beqz t0, load_screen
    lhu t0, BGBASEOFSV(s2)
    add a1, a1, t0

load_screen:
    // Load a row of BG entries from the first horizontal screen
    andi t0, t1, 0xFF
    sll t0, t0, 3
    add a1, a1, t0
    jal dma_read
    li a2, 0x3F

    // Load a row of BG entries from the second horizontal screen
    addi a0, a0, 0x40
    lhu t0, BGBASEOFSH(s2)
    jal dma_read
    add a1, a1, t0

    // Update the RDP draw command with the tile's Y-coordinate
    lw t0, FB_BORDER(sp)
    add t0, t0, s1
    sll t0, t0, 2
    addi t1, t0, 8 << 2
    sh t1, RDP_TILE + 26 // y3
    sh t0, RDP_TILE + 28 // y2
    sh t0, RDP_TILE + 30 // y1

next_tile:
    // Get the BG entry for the current tile
    add t4, s6, s0
    andi t6, t4, 0x1FF
    srl t6, t6, 2
    lhu t6, SCRN_DATA(t6)

    // Skip the tile if its priority doesn't match the layer
    andi t0, t6, 0x2000
    xor t0, t0, gp
    bnez t0, skip_priority

    // Update the RDP draw command with the tile's X-coordinate
    addi t1, s0, 20
    sh t1, RDP_TILE + 32 // x1
    addi t1, s0, 12
    sh t1, RDP_TILE + 40 // x3
    sh t1, RDP_TILE + 48 // x2

    // Update the RDP texture parameters based on mirroring
    srl t5, t6, 10
    andi t5, t5, 0x30
    lw t3, TILE_PARAMS + 0(t5)
    lw t4, TILE_PARAMS + 4(t5)
    lw t5, TILE_PARAMS + 8(t5)
    sw t3, RDP_TILE + 56 // Coordinates
    sw t4, RDP_TILE + 64 // Gradients along X
    sw t5, RDP_TILE + 88 // Gradients along Y

    // Skip uploading if the last tile's number and palette were the same
    andi t0, t6, 0x1FFF
    beq t0, v1, skip_upload
    move v1, t0

    // Check if the tile's VRAM is dirty for the current BG
    andi s8, t6, 0x3FF // Character number
    lhu t0, BGCHARBASE(s2)
    sll t1, s8, s4
    add t3, t0, t1
    srl t0, t3, 6
    lbu t2, VRAM_TABLE(t0)
    and t4, t2, a3
    beqz t4, check_cache

    // Clear the VRAM dirty bit and reset affected cache entries
    xori t1, a3, 0x1F
    and t2, t2, t1
    sb t2, VRAM_TABLE(t0)
    andi t1, s8, 0x3
    sub t1, s8, t1
    sw zero, TILE_TABLE(t1)

check_cache:
    // Skip decoding if the tile is already cached with the same palette
    lbu t1, TILE_TABLE(s8)
    srl t2, t6, 5
    andi t2, t2, 0xE0 // Palette offset
    ori t0, t2, 0x1 // Cache bit
    beq t0, t1, skip_decode
    sb t0, TILE_TABLE(s8)

    // Load the tile's character data from VRAM
    li a0, CHAR_DATA
    lw a1, VRAM_PTR(sp)
    add a1, a1, t3
    jal dma_read
    li a2, 0x3F

    // Set initial values and jump to the tile decoder
    li t7, 0x40 // Texture offset
    jr t9
    li t8, CHAR_DATA + 0xE // Character offset

decode_tile4:
    // Set the 4-color palette offset
    sll t0, t2, 5
    mtc2 t0, $v05, 0 // Palette offset

loop_tile4:
    // Prepare 4-color tile data for decoding
    lpv $v03, 0, 0x00, t8 // Upper/lower byte 1 to lane 0/1, bits 8-15

    // Decode the palette indices
    vand $v01, $v24, $v03, 9 // Mask out other lower bits
    vand $v02, $v24, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor $v02, $v03, $v04, 0 // Combine bits to form indices
    vmudn $v02, $v02, $v25, 0 // Shift to upper byte

    // Add palette offset to non-zero indices and move to the next line
    veq $v00, $v02, $v31, 0
    addi t7, t7, -0x8
    vmrg $v00, $v02, $v05, 8
    addi t8, t8, -0x2
    vadd $v02, $v02, $v00, 0

    // Write the line to the texture buffer and loop until complete
    bnez t7, loop_tile4
    spv $v02, 0, 0, t7
    b cache_tile

decode_tile16:
    // Set the 16-color palette offset
    sll t0, t2, 7
    mtc2 t0, $v05, 0 // Palette offset

loop_tile16:
    // Prepare 16-color tile data for decoding
    lpv $v03, 0, 0x00, t8 // Upper/lower byte 1 to lane 0/1, bits 8-15
    lpv $v13, 0, 0x10, t8 // Upper/lower byte 2 to lane 0/1, bits 8-15

    // Decode the palette indices
    vand $v01, $v24, $v03, 9 // Mask out other lower bits
    vand $v02, $v24, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand $v11, $v24, $v13, 9 // Mask out other lower bits
    vand $v12, $v24, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor $v01, $v12, $v02, 0 // Combine partial indices
    vmudn $v01, $v01, $v25, 0 // Shift to upper byte

    // Add palette offset to non-zero indices and move to the next line
    veq $v00, $v01, $v31, 0
    addi t7, t7, -0x8
    vmrg $v00, $v01, $v05, 8
    addi t8, t8, -0x2
    vadd $v02, $v01, $v00, 0

    // Write the line to the texture buffer and loop until complete
    bnez t7, loop_tile16
    spv $v02, 0, 0, t7
    b cache_tile

decode_tile256:
    // Prepare 256-color tile data for decoding
    lpv $v03, 0, 0x00, t8 // Upper/lower byte 1 to lane 0/1, bits 8-15
    lpv $v13, 0, 0x10, t8 // Upper/lower byte 2 to lane 0/1, bits 8-15
    lpv $v08, 0, 0x20, t8 // Upper/lower byte 3 to lane 0/1, bits 8-15
    lpv $v18, 0, 0x30, t8 // Upper/lower byte 4 to lane 0/1, bits 8-15

    // Decode the palette indices
    vand $v01, $v24, $v03, 9 // Mask out other lower bits
    vand $v02, $v24, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand $v11, $v24, $v13, 9 // Mask out other lower bits
    vand $v12, $v24, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor $v06, $v12, $v02, 0 // Combine partial indices
    vand $v01, $v24, $v08, 9 // Mask out other lower bits
    vand $v02, $v24, $v08, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand $v11, $v24, $v18, 9 // Mask out other lower bits
    vand $v12, $v24, $v18, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor $v07, $v12, $v02, 0 // Combine partial indices
    vmudn $v07, $v07, $v30, 0 // Shift upper indices left
    vor $v00, $v06, $v07, 0 // Combine indices
    vmudn $v00, $v00, $v25, 0 // Shift to upper byte

    // Write the line to the texture buffer and loop until complete
    addi t7, t7, -0x8
    spv $v00, 0, 0, t7
    bnez t7, decode_tile256
    addi t8, t8, -0x2

cache_tile:
    // DMA the texture to the tile cache in RDRAM
    li a0, TEXTURE
    li a1, TILE_CACHE_BG1
    sll t0, s2, 15
    add a1, a1, t0
    sll t0, s8, 6
    add a1, a1, t0
    sw a1, RDP_TILE + 4
    jal dma_write
    li a2, 0x3F

draw_tile:
    // Run the RDP to draw a tile
    li a0, RDP_TILE
    jal rdp_send
    li a1, TILE_JUMPS

finish_tile:
    // Move to the next tile of the row until finished
    blt s0, 248, next_tile
    addi s0, s0, 8

    // Move to the next row of the BG until finished
    addi s1, s1, 8
    blt s1, k1, draw_row

    // Update the BG's tile cache status when finished
    li a0, TILE_TABLE
    li a1, TILE_STATS_BG1
    sll t0, s2, 9
    add a1, a1, t0
    jal dma_write
    li a2, 0x3FF
    b next_layer
    nop

skip_priority:
    // Track that a tile was skipped due to priority
    b finish_tile
    sh t0, PRIO_CHECKS(s2)

skip_decode:
    // Update the RDP texture address and draw a cached tile
    li a1, TILE_CACHE_BG1
    sll t0, s2, 15
    add a1, a1, t0
    sll t0, s8, 6
    add a1, a1, t0
    b draw_tile
    sw a1, RDP_TILE + 4

skip_upload:
    // Run the RDP to draw a tile, skipping texture upload
    li a0, RDP_TILE + 24
    jal rdp_send
    li a1, TILE_JUMPS
    b finish_tile


draw_mode7:
    // Skip the layer if the BG is disabled
    lbu t1, SUB_MASK(s7)
    andi t1, t1, 0x1
    beqz t1, next_layer

    // Update RDP parameters for a texture width of 32 (4 tiles)
    li t0, 0x08 // Width / 4
    sb t0, RDP_MODE7 + 10
    li t0, 0x0107F07F // Tile size
    sw t0, RDP_MODE7 + 20

    // Run the RDP for the start of mode 7
    li a0, RDP_MODE7
    jal rdp_send
    li a1, RDP_FRAME

    // Set the initial tile Y-coordinate
    andi t0, k0, 0x7
    sub s1, k0, t0

    // Calculate the initial screen X-coordinate
    lh t0, M7HOFS
    lh t2, M7X
    sub t0, t0, t2

    // Calculate the initial screen Y-coordinate
    lh t1, M7VOFS
    lh t3, M7Y
    add t1, t1, s1
    sub t1, t1, t3
    addi t1, t1, 1

    // Calculate the initial VRAM X-coordinate
    lh s2, M7A
    sll t2, t2, 8
    move a0, t0
    jal multiply
    move a1, s2
    add t2, t2, v0
    lh s4, M7B
    move a0, t1
    jal multiply
    move a1, s4
    add t8, t2, v0

    // Calculate the initial VRAM Y-coordinate
    lh s5, M7C
    sll t3, t3, 8
    move a0, t0
    jal multiply
    move a1, s5
    add t3, t3, v0
    lh s6, M7D
    move a0, t1
    jal multiply
    move a1, s6
    add t9, t3, v0

    // Calculate the min and max X-offsets within a mode 7 tile
    sll a0, s2, 3
    sub a0, a0, s2
    sll a1, s4, 3
    sub a1, a1, s4
    jal min_max
    add a2, a0, a1
    sw v0, MODE7_BOUNDS + 0
    sw v1, MODE7_BOUNDS + 4

    // Calculate the min and max Y-offsets within a mode 7 tile
    sll a0, s5, 3
    sub a0, a0, s5
    sll a1, s6, 3
    sub a1, a1, s6
    jal min_max
    add a2, a0, a1
    sw v0, MODE7_BOUNDS + 8
    sw v1, MODE7_BOUNDS + 12

    // Update the RDP texture parameters with rotscale values
    sra t0, s2, 4
    sh t0, RDP_TILE + 64 // S-gradient along X (int)
    sra t1, s5, 4
    sh t1, RDP_TILE + 66 // T-gradient along X (int)
    sll t0, s2, 12
    sh t0, RDP_TILE + 80 // S-gradient along X (frac)
    sll t1, s5, 12
    sh t1, RDP_TILE + 82 // T-gradient along X (frac)
    sra t0, s4, 4
    sh t0, RDP_TILE + 88 // S-gradient along Y (int)
    sra t1, s6, 4
    sh t1, RDP_TILE + 90 // T-gradient along Y (int)
    sll t0, s4, 12
    sh t0, RDP_TILE + 96 // S-gradient along Y (frac)
    sll t1, s6, 12
    sh t1, RDP_TILE + 98 // T-gradient along Y (frac)

draw_row7:
    // Set the initial tile X-coordinate
    li s0, 0

    // Update the RDP draw command with the tile's Y-coordinate
    lw t0, FB_BORDER(sp)
    add t0, t0, s1
    sll t0, t0, 2
    addi t1, t0, 8 << 2
    sh t1, RDP_TILE + 26 // y3
    sll t1, t0, 16
    or t0, t0, t1
    sw t0, RDP_TILE + 28 // y2, y1

next_tile7:
    // Update the RDP draw command with the tile's X-coordinate
    addi t0, s0, 20
    sh t0, RDP_TILE + 32 // x1
    addi t1, s0, 12
    sh t1, RDP_TILE + 40 // x3
    sh t1, RDP_TILE + 48 // x2

    // Calculate the S-offset of the top-left tile within the texture
    lw t0, MODE7_BOUNDS + 0
    sra t1, t8, 11
    add t2, t0, t8
    sra t0, t2, 11
    sub s8, t1, t0

    // Calculate how many tiles wide the texture should be
    lw t0, MODE7_BOUNDS + 4
    add t3, t0, t8
    sra t0, t3, 11
    sub v0, t0, t1
    add v0, v0, s8
    blt v0, 4, calc_tofs
    addi v0, v0, 1
    li v0, 4 // Max

calc_tofs:
    // Calculate the T-offset of the top-left tile within the texture
    lw t0, MODE7_BOUNDS + 8
    sra t1, t9, 11
    add t4, t0, t9
    sra t0, t4, 11
    sub gp, t1, t0 // Offset T

    // Calculate how many tiles high the texture should be
    lw t0, MODE7_BOUNDS + 12
    add t5, t0, t9
    sra t0, t5, 11
    sub v1, t0, t1
    add v1, v1, gp
    blt v1, 4, check_wrap
    addi v1, v1, 1
    li v1, 4 // Max

check_wrap:
    // Check if tiles should wrap out of bounds
    lbu t0, M7_NOWRAP
    beqz t0, set_texels
    lui t1, 0x3
    ori t1, t1, 0xFFFF

    // Skip the tile if it's out of X-bounds without wrap
    sltu t2, t1, t2
    sltu t3, t1, t3
    and t0, t2, t3
    bnez t0, finish_tile7

    // Skip the tile if it's out of Y-bounds without wrap
    sltu t4, t1, t4
    sltu t5, t1, t5
    and t0, t4, t5
    bnez t0, finish_tile7

set_texels:
    // Update the amount of texels the RDP should load to TMEM
    sll t1, v1, 7
    addi t1, t1, -1
    sll t1, t1, 12
    li t0, 0x02000200
    or t0, t0, t1
    sw t0, RDP_TILE + 20

    // Update the RDP texture parameters with current coordinates
    srl t4, t8, 4
    andi t4, t4, 0x7F
    sll t0, s8, 7
    add t4, t4, t0
    sh t4, RDP_TILE + 56 // S-coordinate (int)
    srl t4, t9, 4
    andi t4, t4, 0x7F
    sll t0, gp, 7
    add t4, t4, t0
    sh t4, RDP_TILE + 58 // T-coordinate (int)
    sll t4, t8, 12
    sh t4, RDP_TILE + 72 // S-coordinate (frac)
    sll t4, t9, 12
    sh t4, RDP_TILE + 74 // T-coordinate (frac)

    // Set some values for loading BG entries
    li a0, SCRN_DATA
    lw t1, VRAM_PTR(sp)
    li a2, 0x7
    move t5, v1

    // Calculate the Y-offset for the texture's first tile row
    sra t2, t9, 3
    sll t0, gp, 8
    sub t2, t2, t0
    andi t2, t2, 0x7F00

    // Calculate the X-offsets for the texture's first tile row
    sra t3, t8, 10
    sll t0, s8, 1
    sub t3, t3, t0
    andi t3, t3, 0xFE
    addi t6, t3, 0x8
    andi t6, t6, 0xFE

entry_row:
    // Load a row of BG entries for a tile row in the texture
    add a3, t1, t2
    jal dma_read
    add a1, a3, t3
    addi a0, a0, 0x8
    jal dma_read
    add a1, a3, t6

    // Move to the next row and loop until complete
    addi t2, t2, 0x100
    andi t2, t2, 0x7F00
    addi t5, t5, -1
    bnez t5, entry_row
    addi a0, a0, 0x8

    // Set some values for building the texture
    andi a3, t3, 0x7 // DMA offset
    move t5, v0 // Row width
    sll t3, v1, 8 // Texture size

next_subrow:
    // Move to the next row within the texture
    addi v1, v1, -1

next_subtile:
    // Move to the next tile within the texture
    addi v0, v0, -1

    // Get the BG entry for the current tile
    sll t0, v0, 1
    sll t1, v1, 4
    add t0, t0, t1
    add t0, t0, a3
    lbu t6, SCRN_DATA + 1(t0)

    // Load the tile's character data from VRAM
    li a0, CHAR_DATA
    lw a1, VRAM_PTR(sp)
    sll t0, t6, 7
    add a1, a1, t0
    jal dma_read
    li a2, 0x7F

    // Copy the character data into vector registers
    lqv $v00, 0, 0x00, a0
    lqv $v01, 0, 0x10, a0
    lqv $v02, 0, 0x20, a0
    lqv $v03, 0, 0x30, a0
    lqv $v04, 0, 0x40, a0
    lqv $v05, 0, 0x50, a0
    lqv $v06, 0, 0x60, a0
    lqv $v07, 0, 0x70, a0

    // Get the tile's texture offset
    sll t0, v0, 3
    sll t1, v1, 8
    add t0, t0, t1

    // Copy bytes containing pixels into the texture
    spv $v00, 0, 0x00, t0
    spv $v01, 0, 0x20, t0
    spv $v02, 0, 0x40, t0
    spv $v03, 0, 0x60, t0
    spv $v04, 0, 0x80, t0
    spv $v05, 0, 0xA0, t0
    spv $v06, 0, 0xC0, t0

    // Loop through tiles until the texture is complete
    bnez v0, next_subtile
    spv $v07, 0, 0xE0, t0
    move v0, t5
    bnez v1, next_subrow

    // DMA the texture to alternating RDRAM locations
    li a0, TEXTURE
    li a1, MODE7_TEXTURE
    andi t0, s0, 0x8
    sll t0, t0, 8
    add a1, a1, t0
    sw a1, RDP_TILE + 4
    jal dma_write
    addi a2, t3, -1

    // Run the RDP to draw a tile
    li a0, RDP_TILE
    jal rdp_send
    li a1, TILE_JUMPS

finish_tile7:
    // Move to the next tile, adjusting the VRAM coordinates
    addi s0, s0, 8
    sll t0, s2, 3
    add t8, t8, t0
    sll t0, s5, 3
    blt s0, 256, next_tile7
    add t9, t9, t0

    // Move to the next row, adjusting the VRAM coordinates
    addi s1, s1, 8
    sll t0, s2, 8
    sub t8, t8, t0
    sll t0, s5, 8
    sub t9, t9, t0
    sll t0, s4, 3
    add t8, t8, t0
    sll t0, s6, 3
    blt s1, k1, draw_row7
    add t9, t9, t0

    // Restore RDP parameters that were changed for mode 7
    li t0, 0x02
    sb t0, RDP_MODE7 + 10 // Texture width / 4
    li t0, 0x0101F01F
    sw t0, RDP_MODE7 + 20 // Tile size
    li t0, 0x0201F800
    sw t0, RDP_TILE + 20 // Texels to load
    sw zero, RDP_TILE + 72 // Coordinates (frac)
    sw zero, RDP_TILE + 80 // Gradients along X (frac)
    sw zero, RDP_TILE + 96 // Gradients along Y (frac)

    // Run the RDP for the end of mode 7
    li a0, RDP_MODE7
    jal rdp_send
    li a1, RDP_FRAME
    b next_layer


draw_obj:
    // Skip the layer if objects are disabled
    lbu t1, SUB_MASK(s7)
    andi t1, t1, 0x10
    beqz t1, next_layer
    andi a3, t0, 0x3 // Priority

    // Get the index of the first object in rotation
    lhu t9, OAMADD
    andi v1, t9, 0x8000
    beqz v1, no_rotate
    nop
    sll v1, t9, 1
no_rotate:
    addi v1, v1, -4
    andi v1, v1, 0x1FC

    // Ensure the index is within visible object range
    lhu t0, MAX_OBJECT
    blt v1, t0, below_max
    nop
    move v1, t0
below_max:
    move t9, v1

    // Check if the object character base changed
    lhu t0, OBJCHARBASE
    lhu t2, CACHE_BASES + 8
    beq t0, t2, load_objcache
    sh t0, CACHE_BASES + 8

    // Reset the tile cache if something changed
    li t0, TILE_TABLE
    li t2, VRAM_TABLE
clear_objcache:
    sqv $v31, 0, 0x00, t0
    addi t0, t0, 0x20
    bne t0, t2, clear_objcache
    sqv $v31, 0, -0x10, t0
    b check_object

load_objcache:
    // Load the previous cache status if it's still valid
    li a0, TILE_TABLE
    li a1, TILE_STATS_OBJ
    jal dma_read
    li a2, 0x1FF

check_object:
    // Read the 4 object bytes and additional 2 bits
    lw t1, OAM(t9)
    srl t2, t9, 4
    lbu t2, OAM + 0x200(t2)
    srl t3, t9, 1
    andi t3, t3, 0x6
    srl t2, t2, t3

    // Skip the object if its priority doesn't match the layer
    srl t0, t1, 12
    andi t0, t0, 0x3
    xor t0, t0, a3
    bnez t0, next_object

    // Get the object's size based on the large bit
    andi t3, t2, 0x2 // Large
    lhu s0, OBJ_SIZE(t3)
    andi s1, s0, 0xFF // Y-size
    srl s0, s0, 8 // X-size

    // Get the object's Y-coordinate, wrapped past screen bounds
    srl t3, t1, 24
    lhu t4, WRAP_BOUND
    slt t4, t4, t3
    sll t4, t4, 31
    sra t4, t4, 23
    or s8, t3, t4

    // Skip the object if it doesn't occupy any visible scanlines
    add t4, s8, s1
    slt t5, t4, k0
    sgt t6, s8, k1
    or t5, t5, t6
    bnez t5, next_object

    // Get the object's X-coordinate, wrapped past pixel 256
    srl t5, t1, 16
    andi t5, t5, 0xFF
    sll t6, t2, 31 // Upper X
    sra t6, t6, 23
    or s2, t5, t6

    // Skip the object if it doesn't occupy any visible pixels
    add t6, s2, s0
    and t7, t6, s2
    sra t7, t7, 8
    bnez t7, next_object

    // Update the RDP texture parameters based on mirroring
    srl t5, t1, 10
    andi t5, t5, 0x30
    lw t3, TILE_PARAMS + 0(t5)
    lw t4, TILE_PARAMS + 4(t5)
    lw t5, TILE_PARAMS + 8(t5)
    sw t3, RDP_TILE + 56 // Coordinates
    sw t4, RDP_TILE + 64 // Gradients along X
    sw t5, RDP_TILE + 88 // Gradients along Y

    // Set initial values for drawing the object
    sll t3, t1, 3
    andi t3, t3, 0x7000
    addi t3, t3, 0x8000
    mtc2 t3, $v05, 0 // Palette offset
    move s4, s0 // X-size reload
    andi s5, t1, 0x1FF // Character number

    // Set initial values based on horizontal mirroring
    andi t7, t1, 0x4000 // X-mirror
    li s6, 8
    beqz t7, object_ymir
    move v0, s0
    add s2, s2, s0
    addi s2, s2, -8
    addi s6, zero, -8
    sub v0, zero, s0

object_ymir:
    // Set initial values based on vertical mirroring
    andi t7, t1, 0x8000 // Y-mirror
    beqz t7, next_objy
    li gp, 8
    add s8, s8, s1
    addi s8, s8, -8
    addi gp, zero, -8

next_objy:
    // Update the RDP draw command with the object's Y-coordinate
    lw t7, FB_BORDER(sp)
    add t7, t7, s8
    sll t7, t7, 2
    addi t6, t7, 8 << 2
    sh t6, RDP_TILE + 26 // y3
    sh t7, RDP_TILE + 28 // y2
    sh t7, RDP_TILE + 30 // y1

next_objx:
    // Update the RDP draw command with the object's X-coordinate
    addi t7, s2, 12 // Vertical border
    sh t7, RDP_TILE + 40 // x3
    sh t7, RDP_TILE + 48 // x2
    addi t7, t7, 8
    sh t7, RDP_TILE + 32 // x1

    // Check if the tile's VRAM is dirty for objects
    lhu t0, OBJCHARBASE
    sll t4, s5, 5
    add t5, t0, t4
    srl t0, t5, 6
    lbu t2, VRAM_TABLE(t0)
    andi t4, t2, 0x10
    beqz t4, check_objcache

    // Clear the VRAM dirty bit and reset affected cache entries
    andi t2, t2, 0xF
    sb t2, VRAM_TABLE(t0)
    andi t1, s5, 0x1
    sub t1, s5, t1
    sh zero, TILE_TABLE(t1)

check_objcache:
    // Skip decoding if the tile is already cached with the same palette
    lbu t2, TILE_TABLE(s5)
    srl t4, t3, 7
    andi t4, t4, 0xE0 // Palette offset
    ori t0, t4, 0x1 // Cache bit
    beq t0, t2, skip_objdecode
    sb t0, TILE_TABLE(s5)

    // Load the tile's character data from VRAM
    li a0, CHAR_DATA
    lw a1, VRAM_PTR(sp)
    add a1, a1, t5
    jal dma_read
    li a2, 0x1F

    // Set initial values for drawing the tile
    li t7, 0 // Texture offset
    li t8, CHAR_DATA // Character offset

decode_object:
    // Prepare 16-color tile data for decoding
    lpv $v03, 0, 0x00, t8 // Upper/lower byte 1 to lane 0/1, bits 8-15
    lpv $v13, 0, 0x10, t8 // Upper/lower byte 2 to lane 0/1, bits 8-15

    // Decode the palette indices
    vand $v01, $v24, $v03, 9 // Mask out other lower bits
    vand $v02, $v24, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand $v11, $v24, $v13, 9 // Mask out other lower bits
    vand $v12, $v24, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor $v01, $v12, $v02, 0 // Combine partial indices
    vmudn $v01, $v01, $v25, 0 // Shift to upper byte

    // Add palette offset to non-zero indices and move to the next line
    veq $v00, $v01, $v31, 0
    addi t7, t7, 0x8
    vmrg $v00, $v01, $v05, 8
    addi t8, t8, 0x2
    vadd $v02, $v01, $v00, 0

    // Write the line to the texture buffer and loop until complete
    andi t5, t8, 0xF
    bnez t5, decode_object
    spv $v02, 0, -0x8, t7

    // DMA the texture to the tile cache in RDRAM
    li a0, TEXTURE
    li a1, TILE_CACHE_OBJ
    sll t0, s5, 6
    add a1, a1, t0
    sw a1, RDP_TILE + 4
    jal dma_write
    li a2, 0x3F

draw_objtile:
    // Run the RDP to draw an object tile
    li a0, RDP_TILE
    jal rdp_send
    li a1, TILE_JUMPS

    // Loop through object tiles in the X-direction
    addi s0, s0, -8
    add s2, s2, s6
    addi s5, s5, 1
    bnez s0, next_objx
    andi s5, s5, 0x1FF

    // Loop through object tiles in the Y-direction
    move s0, s4
    sub s2, s2, v0
    srl t7, s0, 3
    sub s5, s5, t7
    addi s5, s5, 16
    andi s5, s5, 0x1FF
    addi s1, s1, -8
    bnez s1, next_objy
    add s8, s8, gp

next_object:
    // Move to the next object until all have been drawn
    bnez t9, skip_wrap
    addi t9, t9, -4
    lhu t9, MAX_OBJECT
skip_wrap:
    bne t9, v1, check_object

    // Update the object tile cache status when finished
    li a0, TILE_TABLE
    li a1, TILE_STATS_OBJ
    jal dma_write
    li a2, 0x1FF
    b next_layer
    nop

skip_objdecode:
    // Update the RDP texture address and draw a cached tile
    li a1, TILE_CACHE_OBJ
    sll t0, s5, 6
    add a1, a1, t0
    b draw_objtile
    sw a1, RDP_TILE + 4


next_frame:
    // Halt until the next frame can be drawn
    li t0, 0x2 // Set halt
    mtc0 t0, COP0_SP_STATUS
    b draw_frame
    xori sp, sp, 4


multiply: // a0: multiplicand, a1: multiplier - v0: product
    // Multiply 2 16-bit values to get a 32-bit value
    mtc2 a0, $v00, 0
    mtc2 a1, $v01, 0
    vmudh $v00, $v00, $v01, 0
    vsar $v00, COP2_ACC_MD
    vsar $v01, COP2_ACC_HI
    mfc2 v0, $v00, 0
    mfc2 v1, $v01, 0
    andi v0, v0, 0xFFFF
    sll v1, v1, 16
    jr ra
    or v0, v0, v1


min_max: // a0-a2: values - v0: min, v1: max
    // Find the minimum out of 4 values, including zero
    bgtz a0, min1
    move v0, zero
    move v0, a0
min1:
    bgt a1, v0, min2
    nop
    move v0, a1
min2:
    bgt a2, v0, min3
    nop
    move v0, a2
min3:

    // Find the maximum out of 4 values, including zero
    blez a0, max1
    move v1, zero
    move v1, a0
max1:
    ble a1, v1, max2
    nop
    move v1, a1
max2:
    ble a2, v1, max3
    nop
    move v1, a2
max3:
    jr ra
    nop


dma_write: // a0: RSP address, a1: DRAM address, a2: size
    // Transfer data from the RSP via DMA
    mtc0 a0, COP0_DMA_SPADDR
    mtc0 a1, COP0_DMA_RAMADDR
    b dma_wait
    mtc0 a2, COP0_DMA_WRITE

dma_read: // a0: RSP address, a1: DRAM address, a2: size
    // Transfer data to the RSP via DMA
    mtc0 a0, COP0_DMA_SPADDR
    mtc0 a1, COP0_DMA_RAMADDR
    mtc0 a2, COP0_DMA_READ

dma_wait:
    // Wait for the DMA to complete
    mfc0 t0, COP0_DMA_BUSY
    bnez t0, dma_wait
    nop
    jr ra


rdp_send: // a0: start address, a1: end address
    // Wait for the RDP to be ready and then send commands
    mfc0 t0, COP0_DP_STATUS
    andi t0, t0, 0x40 // Command busy
    bnez t0, rdp_send
    nop
    mtc0 a0, COP0_DP_START
    mtc0 a1, COP0_DP_END
    jr ra
    nop
