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

#include "memory.h"

.globl cpu_ora8
.globl cpu_ora16
.globl cpu_and8
.globl cpu_and16
.globl cpu_eor8
.globl cpu_eor16
.globl cpu_adc8
.globl cpu_adc16
.globl cpu_adc8d
.globl cpu_adc16d
.globl cpu_sbc8
.globl cpu_sbc16
.globl cpu_sbc8d
.globl cpu_sbc16d
.globl cpu_cmp8
.globl cpu_cmp16
.globl cpu_cpx8
.globl cpu_cpx16
.globl cpu_cpy8
.globl cpu_cpy16
.globl cpu_bit8
.globl cpu_bit16
.globl cpu_bit8m
.globl cpu_bit16m
.globl cpu_inc8
.globl cpu_inc16
.globl cpu_inx8
.globl cpu_inx16
.globl cpu_iny8
.globl cpu_iny16
.globl cpu_ina8
.globl cpu_ina16
.globl cpu_dec8
.globl cpu_dec16
.globl cpu_dex8
.globl cpu_dex16
.globl cpu_dey8
.globl cpu_dey16
.globl cpu_dea8
.globl cpu_dea16
.globl cpu_tsb8
.globl cpu_tsb16
.globl cpu_trb8
.globl cpu_trb16
.globl cpu_asl8
.globl cpu_asl16
.globl cpu_asl8m
.globl cpu_asl16m
.globl cpu_lsr8
.globl cpu_lsr16
.globl cpu_lsr8m
.globl cpu_lsr16m
.globl cpu_rol8
.globl cpu_rol16
.globl cpu_rol8m
.globl cpu_rol16m
.globl cpu_ror8
.globl cpu_ror16
.globl cpu_ror8m
.globl cpu_ror16m

.text
.set noreorder

.align 5
cpu_ora8: // ORA op (8-bit)
    // Bitwise or a value with the accumulator and set flags (8-bit)
    MEM_READ8
    la t0, accumulator + 1
    lbu a0, (t0)
    or a0, a0, v0
    j set_nz8
    sb a0, (t0)

.align 5
cpu_ora16: // ORA op (16-bit)
    // Bitwise or a value with the accumulator and set flags (16-bit)
    MEM_READ16
    la t0, accumulator
    lhu a0, (t0)
    or a0, a0, v0
    j set_nz16
    sh a0, (t0)

.align 5
cpu_and8: // AND op (8-bit)
    // Bitwise and a value with the accumulator and set flags (8-bit)
    MEM_READ8
    la t0, accumulator + 1
    lbu a0, (t0)
    and a0, a0, v0
    j set_nz8
    sb a0, (t0)

.align 5
cpu_and16: // AND op (16-bit)
    // Bitwise and a value with the accumulator and set flags (16-bit)
    MEM_READ16
    la t0, accumulator
    lhu a0, (t0)
    and a0, a0, v0
    j set_nz16
    sh a0, (t0)

.align 5
cpu_eor8: // EOR op (8-bit)
    // Bitwise exclusive-or a value with the accumulator and set flags (8-bit)
    MEM_READ8
    la t0, accumulator + 1
    lbu a0, (t0)
    xor a0, a0, v0
    j set_nz8
    sb a0, (t0)

.align 5
cpu_eor16: // EOR op (16-bit)
    // Bitwise exclusive-or a value with the accumulator and set flags (16-bit)
    MEM_READ16
    la t0, accumulator
    lhu a0, (t0)
    xor a0, a0, v0
    j set_nz16
    sh a0, (t0)

.align 5
cpu_adc8: // ADC op (8-bit)
    // Add a value with carry to the accumulator (8-bit)
    MEM_READ8
    lbu t0, accumulator + 1
    add a0, t0, v0
    andi t1, s4, 0x1 // C
    add a0, a0, t1
    sb a0, accumulator + 1

    // Set flags for addition (8-bit)
    andi s4, s4, 0xFFBE
    sgt t1, a0, 0xFF // C
    or s4, s4, t1
    xor t1, a0, t0
    xor t2, a0, v0
    and t1, t1, t2
    srl t1, t1, 1
    andi t1, t1, 0x40 // V
    or s4, s4, t1
    j set_nz8
    andi a0, a0, 0xFF

.align 5
cpu_adc16: // ADC op (16-bit)
    // Add a value with carry to the accumulator (16-bit)
    MEM_READ16
    lhu t0, accumulator
    add a0, t0, v0
    andi t1, s4, 0x1 // C
    add a0, a0, t1
    sh a0, accumulator

    // Set flags for addition (16-bit)
    andi s4, s4, 0xFFBE
    sgt t1, a0, 0xFFFF // C
    or s4, s4, t1
    xor t1, a0, t0
    xor t2, a0, v0
    and t1, t1, t2
    srl t1, t1, 9
    andi t1, t1, 0x40 // V
    or s4, s4, t1
    j set_nz16
    andi a0, a0, 0xFFFF

.align 5
cpu_adc8d: // ADC op (8-bit BCD)
    // Load values for decimal addition (8-bit)
    MEM_READ8
    lbu t0, accumulator + 1
    andi t1, s4, 0x1 // C

    // Add the first decimal digit with carry
    andi t2, t0, 0xF
    andi t3, v0, 0xF
    add a0, t2, t3
    add a0, a0, t1

    // Adjust the first digit on overflow
    blt a0, 0xA, adc8_dec2
    nop
    addi a0, a0, 0x6
    andi a0, a0, 0xF
    addi a0, a0, 0x10

adc8_dec2:
    // Add the last decimal digit (8-bit), unsigned (a0) and signed (a1)
    andi t1, t0, 0xF0
    sll t3, t1, 24
    sra t3, t3, 24
    andi t2, v0, 0xF0
    sll t4, t2, 24
    sra t4, t4, 24
    add t3, t3, t4
    add a1, a0, t3
    add t1, t1, t2
    add a0, a0, t1

    // Adjust the last digit on overflow (8-bit)
    blt a0, 0xA0, adc8_end
    nop
    addi a0, a0, 0x60

adc8_end:
    // Store the result and set flags for decimal addition (8-bit)
    sb a0, accumulator + 1
    andi s4, s4, 0xFFBE
    sgt t1, a0, 0xFF // C
    or s4, s4, t1
    slti t0, a1, -0x80
    sgt t1, a1, 0x7F
    or t1, t1, t0
    sll t1, t1, 6 // V
    or s4, s4, t1
    j set_nz8
    andi a0, a0, 0xFF

.align 5
cpu_adc16d: // ADC op (16-bit BCD)
    // Load values for decimal addition (16-bit)
    MEM_READ16
    lhu t0, accumulator
    andi t1, s4, 0x1 // C

    // Add the first decimal digit with carry
    andi t2, t0, 0xF
    andi t3, v0, 0xF
    add a0, t2, t3
    add a0, a0, t1

    // Adjust the first digit on overflow
    blt a0, 0xA, adc16_dec2
    nop
    addi a0, a0, 0x6
    andi a0, a0, 0xF
    addi a0, a0, 0x10

adc16_dec2:
    // Add the second decimal digit
    andi t2, t0, 0xF0
    andi t3, v0, 0xF0
    add t2, t2, t3
    add a0, a0, t2

    // Adjust the second digit on overflow
    blt a0, 0xA0, adc16_dec3
    nop
    addi a0, a0, 0x60
    andi a0, a0, 0xFF
    addi a0, a0, 0x100

adc16_dec3:
    // Add the third decimal digit
    andi t2, t0, 0xF00
    andi t3, v0, 0xF00
    add t2, t2, t3
    add a0, a0, t2

    // Adjust the third digit on overflow
    blt a0, 0xA00, adc16_dec4
    nop
    addi a0, a0, 0x600
    andi a0, a0, 0xFFF
    addi a0, a0, 0x1000

adc16_dec4:
    // Add the last decimal digit (16-bit), unsigned (a0) and signed (a1)
    andi t1, t0, 0xF000
    sll t3, t1, 16
    sra t3, t3, 16
    andi t2, v0, 0xF000
    sll t4, t2, 16
    sra t4, t4, 16
    add t3, t3, t4
    add a1, a0, t3
    add t1, t1, t2
    add a0, a0, t1

    // Adjust the last digit on overflow (16-bit)
    blt a0, 0xA000, adc16_end
    nop
    addi a0, a0, 0x6000

adc16_end:
    // Store the result and set flags for decimal addition (16-bit)
    sh a0, accumulator
    andi s4, s4, 0xFFBE
    sgt t1, a0, 0xFFFF // C
    or s4, s4, t1
    slti t0, a1, -0x8000
    sgt t1, a1, 0x7F00
    or t1, t1, t0
    sll t1, t1, 6 // V
    or s4, s4, t1
    j set_nz16
    andi a0, a0, 0xFFFF

.align 5
cpu_sbc8: // SBC op (8-bit)
    // Subtract a value with carry from the accumulator (8-bit)
    MEM_READ8
    lbu t0, accumulator + 1
    sub a0, t0, v0
    addi a0, a0, -1
    andi t1, s4, 0x1 // C
    add a0, a0, t1
    sb a0, accumulator + 1

    // Set flags for subtraction (8-bit)
    andi s4, s4, 0xFFBE
    sleu t1, a0, t0 // C
    or s4, s4, t1
    xor t1, t0, v0
    xor t2, t0, a0
    and t1, t1, t2
    srl t1, t1, 1
    andi t1, t1, 0x40 // V
    or s4, s4, t1
    j set_nz8
    andi a0, a0, 0xFF

.align 5
cpu_sbc16: // SBC op (16-bit)
    // Subtract a value with carry from the accumulator (16-bit)
    MEM_READ16
    lhu t0, accumulator
    sub a0, t0, v0
    addi a0, a0, -1
    andi t1, s4, 0x1 // C
    add a0, a0, t1
    sh a0, accumulator

    // Set flags for subtraction (16-bit)
    andi s4, s4, 0xFFBE
    sleu t1, a0, t0 // C
    or s4, s4, t1
    xor t1, t0, v0
    xor t2, t0, a0
    and t1, t1, t2
    srl t1, t1, 9
    andi t1, t1, 0x40 // V
    or s4, s4, t1
    j set_nz16
    andi a0, a0, 0xFFFF

.align 5
cpu_sbc8d: // SBC op (8-bit BCD)
    // Load values for decimal subtraction (8-bit)
    MEM_READ8
    lbu t0, accumulator + 1
    andi t1, s4, 0x1 // C
    xori t1, t1, 0x1

    // Subtract the first decimal digit with carry
    andi t2, t0, 0xF
    andi t3, v0, 0xF
    sub a0, t2, t3
    sub a0, a0, t1

    // Adjust the first digit on overflow
    bgez a0, sbc8_dec2
    nop
    addi a0, a0, -0x6
    andi a0, a0, 0xF
    addi a0, a0, -0x10

sbc8_dec2:
    // Subtract the last decimal digit (8-bit)
    andi t2, t0, 0xF0
    andi t3, v0, 0xF0
    sub t2, t2, t3
    add a0, a0, t2

    // Adjust the last digit on overflow (8-bit)
    bgez a0, sbc8_end
    nop
    addi a0, a0, -0x60

sbc8_end:
    // Store the result and set flags for decimal subtraction (8-bit)
    sb a0, accumulator + 1
    andi s4, s4, 0xFFBE
    sub a1, t0, v0
    sub a1, a1, t1
    sleu t1, a1, t0 // C
    or s4, s4, t1
    xor t1, t0, v0
    xor t2, t0, a1
    and t1, t1, t2
    srl t1, t1, 1
    andi t1, t1, 0x40 // V
    or s4, s4, t1
    j set_nz8
    andi a0, a0, 0xFF

.align 5
cpu_sbc16d: // SBC op (16-bit BCD)
    // Load values for decimal subtraction (16-bit)
    MEM_READ16
    lhu t0, accumulator
    andi t1, s4, 0x1 // C
    xori t1, t1, 0x1

    // Subtract the first decimal digit with carry
    andi t2, t0, 0xF
    andi t3, v0, 0xF
    sub a0, t2, t3
    sub a0, a0, t1

    // Adjust the first digit on overflow
    bgez a0, sbc16_dec2
    nop
    addi a0, a0, -0x6
    andi a0, a0, 0xF
    addi a0, a0, -0x10

sbc16_dec2:
    // Subtract the second decimal digit
    andi t2, t0, 0xF0
    andi t3, v0, 0xF0
    sub t2, t2, t3
    add a0, a0, t2

    // Adjust the second digit on overflow
    bgez a0, sbc16_dec3
    nop
    addi a0, a0, -0x60
    andi a0, a0, 0xFF
    addi a0, a0, -0x100

sbc16_dec3:
    // Subtract the third decimal digit
    andi t2, t0, 0xF00
    andi t3, v0, 0xF00
    sub t2, t2, t3
    add a0, a0, t2

    // Adjust the third digit on overflow
    bgez a0, sbc16_dec4
    nop
    addi a0, a0, -0x600
    andi a0, a0, 0xFFF
    addi a0, a0, -0x1000

sbc16_dec4:
    // Subtract the last decimal digit (16-bit)
    andi t2, t0, 0xF000
    andi t3, v0, 0xF000
    sub t2, t2, t3
    add a0, a0, t2

    // Adjust the last digit on overflow (16-bit)
    bgez a0, sbc16_end
    nop
    addi a0, a0, -0x6000

sbc16_end:
    // Store the result and set flags for decimal subtraction (16-bit)
    sh a0, accumulator
    andi s4, s4, 0xFFBE
    sub a1, t0, v0
    sub a1, a1, t1
    sleu t1, a1, t0 // C
    or s4, s4, t1
    xor t1, t0, v0
    xor t2, t0, a1
    and t1, t1, t2
    srl t1, t1, 9
    andi t1, t1, 0x40 // V
    or s4, s4, t1
    j set_nz16
    andi a0, a0, 0xFFFF

.align 5
cpu_cmp8: // CMP op (8-bit)
    // Compare a value with the accumulator and set flags (8-bit)
    MEM_READ8
    lbu t0, accumulator + 1
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    j set_nz8
    andi a0, a0, 0xFF

.align 5
cpu_cmp16: // CMP op (16-bit)
    // Compare a value with the accumulator and set flags (16-bit)
    MEM_READ16
    lhu t0, accumulator
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    j set_nz16
    andi a0, a0, 0xFFFF

.align 5
cpu_cpx8: // CPX op (8-bit)
    // Compare a value with register X and set flags (8-bit)
    MEM_READ8
    lbu t0, register_x + 1
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    j set_nz8
    andi a0, a0, 0xFF

.align 5
cpu_cpx16: // CPX op (16-bit)
    // Compare a value with register X and set flags (16-bit)
    MEM_READ16
    lhu t0, register_x
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    j set_nz16
    andi a0, a0, 0xFFFF

.align 5
cpu_cpy8: // CPY op (8-bit)
    // Compare a value with register Y and set flags (8-bit)
    MEM_READ8
    lbu t0, register_y + 1
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    j set_nz8
    andi a0, a0, 0xFF

.align 5
cpu_cpy16: // CPY op (16-bit)
    // Compare a value with register Y and set flags (16-bit)
    MEM_READ16
    lhu t0, register_y
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    j set_nz16
    andi a0, a0, 0xFFFF

.align 5
cpu_bit8: // BIT #nn (8-bit)
    // Test the accumulator bits against an immediate value (8-bit)
    MEM_READ8 1(s7)
    lbu t0, accumulator + 1
    and t0, t0, v0

    // Set the Z flag for bit test
    andi s4, s4, 0xFFFD
    seq t0, t0, 0
    sll t0, t0, 1 // Z
    or s4, s4, t0
    j cpu_execute
    addi s7, s7, 2

.align 5
cpu_bit16: // BIT #nnnn (16-bit)
    // Test the accumulator bits against an immediate value (16-bit)
    MEM_READ16 1(s7)
    lhu t0, accumulator
    and t0, t0, v0

    // Set the Z flag for bit test
    andi s4, s4, 0xFFFD
    seq t0, t0, 0
    sll t0, t0, 1 // Z
    or s4, s4, t0
    j cpu_execute
    addi s7, s7, 3

.align 5
cpu_bit8m: // BIT op (8-bit)
    // Test the accumulator bits against a value (8-bit)
    MEM_READ8
    lbu t0, accumulator + 1
    and t0, t0, v0

    // Set flags for bit test (8-bit)
    andi s4, s4, 0xFF3D
    seq t0, t0, 0
    sll t0, t0, 1 // Z
    or s4, s4, t0
    andi t0, v0, 0xC0 // NV
    j cpu_execute
    or s4, s4, t0

.align 5
cpu_bit16m: // BIT op (16-bit)
    // Test the accumulator bits against a value (16-bit)
    MEM_READ16
    lhu t0, accumulator
    and t0, t0, v0

    // Set flags for bit test (16-bit)
    andi s4, s4, 0xFF3D
    seq t0, t0, 0
    sll t0, t0, 1 // Z
    or s4, s4, t0
    srl t0, v0, 8
    andi t0, t0, 0xC0 // NV
    j cpu_execute
    or s4, s4, t0

.align 5
cpu_inc8: // INC op (8-bit)
    // Increment a value in memory and set flags (8-bit)
    MEM_READ8
    addi a1, v0, 1
    MEM_WRITE8
    j set_nz8
    andi a0, a1, 0xFF

.align 5
cpu_inc16: // INC op (16-bit)
    // Increment a value in memory and set flags (16-bit)
    MEM_READ16
    addi a1, v0, 1
    MEM_WRITE16
    j set_nz16
    andi a0, a1, 0xFFFF

.align 5
cpu_inx8: // INX (8-bit)
    // Increment register X and set flags (8-bit)
    lbu a0, register_x + 1
    addi a0, a0, 1
    sb a0, register_x + 1
    andi a0, a0, 0xFF
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_inx16: // INX (16-bit)
    // Increment register X and set flags (16-bit)
    lhu a0, register_x
    addi a0, a0, 1
    sh a0, register_x
    andi a0, a0, 0xFFFF
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_iny8: // INY (8-bit)
    // Increment register Y and set flags (8-bit)
    lbu a0, register_y + 1
    addi a0, a0, 1
    sb a0, register_y + 1
    andi a0, a0, 0xFF
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_iny16: // INY (16-bit)
    // Increment register Y and set flags (16-bit)
    lhu a0, register_y
    addi a0, a0, 1
    sh a0, register_y
    andi a0, a0, 0xFFFF
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_ina8: // INA (8-bit)
    // Increment the accumulator and set flags (8-bit)
    lbu a0, accumulator + 1
    addi a0, a0, 1
    sb a0, accumulator + 1
    andi a0, a0, 0xFF
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_ina16: // INA (16-bit)
    // Increment the accumulator and set flags (16-bit)
    lhu a0, accumulator
    addi a0, a0, 1
    sh a0, accumulator
    andi a0, a0, 0xFFFF
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_dec8: // DEC op (8-bit)
    // Decrement a value in memory and set flags (8-bit)
    MEM_READ8
    addi a1, v0, -1
    MEM_WRITE8
    j set_nz8
    andi a0, a1, 0xFF

.align 5
cpu_dec16: // DEC op (16-bit)
    // Decrement a value in memory and set flags (16-bit)
    MEM_READ16
    addi a1, v0, -1
    MEM_WRITE16
    j set_nz16
    andi a0, a1, 0xFFFF

.align 5
cpu_dex8: // DEX (8-bit)
    // Decrement register X and set flags (8-bit)
    lbu a0, register_x + 1
    addi a0, a0, -1
    sb a0, register_x + 1
    andi a0, a0, 0xFF
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_dex16: // DEX (16-bit)
    // Decrement register X and set flags (16-bit)
    lhu a0, register_x
    addi a0, a0, -1
    sh a0, register_x
    andi a0, a0, 0xFFFF
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_dey8: // DEY (8-bit)
    // Decrement register Y and set flags (8-bit)
    lbu a0, register_y + 1
    addi a0, a0, -1
    sb a0, register_y + 1
    andi a0, a0, 0xFF
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_dey16: // DEY (16-bit)
    // Decrement register Y and set flags (16-bit)
    lhu a0, register_y
    addi a0, a0, -1
    sh a0, register_y
    andi a0, a0, 0xFFFF
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_dea8: // DEA (8-bit)
    // Decrement the accumulator and set flags (8-bit)
    lbu a0, accumulator + 1
    addi a0, a0, -1
    sb a0, accumulator + 1
    andi a0, a0, 0xFF
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_dea16: // DEA (16-bit)
    // Decrement the accumulator and set flags (16-bit)
    lhu a0, accumulator
    addi a0, a0, -1
    sh a0, accumulator
    andi a0, a0, 0xFFFF
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_tsb8: // TSB op (8-bit)
    // Test the accumulator bits against a value (8-bit)
    MEM_READ8
    lbu t0, accumulator + 1
    and t1, t0, v0

    // Set the Z flag for bit test
    andi s4, s4, 0xFFFD
    seq t1, t1, 0
    sll t1, t1, 1 // Z
    or s4, s4, t1

    // Set bits of the value in memory
    or a1, t0, v0
    MEM_WRITE8
    j cpu_execute
    nop

.align 5
cpu_tsb16: // TSB op (16-bit)
    // Test the accumulator bits against a value (16-bit)
    MEM_READ16
    lhu t0, accumulator
    and t1, t0, v0

    // Set the Z flag for bit test
    andi s4, s4, 0xFFFD
    seq t1, t1, 0
    sll t1, t1, 1 // Z
    or s4, s4, t1

    // Set bits of the value in memory
    or a1, t0, v0
    MEM_WRITE16
    j cpu_execute
    nop

.align 5
cpu_trb8: // TRB op (8-bit)
    // Test the accumulator bits against a value (8-bit)
    MEM_READ8
    lbu t0, accumulator + 1
    and t1, t0, v0

    // Set the Z flag for bit test
    andi s4, s4, 0xFFFD
    seq t1, t1, 0
    sll t1, t1, 1 // Z
    or s4, s4, t1

    // Clear bits of the value in memory
    not a1, t0
    and a1, a1, v0
    MEM_WRITE8
    j cpu_execute
    nop

.align 5
cpu_trb16: // TRB op (16-bit)
    // Test the accumulator bits against a value (16-bit)
    MEM_READ16
    lhu t0, accumulator
    and t1, t0, v0

    // Set the Z flag for bit test
    andi s4, s4, 0xFFFD
    seq t1, t1, 0
    sll t1, t1, 1 // Z
    or s4, s4, t1

    // Clear bits of the value in memory
    not a1, t0
    and a1, a1, v0
    MEM_WRITE16
    j cpu_execute
    nop

.align 5
cpu_asl8: // ASL A (8-bit)
    // Shift the accumulator left and set flags (8-bit)
    lbu t0, accumulator + 1
    sll a0, t0, 1
    sb a0, accumulator + 1
    andi s4, s4, 0xFFFE
    srl t0, t0, 7 // C
    or s4, s4, t0
    andi a0, a0, 0xFF
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_asl16: // ASL A (16-bit)
    // Shift the accumulator left and set flags (16-bit)
    lhu t0, accumulator
    sll a0, t0, 1
    sh a0, accumulator
    andi s4, s4, 0xFFFE
    srl t0, t0, 15 // C
    or s4, s4, t0
    andi a0, a0, 0xFFFF
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_asl8m: // ASL op (8-bit)
    // Shift a value in memory left and set flags (8-bit)
    MEM_READ8
    sll a1, v0, 1
    andi s4, s4, 0xFFFE
    srl t0, v0, 7 // C
    or s4, s4, t0
    MEM_WRITE8
    j set_nz8
    andi a0, a1, 0xFF

.align 5
cpu_asl16m: // ASL op (16-bit)
    // Shift a value in memory left and set flags (16-bit)
    MEM_READ16
    sll a1, v0, 1
    andi s4, s4, 0xFFFE
    srl t0, v0, 15 // C
    or s4, s4, t0
    MEM_WRITE16
    j set_nz16
    andi a0, a1, 0xFFFF

.align 5
cpu_lsr8: // LSR A (8-bit)
    // Shift the accumulator right and set flags (8-bit)
    lbu t0, accumulator + 1
    srl a0, t0, 1
    sb a0, accumulator + 1
    andi s4, s4, 0xFFFE
    andi t0, t0, 0x1 // C
    or s4, s4, t0
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_lsr16: // LSR A (16-bit)
    // Shift the accumulator right and set flags (16-bit)
    lhu t0, accumulator
    srl a0, t0, 1
    sh a0, accumulator
    andi s4, s4, 0xFFFE
    andi t0, t0, 0x1 // C
    or s4, s4, t0
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_lsr8m: // LSR op (8-bit)
    // Shift a value in memory right and set flags (8-bit)
    MEM_READ8
    srl a1, v0, 1
    andi s4, s4, 0xFFFE
    andi t0, v0, 0x1 // C
    or s4, s4, t0
    MEM_WRITE8
    j set_nz8
    move a0, a1

.align 5
cpu_lsr16m: // LSR op (16-bit)
    // Shift a value in memory right and set flags (16-bit)
    MEM_READ16
    srl a1, v0, 1
    andi s4, s4, 0xFFFE
    andi t0, v0, 0x1 // C
    or s4, s4, t0
    MEM_WRITE16
    j set_nz16
    move a0, a1

.align 5
cpu_rol8: // ROL A (8-bit)
    // Rotate the accumulator left and set flags (8-bit)
    lbu t0, accumulator + 1
    sll a0, t0, 1
    andi t1, s4, 0x1
    or a0, a0, t1
    sb a0, accumulator + 1
    andi s4, s4, 0xFFFE
    srl t0, t0, 7 // C
    or s4, s4, t0
    andi a0, a0, 0xFF
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_rol16: // ROL A (16-bit)
    // Rotate the accumulator left and set flags (16-bit)
    lhu t0, accumulator
    sll a0, t0, 1
    andi t1, s4, 0x1
    or a0, a0, t1
    sh a0, accumulator
    andi s4, s4, 0xFFFE
    srl t0, t0, 15 // C
    or s4, s4, t0
    andi a0, a0, 0xFFFF
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_rol8m: // ROL op (8-bit)
    // Rotate a value in memory left and set flags (8-bit)
    MEM_READ8
    sll a1, v0, 1
    andi t0, s4, 0x1
    or a1, a1, t0
    andi s4, s4, 0xFFFE
    srl t0, v0, 7 // C
    or s4, s4, t0
    MEM_WRITE8
    j set_nz8
    andi a0, a1, 0xFF

.align 5
cpu_rol16m: // ROL op (16-bit)
    // Rotate a value in memory left and set flags (16-bit)
    MEM_READ16
    sll a1, v0, 1
    andi t0, s4, 0x1
    or a1, a1, t0
    andi s4, s4, 0xFFFE
    srl t0, v0, 15 // C
    or s4, s4, t0
    MEM_WRITE16
    j set_nz16
    andi a0, a1, 0xFFFF

.align 5
cpu_ror8: // ROR A (8-bit)
    // Rotate the accumulator right and set flags (8-bit)
    lbu t0, accumulator + 1
    srl a0, t0, 1
    sll t1, s4, 7
    or a0, a0, t1
    sb a0, accumulator + 1
    andi s4, s4, 0xFFFE
    andi t0, t0, 0x1 // C
    or s4, s4, t0
    andi a0, a0, 0xFF
    j set_nz8
    addi s7, s7, 1

.align 5
cpu_ror16: // ROR A (16-bit)
    // Rotate the accumulator right and set flags (16-bit)
    lhu t0, accumulator
    srl a0, t0, 1
    sll t1, s4, 15
    or a0, a0, t1
    sh a0, accumulator
    andi s4, s4, 0xFFFE
    andi t0, t0, 0x1 // C
    or s4, s4, t0
    andi a0, a0, 0xFFFF
    j set_nz16
    addi s7, s7, 1

.align 5
cpu_ror8m: // ROR op (8-bit)
    // Rotate a value in memory right and set flags (8-bit)
    MEM_READ8
    srl a1, v0, 1
    sll t0, s4, 7
    or a1, a1, t0
    andi s4, s4, 0xFFFE
    andi t0, v0, 0x1 // C
    or s4, s4, t0
    MEM_WRITE8
    j set_nz8
    andi a0, a1, 0xFF

.align 5
cpu_ror16m: // ROR op (16-bit)
    // Rotate a value in memory right and set flags (16-bit)
    MEM_READ16
    srl a1, v0, 1
    sll t0, s4, 15
    or a1, a1, t0
    andi s4, s4, 0xFFFE
    andi t0, v0, 0x1 // C
    or s4, s4, t0
    MEM_WRITE16
    j set_nz16
    andi a0, a1, 0xFFFF
