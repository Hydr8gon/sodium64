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

#include <regdef.h>

.globl read_rddivl
.globl read_rddivh
.globl read_rdmpyl
.globl read_rdmpyh
.globl write_wrmpya
.globl write_wrmpyb
.globl write_wrdivl
.globl write_wrdivh
.globl write_wrdivb

.data

.align 4
wrdiva: .hword 0
rddiv: .hword 0
rdmpy: .hword 0
wrmpya: .byte 0

.text

.align 5
read_rddivl: // v0: value
    // Read the low byte of the division quotient
    lbu v0, rddiv + 1
    jr ra

.align 5
read_rddivh: // v0: value
    // Read the high byte of the division quotient
    lbu v0, rddiv
    jr ra

.align 5
read_rdmpyl: // v0: value
    // Read the low byte of the multiply product/division remainder
    lbu v0, rdmpy + 1
    jr ra

.align 5
read_rdmpyh: // v0: value
    // Read the high byte of the multiply product/division remainder
    lbu v0, rdmpy
    jr ra

.align 5
write_wrmpya: // a1: value
    // Set the 8-bit multiplicand
    sb a1, wrmpya
    jr ra

.align 5
write_wrmpyb: // a1: value
    // Multiply the multiplicand by the value and set the product
    lbu t0, wrmpya
    mult t0, a1
    mflo t0
    sh t0, rdmpy
    sh a1, rddiv
    jr ra

.align 5
write_wrdivl: // a1: value
    // Set the low byte of the 16-bit dividend
    sb a1, wrdiva + 1
    jr ra

.align 5
write_wrdivh: // a1: value
    // Set the high byte of the 16-bit dividend
    sb a1, wrdiva
    jr ra

.align 5
write_wrdivb: // a1: value
    // Divide the dividend by the value and set the quotient and remainder
    beqz a1, div_zero
    lhu t0, wrdiva
    div t0, a1
    mflo t0
    sh t0, rddiv
    mfhi t1
    sh t1, rdmpy
    jr ra

div_zero:
    // Handle division by zero cases
    li t0, 0xFFFF
    sh t0, rddiv
    lhu t1, wrdiva
    sh t1, rdmpy
    jr ra
