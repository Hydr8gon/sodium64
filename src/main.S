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

#include <regdef.h>

.globl main

.data

framebuffer: .word 0xA03B0000

.text

main:
    // Initialize the VI to display a 16-bit 256x224 framebuffer
    lui  t0, 0xA440     // VI register upper address
    li   t1, 0x0202     // 16-bit pixel format, no anti-aliasing
    sw   t1, 0x0000(t0) // VI_STATUS_REG
    li   t1, 0xA03B0000 // Framebuffer address
    sw   t1, 0x0004(t0) // VI_ORIGIN_REG
    li   t1, 0x0100     // Framebuffer width
    sw   t1, 0x0008(t0) // VI_WIDTH_REG
    li   t1, 0x0200     // Line to trigger interrupt
    sw   t1, 0x000C(t0) // VI_INTR_REG
    li   t1, 0x0000     // Clear interrupt
    sw   t1, 0x0010(t0) // VI_CURRENT
    li   t1, 0x03E52239 // Various timing parameters
    sw   t1, 0x0014(t0) // VI_BURST_REG
    li   t1, 0x020D     // Lines per frame (NTSC standard)
    sw   t1, 0x0018(t0) // VI_V_SYNC_REG
    li   t1, 0x0C15     // Quarter-pixels per line
    sw   t1, 0x001C(t0) // VI_H_SYNC_REG
    li   t1, 0x0C150C15 // Same as above
    sw   t1, 0x0020(t0) // VI_LEAP_REG
    li   t1, 0x006C02EC // Active horizontal pixel range
    sw   t1, 0x0024(t0) // VI_H_START_REG
    li   t1, 0x002501FF // Active vertical pixel range
    sw   t1, 0x0028(t0) // VI_V_START_REG
    li   t1, 0x000E0204 // Vertical color burst range
    sw   t1, 0x002C(t0) // VI_V_BURST_REG
    li   t1, 0x019A     // Horizontal scale (10-bit fraction, 256/640)
    sw   t1, 0x0030(t0) // VI_X_SCALE_REG
    li   t1, 0x03BC     // Vertical scale (10-bit fraction, 224/240)
    sw   t1, 0x0034(t0) // VI_Y_SCALE_REG

    // Clear VRAM on boot (hardcoded for easy RSP access)
    li t0, 0xA03F0000
    li t1, 0xA0400000
clear_vram:
    sw   zero, (t0)
    addi t0, t0, 4
    bne  t0, t1, clear_vram

    // Upload the RSP code and data
    li   a0, 0x1000 // IMEM address
    la   a1, rsp_main_text_start
    jal  rsp_upload
    li   a0, 0x0000 // DMEM address
    la   a1, rsp_main_data_start
    jal  rsp_upload

    // Start the RSP
    li   t0, 0x0001     // Clear halt
    sw   t0, 0xA4040010 // SP_STATUS_REG

    // Setup the VI interrupt handler using libdragon
    jal  init_interrupts
    la   a0, vi_interrupt
    jal  register_VI_handler
    li   a0, 1
    li   a1, 512
    jal  set_VI_interrupt

    // Initialize the emulator
    jal  memory_init
    jal  cpu_init

    // Start execution
    j    cpu_execute


rsp_upload: // a0: RSP address, a1: DRAM address
    // Transfer data to the RSP via DMA
    lui  t0, 0xA404     // SP register upper address
    sw   a0, 0x0000(t0) // SP_MEM_ADDR_REG
    sw   a1, 0x0004(t0) // SP_DRAM_ADDR_REG
    li   t1, 0x0FFF     // Data size
    sw   t1, 0x0008(t0) // SP_RD_LEN_REG

    // Wait for the DMA to complete
dma_wait:
    lw   t1, 0x0018(t0) // SP_DMA_BUSY_REG
    bne  t1, zero, dma_wait
    jr   ra


vi_interrupt:
    // Continue if a new frame is ready, otherwise just update input
    lbu  t0, frame_ready
    bne  t0, zero, swap_buffers
    j    update_input

    // Swap the framebuffer with the newly-rendered one
swap_buffers:
    lw   t0, framebuffer
    li   t1, 0xA03B0000
    bne  t0, t1, set_buffer
    li   t1, 0xA03D0000
set_buffer:
    sw   t1, 0xA4400004 // VI_ORIGIN_REG
    sw   t1, framebuffer

    // Indicate the frame isn't ready so a new one will be drawn, and update input
    li   t0, 0x00
    sb   t0, frame_ready
    j    update_input
