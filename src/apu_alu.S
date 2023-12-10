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

#include "apu_address.h"

.globl apu_orimm
.globl apu_ordir
.globl apu_ordrx
.globl apu_orbrx
.globl apu_orabs
.globl apu_orabx
.globl apu_oraby
.globl apu_oridx
.globl apu_oridy
.globl apu_ordri
.globl apu_ordr2
.globl apu_orbxy
.globl apu_andimm
.globl apu_anddir
.globl apu_anddrx
.globl apu_andbrx
.globl apu_andabs
.globl apu_andabx
.globl apu_andaby
.globl apu_andidx
.globl apu_andidy
.globl apu_anddri
.globl apu_anddr2
.globl apu_andbxy
.globl apu_eorimm
.globl apu_eordir
.globl apu_eordrx
.globl apu_eorbrx
.globl apu_eorabs
.globl apu_eorabx
.globl apu_eoraby
.globl apu_eoridx
.globl apu_eoridy
.globl apu_eordri
.globl apu_eordr2
.globl apu_eorbxy
.globl apu_cmpimm
.globl apu_cmpdir
.globl apu_cmpdrx
.globl apu_cmpbrx
.globl apu_cmpabs
.globl apu_cmpabx
.globl apu_cmpaby
.globl apu_cmpidx
.globl apu_cmpidy
.globl apu_cmpdri
.globl apu_cmpdr2
.globl apu_cmpbxy
.globl apu_cpximm
.globl apu_cpxdir
.globl apu_cpxabs
.globl apu_cpyimm
.globl apu_cpydir
.globl apu_cpyabs
.globl apu_adcimm
.globl apu_adcdir
.globl apu_adcdrx
.globl apu_adcbrx
.globl apu_adcabs
.globl apu_adcabx
.globl apu_adcaby
.globl apu_adcidx
.globl apu_adcidy
.globl apu_adcdri
.globl apu_adcdr2
.globl apu_adcbxy
.globl apu_sbcimm
.globl apu_sbcdir
.globl apu_sbcdrx
.globl apu_sbcbrx
.globl apu_sbcabs
.globl apu_sbcabx
.globl apu_sbcaby
.globl apu_sbcidx
.globl apu_sbcidy
.globl apu_sbcdri
.globl apu_sbcdr2
.globl apu_sbcbxy
.globl apu_asla
.globl apu_asldir
.globl apu_asldrx
.globl apu_aslabs
.globl apu_lsra
.globl apu_lsrdir
.globl apu_lsrdrx
.globl apu_lsrabs
.globl apu_rola
.globl apu_roldir
.globl apu_roldrx
.globl apu_rolabs
.globl apu_rora
.globl apu_rordir
.globl apu_rordrx
.globl apu_rorabs
.globl apu_deca
.globl apu_decx
.globl apu_decy
.globl apu_decdir
.globl apu_decdrx
.globl apu_decabs
.globl apu_inca
.globl apu_incx
.globl apu_incy
.globl apu_incdir
.globl apu_incdrx
.globl apu_incabs
.globl apu_addw
.globl apu_subw
.globl apu_cmpw
.globl apu_decw
.globl apu_incw
.globl apu_div
.globl apu_mul
.globl apu_clr0
.globl apu_clr1
.globl apu_clr2
.globl apu_clr3
.globl apu_clr4
.globl apu_clr5
.globl apu_clr6
.globl apu_clr7
.globl apu_set0
.globl apu_set1
.globl apu_set2
.globl apu_set3
.globl apu_set4
.globl apu_set5
.globl apu_set6
.globl apu_set7
.globl apu_not1
.globl apu_mov1a
.globl apu_mov1b
.globl apu_or1a
.globl apu_or1b
.globl apu_and1a
.globl apu_and1b
.globl apu_eor1
.globl apu_clrc
.globl apu_setc
.globl apu_notc
.globl apu_clrv
.globl apu_xcn
.globl apu_tclr1
.globl apu_tset1

.text

.macro ORA // OR A,op
    // Bitwise or a value with the accumulator and set flags
    jal  apu_read8
    lbu  a0, apu_accum
    or   a0, a0, v0
    sb   a0, apu_accum
    j    apu_set_nz
.endm

apu_orimm: IMM; ORA // OR A,#nn
apu_ordir: DIR; ORA // OR A,aa
apu_ordrx: DRX; ORA // OR A,aa+X
apu_orbrx: BRX; ORA // OR A,(X)
apu_orabs: ABS; ORA // OR A,aaaa
apu_orabx: ABX; ORA // OR A,aaaa+X
apu_oraby: ABY; ORA // OR A,aaaa+Y
apu_oridx: IDX; ORA // OR A,[aa+X]
apu_oridy: IDY; ORA // OR A,[aa]+Y


.macro ORM // OR aa,op
    // Bitwise or a value with another memory value and set flags
    jal  apu_read8
    or   a1, a1, v0
    jal  apu_write8
    move a0, a1
    j    apu_set_nz
.endm

apu_ordri: DRI; ORM // OR aa,#nn
apu_ordr2: DR2; ORM // OR aa,bb
apu_orbxy: BXY; ORM // OR (X),(Y)


.macro ANDA // AND A,op
    // Bitwise and a value with the accumulator and set flags
    jal  apu_read8
    lbu  a0, apu_accum
    and  a0, a0, v0
    sb   a0, apu_accum
    j    apu_set_nz
.endm

apu_andimm: IMM; ANDA // AND A,#nn
apu_anddir: DIR; ANDA // AND A,aa
apu_anddrx: DRX; ANDA // AND A,aa+X
apu_andbrx: BRX; ANDA // AND A,(X)
apu_andabs: ABS; ANDA // AND A,aaaa
apu_andabx: ABX; ANDA // AND A,aaaa+X
apu_andaby: ABY; ANDA // AND A,aaaa+Y
apu_andidx: IDX; ANDA // AND A,[aa+X]
apu_andidy: IDY; ANDA // AND A,[aa]+Y


.macro ANDM // AND aa,op
    // Bitwise and a value with another memory value and set flags
    jal  apu_read8
    and  a1, a1, v0
    jal  apu_write8
    move a0, a1
    j    apu_set_nz
.endm

apu_anddri: DRI; ANDM // AND aa,#nn
apu_anddr2: DR2; ANDM // AND aa,bb
apu_andbxy: BXY; ANDM // AND (X),(Y)


.macro EORA // EOR A,op
    // Bitwise exclusive or a value with the accumulator and set flags
    jal  apu_read8
    lbu  a0, apu_accum
    xor  a0, a0, v0
    sb   a0, apu_accum
    j    apu_set_nz
.endm

apu_eorimm: IMM; EORA // EOR A,#nn
apu_eordir: DIR; EORA // EOR A,aa
apu_eordrx: DRX; EORA // EOR A,aa+X
apu_eorbrx: BRX; EORA // EOR A,(X)
apu_eorabs: ABS; EORA // EOR A,aaaa
apu_eorabx: ABX; EORA // EOR A,aaaa+X
apu_eoraby: ABY; EORA // EOR A,aaaa+Y
apu_eoridx: IDX; EORA // EOR A,[aa+X]
apu_eoridy: IDY; EORA // EOR A,[aa]+Y


.macro EORM // EOR aa,op
    // Bitwise exclusive or a value with another memory value and set flags
    jal  apu_read8
    xor  a1, a1, v0
    jal  apu_write8
    move a0, a1
    j    apu_set_nz
.endm

apu_eordri: DRI; EORM // EOR aa,#nn
apu_eordr2: DR2; EORM // EOR aa,bb
apu_eorbxy: BXY; EORM // EOR (X),(Y)


.macro CMPA // CMP A,op
    // Compare a value with the accumulator and set flags
    jal  apu_read8
    lbu  t0, apu_accum
    sub  a0, t0, v0
    lbu  t1, apu_flags
    andi t1, t1, 0xFE
    sleu t2, a0, t0 // C
    or   t1, t1, t2
    sb   t1, apu_flags
    j    apu_set_nz
.endm

apu_cmpimm: IMM; CMPA // CMP A,#nn
apu_cmpdir: DIR; CMPA // CMP A,aa
apu_cmpdrx: DRX; CMPA // CMP A,aa+X
apu_cmpbrx: BRX; CMPA // CMP A,(X)
apu_cmpabs: ABS; CMPA // CMP A,aaaa
apu_cmpabx: ABX; CMPA // CMP A,aaaa+X
apu_cmpaby: ABY; CMPA // CMP A,aaaa+Y
apu_cmpidx: IDX; CMPA // CMP A,[aa+X]
apu_cmpidy: IDY; CMPA // CMP A,[aa]+Y


.macro CMPM // CMP aa,op
    // Compare a value with another memory value and set flags
    jal  apu_read8
    sub  a0, v0, a1
    lbu  t1, apu_flags
    andi t1, t1, 0xFE
    sleu t2, a0, v0 // C
    or   t1, t1, t2
    sb   t1, apu_flags
    j    apu_set_nz
.endm

apu_cmpdri: DRI; CMPM // CMP aa,#nn
apu_cmpdr2: DR2; CMPM // CMP aa,bb
apu_cmpbxy: BXY; CMPM // CMP (X),(Y)


.macro CMPX // CMP X,op
    // Compare a value with register X and set flags
    jal  apu_read8
    lbu  t0, apu_reg_x
    sub  a0, t0, v0
    lbu  t1, apu_flags
    andi t1, t1, 0xFE
    sleu t2, a0, t0 // C
    or   t1, t1, t2
    sb   t1, apu_flags
    j    apu_set_nz
.endm

apu_cpximm: IMM; CMPX // CMP X,#nn
apu_cpxdir: DIR; CMPX // CMP X,aa
apu_cpxabs: ABS; CMPX // CMP X,aaaa


.macro CMPY // CMP Y,op
    // Compare a value with register Y and set flags
    jal  apu_read8
    lbu  t0, apu_reg_y
    sub  a0, t0, v0
    lbu  t1, apu_flags
    andi t1, t1, 0xFE
    sleu t2, a0, t0 // C
    or   t1, t1, t2
    sb   t1, apu_flags
    j    apu_set_nz
.endm

apu_cpyimm: IMM; CMPY // CMP Y,#nn
apu_cpydir: DIR; CMPY // CMP Y,aa
apu_cpyabs: ABS; CMPY // CMP Y,aaaa


.macro ADCA // ADC A,op
    // Add a value with carry to the accumulator
    jal  apu_read8
    lbu  t0, apu_accum
    add  a0, t0, v0
    lbu  t2, apu_flags
    andi t1, t2, 0x1 // C
    add  a0, a0, t1
    sb   a0, apu_accum

    // Set flags for addition
    // TODO: set the H flag
    andi t2, t2, 0xB6
    sgt  t1, a0, 0xFF // C
    or   t2, t2, t1
    xor  t1, a0, t0
    xor  t3, a0, v0
    and  t1, t1, t3
    srl  t1, t1, 1
    andi t1, t1, 0x40 // V
    or   t2, t2, t1
    sb   t2, apu_flags
    j    apu_set_nz
.endm

apu_adcimm: IMM; ADCA // ADC A,#nn
apu_adcdir: DIR; ADCA // ADC A,aa
apu_adcdrx: DRX; ADCA // ADC A,aa+X
apu_adcbrx: BRX; ADCA // ADC A,(X)
apu_adcabs: ABS; ADCA // ADC A,aaaa
apu_adcabx: ABX; ADCA // ADC A,aaaa+X
apu_adcaby: ABY; ADCA // ADC A,aaaa+Y
apu_adcidx: IDX; ADCA // ADC A,[aa+X]
apu_adcidy: IDY; ADCA // ADC A,[aa]+Y


.macro ADCM // ADC aa,op
    // Add a value with carry to another memory value
    jal  apu_read8
    move s1, a1
    add  a1, v0, s1
    lbu  t2, apu_flags
    andi t1, t2, 0x1 // C
    add  a1, a1, t1
    jal  apu_write8
    move a0, a1

    // Set flags for addition
    // TODO: set the H flag
    andi t2, t2, 0xB6
    sgt  t1, a0, 0xFF // C
    or   t2, t2, t1
    xor  t1, a0, v0
    xor  t3, a0, s1
    and  t1, t1, t3
    srl  t1, t1, 1
    andi t1, t1, 0x40 // V
    or   t2, t2, t1
    sb   t2, apu_flags
    j    apu_set_nz
.endm

apu_adcdri: DRI; ADCM // ADC aa,#nn
apu_adcdr2: DR2; ADCM // ADC aa,bb
apu_adcbxy: BXY; ADCM // ADC (X),(Y)


.macro SBCA // SBC A,op
    // Subtract a value with carry from the accumulator
    jal  apu_read8
    lbu  t0, apu_accum
    sub  a0, t0, v0
    addi a0, a0, -1
    lbu  t2, apu_flags
    andi t1, t2, 0x1 // C
    add  a0, a0, t1
    sb   a0, apu_accum

    // Set flags for subtraction
    // TODO: set the H flag
    andi t2, t2, 0xB6
    sleu t1, a0, t0 // C
    or   t2, t2, t1
    xor  t1, t0, v0
    xor  t3, t0, a0
    and  t1, t1, t3
    srl  t1, t1, 1
    andi t1, t1, 0x40 // V
    or   t2, t2, t1
    sb   t2, apu_flags
    j    apu_set_nz
.endm

apu_sbcimm: IMM; SBCA // SBC A,#nn
apu_sbcdir: DIR; SBCA // SBC A,aa
apu_sbcdrx: DRX; SBCA // SBC A,aa+X
apu_sbcbrx: BRX; SBCA // SBC A,(X)
apu_sbcabs: ABS; SBCA // SBC A,aaaa
apu_sbcabx: ABX; SBCA // SBC A,aaaa+X
apu_sbcaby: ABY; SBCA // SBC A,aaaa+Y
apu_sbcidx: IDX; SBCA // SBC A,[aa+X]
apu_sbcidy: IDY; SBCA // SBC A,[aa]+Y


.macro SBCM // SBC aa,op
    // Subtract a value with carry from another memory value
    jal  apu_read8
    move s1, a1
    sub  a1, v0, s1
    addi a1, a1, -1
    lbu  t2, apu_flags
    andi t1, t2, 0x1 // C
    add  a1, a1, t1
    jal  apu_write8
    move a0, a1

    // Set flags for subtraction
    // TODO: set the H flag
    andi t2, t2, 0xB6
    sleu t1, a1, v0 // C
    or   t2, t2, t1
    xor  t1, v0, s1
    xor  t3, v0, a1
    and  t1, t1, t3
    srl  t1, t1, 1
    andi t1, t1, 0x40 // V
    or   t2, t2, t1
    sb   t2, apu_flags
    j    apu_set_nz
.endm

apu_sbcdri: DRI; SBCM // SBC aa,#nn
apu_sbcdr2: DR2; SBCM // SBC aa,bb
apu_sbcbxy: BXY; SBCM // SBC (X),(Y)


apu_asla: // ASL A
    // Shift the accumulator left and set flags
    NONE
    lbu  t0, apu_accum
    sll  a0, t0, 1
    sb   a0, apu_accum
    lbu  t1, apu_flags
    srl  t0, t0, 7 // C
    andi t1, t1, 0xFE
    or   t1, t1, t0
    sb   t1, apu_flags
    j    apu_set_nz


.macro ASL // ASL op
    // Shift a memory value left and set flags
    jal  apu_read8
    sll  a1, v0, 1
    lbu  t1, apu_flags
    srl  t0, v0, 7 // C
    andi t1, t1, 0xFE
    or   t1, t1, t0
    sb   t1, apu_flags
    jal  apu_write8
    move a0, a1
    j    apu_set_nz
.endm

apu_asldir: DIR; ASL // ASL aa
apu_asldrx: DRX; ASL // ASL aa+X
apu_aslabs: ABS; ASL // ASL aaaa


apu_lsra: // LSR A
    // Shift the accumulator right and set flags
    NONE
    lbu  t0, apu_accum
    srl  a0, t0, 1
    sb   a0, apu_accum
    lbu  t1, apu_flags
    andi t0, t0, 0x1 // C
    andi t1, t1, 0xFE
    or   t1, t1, t0
    sb   t1, apu_flags
    j    apu_set_nz


.macro LSR // LSR op
    // Shift a memory value left and set flags
    jal  apu_read8
    srl  a1, v0, 1
    lbu  t1, apu_flags
    andi t0, v0, 0x1 // C
    andi t1, t1, 0xFE
    or   t1, t1, t0
    sb   t1, apu_flags
    jal  apu_write8
    move a0, a1
    j    apu_set_nz
.endm

apu_lsrdir: DIR; LSR // LSR aa
apu_lsrdrx: DRX; LSR // LSR aa+X
apu_lsrabs: ABS; LSR // LSR aaaa


apu_rola: // ROL A
    // Rotate the accumulator left and set flags
    NONE
    lbu  t0, apu_accum
    lbu  t1, apu_flags
    sll  a0, t0, 1
    andi t2, t1, 0x1
    or   a0, a0, t2
    sb   a0, apu_accum
    andi t1, t1, 0xFE
    srl  t0, t0, 7 // C
    or   t1, t1, t0
    sb   t1, apu_flags
    j    apu_set_nz


.macro ROL // ROL op
    // Rotate a memory value left and set flags
    jal  apu_read8
    lbu  t1, apu_flags
    sll  a1, v0, 1
    andi t2, t1, 0x1
    or   a1, a1, t2
    andi t1, t1, 0xFE
    srl  t0, v0, 7 // C
    or   t1, t1, t0
    sb   t1, apu_flags
    jal  apu_write8
    move a0, a1
    j    apu_set_nz
.endm

apu_roldir: DIR; ROL // ROL aa
apu_roldrx: DRX; ROL // ROL aa+X
apu_rolabs: ABS; ROL // ROL aaaa


apu_rora: // ROR A
    // Rotate the accumulator right and set flags
    NONE
    lbu  t0, apu_accum
    lbu  t1, apu_flags
    srl  a0, t0, 1
    sll  t2, t1, 7
    or   a0, a0, t2
    sb   a0, apu_accum
    andi t1, t1, 0xFE
    andi t0, t0, 0x1 // C
    or   t1, t1, t0
    sb   t1, apu_flags
    j    apu_set_nz


.macro ROR // ROR op
    // Rotate a memory value right and set flags
    jal  apu_read8
    lbu  t1, apu_flags
    srl  a1, v0, 1
    sll  t2, t1, 7
    or   a1, a1, t2
    andi t1, t1, 0xFE
    andi t0, v0, 0x1 // C
    or   t1, t1, t0
    sb   t1, apu_flags
    jal  apu_write8
    move a0, a1
    j    apu_set_nz
.endm

apu_rordir: DIR; ROR // ROL aa
apu_rordrx: DRX; ROR // ROL aa+X
apu_rorabs: ABS; ROR // ROL aaaa


apu_deca: // DEC A
    // Decrement the accumulator and set flags
    NONE
    lbu  a0, apu_accum
    addi a0, a0, -1
    sb   a0, apu_accum
    j    apu_set_nz


apu_decx: // DEC X
    // Decrement the X register and set flags
    NONE
    lbu  a0, apu_reg_x
    addi a0, a0, -1
    sb   a0, apu_reg_x
    j    apu_set_nz


apu_decy: // DEC Y
    // Decrement the Y register and set flags
    NONE
    lbu  a0, apu_reg_y
    addi a0, a0, -1
    sb   a0, apu_reg_y
    j    apu_set_nz


.macro DEC // DEC op
    // Decrement a memory value and set flags
    jal  apu_read8
    addi a1, v0, -1
    jal  apu_write8
    move a0, a1
    j    apu_set_nz
.endm

apu_decdir: DIR; DEC // DEC aa
apu_decdrx: DRX; DEC // DEC aa+X
apu_decabs: ABS; DEC // DEC aaaa


apu_inca: // INC A
    // Increment the accumulator and set flags
    NONE
    lbu  a0, apu_accum
    addi a0, a0, 1
    sb   a0, apu_accum
    j    apu_set_nz


apu_incx: // INC X
    // Increment the X register and set flags
    NONE
    lbu  a0, apu_reg_x
    addi a0, a0, 1
    sb   a0, apu_reg_x
    j    apu_set_nz


apu_incy: // INC Y
    // Increment the Y register and set flags
    NONE
    lbu  a0, apu_reg_y
    addi a0, a0, 1
    sb   a0, apu_reg_y
    j    apu_set_nz


.macro INC // INC op
    // Increment a memory value and set flags
    jal  apu_read8
    addi a1, v0, 1
    jal  apu_write8
    move a0, a1
    j    apu_set_nz
.endm

apu_incdir: DIR; INC // INC aa
apu_incdrx: DRX; INC // INC aa+X
apu_incabs: ABS; INC // INC aaaa


apu_addw: // ADDW YA,aa
    // Load a 16-bit value from memory
    DIR
    addi a0, a0, 1
    jal  apu_read8
    sll  s1, v0, 8
    addi a0, a0, -1
    jal  apu_read8
    or   a1, v0, s1

    // Add the value from register YA and set flags
    // TODO: set the H flag
    lhu  t0, apu_reg_y
    add  a0, t0, a1
    sh   a0, apu_reg_y
    lbu  t1, apu_flags
    andi t1, t1, 0xB6
    sgt  t2, a0, 0xFFFF // C
    or   t1, t1, t2
    xor  t2, a0, t0
    xor  t3, a0, a1
    and  t2, t2, t3
    srl  t2, t2, 9
    andi t2, t2, 0x40 // V
    or   t1, t1, t2
    sb   t1, apu_flags

    // Adjust the 16-bit value for 8-bit flag logic and set flags
    sne  t0, a0, zero
    srl  t1, a0, 8
    or   a0, t0, t1
    j    apu_set_nz


apu_subw: // SUBW YA,aa
    // Load a 16-bit value from memory
    DIR
    addi a0, a0, 1
    jal  apu_read8
    sll  s1, v0, 8
    addi a0, a0, -1
    jal  apu_read8
    or   a1, v0, s1

    // Subtract the value from register YA and set flags
    // TODO: set the H flag
    lhu  t0, apu_reg_y
    sub  a0, t0, a1
    sh   a0, apu_reg_y
    lbu  t1, apu_flags
    andi t1, t1, 0xB6
    sleu t2, a0, t0 // C
    or   t1, t1, t2
    xor  t2, t0, a1
    xor  t3, t0, a0
    and  t2, t2, t3
    srl  t2, t2, 9
    andi t2, t2, 0x40 // V
    or   t1, t1, t2
    sb   t1, apu_flags

    // Adjust the 16-bit value for 8-bit flag logic and set flags
    sne  t0, a0, zero
    srl  t1, a0, 8
    or   a0, t0, t1
    j    apu_set_nz


apu_cmpw: // CMPW YA,aa
    // Load a 16-bit value from memory
    DIR
    addi a0, a0, 1
    jal  apu_read8
    sll  s1, v0, 8
    addi a0, a0, -1
    jal  apu_read8
    or   a1, v0, s1

    // Compare the value with register YA and set flags
    lhu  t0, apu_reg_y
    sub  a0, t0, a1
    lbu  t1, apu_flags
    andi t1, t1, 0xFE
    sleu t2, a0, t0 // C
    or   t1, t1, t2
    sb   t1, apu_flags

    // Adjust the 16-bit value for 8-bit flag logic and set flags
    sne  t0, a0, zero
    srl  t1, a0, 8
    or   a0, t0, t1
    j    apu_set_nz


apu_decw: // DECW aa
    // Load a 16-bit value from memory
    DIR
    addi a0, a0, 1
    jal  apu_read8
    sll  s1, v0, 8
    addi a0, a0, -1
    jal  apu_read8
    or   a1, v0, s1

    // Decrement the value and store it back in memory
    addi a1, a1, -1
    move s1, a1
    jal  apu_write8
    addi a0, a0, 1
    srl  a1, a1, 8
    jal  apu_write8

    // Adjust the 16-bit value for 8-bit flag logic and set flags
    sne  t0, s1, zero
    or   a0, t0, a1
    j    apu_set_nz


apu_incw: // INCW aa
    // Load a 16-bit value from memory
    DIR
    addi a0, a0, 1
    jal  apu_read8
    sll  s1, v0, 8
    addi a0, a0, -1
    jal  apu_read8
    or   a1, v0, s1

    // Increment the value and store it back in memory
    addi a1, a1, 1
    andi s1, a1, 0xFFFF
    jal  apu_write8
    addi a0, a0, 1
    srl  a1, s1, 8
    jal  apu_write8

    // Adjust the 16-bit value for 8-bit flag logic and set flags
    sne  t0, s1, zero
    or   a0, t0, a1
    j    apu_set_nz


apu_div: // DIV YA,X
    // Divide register YA with X
    NONE
    lhu  t0, apu_reg_y
    lbu  t1, apu_reg_x
    div  t0, t1
    mflo a0 // Quotient
    mfhi t0 // Remainder
    sb   a0, apu_accum
    sb   t0, apu_reg_y

    // Set flags for the quotient
    // TODO: set the H flag
    lbu  t1, apu_flags
    sgt  t0, a0, 0xFF
    sll  t0, t0, 6 // V
    andi t1, t1, 0xB7
    or   t1, t1, t0
    sb   t1, apu_flags
    j    apu_set_nz


apu_mul: // MUL YA
    // Multiply register Y with the accumulator
    NONE
    lbu  t0, apu_reg_y
    lbu  t1, apu_accum
    mult t0, t1
    mflo t0

    // Move the 16-bit result to register YA and set flags for Y
    sh   t0, apu_reg_y
    srl  a0, t0, 8
    j    apu_set_nz


.macro CLR1 mask // CLR1 aa.b
    // Clear a bit in a memory value
    DIR
    jal  apu_read8
    andi a1, v0, ~\mask & 0xFF
    jal  apu_write8
    j    cpu_execute
.endm

apu_clr0: CLR1 0x01 // CLR1 aa.0
apu_clr1: CLR1 0x02 // CLR1 aa.1
apu_clr2: CLR1 0x04 // CLR1 aa.2
apu_clr3: CLR1 0x08 // CLR1 aa.3
apu_clr4: CLR1 0x10 // CLR1 aa.4
apu_clr5: CLR1 0x20 // CLR1 aa.5
apu_clr6: CLR1 0x40 // CLR1 aa.6
apu_clr7: CLR1 0x80 // CLR1 aa.7


.macro SET1 mask // SET1 aa.b
    // Set a bit in a memory value
    DIR
    jal  apu_read8
    ori  a1, v0, \mask
    jal  apu_write8
    j    cpu_execute
.endm

apu_set0: SET1 0x01 // SET1 aa.0
apu_set1: SET1 0x02 // SET1 aa.1
apu_set2: SET1 0x04 // SET1 aa.2
apu_set3: SET1 0x08 // SET1 aa.3
apu_set4: SET1 0x10 // SET1 aa.4
apu_set5: SET1 0x20 // SET1 aa.5
apu_set6: SET1 0x40 // SET1 aa.6
apu_set7: SET1 0x80 // SET1 aa.7


apu_not1: // NOT1 aaa.b
    // Invert a bit in a memory value
    DRB
    jal  apu_read8
    xor  a1, a1, v0
    jal  apu_write8
    j    cpu_execute


apu_mov1a: // MOV1 aaa.b,C
    // Set a bit in a memory value to the carry flag
    DRB
    jal  apu_read8
    lbu  t0, apu_flags
    xori t1, a1, 0xFF
    and  v0, v0, t1
    andi t0, t0, 0x1
    sub  t0, zero, t0
    and  t0, t0, a1
    or   a1, v0, t0
    jal  apu_write8
    j    cpu_execute


apu_mov1b: // MOV1 C,aaa.b
    // Set the carry flag to a bit from a memory value
    DRB
    jal  apu_read8
    lbu  t0, apu_flags
    and  t1, v0, a1
    sltu t1, zero, t1
    andi t0, t0, 0xFE
    or   t0, t0, t1
    sb   t0, apu_flags
    j    cpu_execute


apu_or1a: // OR1 C,aaa.b
    // Bitwise or the carry flag with a bit from a memory value
    DRB
    jal  apu_read8
    lbu  t0, apu_flags
    and  t1, v0, a1
    sltu t1, zero, t1
    or   t0, t0, t1
    sb   t0, apu_flags
    j    cpu_execute


apu_or1b: // OR1 C,/aaa.b
    // Bitwise or the carry flag with a negated bit from a memory value
    DRB
    jal  apu_read8
    lbu  t0, apu_flags
    xori v0, v0, 0xFF
    and  t1, v0, a1
    sltu t1, zero, t1
    or   t0, t0, t1
    sb   t0, apu_flags
    j    cpu_execute


apu_and1a: // AND1 C,aaa.b
    // Bitwise and the carry flag with a bit from a memory value
    DRB
    jal  apu_read8
    lbu  t0, apu_flags
    and  t1, v0, a1
    sltu t1, zero, t1
    ori  t1, t1, 0xFE
    and  t0, t0, t1
    sb   t0, apu_flags
    j    cpu_execute


apu_and1b: // AND1 C,/aaa.b
    // Bitwise and the carry flag with a negated bit from a memory value
    DRB
    jal  apu_read8
    lbu  t0, apu_flags
    xori v0, v0, 0xFF
    and  t1, v0, a1
    sltu t1, zero, t1
    ori  t1, t1, 0xFE
    and  t0, t0, t1
    sb   t0, apu_flags
    j    cpu_execute


apu_eor1: // EOR1 C,aaa.b
    // Bitwise exclusive or the carry flag with a bit from a memory value
    DRB
    jal  apu_read8
    lbu  t0, apu_flags
    and  t1, v0, a1
    sltu t1, zero, t1
    xor  t0, t0, t1
    sb   t0, apu_flags
    j    cpu_execute


apu_clrc: // CLRC
    // Clear the C flag
    NONE
    lbu  t0, apu_flags
    andi t0, t0, 0xFE
    sb   t0, apu_flags
    j    cpu_execute


apu_setc: // SETC
    // Set the C flag
    NONE
    lbu  t0, apu_flags
    ori  t0, t0, 0x1
    sb   t0, apu_flags
    j    cpu_execute


apu_notc: // NOTC
    // Negate the C flag
    NONE
    lbu  t0, apu_flags
    xori t0, t0, 0x1
    sb   t0, apu_flags
    j    cpu_execute


apu_clrv: // CLRV
    // Clear the V and H flags
    NONE
    lbu  t0, apu_flags
    andi t0, t0, 0xB7
    sb   t0, apu_flags
    j    cpu_execute


apu_xcn: // XCN A
    // Reverse the accumulator's high and low nibbles
    NONE
    lbu  t0, apu_accum
    srl  t1, t0, 4
    sll  t0, t0, 4
    or   a0, t0, t1
    sb   a0, apu_accum
    j    apu_set_nz


apu_tclr1: // TCLR1 aaaa
    // Clear bits in a memory value and set flags
    ABS
    jal  apu_read8
    lbu  s1, apu_accum
    xori t0, s1, 0xFF
    and  a1, v0, t0
    jal  apu_write8
    sub  a0, s1, v0 // CMP
    j    apu_set_nz


apu_tset1: // TSET1 aaaa
    // Set bits in a memory value and set flags
    ABS
    jal  apu_read8
    lbu  s1, apu_accum
    or   a1, v0, s1
    jal  apu_write8
    sub  a0, s1, v0 // CMP
    j    apu_set_nz
