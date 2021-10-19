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

palette:   .hword 0:0x100
scanline:  .hword 0:0x100
scrn_data: .hword 0:0x20
char_data: .hword 0:0x20

.space 0xB75

bg_types:    .byte  0x55       // 0xFF5
bg1scrnbase: .hword 0x0000     // 0xFF6-0xFF7
bg1charbase: .hword 0x0000     // 0xFF8-0xFF9
bg1vofs:     .hword 0x0000     // 0xFFA-0xFFB
framebuffer: .word  0xA0320000 // 0xFFC-0xFFF

.text

draw_frame:
    // Set initial values for the frame
    li   s0, 0   // Current X coordinate
    li   s1, 0   // Current Y coordinate
    li   s2, 256 // Maximum X coordinate
    li   s3, 224 // Maximum Y coordinate

draw_line:
    // Get the character data shift from the BG type
    lbu  s4, bg_types
    andi s4, s4, 0x3
    beq  s4, zero, end_line
    addi s4, s4, 3

    // Get the vertical offset within the BG
    lhu  s5, bg1vofs
    add  s5, s5, s1

    // Load the BG entries for the current line
    la   a0, scrn_data
    la   a1, 0xA0340000 // VRAM
    lhu  t0, bg1scrnbase
    add  a1, a1, t0
    andi t0, s5, 0xFF & ~7
    sll  t0, t0, 3
    add  a1, a1, t0
    li   a2, 0x003F
    jal  dma_read

    // Calculate the character offset for the current line
    la   a0, char_data
    andi s5, s5, 7
    sll  s5, s5, 1
    la   t0, 0xA0340000 // VRAM
    add  s5, s5, t0
    lhu  t0, bg1charbase
    add  s5, s5, t0

draw_tile:
    // Get the BG entry for the current tile
    // TODO: priority, mirroring
    srl  t5, s0, 3
    sll  t5, t5, 1
    lhu  t5, scrn_data(t5)

    // Load the tile's character data
    andi t0, t5, 0x03FF
    sll  t0, t0, s4
    add  a1, s5, t0
    jal  dma_read

    // DMA aligns to 64-bit words, so adjust the data offset accordingly
    andi t4, s5, 7

    // Prepare data for 4-color tiles
    lhu  t0, char_data + 0x00(t4)
    bne  s4, 4, prepare_data16
    srl  t6, t5, 7
    andi t6, t6, 0x7 << 3 // Palette offset
    la   t7, draw_pixel4
    jr   t7

prepare_data16:
    // Prepare data for 16-color tiles
    lhu  t1, char_data + 0x10(t4)
    sll  t1, t1, 2
    bne  s4, 5, prepare_data256
    srl  t6, t5, 5
    andi t6, t6, 0x7 << 5 // Palette offset
    la   t7, draw_pixel16
    jr   t7

prepare_data256:
    // Prepare data for 256-color tiles
    lhu  t2, char_data + 0x20(t4)
    sll  t2, t3, 4
    lhu  t3, char_data + 0x30(t4)
    sll  t3, t3, 6
    li   t6, 0
    la   t7, draw_pixel256

draw_pixel256:
    // Decode bits 6-7 of the palette index
    sll  t3, t3, 1
    andi t5, t3, 0x4000
    or   t4, t4, t5
    srl  t5, t3, 7
    andi t5, t5, 0x8000
    or   t4, t4, t5

    // Decode bits 4-5 of the palette index
    sll  t2, t2, 1
    andi t5, t2, 0x1000
    or   t4, t4, t5
    srl  t5, t2, 7
    andi t5, t5, 0x2000
    or   t4, t4, t5

draw_pixel16:
    // Decode bits 2-3 of the palette index
    sll  t1, t1, 1
    andi t5, t1, 0x400
    or   t4, t4, t5
    srl  t5, t1, 7
    andi t5, t5, 0x800
    or   t4, t4, t5

draw_pixel4:
    // Decode bits 0-1 of the palette index
    sll  t0, t0, 1
    andi t5, t0, 0x100
    or   t4, t4, t5
    srl  t5, t0, 7
    andi t5, t5, 0x200
    or   t4, t4, t5

    // Draw a pixel with the palette color
    srl  t4, t4, 7
    beq  t4, zero, transparent
    add  t4, t4, t6
transparent:
    lhu  t4, palette(t4)
    sll  t5, s0, 1
    sh   t4, scanline(t5)

    // Move to the next pixel until the scanline is complete
    addi s0, s0, 1
    andi t4, s0, 7
    beq  t4, zero, end_tile
    jr   t7
end_tile:
    bne  s0, s2, draw_tile

end_line:
    // DMA the scanline to the framebuffer
    la   a0, scanline
    lw   a1, framebuffer
    sll  t0, s1, 9 // Scanline offset
    add  a1, a1, t0
    li   a2, 0x01FF
    jal  dma_write

    // Move to the next line until the frame is complete
    li   s0, 0
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
