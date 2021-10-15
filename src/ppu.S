#include <regdef.h>

.globl frame_ready

.globl ppu_event
.globl read_hvbjoy
.globl write_vmaddl
.globl write_vmaddh
.globl write_vmdatal
.globl write_vmdatah
.globl write_cgadd
.globl write_cgdata
.globl write_nmitimen

.data

frame_ready: .byte 0x00

cgram:  .hword 0:0x100
cgbyte: .byte  0x00

vmadd:    .hword 0x0000
cgadd:    .hword 0x0000
nmitimen: .byte  0x00
hvbjoy:   .byte  0x00

.text

ppu_event:
    // Check the current V-blank flag
    lbu  t0, hvbjoy
    bge  t0, 0x80, vblank_end

vblank_start:
    // Set the V-blank flag
    or   t0, t0, 0x80
    sb   t0, hvbjoy

    // Wait until the RSP is finished rendering
rsp_wait:
    lw   t0, 0xA4040010 // SP_STATUS_REG
    andi t0, t0, 0x0001 // Halt
    beq  t0, zero, rsp_wait

    // Indicate a new frame is ready
    li   t0, 0x01
    sb   t0, frame_ready

    // Schedule the V-blank end and trigger an NMI if enabled
    add  s5, 341 * 36 * 4 // V-blank period
    lbu  t0, nmitimen
    blt  t0, 0x80, no_nmi
    j    trigger_nmi

vblank_end:
    // Clear the V-blank flag
    andi t0, t0, ~0x80 & 0xFF
    sb   t0, hvbjoy

    // Wait for the last frame to be displayed
frame_wait:
    lbu  t0, frame_ready
    bne  t0, zero, frame_wait

    // Unhalt the RSP so it can render the next frame
    li   t0, 0x0001     // Clear halt
    sw   t0, 0xA4040010 // SP_STATUS_REG

    // Schedule the V-blank start or skip to it if halted
    bge  s4, 0x200, vblank_start
    add  s5, 341 * 225 * 4
no_nmi:
    j    cpu_execute


read_hvbjoy: // v0: value
    // Read from the HVBJOY register
    lbu  v0, hvbjoy
    jr   ra


write_vmaddl: // a1: value
    // Set the low byte of the VRAM address
    sb   a1, vmadd + 1
    jr   ra


write_vmaddh: // a1: value
    // Set the high byte of the VRAM address
    andi t0, a1, 0x7F
    sb   t0, vmadd
    jr   ra


write_vmdatal: // a1: value
    // Write to the low VRAM byte at the current address
    lhu  t0, vmadd
    sll  t1, t0, 1
    sb   a1, 0xA0140001(t1)
    jr   ra


write_vmdatah: // a1: value
    // Write to the high VRAM byte at the current address
    lhu  t0, vmadd
    sll  t1, t0, 1
    sb   a1, 0xA0140000(t1)

    // Increment the VRAM address
    addi t0, t0, 1
    andi t0, t0, 0x7FFF
    sh   t0, vmadd
    jr   ra


write_cgadd: // a1: value
    // Set the palette address, resetting to first access
    sll  t0, a1, 1
    sb   t0, cgadd
    jr   ra


write_cgdata: // a1: value
    // Increment the palette address and check bit 0 for first/second access
    lhu  t0, cgadd
    addi t1, t0, 1
    sh   t1, cgadd
    andi t1, t0, 1
    bne  t1, zero, cg_high

    // Save the low byte on first access
    sb   a1, cgbyte
    jr   ra

cg_high:
    // Form a 16-bit value with the low byte and write it to CGRAM
    andi t0, t0, 0xFF << 1
    lbu  t1, cgbyte
    sll  t2, a1, 8
    or   t1, t1, t2
    sh   t1, cgram(t0)

    // Rearrange the RGB components to be N64 format
    andi t2, t1, 0x1F << 0  // R
    sll  t3, t2, 11
    andi t2, t1, 0x1F << 5  // G
    sll  t2, t2, 1
    or   t3, t3, t2
    andi t2, t1, 0x1F << 10 // B
    srl  t2, t2, 9
    or   t3, t3, t2

    // Update the RSP's converted palette in DMEM
    // DMEM access from the main CPU is 32-bit, so check if this is a low or high half-word
    andi t1, t0, ~3 & 0xFFFF
    la   t2, 0xA4000000 // DMEM
    add  t2, t2, t1
    bne  t1, t0, dmem_high

    // Change the low half-word and write the value back
    lw   t0, (t2)
    andi t0, t0, 0xFFFF
    sll  t3, t3, 16
    or   t3, t3, t0
    sw   t3, (t2)
    jr   ra

dmem_high:
    // Change the high half-word and write the value back
    lw   t0, (t2)
    lui  t1, 0xFFFF
    and  t0, t0, t1
    or   t3, t3, t0
    sw   t3, (t2)
    jr   ra


write_nmitimen: // a1: value
    // Write to the NMITIMEN register
    sb   a1, nmitimen
    jr   ra
