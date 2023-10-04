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

// Define data addresses as numerical constants
// This allows loads/stores without a hidden opcode to set the upper address
#define TEXTURE      0x000
#define TILE_TABLE   0x040
#define VRAM_TABLE   0x440
#define OAM          0x840
#define SCRN_DATA    0xA60
#define CHAR_DATA    0xAE0
#define VEC_DATA     0xB60
#define RDP_INIT     0xBE0
#define RDP_FRAME    0xC00
#define RDP_SECTION  0xC18
#define RDP_MODE7    0xC40
#define RDP_TILE     0xC50
#define LAYER_CHART  0xCC8
#define TILE_PARAMS  0xD58
#define TILE_JUMPS   0xD98
#define MODE7_BOUNDS 0xDA4
#define CACHE_BASES  0xDB4
#define MASK_OFS     0xDBE
#define OBJ_SIZE     0xDC0
#define OBJCHARBASE  0xDC4
#define OAMADD       0xDC6
#define BGSCRNBASE   0xDC8
#define BGBASEOFSH   0xDD0
#define BGBASEOFSV   0xDD8
#define BGCHARBASE   0xDE0
#define BGHOFS       0xDE8
#define BGVOFS       0xDF0
#define M7HOFS       0xDF8
#define M7VOFS       0xDFA
#define M7A          0xDFC
#define M7B          0xDFE
#define M7C          0xE00
#define M7D          0xE02
#define M7X          0xE04
#define M7Y          0xE06
#define FILL_COLOR   0xE08
#define FORCE_BLANK  0xE0A
#define BG_MODE      0xE0B
#define SUB_MASK     0xE0C
#define MAIN_MASK    0xE0D
#define M7_NOWRAP    0xE0E
#define SPLIT_LINE   0xE0F
#define FB_BORDER    0xFF0
#define FRAME_END    0xFF4
#define SECTION_PTR  0xFF8
#define FRAMEBUFFER  0xFFC

.set reorder

.data

texture:    .byte 0:0x40
tile_table: .byte 0:0x400
vram_table: .byte 0:0x400
oam:        .byte 0:0x220
scrn_data:  .byte 0:0x80
char_data:  .byte 0:0x80

vec_data:
    .hword 0x8000, 0x4000, 0x2000, 0x1000, 0x0800, 0x0400, 0x0200, 0x0100 // Mask
    .hword 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100 // Shift byte
    .hword 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100 // Shift 1
    .hword 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200 // Shift 2
    .hword 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400 // Shift 3
    .hword 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 0x0200, 0x0400, 0x0800 // Shift 4
    .hword 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010, 0x0010 // Shift 5
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 // Zero

rdp_init:
    // RDP commands that only need to run once
    .dword 0x3C080E10001C8241 // Set Combine
    .dword 0x39000000FFFFFFFF // Set Blend Color
    .dword 0x3510810000000000 // Set Tile (palette)
    .dword 0x3550000002054150 // Set Tile (block)

rdp_frame:
    // RDP commands that run at the start of a frame
    .dword 0x3F100117A03CF300 // Set Color Image
    .dword 0x3D100000A038C000 // Set Texture Image (palette)
    .dword 0x3300000000400000 // Load Block (palette)

rdp_section:
    // RDP commands that run when changing the frame section
    .dword 0x2D030020004303A0 // Set Scissor
    .dword 0x3700000000000000 // Set Fill Color
    .dword 0x2F3888FF00040001 // Set Other Modes (fill)
    .dword 0x3642F3A000030020 // Fill Rectangle
    .dword 0x2F0888FF00040001 // Set Other Modes (1 cycle)

rdp_mode7:
    // RDP commands that run when changing to/from mode 7
    .dword 0x3548020001054150 // Set Tile (texture)
    .dword 0x320000000101F01F // Set Tile Size

rdp_tile:
    // RDP commands that run when a tile is being drawn
    .dword 0x3D500003A0330000 // Set Texture Image (texture)
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

tile_params:
    // S/T coordinates, gradients along X, gradients along Y
    .word 0x00000000, 0x00100000, 0x00000010, 0 // No mirror
    .word 0x00700000, 0xFFF00000, 0x00000010, 0 // X-mirror
    .word 0x00000070, 0x00100000, 0x0000FFF0, 0 // Y-mirror
    .word 0x00700070, 0xFFF00000, 0x0000FFF0, 0 // XY-mirror

tile_jumps:   .word  decode_tile4, decode_tile16, decode_tile256
mode7_bounds: .word  0:4
cache_bases:  .hword 0:5
mask_ofs:     .byte  0

// Values that are reloaded for each section (0x50 bytes)
obj_size:    .word  0x10100808
objcharbase: .hword 0x0000
oamadd:      .hword 0x0000
bgscrnbase:  .hword 0x0000:4
bgbaseofsh:  .hword 0x0000:4
bgbaseofsv:  .hword 0x0000:4
bgcharbase:  .hword 0x0000:4
bghofs:      .hword 0x0000:4
bgvofs:      .hword 0x0000:4
m7hofs:      .hword 0x0000
m7vofs:      .hword 0x0000
m7a:         .hword 0x0000
m7b:         .hword 0x0000
m7c:         .hword 0x0000
m7d:         .hword 0x0000
m7x:         .hword 0x0000
m7y:         .hword 0x0000
fill_color:  .hword 0x0000
force_blank: .byte  0x00
bg_mode:     .byte  0x00
sub_mask:    .byte  0x00
main_mask:   .byte  0x00
m7_nowrap:   .byte  0x00
split_line:  .byte  0x00

.space 0x1E0

// Values with hardcoded addresses for easy CPU access
fb_border:   .word 0x08       // 0xFF0
frame_end:   .word 0xDF       // 0xFF4
section_ptr: .word 0xA037E000 // 0xFF8
framebuffer: .word 0xA03CF300 // 0xFFC

.text

main:
    // Load the constants for vector math
    la   t0, VEC_DATA
    lqv  $v24, 0, 0x00, t0
    lqv  $v25, 0, 0x10, t0
    lqv  $v26, 0, 0x20, t0
    lqv  $v27, 0, 0x30, t0
    lqv  $v28, 0, 0x40, t0
    lqv  $v29, 0, 0x50, t0
    lqv  $v30, 0, 0x60, t0
    lqv  $v31, 0, 0x70, t0

    // Run the RDP initialization commands
    li   t0, 0x2 // Use DMEM
    mtc0 t0, COP0_DP_STATUS
    la   a0, RDP_INIT
    la   a1, RDP_TILE
    jal  rdp_send

draw_frame:
    // Set the initial section bound
    li   k1, 0

next_section:
    // Finish the frame after the last section is done
    lw   t0, FRAME_END
    bgt  k1, t0, next_frame

    // Load values for the next section
    la   a0, OBJ_SIZE
    lw   a1, section_ptr
    li   a2, 0x4F
    jal  dma_read
    addi a1, a1, 0x50
    sw   a1, section_ptr

    // Set the section bounds
    move k0, k1
    lbu  k1, SPLIT_LINE
    addi k1, k1, 1

    // Update the RDP scissor and fill bounds for the section
    lw   t0, FB_BORDER
    add  t1, t0, k0
    sll  t1, t1, 2
    sh   t1, RDP_SECTION + 2
    sh   t1, RDP_SECTION + 30
    add  t2, t0, k1
    sll  t2, t2, 2
    sh   t2, RDP_SECTION + 6
    ori  t2, t2, 0xF000
    sh   t2, RDP_SECTION + 26

    // Update the RDP fill color for the section
    lbu  t1, FORCE_BLANK
    li   t0, 0
    bnez t1, blank_set
    lhu  t0, FILL_COLOR
blank_set:
    sh   t0, RDP_SECTION + 12
    sh   t0, RDP_SECTION + 14

    // Run the RDP to prepare the section
    la   a0, RDP_SECTION
    la   a1, RDP_MODE7
    jal  rdp_send

    // Don't draw any layers if force blank is set
    bnez t1, next_section

    // Set the initial layer lookup offset
    lbu  s3, BG_MODE
    sll  s3, s3, 4
    sb   zero, MASK_OFS

next_layer:
    // Look up the next layer and check if it's BG or OBJ
    // Layers are drawn in an order that mimics priority without slow depth testing
    // This isn't fully accurate; OBJ priority effects like SMB3 pipes won't work
    lbu  t0, LAYER_CHART(s3)
    addi s3, s3, 1
    lbu  t1, MASK_OFS
    bge  t0, 0x80, draw_obj
    beq  t0, 0x40, draw_mode7
    bnez t0, draw_bg

    // After the sub screen layers are done, draw the main screen layers on top
    // Blending isn't implemented, but this at least allows using screens to reorder layers
    bnez t1, next_section
    lbu  s3, BG_MODE
    sll  s3, s3, 4
    li   t1, 1
    sb   t1, MASK_OFS
    b    next_layer


draw_bg:
    // Skip the layer if the BG is disabled
    lbu  t1, SUB_MASK(t1)
    li   t2, 1
    andi t3, t0, 0x03 // Index
    sll  a3, t2, t3   // Mask
    and  t1, t1, a3
    beqz t1, next_layer

    // Set parameters based on the BG type
    srl  t1, t0, 2
    andi s4, t1, 0x03
    sll  t1, s4, 2
    lw   t9, TILE_JUMPS - 4(t1) // Code path
    addi s4, s4, 3              // Character shift
    andi gp, t0, 0x40           // Priority
    sll  gp, gp, 7

    // Check if the BG type or character base changed
    sll  s2, t3, 1
    lhu  t0, BGCHARBASE(s2)
    or   t0, t0, s4
    lhu  t1, CACHE_BASES(s2)
    beq  t0, t1, load_cache
    sh   t0, CACHE_BASES(s2)

    // Reset the tile cache if something changed
    la   t0, TILE_TABLE
    la   t1, VRAM_TABLE
clear_cache:
    sqv  $v31, 0, 0x00, t0
    sqv  $v31, 0, 0x10, t0
    addi t0, t0, 0x20
    bne  t0, t1, clear_cache
    b    get_offsets

load_cache:
    // Load the previous cache status if it's still valid
    la   a0, TILE_TABLE
    la   a1, 0xA0378000
    sll  t0, s2, 9
    add  a1, a1, t0
    li   a2, 0x3FF
    jal  dma_read

get_offsets:
    // Get the horizontal and vertical offsets within the BG
    lhu  s5, BGVOFS(s2)
    lhu  s6, BGHOFS(s2)
    addi s5, s5, 1

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
    la   a0, SCRN_DATA
    la   a1, 0xA03F0000 // VRAM
    lhu  t0, BGSCRNBASE(s2)
    add  a1, a1, t0

    // Apply the vertical base offset if past the bounds of the first screen
    add  t1, s5, s1
    andi t0, t1, 0x100
    beqz t0, load_screen
    lhu  t0, BGBASEOFSV(s2)
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
    lhu  t0, BGBASEOFSH(s2)
    add  a1, a1, t0
    jal  dma_read

    // Update the RDP draw command with the tile's Y-coordinate
    lw   t0, FB_BORDER
    add  t0, t0, s1
    sll  t0, t0, 2
    addi t1, t0, 8 << 2
    sh   t1, RDP_TILE + 26 // y3
    sh   t0, RDP_TILE + 28 // y2
    sh   t0, RDP_TILE + 30 // y1

next_tile:
    // Get the BG entry for the current tile
    add  t4, s6, s0
    andi t6, t4, 0x1FF
    srl  t6, t6, 2
    lhu  t6, SCRN_DATA(t6)

    // Skip the tile if its priority doesn't match the layer
    andi t0, t6, 0x2000
    xor  t0, t0, gp
    bnez t0, finish_tile

    // Update the RDP draw command with the tile's X-coordinate
    addi t0, s0, 20
    sh   t0, RDP_TILE + 32 // x1
    addi t1, s0, 12
    sh   t1, RDP_TILE + 40 // x3
    sh   t1, RDP_TILE + 48 // x2

    // Update the RDP texture parameters based on mirroring
    srl  t5, t6, 10
    andi t5, t5, 0x30
    lw   t3, TILE_PARAMS + 0(t5)
    lw   t4, TILE_PARAMS + 4(t5)
    lw   t5, TILE_PARAMS + 8(t5)
    sw   t3, RDP_TILE + 56 // Coordinates
    sw   t4, RDP_TILE + 64 // Gradients along X
    sw   t5, RDP_TILE + 88 // Gradients along Y

    // Skip uploading if the last tile's number and palette were the same
    andi t0, t6, 0x1FFF
    beq  t0, v1, skip_upload
    move v1, t0

    // Check if the tile's VRAM is dirty for the current BG
    andi s8, t6, 0x3FF // Character number
    lhu  t0, BGCHARBASE(s2)
    sll  t1, s8, s4
    add  t3, t0, t1
    srl  t0, t3, 6
    lbu  t2, VRAM_TABLE(t0)
    and  t4, t2, a3
    beqz t4, check_cache

    // Clear the VRAM dirty bit and reset affected cache entries
    xori t1, a3, 0x1F
    and  t2, t2, t1
    sb   t2, VRAM_TABLE(t0)
    andi t1, s8, 0x3
    sub  t1, s8, t1
    sw   zero, TILE_TABLE(t1)

check_cache:
    // Skip decoding if the tile is already cached with the same palette
    lbu  t1, TILE_TABLE(s8)
    srl  t2, t6, 5
    andi t2, t2, 0xE0  // Palette offset
    ori  t0, t2, 0x01  // Cache bit
    beq  t0, t1, skip_decode
    sb   t0, TILE_TABLE(s8)

    // Load the tile's character data from VRAM
    la   a0, CHAR_DATA
    la   a1, 0xA03F0000 // VRAM
    add  a1, a1, t3
    li   a2, 0x3F
    jal  dma_read

    // Set initial values and jump to the tile decoder
    li   t7, 0x40            // Texture offset
    la   t8, CHAR_DATA + 0xE // Character offset
    jr   t9

decode_tile4:
    // Set the 4-color palette offset
    sll  t0, t2, 5
    mtc2 t0, $v05, 0 // Palette offset

loop_tile4:
    // Prepare 4-color tile data for decoding
    lpv  $v03, 0, 0x00, t8 // Upper/lower byte 1 to lane 0/1, bits 8-15

    // Decode the palette indices
    vand  $v01, $v24, $v03, 9 // Mask out other lower bits
    vand  $v02, $v24, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form indices
    vmudn $v02, $v02, $v25, 0 // Shift to upper byte

    // Add the palette offset to non-zero indices
    // In parallel, move to the next line of the tile
    veq  $v00, $v02, $v31, 0
        addi t7, t7, -0x8
    vmrg $v00, $v02, $v05, 8
        addi t8, t8, -0x2
    vadd $v02, $v02, $v00, 0

    // Write the line to the texture buffer and loop until complete
    spv  $v02, 0, 0, t7
    bnez t7, loop_tile4
    b    cache_tile

decode_tile16:
    // Set the 16-color palette offset
    sll  t0, t2, 7
    mtc2 t0, $v05, 0 // Palette offset

loop_tile16:
    // Prepare 16-color tile data for decoding
    lpv  $v03, 0, 0x00, t8 // Upper/lower byte 1 to lane 0/1, bits 8-15
    lpv  $v13, 0, 0x10, t8 // Upper/lower byte 2 to lane 0/1, bits 8-15

    // Decode the palette indices
    vand  $v01, $v24, $v03, 9 // Mask out other lower bits
    vand  $v02, $v24, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v24, $v13, 9 // Mask out other lower bits
    vand  $v12, $v24, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices
    vmudn $v01, $v01, $v25, 0 // Shift to upper byte

    // Add the palette offset to non-zero indices
    // In parallel, move to the next line of the tile
    veq  $v00, $v01, $v31, 0
        addi t7, t7, -0x8
    vmrg $v00, $v01, $v05, 8
        addi t8, t8, -0x2
    vadd $v02, $v01, $v00, 0

    // Write the line to the texture buffer and loop until complete
    spv  $v02, 0, 0, t7
    bnez t7, loop_tile16
    b    cache_tile

decode_tile256:
    // Prepare 256-color tile data for decoding
    lpv  $v03, 0, 0x00, t8 // Upper/lower byte 1 to lane 0/1, bits 8-15
    lpv  $v13, 0, 0x10, t8 // Upper/lower byte 2 to lane 0/1, bits 8-15
    lpv  $v08, 0, 0x20, t8 // Upper/lower byte 3 to lane 0/1, bits 8-15
    lpv  $v18, 0, 0x30, t8 // Upper/lower byte 4 to lane 0/1, bits 8-15

    // Decode the palette indices
    vand  $v01, $v24, $v03, 9 // Mask out other lower bits
    vand  $v02, $v24, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v24, $v13, 9 // Mask out other lower bits
    vand  $v12, $v24, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v06, $v12, $v02, 0 // Combine partial indices
    vand  $v01, $v24, $v08, 9 // Mask out other lower bits
    vand  $v02, $v24, $v08, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v24, $v18, 9 // Mask out other lower bits
    vand  $v12, $v24, $v18, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v07, $v12, $v02, 0 // Combine partial indices
    vmudn $v07, $v07, $v30, 0 // Shift upper indices left
    vor   $v00, $v06, $v07, 0 // Combine indices
    vmudn $v00, $v00, $v25, 0 // Shift to upper byte

    // Write the line to the texture buffer and loop until complete
    addi t7, t7, -0x8
    spv  $v00, 0, 0, t7
    addi t8, t8, -0x2
    bnez t7, decode_tile256

cache_tile:
    // DMA the texture to the tile cache in RDRAM
    la   a0, TEXTURE
    la   a1, 0xA0330000
    sll  t0, s2, 15
    add  a1, a1, t0
    sll  t0, s8, 6
    add  a1, a1, t0
    sw   a1, RDP_TILE + 4
    li   a2, 0x3F
    jal  dma_write

draw_tile:
    // Run the RDP to draw a tile
    la   a0, RDP_TILE
    la   a1, LAYER_CHART
    jal  rdp_send

finish_tile:
    // Move to the next tile of the row until finished
    addi s0, s0, 8
    blt  s0, 256, next_tile

    // Move to the next row of the BG until finished
    addi s1, s1, 8
    blt  s1, k1, draw_row

    // Update the BG's tile cache status when finished
    la   a0, TILE_TABLE
    la   a1, 0xA0378000
    sll  t0, s2, 9
    add  a1, a1, t0
    li   a2, 0x3FF
    jal  dma_write
    b    next_layer

skip_decode:
    // Update the RDP texture address and draw a cached tile
    la   a1, 0xA0330000
    sll  t0, s2, 15
    add  a1, a1, t0
    sll  t0, s8, 6
    add  a1, a1, t0
    sw   a1, RDP_TILE + 4
    b    draw_tile

skip_upload:
    // Run the RDP to draw a tile, skipping texture upload
    la   a0, RDP_TILE + 24
    la   a1, LAYER_CHART
    jal  rdp_send
    b    finish_tile


draw_mode7:
    // Skip the layer if the BG is disabled
    lbu  t1, SUB_MASK(t1)
    andi t1, t1, 0x1
    beqz t1, next_layer

    // Update RDP parameters for a texture width of 32 (4 tiles)
    li   t0, 0x08   // Width / 4
    sb   t0, RDP_MODE7 + 2
    li   t0, 0x0107F07F // Tile size
    sw   t0, RDP_MODE7 + 12

    // Set the initial tile Y-coordinate
    andi t0, k0, 0x7
    sub  s1, k0, t0

    // Calculate the initial screen X-coordinate
    lh   t0, M7HOFS
    lh   t2, M7X
    sub  t0, t0, t2

    // Calculate the initial screen Y-coordinate
    lh   t1, M7VOFS
    lh   t3, M7Y
    add  t1, t1, s1
    sub  t1, t1, t3
    addi t1, t1, 1

    // Calculate the initial VRAM X-coordinate
    lh    s2, M7A
    sll   t2, t2, 8
    move  a0, t0
    move  a1, s2
    jal   multiply
    add   t2, t2, v0
    lh    s4, M7B
    move  a0, t1
    move  a1, s4
    jal   multiply
    add   t8, t2, v0

    // Calculate the initial VRAM Y-coordinate
    lh    s5, M7C
    sll   t3, t3, 8
    move  a0, t0
    move  a1, s5
    jal   multiply
    add   t3, t3, v0
    lh    s6, M7D
    move  a0, t1
    move  a1, s6
    jal   multiply
    add   t9, t3, v0

    // Calculate the min and max X-offsets within a mode 7 tile
    sll  a0, s2, 3
    sub  a0, a0, s2
    sll  a1, s4, 3
    sub  a1, a1, s4
    add  a2, a0, a1
    jal  min_max
    sw   v0, MODE7_BOUNDS + 0
    sw   v1, MODE7_BOUNDS + 4

    // Calculate the min and max Y-offsets within a mode 7 tile
    sll  a0, s5, 3
    sub  a0, a0, s5
    sll  a1, s6, 3
    sub  a1, a1, s6
    add  a2, a0, a1
    jal  min_max
    sw   v0, MODE7_BOUNDS + 8
    sw   v1, MODE7_BOUNDS + 12

    // Update the RDP texture parameters with rotscale values
    sra  t0, s2, 4
    sh   t0, RDP_TILE + 64 // S-gradient along X (int)
    sra  t1, s5, 4
    sh   t1, RDP_TILE + 66 // T-gradient along X (int)
    sll  t0, s2, 12
    sh   t0, RDP_TILE + 80 // S-gradient along X (frac)
    sll  t1, s5, 12
    sh   t1, RDP_TILE + 82 // T-gradient along X (frac)
    sra  t0, s4, 4
    sh   t0, RDP_TILE + 88 // S-gradient along Y (int)
    sra  t1, s6, 4
    sh   t1, RDP_TILE + 90 // T-gradient along Y (int)
    sll  t0, s4, 12
    sh   t0, RDP_TILE + 96 // S-gradient along Y (frac)
    sll  t1, s6, 12
    sh   t1, RDP_TILE + 98 // T-gradient along Y (frac)

draw_row7:
    // Set the initial tile X-coordinate
    li   s0, 0

    // Update the RDP draw command with the tile's Y-coordinate
    lw   t0, FB_BORDER
    add  t0, t0, s1
    sll  t0, t0, 2
    addi t1, t0, 8 << 2
    sh   t1, RDP_TILE + 26 // y3
    sll  t1, t0, 16
    or   t0, t0, t1
    sw   t0, RDP_TILE + 28 // y2, y1

next_tile7:
    // Update the RDP draw command with the tile's X-coordinate
    addi t0, s0, 20
    sh   t0, RDP_TILE + 32 // x1
    addi t1, s0, 12
    sh   t1, RDP_TILE + 40 // x3
    sh   t1, RDP_TILE + 48 // x2

    // Calculate the S-offset of the top-left tile within the texture
    lw   t0, MODE7_BOUNDS + 0
    sra  t1, t8, 11
    add  t2, t0, t8
    sra  t0, t2, 11
    sub  s8, t1, t0

    // Calculate how many tiles wide the texture should be
    lw   t0, MODE7_BOUNDS + 4
    add  t3, t0, t8
    sra  t0, t3, 11
    sub  v0, t0, t1
    add  v0, v0, s8
    addi v0, v0, 1
    ble  v0, 4, calc_tofs
    li   v0, 4 // Max

calc_tofs:
    // Calculate the T-offset of the top-left tile within the texture
    lw   t0, MODE7_BOUNDS + 8
    sra  t1, t9, 11
    add  t4, t0, t9
    sra  t0, t4, 11
    sub  gp, t1, t0 // Offset T

    // Calculate how many tiles high the texture should be
    lw   t0, MODE7_BOUNDS + 12
    add  t5, t0, t9
    sra  t0, t5, 11
    sub  v1, t0, t1
    add  v1, v1, gp
    addi v1, v1, 1
    ble  v1, 4, check_wrap
    li   v1, 4 // Max

check_wrap:
    // Check if tiles should wrap out of bounds
    lbu  t0, M7_NOWRAP
    beqz t0, set_texels
    li   t1, 0x3FFFF

    // Skip the tile if it's out of X-bounds without wrap
    sltu t2, t1, t2
    sltu t3, t1, t3
    and  t0, t2, t3
    bnez t0, finish_tile7

    // Skip the tile if it's out of Y-bounds without wrap
    sltu t4, t1, t4
    sltu t5, t1, t5
    and  t0, t4, t5
    bnez t0, finish_tile7

set_texels:
    // Update the amount of texels the RDP should load to TMEM
    li   t0, 0x02000200
    sll  t1, v1, 7
    addi t1, t1, -1
    sll  t1, t1, 12
    or   t0, t0, t1
    sw   t0, RDP_TILE + 20

    // Update the RDP texture parameters with current coordinates
    srl  t4, t8, 4
    andi t4, t4, 0x7F
    sll  t0, s8, 7
    add  t4, t4, t0
    sh   t4, RDP_TILE + 56 // S-coordinate (int)
    srl  t4, t9, 4
    andi t4, t4, 0x7F
    sll  t0, gp, 7
    add  t4, t4, t0
    sh   t4, RDP_TILE + 58 // T-coordinate (int)
    sll  t4, t8, 12
    sh   t4, RDP_TILE + 72 // S-coordinate (frac)
    sll  t4, t9, 12
    sh   t4, RDP_TILE + 74 // T-coordinate (frac)

    // Set some values for loading BG entries
    la   a0, SCRN_DATA
    la   t1, 0xA03F0000 // VRAM
    li   a2, 0x7
    move t5, v1

    // Calculate the Y-offset for the texture's first tile row
    sra  t2, t9, 3
    sll  t0, gp, 8
    sub  t2, t2, t0
    andi t2, t2, 0x7F00

    // Calculate the X-offsets for the texture's first tile row
    sra  t3, t8, 10
    sll  t0, s8, 1
    sub  t3, t3, t0
    andi t3, t3, 0xFE
    addi t6, t3, 0x8
    andi t6, t6, 0xFE

entry_row:
    // Load a row of BG entries for a tile row in the texture
    add  a3, t1, t2
    add  a1, a3, t3
    jal  dma_read
    addi a0, a0, 0x8
    add  a1, a3, t6
    jal  dma_read

    // Move to the next row and loop until complete
    addi a0, a0, 0x8
    addi t2, t2, 0x100
    andi t2, t2, 0x7F00
    addi t5, t5, -1
    bnez t5, entry_row

    // Set some values for building the texture
    andi a3, t3, 0x7 // DMA offset
    move t5, v0      // Row width
    sll  t3, v1, 8   // Texture size

next_subrow:
    // Move to the next row within the texture
    addi v1, v1, -1

next_subtile:
    // Move to the next tile within the texture
    addi v0, v0, -1

    // Get the BG entry for the current tile
    sll  t0, v0, 1
    sll  t1, v1, 4
    add  t0, t0, t1
    add  t0, t0, a3
    lbu  t6, SCRN_DATA + 1(t0)

    // Load the tile's character data from VRAM
    la   a0, CHAR_DATA
    la   a1, 0xA03F0000 // VRAM
    sll  t0, t6, 7
    add  a1, a1, t0
    li   a2, 0x7F
    jal  dma_read

    // Set the initial decoding offsets
    addi t7, a0, 0x80
    sll  t0, v0, 3
    addi t1, v1, 1
    sll  t1, t1, 8
    add  t0, t0, t1

decode_tile7:
    // Copy a tile line to the texture buffer and loop until complete
    addi  t7, t7, -0x10
    lqv   $v00, 0, 0, t7
    addi  t0, t0, -0x20
    spv   $v00, 0, 0, t0
    bne   t7, a0, decode_tile7

    // Loop through tiles until the texture is complete
    bnez v0, next_subtile
    move v0, t5
    bnez v1, next_subrow

    // DMA the texture to alternating RDRAM locations
    la   a0, TEXTURE
    la   a1, 0xA0380000
    andi t0, s0, 0x8
    sll  t0, t0, 8
    add  a1, a1, t0
    sw   a1, RDP_TILE + 4
    addi a2, t3, -1
    jal  dma_write

    // Run the RDP to draw a tile
    la   a0, RDP_MODE7
    la   a1, LAYER_CHART
    jal  rdp_send

finish_tile7:
    // Move to the next tile, adjusting the VRAM coordinates
    addi s0, s0, 8
    sll  t0, s2, 3
    add  t8, t8, t0
    sll  t0, s5, 3
    add  t9, t9, t0
    blt  s0, 256, next_tile7

    // Move to the next row, adjusting the VRAM coordinates
    addi s1, s1, 8
    sll  t0, s2, 8
    sub  t8, t8, t0
    sll  t0, s5, 8
    sub  t9, t9, t0
    sll  t0, s4, 3
    add  t8, t8, t0
    sll  t0, s6, 3
    add  t9, t9, t0
    blt  s1, k1, draw_row7

    // Restore RDP parameters that were changed for mode 7
    li   t0, 0x02
    sb   t0, RDP_MODE7 + 2   // Texture width / 4
    li   t0, 0x0101F01F
    sw   t0, RDP_MODE7 + 12  // Tile size
    li   t0, 0x0201F800
    sw   t0, RDP_TILE + 20   // Texels to load
    sw   zero, RDP_TILE + 72 // Coordinates (frac)
    sw   zero, RDP_TILE + 80 // Gradients along X (frac)
    sw   zero, RDP_TILE + 96 // Gradients along Y (frac)

    // Run the RDP for the end of mode 7
    la   a0, RDP_MODE7
    la   a1, RDP_TILE
    jal  rdp_send
    b    next_layer


draw_obj:
    // Skip the layer if objects are disabled
    lbu  t1, SUB_MASK(t1)
    andi a3, t0, 0x03 // Priority
    andi t1, t1, 0x10
    beqz t1, next_layer

    // Set the OAM count to the first in rotation
    lhu  t9, OAMADD
    andi v1, t9, 0x8000
    beqz v1, no_rotate
    sll  v1, t9, 1
no_rotate:
    addi v1, v1, -4
    andi v1, v1, 0x1FC
    move t9, v1

    // Check if the object character base changed
    lhu  t0, OBJCHARBASE
    lhu  t2, CACHE_BASES + 8
    beq  t0, t2, load_objcache
    sh   t0, CACHE_BASES + 8

    // Reset the tile cache if something changed
    la   t0, TILE_TABLE
    la   t2, VRAM_TABLE
clear_objcache:
    sqv  $v31, 0, 0x00, t0
    sqv  $v31, 0, 0x10, t0
    addi t0, t0, 0x20
    bne  t0, t2, clear_objcache
    b    check_object

load_objcache:
    // Load the previous cache status if it's still valid
    la   a0, TILE_TABLE
    la   a1, 0xA0379000
    li   a2, 0x1FF
    jal  dma_read

check_object:
    // Read the 4 object bytes and additional 2 bits
    lw   t1, OAM(t9)
    srl  t2, t9, 4
    lbu  t2, OAM + 0x200(t2)
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
    lhu  s0, OBJ_SIZE(t0)
    andi s1, s0, 0xFF // Y-size
    srl  s0, s0, 8    // X-size

    // Get the object's Y-coordinate, wrapped past line 240
    srl  t3, t1, 24
    li   t4, 240
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
    srl  t5, t1, 10
    andi t5, t5, 0x30
    lw   t3, TILE_PARAMS + 0(t5)
    lw   t4, TILE_PARAMS + 4(t5)
    lw   t5, TILE_PARAMS + 8(t5)
    sw   t3, RDP_TILE + 56 // Coordinates
    sw   t4, RDP_TILE + 64 // Gradients along X
    sw   t5, RDP_TILE + 88 // Gradients along Y

    // Set initial values for drawing the object
    sll  t3, t1, 3
    andi t3, t3, 0x7000
    addi t3, t3, 0x8000
    mtc2 t3, $v05, 0   // Palette offset
    move s4, s0        // X-size reload
    andi s5, t1, 0x1FF // Character number

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
    lw   t7, FB_BORDER
    add  t7, t7, s8
    sll  t7, t7, 2
    addi t6, t7, 8 << 2
    sh   t6, RDP_TILE + 26 // y3
    sh   t7, RDP_TILE + 28 // y2
    sh   t7, RDP_TILE + 30 // y1

next_objx:
    // Update the RDP draw command with the object's X-coordinate
    addi t7, s2, 12 // Vertical border
    sh   t7, RDP_TILE + 40 // x3
    sh   t7, RDP_TILE + 48 // x2
    addi t7, t7, 8
    sh   t7, RDP_TILE + 32 // x1

    // Check if the tile's VRAM is dirty for objects
    lhu  t0, OBJCHARBASE
    sll  t4, s5, 5
    add  t5, t0, t4
    srl  t0, t5, 6
    lbu  t2, VRAM_TABLE(t0)
    andi t4, t2, 0x10
    beqz t4, check_objcache

    // Clear the VRAM dirty bit and reset affected cache entries
    andi t2, t2, 0xF
    sb   t2, VRAM_TABLE(t0)
    andi t1, s5, 0x1
    sub  t1, s5, t1
    sh   zero, TILE_TABLE(t1)

check_objcache:
    // Skip decoding if the tile is already cached with the same palette
    lbu  t2, TILE_TABLE(s5)
    srl  t4, t3, 7
    andi t4, t4, 0xE0 // Palette offset
    ori  t0, t4, 0x01 // Cache bit
    beq  t0, t2, skip_objdecode
    sb   t0, TILE_TABLE(s5)

    // Load the tile's character data from VRAM
    la   a0, CHAR_DATA
    la   a1, 0xA03F0000 // VRAM
    add  a1, a1, t5
    li   a2, 0x1F
    jal  dma_read

    // Set initial values for drawing the tile
    li   t7, 0         // Texture offset
    la   t8, CHAR_DATA // Character offset

decode_object:
    // Prepare 16-color tile data for decoding
    lpv  $v03, 0, 0x00, t8 // Upper/lower byte 1 to lane 0/1, bits 8-15
    lpv  $v13, 0, 0x10, t8 // Upper/lower byte 2 to lane 0/1, bits 8-15

    // Decode the palette indices
    vand  $v01, $v24, $v03, 9 // Mask out other lower bits
    vand  $v02, $v24, $v03, 8 // Mask out other upper bis
    vmudl $v03, $v26, $v01, 0 // Shift lower bits to bit 0
    vmudl $v04, $v27, $v02, 0 // Shift upper bits to bit 1
    vor   $v02, $v03, $v04, 0 // Combine bits to form partial indices
    vand  $v11, $v24, $v13, 9 // Mask out other lower bits
    vand  $v12, $v24, $v13, 8 // Mask out other upper bits
    vmudl $v13, $v28, $v11, 0 // Shift lower bits to bit 2
    vmudl $v14, $v29, $v12, 0 // Shift upper bits to bit 3
    vor   $v12, $v13, $v14, 0 // Combine bits to form partial indices
    vor   $v01, $v12, $v02, 0 // Combine partial indices
    vmudn $v01, $v01, $v25, 0 // Shift to upper byte

    // Add the palette offset to non-zero indices
    // In parallel, move to the next line of the tile
    veq  $v00, $v01, $v31, 0
        addi t7, t7, 0x8
    vmrg $v00, $v01, $v05, 8
        addi t8, t8, 0x2
    vadd $v02, $v01, $v00, 0

    // Write the line to the texture buffer and loop until complete
    andi t5, t8, 0xF
    spv  $v02, 0, -0x8, t7
    bnez t5, decode_object

    // DMA the texture to the tile cache in RDRAM
    la   a0, TEXTURE
    la   a1, 0xA0370000
    sll  t0, s5, 6
    add  a1, a1, t0
    sw   a1, RDP_TILE + 4
    li   a2, 0x3F
    jal  dma_write

draw_objtile:
    // Run the RDP to draw an object tile
    la   a0, RDP_TILE
    la   a1, LAYER_CHART
    jal  rdp_send

    // Loop through object tiles in the X-direction
    addi s0, s0, -8
    add  s2, s2, s6
    addi s5, s5, 1
    andi s5, s5, 0x1FF
    bnez s0, next_objx

    // Loop through object tiles in the Y-direction
    move s0, s4
    sub  s2, s2, v0
    srl  t7, s0, 3
    sub  s5, s5, t7
    addi s5, s5, 16
    andi s5, s5, 0x1FF
    addi s1, s1, -8
    add  s8, s8, gp
    bnez s1, next_objy

next_object:
    // Move to the next object until all have been drawn
    addi t9, t9, -4
    andi t9, t9, 0x1FC
    bne  t9, v1, check_object

    // Update the object tile cache status when finished
    la   a0, TILE_TABLE
    la   a1, 0xA0379000
    li   a2, 0x1FF
    jal  dma_write
    b    next_layer

skip_objdecode:
    // Update the RDP texture address and draw a cached tile
    la   a1, 0xA0370000
    sll  t0, s5, 6
    add  a1, a1, t0
    sw   a1, RDP_TILE + 4
    b    draw_objtile


next_frame:
    // Halt until the next frame can be drawn
    li   t0, 0x0002 // Set halt
    mtc0 t0, COP0_SP_STATUS

    // Update the RDP color buffer command with the next buffer address
    lw   t0, FRAMEBUFFER
    li   t1, 0x20D00 // Buffer size
    add  t0, t0, t1
    li   t1, 0xA03F0000
    bne  t0, t1, set_buffer
    li   t0, 0xA038D900
set_buffer:
    sw   t0, RDP_FRAME + 4
    sw   t0, FRAMEBUFFER

    // Run the RDP to prepare the next frame
    la   a0, RDP_FRAME
    la   a1, RDP_SECTION
    jal  rdp_send
    b    draw_frame


multiply: // a0: multiplicand, a1: multiplier - v0: product
    // Multiply 2 16-bit values to get a 32-bit value
    mtc2  a0, $v00, 0
    mtc2  a1, $v01, 0
    vmudh $v00, $v00, $v01, 0
    vsar  $v00, COP2_ACC_MD
    vsar  $v01, COP2_ACC_HI
    mfc2  v0, $v00, 0
    mfc2  v1, $v01, 0
    andi  v0, v0, 0xFFFF
    sll   v1, v1, 16
    or    v0, v0, v1
    jr    ra


min_max: // a0-a2: values - v0: min, v1: max
    // Find the minimum out of 4 values, including zero
    move v0, zero
    bgtz a0, min1
    move v0, a0
min1:
    bgt  a1, v0, min2
    move v0, a1
min2:
    bgt  a2, v0, min3
    move v0, a2
min3:

    // Find the maximum out of 4 values, including zero
    move v1, zero
    blez a0, max1
    move v1, a0
max1:
    ble  a1, v1, max2
    move v1, a1
max2:
    ble  a2, v1, max3
    move v1, a2
max3:
    jr   ra


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
