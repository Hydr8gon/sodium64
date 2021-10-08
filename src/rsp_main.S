#include <rsp.inc>

.set reorder

.data

scanline: .space 256 * 2
framebuffer: .word 0xA0120000

.text

draw_frame:
    // Set initial values for the frame
    li   t0, 0   // Current X coordinate
    li   t1, 0   // Current Y coordinate
    li   t2, 256 // Maximum X coordinate
    li   t3, 224 // Maximum Y coordinate

draw_line:
    // Calculate the blue component
    add  t4, t0, t7
    andi t4, t4, 0x1F

    // Calculate the red component
    add  t5, t1, t7
    andi t5, t5, 0x1F

    // Form a 16-bit color with the values
    sll  t4, t4, 10
    or   t4, t4, t5
    sll  t4, t4, 1

    // Draw the current pixel
    la   t5, scanline
    sll  t6, t0, 1
    add  t5, t5, t6
    sh   t4, (t5)

    // Move to the next pixel until the scanline is complete
    addi t0, t0, 1
    bne  t0, t2, draw_line

    // Wait for the DMA to be ready
dma_wait:
    mfc0 t4, COP0_DMA_BUSY
    bne t4, zero, dma_wait

    // DMA the scanline to the framebuffer
    la   t4, scanline
    mtc0 t4, COP0_DMA_SPADDR
    lw   t4, framebuffer
    sll  t5, t1, 9 // Scanline offset
    add  t4, t4, t5
    mtc0 t4, COP0_DMA_RAMADDR
    li   t4, 0x01FF
    mtc0 t4, COP0_DMA_WRITE

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

    // Update the offset and draw a new frame
    addi t7, t7, 1
    j    draw_frame
