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

#include "cpu_address.h"

.globl tay_8
.globl tay_16
.globl tax_8
.globl tax_16
.globl tsx_8
.globl tsx_16
.globl tya_8
.globl tya_16
.globl txa_8
.globl txa_16
.globl txs_e
.globl txs
.globl txy_8
.globl txy_16
.globl tyx_8
.globl tyx_16
.globl tdc
.globl tcd
.globl tsc
.globl tcs_e
.globl tcs
.globl lda_8
.globl lda_16
.globl ldadir_8
.globl ldadir_16
.globl ldadrx_8
.globl ldadrx_16
.globl ldadrs_8
.globl ldadrs_16
.globl ldaabs_8
.globl ldaabs_16
.globl ldaabx_8
.globl ldaabx_16
.globl ldaaby_8
.globl ldaaby_16
.globl ldalng_8
.globl ldalng_16
.globl ldalnx_8
.globl ldalnx_16
.globl ldaind_8
.globl ldaind_16
.globl ldaidx_8
.globl ldaidx_16
.globl ldaidy_8
.globl ldaidy_16
.globl ldaisy_8
.globl ldaisy_16
.globl ldaidl_8
.globl ldaidl_16
.globl ldaily_8
.globl ldaily_16
.globl ldx_8
.globl ldx_16
.globl ldxdir_8
.globl ldxdir_16
.globl ldxdry_8
.globl ldxdry_16
.globl ldxabs_8
.globl ldxabs_16
.globl ldxaby_8
.globl ldxaby_16
.globl ldy_8
.globl ldy_16
.globl ldydir_8
.globl ldydir_16
.globl ldydrx_8
.globl ldydrx_16
.globl ldyabs_8
.globl ldyabs_16
.globl ldyabx_8
.globl ldyabx_16
.globl stzdir_8
.globl stzdir_16
.globl stzdrx_8
.globl stzdrx_16
.globl stzabs_8
.globl stzabs_16
.globl stzabx_8
.globl stzabx_16
.globl stadir_8
.globl stadir_16
.globl stadrx_8
.globl stadrx_16
.globl stadrs_8
.globl stadrs_16
.globl staabs_8
.globl staabs_16
.globl staabx_8
.globl staabx_16
.globl staaby_8
.globl staaby_16
.globl stalng_8
.globl stalng_16
.globl stalnx_8
.globl stalnx_16
.globl staind_8
.globl staind_16
.globl staidx_8
.globl staidx_16
.globl staidy_8
.globl staidy_16
.globl staisy_8
.globl staisy_16
.globl staidl_8
.globl staidl_16
.globl staily_8
.globl staily_16
.globl stxdir_8
.globl stxdir_16
.globl stxdry_8
.globl stxdry_16
.globl stxabs_8
.globl stxabs_16
.globl stydir_8
.globl stydir_16
.globl stydrx_8
.globl stydrx_16
.globl styabs_8
.globl styabs_16
.globl pha_8
.globl pha_16
.globl phx_8
.globl phx_16
.globl phy_8
.globl phy_16
.globl php
.globl phb
.globl phk
.globl phd
.globl pei
.globl pea
.globl per
.globl pla_8
.globl pla_16
.globl plx_8
.globl plx_16
.globl ply_8
.globl ply_16
.globl pld
.globl plb
.globl plp
.globl mvp_8
.globl mvp_16
.globl mvn_8
.globl mvn_16

.text

tay_8: // TAY (8-bit)
    // Transfer the accumulator to register Y and set flags (8-bit)
    lbu  a0, accumulator + 1
    sb   a0, register_y + 1
    addi s7, s7, 1
    j    set_nz8


tay_16: // TAY (16-bit)
    // Transfer the accumulator to register Y and set flags (16-bit)
    lhu  a0, accumulator
    sh   a0, register_y
    addi s7, s7, 1
    j    set_nz16


tax_8: // TAX (8-bit)
    // Transfer the accumulator to register X and set flags (8-bit)
    lbu  a0, accumulator + 1
    sb   a0, register_x + 1
    addi s7, s7, 1
    j    set_nz8


tax_16: // TAX (16-bit)
    // Transfer the accumulator to register X and set flags (16-bit)
    lhu  a0, accumulator
    sh   a0, register_x
    addi s7, s7, 1
    j    set_nz16


tsx_8: // TSX (8-bit)
    // Transfer the stack pointer to register X and set flags (8-bit)
    lbu  a0, stack_ptr + 1
    sb   a0, register_x + 1
    addi s7, s7, 1
    j    set_nz8


tsx_16: // TSX (16-bit)
    // Transfer the stack pointer to register X and set flags (16-bit)
    lhu  a0, stack_ptr
    sh   a0, register_x
    addi s7, s7, 1
    j    set_nz16


tya_8: // TYA (8-bit)
    // Transfer register Y to the accumulator and set flags (8-bit)
    lbu  a0, register_y + 1
    sb   a0, accumulator + 1
    addi s7, s7, 1
    j    set_nz8


tya_16: // TYA (16-bit)
    // Transfer register Y to the accumulator and set flags (16-bit)
    lhu  a0, register_y
    sh   a0, accumulator
    addi s7, s7, 1
    j    set_nz16


txa_8: // TXA (8-bit)
    // Transfer register X to the accumulator and set flags (8-bit)
    lbu  a0, register_x + 1
    sb   a0, accumulator + 1
    addi s7, s7, 1
    j    set_nz8


txa_16: // TXA (16-bit)
    // Transfer register X to the accumulator and set flags (16-bit)
    lhu  a0, register_x
    sh   a0, accumulator
    addi s7, s7, 1
    j    set_nz16


txs_e: // TXS (emulation mode)
    // Transfer register X to the stack pointer (emulation mode)
    lbu  a0, register_x + 1
    sb   a0, stack_ptr + 1
    addi s7, s7, 1
    j    cpu_execute


txs: // TXS
    // Transfer register X to the stack pointer
    lhu  a0, register_x
    sh   a0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


txy_8: // TXY (8-bit)
    // Transfer register X to register Y and set flags (8-bit)
    lbu  a0, register_x + 1
    sb   a0, register_y + 1
    addi s7, s7, 1
    j    set_nz8


txy_16: // TXY (16-bit)
    // Transfer register X to register Y and set flags (16-bit)
    lhu  a0, register_x
    sh   a0, register_y
    addi s7, s7, 1
    j    set_nz16


tyx_8: // TYX (8-bit)
    // Transfer register Y to register X and set flags (8-bit)
    lbu  a0, register_y + 1
    sb   a0, register_x + 1
    addi s7, s7, 1
    j    set_nz8


tyx_16: // TYX (16-bit)
    // Transfer register Y to register X and set flags (16-bit)
    lhu  a0, register_y
    sh   a0, register_x
    addi s7, s7, 1
    j    set_nz16


tdc: // TDC
    // Transfer the direct offset to the accumulator and set flags
    move a0, s8
    sh   a0, accumulator
    addi s7, s7, 1
    j    set_nz16


tcd: // TCD
    // Transfer the accumulator to the direct offset and set flags
    lhu  a0, accumulator
    move s8, a0
    addi s7, s7, 1
    j    set_nz16


tsc: // TSC
    // Transfer the stack pointer to the accumulator and set flags
    lhu  a0, stack_ptr
    sh   a0, accumulator
    addi s7, s7, 1
    j    set_nz16


tcs_e: // TCS (emulation mode)
    // Transfer the accumulator to the stack pointer (emulation mode)
    lbu  a0, accumulator + 1
    sb   a0, stack_ptr + 1
    addi s7, s7, 1
    j    cpu_execute


tcs: // TCS
    // Transfer the accumulator to the stack pointer
    lhu  a0, accumulator
    sh   a0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


.macro LDA_8 // LDA op (8-bit)
    // Load a value to the accumulator and set flags (8-bit)
    MEM_READ8
    move a0, v0
    sb   a0, accumulator + 1
    j    set_nz8
.endm

lda_8:    IM8; LDA_8 // LDA #nn      (8-bit)
ldadir_8: DIR; LDA_8 // LDA nn       (8-bit)
ldadrx_8: DRX; LDA_8 // LDA nn,X     (8-bit)
ldadrs_8: DRS; LDA_8 // LDA nn,S     (8-bit)
ldaabs_8: ABS; LDA_8 // LDA nnnn     (8-bit)
ldaabx_8: ABX; LDA_8 // LDA nnnn,X   (8-bit)
ldaaby_8: ABY; LDA_8 // LDA nnnn,Y   (8-bit)
ldalng_8: LNG; LDA_8 // LDA nnnnnn   (8-bit)
ldalnx_8: LNX; LDA_8 // LDA nnnnnn,X (8-bit)
ldaind_8: IND; LDA_8 // LDA (nn)     (8-bit)
ldaidx_8: IDX; LDA_8 // LDA (nn,X)   (8-bit)
ldaidy_8: IDY; LDA_8 // LDA (nn),Y   (8-bit)
ldaisy_8: ISY; LDA_8 // LDA (nn,S),Y (8-bit)
ldaidl_8: IDL; LDA_8 // LDA [nn]     (8-bit)
ldaily_8: ILY; LDA_8 // LDA [nn],Y   (8-bit)


.macro LDA_16 // LDA op (16-bit)
    // Load a value to the accumulator and set flags (16-bit)
    MEM_READ16
    move a0, v0
    sh   a0, accumulator
    j    set_nz16
.endm

lda_16:    I16; LDA_16 // LDA #nnnn    (16-bit)
ldadir_16: DIR; LDA_16 // LDA nn       (16-bit)
ldadrx_16: DRX; LDA_16 // LDA nn,X     (16-bit)
ldadrs_16: DRS; LDA_16 // LDA nn,S     (16-bit)
ldaabs_16: ABS; LDA_16 // LDA nnnn     (16-bit)
ldaabx_16: ABX; LDA_16 // LDA nnnn,X   (16-bit)
ldaaby_16: ABY; LDA_16 // LDA nnnn,Y   (16-bit)
ldalng_16: LNG; LDA_16 // LDA nnnnnn   (16-bit)
ldalnx_16: LNX; LDA_16 // LDA nnnnnn,X (16-bit)
ldaind_16: IND; LDA_16 // LDA (nn)     (16-bit)
ldaidx_16: IDX; LDA_16 // LDA (nn,X)   (16-bit)
ldaidy_16: IDY; LDA_16 // LDA (nn),Y   (16-bit)
ldaisy_16: ISY; LDA_16 // LDA (nn,S),Y (16-bit)
ldaidl_16: IDL; LDA_16 // LDA [nn]     (16-bit)
ldaily_16: ILY; LDA_16 // LDA [nn],Y   (16-bit)


.macro LDX_8 // LDX op (8-bit)
    // Load a value to register X and set flags (8-bit)
    MEM_READ8
    move a0, v0
    sb   a0, register_x + 1
    j    set_nz8
.endm

ldx_8:    IM8; LDX_8 // LDX #nn    (8-bit)
ldxdir_8: DIR; LDX_8 // LDX nn     (8-bit)
ldxdry_8: DRY; LDX_8 // LDX nn,Y   (8-bit)
ldxabs_8: ABS; LDX_8 // LDX nnnn   (8-bit)
ldxaby_8: ABY; LDX_8 // LDX nnnn,Y (8-bit)


.macro LDX_16 // LDX op (16-bit)
    // Load a value to register X and set flags (16-bit)
    MEM_READ16
    move a0, v0
    sh   a0, register_x
    j    set_nz16
.endm

ldx_16:    I16; LDX_16 // LDX #nnnn  (16-bit)
ldxdir_16: DIR; LDX_16 // LDX nn     (16-bit)
ldxdry_16: DRY; LDX_16 // LDX nn,Y   (16-bit)
ldxabs_16: ABS; LDX_16 // LDX nnnn   (16-bit)
ldxaby_16: ABY; LDX_16 // LDX nnnn,Y (16-bit)


.macro LDY_8 // LDY op (8-bit)
    // Load a value to register Y and set flags (8-bit)
    MEM_READ8
    move a0, v0
    sb   a0, register_y + 1
    j    set_nz8
.endm

ldy_8:    IM8; LDY_8 // LDY #nn    (8-bit)
ldydir_8: DIR; LDY_8 // LDY nn     (8-bit)
ldydrx_8: DRX; LDY_8 // LDY nn,X   (8-bit)
ldyabs_8: ABS; LDY_8 // LDY nnnn   (8-bit)
ldyabx_8: ABX; LDY_8 // LDY nnnn,X (8-bit)


.macro LDY_16 // LDY op (16-bit)
    // Load a value to register Y and set flags (16-bit)
    MEM_READ16
    move a0, v0
    sh   a0, register_y
    j    set_nz16
.endm

ldy_16:    I16; LDY_16 // LDY #nnnn  (16-bit)
ldydir_16: DIR; LDY_16 // LDY nn     (16-bit)
ldydrx_16: DRX; LDY_16 // LDY nn,X   (16-bit)
ldyabs_16: ABS; LDY_16 // LDY nnnn   (16-bit)
ldyabx_16: ABX; LDY_16 // LDY nnnn,X (16-bit)


.macro STZ_8 // STZ op (8-bit)
    // Store zero to memory (8-bit)
    li   a1, 0
    MEM_WRITE8
    j    cpu_execute
.endm

stzdir_8: DIR; STZ_8 // STZ nn     (8-bit)
stzdrx_8: DRX; STZ_8 // STZ nn,X   (8-bit)
stzabs_8: ABS; STZ_8 // STZ nnnn   (8-bit)
stzabx_8: ABX; STZ_8 // STZ nnnn,X (8-bit)


.macro STZ_16 // STZ op (16-bit)
    // Store zero to memory (16-bit)
    li   a1, 0
    MEM_WRITE16
    j    cpu_execute
.endm

stzdir_16: DIR; STZ_16 // STZ nn     (16-bit)
stzdrx_16: DRX; STZ_16 // STZ nn,X   (16-bit)
stzabs_16: ABS; STZ_16 // STZ nnnn   (16-bit)
stzabx_16: ABX; STZ_16 // STZ nnnn,X (16-bit)


.macro STA_8 // STA op (8-bit)
    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    MEM_WRITE8
    j    cpu_execute
.endm

stadir_8: DIR; STA_8 // STA nn       (8-bit)
stadrx_8: DRX; STA_8 // STA nn,X     (8-bit)
stadrs_8: DRS; STA_8 // STA nn,S     (8-bit)
staabs_8: ABS; STA_8 // STA nnnn     (8-bit)
staabx_8: ABX; STA_8 // STA nnnn,X   (8-bit)
staaby_8: ABY; STA_8 // STA nnnn,Y   (8-bit)
stalng_8: LNG; STA_8 // STA nnnnnn   (8-bit)
stalnx_8: LNX; STA_8 // STA nnnnnn,X (8-bit)
staind_8: IND; STA_8 // STA (nn)     (8-bit)
staidx_8: IDX; STA_8 // STA (nn,X)   (8-bit)
staidy_8: IDY; STA_8 // STA (nn),Y   (8-bit)
staisy_8: ISY; STA_8 // STA (nn,S),Y (8-bit)
staidl_8: IDL; STA_8 // STA [nn]     (8-bit)
staily_8: ILY; STA_8 // STA [nn],Y   (8-bit)


.macro STA_16 // STA op (16-bit)
    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    MEM_WRITE16
    j    cpu_execute
.endm

stadir_16: DIR; STA_16 // STA nn       (16-bit)
stadrx_16: DRX; STA_16 // STA nn,X     (16-bit)
stadrs_16: DRS; STA_16 // STA nn,S     (16-bit)
staabs_16: ABS; STA_16 // STA nnnn     (16-bit)
staabx_16: ABX; STA_16 // STA nnnn,X   (16-bit)
staaby_16: ABY; STA_16 // STA nnnn,Y   (16-bit)
stalng_16: LNG; STA_16 // STA nnnnnn   (16-bit)
stalnx_16: LNX; STA_16 // STA nnnnnn,X (16-bit)
staind_16: IND; STA_16 // STA (nn)     (16-bit)
staidx_16: IDX; STA_16 // STA (nn,X)   (16-bit)
staidy_16: IDY; STA_16 // STA (nn),Y   (16-bit)
staisy_16: ISY; STA_16 // STA (nn,S),Y (16-bit)
staidl_16: IDL; STA_16 // STA [nn]     (16-bit)
staily_16: ILY; STA_16 // STA [nn],Y   (16-bit)


.macro STX_8 // STX op (8-bit)
    // Store register X to memory (8-bit)
    lbu  a1, register_x + 1
    MEM_WRITE8
    j    cpu_execute
.endm

stxdir_8: DIR; STX_8 // STX nn   (8-bit)
stxdry_8: DRY; STX_8 // STX nn,Y (8-bit)
stxabs_8: ABS; STX_8 // STX nnnn (8-bit)


.macro STX_16 // STX op (16-bit)
    // Store register X to memory (16-bit)
    lhu  a1, register_x
    MEM_WRITE16
    j    cpu_execute
.endm

stxdir_16: DIR; STX_16 // STX nn   (16-bit)
stxdry_16: DRY; STX_16 // STX nn,Y (16-bit)
stxabs_16: ABS; STX_16 // STX nnnn (16-bit)


.macro STY_8 // STY op (8-bit)
    // Store register Y to memory (8-bit)
    lbu  a1, register_y + 1
    MEM_WRITE8
    j    cpu_execute
.endm

stydir_8: DIR; STY_8 // STY nn   (8-bit)
stydrx_8: DRX; STY_8 // STY nn,X (8-bit)
styabs_8: ABS; STY_8 // STY nnnn (8-bit)


.macro STY_16 // STY op (16-bit)
    // Store register Y to memory (16-bit)
    lhu  a1, register_y
    MEM_WRITE16
    j    cpu_execute
.endm

stydir_16: DIR; STY_16 // STY nn   (16-bit)
stydrx_16: DRX; STY_16 // STY nn,X (16-bit)
styabs_16: ABS; STY_16 // STY nnnn (16-bit)


pha_8: // PHA (8-bit)
    // Push the accumulator to the stack (8-bit)
    lhu  s0, stack_ptr
    lbu  a1, accumulator + 1
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


pha_16: // PHA (16-bit)
    // Push the accumulator to the stack (16-bit)
    lhu  s0, stack_ptr
    lhu  a1, accumulator
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phx_8: // PHX (8-bit)
    // Push register X to the stack (8-bit)
    lhu  s0, stack_ptr
    lbu  a1, register_x + 1
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phx_16: // PHX (16-bit)
    // Push register X to the stack (16-bit)
    lhu  s0, stack_ptr
    lhu  a1, register_x
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phy_8: // PHY (8-bit)
    // Push register Y to the stack (8-bit)
    lhu  s0, stack_ptr
    lbu  a1, register_y + 1
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phy_16: // PHY (16-bit)
    // Push register Y to the stack (16-bit)
    lhu  s0, stack_ptr
    lhu  a1, register_y
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


php: // PHP
    // Push the flags to the stack
    lhu  s0, stack_ptr
    andi a1, s4, 0xFF
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phb: // PHB
    // Push the data bank to the stack
    lhu  s0, stack_ptr
    lbu  a1, data_bank + 1
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phk: // PHK
    // Push the PC bank to the stack
    lhu  s0, stack_ptr
    srl  a1, s7, 16
    addi s0, s0, -1
    MEM_WRITE8 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phd: // PHD
    // Push the direct offset to the stack
    lhu  s0, stack_ptr
    move a1, s8
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


pei: // PEI nn
    // Get the 8-bit immediate value added to the direct offset as an address
    MEM_READ8 1(s7)
    add  s0, s8, v0

    // Load a 16-bit value from memory and push it to the stack
    MEM_READ16
    lhu  s0, stack_ptr
    move a1, v0
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 2
    j    cpu_execute


pea: // PEA #nnnn
    // Push a 16-bit immediate value to the stack
    MEM_READ16 1(s7)
    lhu  s0, stack_ptr
    move a1, v0
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh   s0, stack_ptr
    addi s7, s7, 3
    j    cpu_execute


per: // PER disp16
    // Add a sign-extended 16-bit immediate value to the PC
    MEM_READ16 1(s7)
    sll  t0, v0, 16
    sra  t0, t0, 16
    addi s7, s7, 3
    add  a1, s7, t0

    // Push the resulting value to the stack
    lhu  s0, stack_ptr
    addi s0, s0, -2
    MEM_WRITE16 1(s0)
    sh   s0, stack_ptr
    j    cpu_execute


pla_8: // PLA (8-bit)
    // Pop the accumulator from the stack and set flags (8-bit)
    lhu  s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh   t0, stack_ptr
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 1
    j    set_nz8


pla_16: // PLA (16-bit)
    // Pop the accumulator from the stack and set flags (16-bit)
    lhu  s0, stack_ptr
    MEM_READ16 1(s0)
    addi t0, s0, 2
    sh   t0, stack_ptr
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 1
    j    set_nz16


plx_8: // PLX (8-bit)
    // Pop register X from the stack and set flags (8-bit)
    lhu  s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh   t0, stack_ptr
    move a0, v0
    sb   a0, register_x + 1
    addi s7, s7, 1
    j    set_nz8


plx_16: // PLX (16-bit)
    // Pop register X from the stack and set flags (16-bit)
    lhu  s0, stack_ptr
    MEM_READ16 1(s0)
    addi t0, s0, 2
    sh   t0, stack_ptr
    move a0, v0
    sh   a0, register_x
    addi s7, s7, 1
    j    set_nz16


ply_8: // PLY (8-bit)
    // Pop register Y from the stack and set flags (8-bit)
    lhu  s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh   t0, stack_ptr
    move a0, v0
    sb   a0, register_y + 1
    addi s7, s7, 1
    j    set_nz8


ply_16: // PLY (16-bit)
    // Pop register Y from the stack and set flags (16-bit)
    lhu  s0, stack_ptr
    MEM_READ16 1(s0)
    addi t0, s0, 2
    sh   t0, stack_ptr
    move a0, v0
    sh   a0, register_y
    addi s7, s7, 1
    j    set_nz16


pld: // PLD
    // Pop the direct offset from the stack and set flags
    lhu  s0, stack_ptr
    MEM_READ16 1(s0)
    addi t0, s0, 2
    sh   t0, stack_ptr
    move a0, v0
    move s8, a0
    addi s7, s7, 1
    j    set_nz16


plb: // PLB
    // Pop the data bank from the stack and set flags
    lhu  s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh   t0, stack_ptr
    move a0, v0
    sb   a0, data_bank + 1
    addi s7, s7, 1
    j    set_nz8


plp: // PLP
    // Pop the flags from the stack
    lhu  s0, stack_ptr
    MEM_READ8 1(s0)
    addi t0, s0, 1
    sh   t0, stack_ptr
    andi s4, s4, 0xFF00
    or   s4, s4, v0
    addi s7, s7, 1
    j    update_mode


mvp_8: // MVP ss,dd (8-bit)
    // Get the immediate 8-bit value plus register Y as the destination address (8-bit)
    MEM_READ8 1(s7)
    sll  s0, v0, 16
    lbu  t0, register_y + 1
    add  s0, s0, t0

    // Get the next immediate 8-bit value plus register Y as the source address (8-bit)
    MEM_READ8 2(s7)
    sll  s1, v0, 16
    lbu  t0, register_x + 1
    add  s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    MEM_READ8 0(s1)
    move a1, v0
    MEM_WRITE8

    // Decrement the registers (8-bit)
    addi t0, s1, -1
    sb   t0, register_x + 1
    addi t0, s0, -1
    sb   t0, register_y + 1

    // Decrement the accumulator and don't increment the PC until it underflows
    lhu  t0, accumulator
    addi t1, t0, -1
    sh   t1, accumulator
    bnez t0, mvp8_cont
    addi s7, s7, 3
mvp8_cont:
    j    cpu_execute


mvp_16: // MVP ss,dd (16-bit)
    // Get the immediate 8-bit value plus register Y as the destination address (16-bit)
    MEM_READ8 1(s7)
    sll  s0, v0, 16
    lhu  t0, register_y
    add  s0, s0, t0

    // Get the next immediate 8-bit value plus register Y as the source address (16-bit)
    MEM_READ8 2(s7)
    sll  s1, v0, 16
    lhu  t0, register_x
    add  s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    MEM_READ8 0(s1)
    move a1, v0
    MEM_WRITE8

    // Decrement the registers (16-bit)
    addi t0, s1, -1
    sh   t0, register_x
    addi t0, s0, -1
    sh   t0, register_y

    // Decrement the accumulator and don't increment the PC until it underflows
    lhu  t0, accumulator
    addi t1, t0, -1
    sh   t1, accumulator
    bnez t0, mvp16_cont
    addi s7, s7, 3
mvp16_cont:
    j    cpu_execute


mvn_8: // MVN ss,dd (8-bit)
    // Get the immediate 8-bit value plus register Y as the destination address (8-bit)
    MEM_READ8 1(s7)
    sll  s0, v0, 16
    lbu  t0, register_y + 1
    add  s0, s0, t0

    // Get the next immediate 8-bit value plus register Y as the source address (8-bit)
    MEM_READ8 2(s7)
    sll  s1, v0, 16
    lbu  t0, register_x + 1
    add  s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    MEM_READ8 0(s1)
    move a1, v0
    MEM_WRITE8

    // Increment the registers (8-bit)
    addi t0, s1, 1
    sb   t0, register_x + 1
    addi t0, s0, 1
    sb   t0, register_y + 1

    // Decrement the accumulator and don't increment the PC until it underflows
    lhu  t0, accumulator
    addi t1, t0, -1
    sh   t1, accumulator
    bnez t0, mvn8_cont
    addi s7, s7, 3
mvn8_cont:
    j    cpu_execute


mvn_16: // MVN ss,dd (16-bit)
    // Get the immediate 8-bit value plus register Y as the destination address (16-bit)
    MEM_READ8 1(s7)
    sll  s0, v0, 16
    lhu  t0, register_y
    add  s0, s0, t0

    // Get the next immediate 8-bit value plus register Y as the source address (16-bit)
    MEM_READ8 2(s7)
    sll  s1, v0, 16
    lhu  t0, register_x
    add  s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    MEM_READ8 0(s1)
    move a1, v0
    MEM_WRITE8

    // Increment the registers (16-bit)
    addi t0, s1, 1
    sh   t0, register_x
    addi t0, s0, 1
    sh   t0, register_y

    // Decrement the accumulator and don't increment the PC until it underflows
    lhu  t0, accumulator
    addi t1, t0, -1
    sh   t1, accumulator
    bnez t0, mvn16_cont
    addi s7, s7, 3
mvn16_cont:
    j    cpu_execute
