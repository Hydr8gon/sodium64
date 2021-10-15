#include <rsp.inc>

.set reorder

.data

palette:     .hword 0:256
scanline:    .hword 0:256
framebuffer: .word  0xA0120000

.text

draw_frame:
    // Set initial values for the frame
    li   t0, 0   // Current X coordinate
    li   t1, 0   // Current Y coordinate
    li   t2, 256 // Maximum X coordinate
    li   t3, 224 // Maximum Y coordinate

draw_line:
    // Draw the current pixel using the X coordinate as a palette index
    sll  t4, t0, 1
    lhu  t5, palette(t4)
    sh   t5, scanline(t4)

    // Move to the next pixel until the scanline is complete
    addi t0, t0, 1
    bne  t0, t2, draw_line

    // DMA the scanline to the framebuffer
    la   t4, scanline
    mtc0 t4, COP0_DMA_SPADDR
    lw   t4, framebuffer
    sll  t5, t1, 9 // Scanline offset
    add  t4, t4, t5
    mtc0 t4, COP0_DMA_RAMADDR
    li   t4, 0x01FF
    mtc0 t4, COP0_DMA_WRITE

    // Wait for the DMA to complete
dma_wait:
    mfc0 t4, COP0_DMA_BUSY
    bne t4, zero, dma_wait

    // Move to the next line until the frame is complete
    li   t0, 0
    addi t1, t1, 1
    bne  t1, t3, draw_line

    // Halt until the next frame needs to be drawn
    li   t4, 0x0002 // Set halt
    mtc0 t4, COP0_SP_STATUS

    // Swap the framebuffer with the previously-rendered one
    lw   t4, framebuffer
    li   t5, 0xA0100000
    bne  t4, t5, set_buffer
    li   t5, 0xA0120000
set_buffer:
    sw   t5, framebuffer
    j    draw_frame
