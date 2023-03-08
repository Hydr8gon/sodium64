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

#include <regdef.h>

.globl _start

// Entry point; jump directly to main
.section .boot
_start:
    j    main
.section .code

.data

framebuffer: .word 0xA038D900

.text

main:
    // Disable interrupts and do the magic hardware init
    mtc0 zero, $12 // Status
    li   t0, 8
    sw   t0, 0xBFC007FC

    // Initialize the .bss area with zeroes
    la   t0, __bss_start
    la   t1, __bss_end
bss_loop:
    sw   zero, (t0)
    addi t0, t0, 4
    bltu t0, t1, bss_loop

    // Initialize the VI to display a 16-bit 256x224 framebuffer
    lui  t0, 0xA440     // VI register upper address
    li   t1, 0x0202     // 16-bit pixel format, no anti-aliasing
    sw   t1, 0x0000(t0) // VI_STATUS_REG
    li   t1, 0xA038D900 // Framebuffer address
    sw   t1, 0x0004(t0) // VI_ORIGIN_REG
    li   t1, 0x0118     // Framebuffer width
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
    li   t1, 0x01C0     // Horizontal scale (10-bit fraction, 280/640)
    sw   t1, 0x0030(t0) // VI_X_SCALE_REG
    li   t1, 0x0400     // Vertical scale (10-bit fraction, 240/240)
    sw   t1, 0x0034(t0) // VI_Y_SCALE_REG

    // Initialize the AI to output 16-bit samples at 32000Hz
    lui  t0, 0xA450     // AI register upper address
    li   t1, 0x0001     // DMA enable
    sw   t1, 0x0008(t0) // AI_CONTROL
    li   t1, 0x05F1     // 48681812 / 32000Hz
    sw   t1, 0x0010(t0) // AI_DAC_RATE
    li   t1, 0x000F     // 16-bit - 1
    sw   t1, 0x0014(t0) // AI_BIT_RATE

    // Update the exception vectors
    la    t0, exception_vector
    lw    t1, 0x0000(t0)
    lw    t2, 0x0004(t0)
    lui   t0, 0xA000
    sw    t1, 0x0000(t0)
    sw    t2, 0x0004(t0)
    sw    t1, 0x0080(t0)
    sw    t2, 0x0084(t0)
    sw    t1, 0x0100(t0)
    sw    t2, 0x0104(t0)
    sw    t1, 0x0180(t0)
    sw    t2, 0x0184(t0)
    cache 0x10, 0x0000(t0)
    cache 0x10, 0x0080(t0)
    cache 0x10, 0x0100(t0)
    cache 0x10, 0x0180(t0)

    // Initialize the stack below the ROM buffer
    la   sp, 0x80340000

    // Read SRAM from the cart to memory
    li   t0, 0xA8000000
    la   t1, sram
    andi t2, t1, 0xFFF  // 4KB-aligned
    sub  t1, t1, t2
    addi t2, t1, 0x2000 // 8KB size
read_sram:
    lw   t3, (t0)
    addi t0, t0, 4
    jal  sram_wait
    sw   t3, (t1)
    addi t1, t1, 4
    bne  t1, t2, read_sram

    // Clear the framebuffers and VRAM (hardcoded for RSP access)
    li   t0, 0xA038D900
    li   t1, 0xA0400000
clear_vram:
    sw   zero, (t0)
    addi t0, t0, 4
    bne  t0, t1, clear_vram

    // Initialize the emulator
    jal  reset_tlb
    jal  input_init
    jal  memory_init
    jal  cpu_init

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

    // Enable VI interrupts and nothing else
    li   t0, 0x0595     // Set VI mask
    sw   t0, 0xA430000C // MI_MASK_REG
    li   t0, 0x401      // Enable interrupts
    mtc0 t0, $12        // Status

    // Start execution
    j    cpu_execute


rsp_upload: // a0: RSP address, a1: DRAM address
    // Transfer data to the RSP via DMA
    lui  t0, 0xA404     // SP register upper address
    sw   a0, 0x0000(t0) // SP_MEM_ADDR_REG
    sw   a1, 0x0004(t0) // SP_DRAM_ADDR_REG
    li   t1, 0x0FFF     // Data size
    sw   t1, 0x0008(t0) // SP_RD_LEN_REG

dma_wait:
    // Wait for the DMA to complete
    lw   t1, 0x0018(t0) // SP_DMA_BUSY_REG
    bnez t1, dma_wait
    jr   ra


reset_tlb:
    // Map all TLB entries to inaccessible locations
    mtc0 zero, $5 // PageMask
    li   t0, 0x80000000
    mtc0 t0, $10  // EntryHi
    li   t0, 32
next_tlb:
    addi t0, t0, -1
    mtc0 t0, $0   // Index
    nop
    tlbwi
    bnez t0, next_tlb
    jr   ra


exception_vector:
    // Jump to the custom exception handler (copied to exception vectors)
    j    exception_handler


exception_handler:
    // Jump to the appropriate handler for supported exceptions
    mfc0 k0, $13          // Cause
    andi k0, k0, 0x7C
    addi k1, k0, -0x8     // TLB load miss
    beqz k1, tlbl_exception
    addi k1, k0, -0xC     // TLB store miss
    beqz k1, tlbs_exception
    addi k1, k0, -0x4     // TLB modification
    beqz k1, tlbm_exception

    // Jump to the appropriate handler for supported interrupts
    mfc0 k0, $13 // Cause
    andi k1, k0, 0x1000
    bnez k1, reset_interrupt
    andi k1, k0, 0x400
    bnez k1, vi_interrupt
    eret


vi_interrupt:
    // Acknowledge the VI interrupt
    lui  k0, 0xA440
    sw   zero, 0x0010(k0) // VI_CURRENT

    // Continue if the next frame is ready, otherwise just update input
    la   k0, frame_count
    lbu  k1, (k0)
    bnez k1, swap_buffers
    j    input_update

swap_buffers:
    // Decrement the frame counter
    addi k1, k1, -1
    sb   k1, (k0)

    // Get the address of the next of three framebuffers
    la   k0, framebuffer
    lw   k0, (k0)
    li   k1, 0x20D00 // Buffer size
    add  k0, k0, k1
    li   k1, 0xA03F0000
    bne  k0, k1, set_buffer
    li   k0, 0xA038D900

set_buffer:
    // Set the framebuffer address and update input
    lui  k1, 0xA440
    sw   k0, 0x0004(k1) // VI_ORIGIN
    la   k1, framebuffer
    sw   k0, (k1)
    j    input_update


reset_interrupt:
    // Stop the RSP and prepare the RDP for reset
    li   t0, 0x0002     // Set halt
    sw   t0, 0xA4040010 // SP_STATUS
    li   t0, 0x0001     // Use RDRAM
    sw   t0, 0xA410000C // DP_STATUS

    // Reset the TLB to ensure unmapped SRAM is updated
    jal  reset_tlb

    // Write SRAM from memory to the cart
    li   t0, 0xA8000000
    la   t1, sram
    andi t2, t1, 0xFFF // 4KB-aligned
    sub  t1, t1, t2
    li   t2, 0x8000    // 32KB size
    add  t2, t2, t1
write_sram:
    lw   t3, (t1)
    addi t1, t1, 4
    jal  sram_wait
    sw   t3, (t0)
    addi t0, t0, 4
    bne  t1, t2, write_sram

loop:
    // Wait until the system resets
    b    loop


sram_wait:
    // Wait a while between SRAM accesses
    li   t4, 0x200
sram_loop:
    addi t4, t4, -1
    bnez t4, sram_loop
    jr   ra
