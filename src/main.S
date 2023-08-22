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

#include "defines.h"

.globl fps_emulate
.globl fps_display
.globl frame_count

.globl _start

.data

.align 4
framebuffer: .word FRAMEBUFFER1
fps_native: .byte 0
fps_emulate: .byte 0
fps_display: .byte 0
frame_count: .byte 0

.section .boot

_start:
    // Jump to the main function (entry point)
    j main

exception_vector:
    // Jump to the exception handler (copied to exception vectors)
    j exception_handler

.text

.align 5
main:
    // Disable interrupts and do the magic hardware init
    mtc0 zero, $12 // Status
    li t0, 8
    sw t0, 0xBFC007FC

    // Clear framebuffers and other hardcoded data
    li t0, FRAMEBUFFER1
    li t1, JIT_BUFFER
clear_vram:
    sd zero, (t0)
    addi t0, t0, 8
    bne t0, t1, clear_vram

    // Initialize the VI to display a 16-bit 256x224 framebuffer
    lui t0, 0xA440 // VI register upper address
    li t1, 0x00000202 // 16-bit pixel format, no anti-aliasing
    sw t1, 0x0000(t0) // VI_CONTROL
    li t1, FRAMEBUFFER1 // Framebuffer address
    sw t1, 0x0004(t0) // VI_ORIGIN
    li t1, 0x00000118 // Framebuffer width
    sw t1, 0x0008(t0) // VI_WIDTH
    li t1, 0x00000200 // Line to trigger interrupt
    sw t1, 0x000C(t0) // VI_V_INTR
    li t1, 0x00000000 // Clear interrupt
    sw t1, 0x0010(t0) // VI_V_CURRENT
    li t1, 0x03E52239 // Various timing parameters
    sw t1, 0x0014(t0) // VI_BURST
    li t1, 0x0000020D // Lines per frame (NTSC standard)
    sw t1, 0x0018(t0) // VI_V_SYNC
    li t1, 0x00000C15 // Quarter-pixels per line
    sw t1, 0x001C(t0) // VI_H_SYNC
    li t1, 0x0C150C15 // Same as above
    sw t1, 0x0020(t0) // VI_H_SYNC_LEAP
    li t1, 0x006C02EC // Active horizontal pixel range
    sw t1, 0x0024(t0) // VI_H_VIDEO
    li t1, 0x002501FF // Active vertical pixel range
    sw t1, 0x0028(t0) // VI_V_VIDEO
    li t1, 0x000E0204 // Vertical color burst range
    sw t1, 0x002C(t0) // VI_V_BURST
    li t1, 0x000001C0 // Horizontal scale (10-bit fraction, 280/640)
    sw t1, 0x0030(t0) // VI_X_SCALE
    li t1, 0x00000400 // Vertical scale (10-bit fraction, 240/240)
    sw t1, 0x0034(t0) // VI_Y_SCALE

    // Initialize the AI to output 16-bit samples at the DSP rate
    lui t0, 0xA450 // AI register upper address
    li t1, 0x00000001 // DMA enable
    sw t1, 0x0008(t0) // AI_CONTROL
    li t1, 48681812 / (60 * 262 * 341 * 4 / DSP_SAMPLE) + 1
    sw t1, 0x0010(t0) // AI_DAC_RATE
    li t1, 0x0000000F // 16-bit - 1
    sw t1, 0x0014(t0) // AI_BIT_RATE

    // Update the exception vectors
    lui t0, 0xA000
    ld t1, exception_vector
    sd t1, 0x0000(t0)
    sd t1, 0x0080(t0)
    sd t1, 0x0100(t0)
    sd t1, 0x0180(t0)
    cache 0x10, 0x0000(t0)
    cache 0x10, 0x0080(t0)
    cache 0x10, 0x0100(t0)
    cache 0x10, 0x0180(t0)

    // Setup SRAM signal speed to something consistent but safe.
    lui  t0, 0xA460       // PI register upper address
    li   t1, 0x06
    sw   t1, 0x0024(t0)   // LAT
    li   t1, 0x0B
    sw   t1, 0x0028(t0)   // PWD
    li   t1, 0x07
    sw   t1, 0x002C(t0)   // PGS
    li   t1, 0x03
    sw   t1, 0x0030(t0)   // RLS

    // Use DMA to copy SRAM from the cart to memory
    la t1, sram // Local SRAM
    sw t1, 0x0000(t0) // PI_DRAM_ADDR
    li t1, 0x08000000 // Cart SRAM
    sw t1, 0x0004(t0) // PI_CART_ADDR
    li t1, 0x00007FFF // 32KB size
    sw t1, 0x000C(t0) // PI_WR_LEN

pi_wait1:
    // Wait for the DMA to complete
    lw t1, 0x0010(t0) // PI_STATUS
    andi t1, t1, 0x1 // DMA busy
    bnez t1, pi_wait1

    // Initialize the emulator
    jal reset_tlb
    jal input_init
    jal memory_init
    jal section_init
    jal cpu_init

    // Upload the RSP code and data
    li a0, 0x1000 // IMEM address
    la a1, rsp_main_text_start
    jal rsp_upload
    li a0, 0x0000 // DMEM address
    la a1, rsp_main_data_start
    jal rsp_upload

    // Enable VI interrupts and nothing else
    li t0, 0x00000595 // Set VI mask
    sw t0, 0xA430000C // MI_MASK
    li t0, 0x00000401 // Enable interrupts
    mtc0 t0, $12 // Status

    // Start execution
    j cpu_execute

.align 5
rsp_upload: // a0: RSP address, a1: DRAM address
    // Transfer data to the RSP via DMA
    lui t0, 0xA404 // SP register upper address
    sw a0, 0x0000(t0) // SP_MEM_ADDR
    sw a1, 0x0004(t0) // SP_DRAM_ADDR
    li t1, 0x00000FFF // Data size
    sw t1, 0x0008(t0) // SP_RD_LEN

dma_wait:
    // Wait for the DMA to complete
    lw t1, 0x0018(t0) // SP_DMA_BUSY
    bnez t1, dma_wait
    jr ra

.align 5
reset_tlb:
    // Map all TLB entries to inaccessible locations
    mtc0 zero, $5 // PageMask
    li t0, 0x80000000
    mtc0 t0, $10 // EntryHi
    li t0, 32
next_tlb:
    addi t0, t0, -1
    mtc0 t0, $0 // Index
    nop
    tlbwi
    bnez t0, next_tlb
    jr ra

.align 5
exception_handler:
    // Jump to the appropriate handler for supported exceptions
    mfc0 k0, $13 // Cause
    andi k0, k0, 0x7C
    addi k1, k0, -0x8 // TLB load miss
    beqz k1, tlbl_exception
    addi k1, k0, -0xC // TLB store miss
    beqz k1, tlbs_exception
    addi k1, k0, -0x4 // TLB modification
    beqz k1, tlbm_exception

    // Jump to the appropriate handler for supported interrupts
    mfc0 k0, $13 // Cause
    andi k1, k0, 0x1000
    bnez k1, reset_interrupt
    andi k1, k0, 0x400
    bnez k1, vi_interrupt
    eret

.align 5
vi_interrupt:
    // Acknowledge the VI interrupt
    lui k0, 0xA440
    sw zero, 0x0010(k0) // VI_CURRENT

    // Wait one second by counting 60 frames at 60Hz
    la k0, fps_native
    lbu k1, (k0)
    addi k1, k1, -59
    beqz k1, update_fps
    addi k1, k1, 60
    sb k1, (k0)
    b check_frame

update_fps:
    // Update the display FPS and reset the counters
    la k0, fps_emulate
    lbu k1, (k0)
    sb zero, (k0)
    la k0, fps_native
    sb zero, (k0)
    la k0, fps_display
    sb k1, (k0)

    // Check if SRAM is dirty
    la k0, sram_dirty
    lbu k1, (k0)
    beqz k1, check_frame
    sb zero, (k0)

    // Use DMA to copy SRAM from memory to the cart
    lui k0, 0xA460 // PI register upper address
    la k1, sram // Local SRAM
    sw k1, 0x0000(k0) // PI_DRAM_ADDR
    li k1, 0x08000000 // Cart SRAM
    sw k1, 0x0004(k0) // PI_CART_ADDR
    li k1, 0x00007FFF // 32KB size
    sw k1, 0x0008(k0) // PI_RD_LEN

pi_wait2:
    // Wait for the DMA to complete
    lw k1, 0x0010(k0) // PI_STATUS
    andi k1, k1, 0x1 // DMA busy
    bnez k1, pi_wait2

check_frame:
    // Continue if the next frame is ready; otherwise just update input
    la k0, frame_count
    lbu k1, (k0)
    beqz k1, input_update

    // Decrement the frame counter
    addi k1, k1, -1
    sb k1, (k0)

    // Get the address of the next of three framebuffers
    la k0, framebuffer
    lw k0, (k0)
    li k1, FRAMEBUFFER2 - FRAMEBUFFER1
    add k0, k0, k1
    li k1, MODE7_TEXTURE
    bne k0, k1, set_buffer
    li k0, FRAMEBUFFER1

set_buffer:
    // Set the framebuffer address and update input
    lui k1, 0xA440
    sw k0, 0x0004(k1) // VI_ORIGIN
    la k1, framebuffer
    sw k0, (k1)
    j input_update

.align 5
reset_interrupt:
    // Stop the RSP and prepare the RDP for reset
    li t0, 0x00000002 // Set halt
    sw t0, 0xA4040010 // SP_STATUS
    li t0, 0x00000001 // Use RDRAM
    sw t0, 0xA410000C // DP_STATUS

loop:
    // Wait until the system resets
    b loop
