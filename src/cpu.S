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

#include "memory.h"

.globl accumulator
.globl register_x
.globl register_y
.globl stack_ptr
.globl data_bank

.globl cpu_init
.globl set_nz8
.globl set_nz16
.globl cpu_execute
.globl trigger_nmi
.globl update_mode

.data

data_bank: .word 0
accumulator: .hword 0
register_x: .hword 0
register_y: .hword 0
stack_ptr: .hword 0x1FF

.macro OPS_E d // Lookup table for 6502 emulation mode
    .word cpu_brke, 0,  cpu_idx, cpu_ora8,  cpu_cope, 0,  cpu_drs, cpu_ora8 // 0x00-0x03
    .word cpu_dir, cpu_tsb8,  cpu_dir, cpu_ora8,  cpu_dir, cpu_asl8m,  cpu_idl, cpu_ora8 // 0x04-0x07
    .word cpu_php, 0,  cpu_im8, cpu_ora8,  cpu_asl8, 0,  cpu_phd, 0 // 0x08-0x0B
    .word cpu_abs, cpu_tsb8,  cpu_abs, cpu_ora8,  cpu_abs, cpu_asl8m,  cpu_lng, cpu_ora8 // 0x0C-0x0F
    .word cpu_bpl, 0,  cpu_idy, cpu_ora8,  cpu_ind, cpu_ora8,  cpu_isy, cpu_ora8 // 0x10-0x13
    .word cpu_dir, cpu_trb8,  cpu_drx, cpu_ora8,  cpu_drx, cpu_asl8m,  cpu_ily, cpu_ora8 // 0x14-0x17
    .word cpu_clc, 0,  cpu_aby, cpu_ora8,  cpu_ina8, 0,  cpu_tcse, 0 // 0x18-0x1B
    .word cpu_abs, cpu_trb8,  cpu_abx, cpu_ora8,  cpu_abx, cpu_asl8m,  cpu_lnx, cpu_ora8 // 0x1C-0x1F
    .word cpu_jsr, 0,  cpu_idx, cpu_and8,  cpu_jsle, 0,  cpu_drs, cpu_and8 // 0x20-0x23
    .word cpu_dir, cpu_bit8m,  cpu_dir, cpu_and8,  cpu_dir, cpu_rol8m,  cpu_idl, cpu_and8 // 0x24-0x27
    .word cpu_plp, 0,  cpu_im8, cpu_and8,  cpu_rol8, 0,  cpu_pld, 0 // 0x28-0x2B
    .word cpu_abs, cpu_bit8m,  cpu_abs, cpu_and8,  cpu_abs, cpu_rol8m,  cpu_lng, cpu_and8 // 0x2C-0x2F
    .word cpu_bmi, 0,  cpu_idy, cpu_and8,  cpu_ind, cpu_and8,  cpu_isy, cpu_and8 // 0x30-0x33
    .word cpu_drx, cpu_bit8m,  cpu_drx, cpu_and8,  cpu_drx, cpu_rol8m,  cpu_ily, cpu_and8 // 0x34-0x37
    .word cpu_sec, 0,  cpu_aby, cpu_and8,  cpu_dea8, 0,  cpu_tsc, 0 // 0x38-0x3B
    .word cpu_abx, cpu_bit8m,  cpu_abx, cpu_and8,  cpu_abx, cpu_rol8m,  cpu_lnx, cpu_and8 // 0x3C-0x3F
    .word cpu_rtie, 0,  cpu_idx, cpu_eor8,  cpu_wdm, 0,  cpu_drs, cpu_eor8 // 0x40-0x43
    .word cpu_mvp8, 0,  cpu_dir, cpu_eor8,  cpu_dir, cpu_lsr8m,  cpu_idl, cpu_eor8 // 0x44-0x47
    .word cpu_pha8, 0,  cpu_im8, cpu_eor8,  cpu_lsr8, 0,  cpu_phk, 0 // 0x48-0x4B
    .word cpu_jmp, 0,  cpu_abs, cpu_eor8,  cpu_abs, cpu_lsr8m,  cpu_lng, cpu_eor8 // 0x4C-0x4F
    .word cpu_bvc, 0,  cpu_idy, cpu_eor8,  cpu_ind, cpu_eor8,  cpu_isy, cpu_eor8 // 0x50-0x53
    .word cpu_mvn8, 0,  cpu_drx, cpu_eor8,  cpu_drx, cpu_lsr8m,  cpu_ily, cpu_eor8 // 0x54-0x57
    .word cpu_cli, 0,  cpu_aby, cpu_eor8,  cpu_phy8, 0,  cpu_tcd, 0 // 0x58-0x5B
    .word cpu_jmle, 0,  cpu_abx, cpu_eor8,  cpu_abx, cpu_lsr8m,  cpu_lnx, cpu_eor8 // 0x5C-0x5F
    .word cpu_rts, 0,  cpu_idx, cpu_adc8\d,  cpu_per, 0,  cpu_drs, cpu_adc8\d // 0x60-0x63
    .word cpu_dir, cpu_stz8,  cpu_dir, cpu_adc8\d,  cpu_dir, cpu_ror8m,  cpu_idl, cpu_adc8\d // 0x64-0x67
    .word cpu_pla8, 0,  cpu_im8, cpu_adc8\d,  cpu_ror8, 0,  cpu_rtle, 0 // 0x68-0x6B
    .word cpu_jmpi, 0,  cpu_abs, cpu_adc8\d,  cpu_abs, cpu_ror8m,  cpu_lng, cpu_adc8\d // 0x6C-0x6F
    .word cpu_bvs, 0,  cpu_idy, cpu_adc8\d,  cpu_ind, cpu_adc8\d,  cpu_isy, cpu_adc8\d // 0x70-0x73
    .word cpu_drx, cpu_stz8,  cpu_drx, cpu_adc8\d,  cpu_drx, cpu_ror8m,  cpu_ily, cpu_adc8\d // 0x74-0x77
    .word cpu_sei, 0,  cpu_aby, cpu_adc8\d,  cpu_ply8, 0,  cpu_tdc, 0 // 0x78-0x7B
    .word cpu_jmpx, 0,  cpu_abx, cpu_adc8\d,  cpu_abx, cpu_ror8m,  cpu_lnx, cpu_adc8\d // 0x7C-0x7F
    .word cpu_bra, 0,  cpu_idx, cpu_sta8,  cpu_brl, 0,  cpu_drs, cpu_sta8 // 0x80-0x83
    .word cpu_dir, cpu_sty8,  cpu_dir, cpu_sta8,  cpu_dir, cpu_stx8,  cpu_idl, cpu_sta8 // 0x84-0x87
    .word cpu_dey8, 0,  cpu_bit8, 0,  cpu_txa8, 0,  cpu_phb, 0 // 0x88-0x8B
    .word cpu_abs, cpu_sty8,  cpu_abs, cpu_sta8,  cpu_abs, cpu_stx8,  cpu_lng, cpu_sta8 // 0x8C-0x8F
    .word cpu_bcc, 0,  cpu_idy, cpu_sta8,  cpu_ind, cpu_sta8,  cpu_isy, cpu_sta8 // 0x90-0x93
    .word cpu_drx, cpu_sty8,  cpu_drx, cpu_sta8,  cpu_dry, cpu_stx8,  cpu_ily, cpu_sta8 // 0x94-0x97
    .word cpu_tya8, 0,  cpu_aby, cpu_sta8,  cpu_txse, 0,  cpu_txy8, 0 // 0x98-0x9B
    .word cpu_abs, cpu_stz8,  cpu_abx, cpu_sta8,  cpu_abx, cpu_stz8,  cpu_lnx, cpu_sta8 // 0x9C-0x9F
    .word cpu_im8, cpu_ldy8,  cpu_idx, cpu_lda8,  cpu_im8, cpu_ldx8,  cpu_drs, cpu_lda8 // 0xA0-0xA3
    .word cpu_dir, cpu_ldy8,  cpu_dir, cpu_lda8,  cpu_dir, cpu_ldx8,  cpu_idl, cpu_lda8 // 0xA4-0xA7
    .word cpu_tay8, 0,  cpu_im8, cpu_lda8,  cpu_tax8, 0,  cpu_plb, 0 // 0xA8-0xAB
    .word cpu_abs, cpu_ldy8,  cpu_abs, cpu_lda8,  cpu_abs, cpu_ldx8,  cpu_lng, cpu_lda8 // 0xAC-0xAF
    .word cpu_bcs, 0,  cpu_idy, cpu_lda8,  cpu_ind, cpu_lda8,  cpu_isy, cpu_lda8 // 0xB0-0xB3
    .word cpu_drx, cpu_ldy8,  cpu_drx, cpu_lda8,  cpu_dry, cpu_ldx8,  cpu_ily, cpu_lda8 // 0xB4-0xB7
    .word cpu_clv, 0,  cpu_aby, cpu_lda8,  cpu_tsx8, 0,  cpu_tyx8, 0 // 0xB8-0xBB
    .word cpu_abx, cpu_ldy8,  cpu_abx, cpu_lda8,  cpu_aby, cpu_ldx8,  cpu_lnx, cpu_lda8 // 0xBC-0xBF
    .word cpu_im8, cpu_cpy8,  cpu_idx, cpu_cmp8,  cpu_rep, 0,  cpu_drs, cpu_cmp8 // 0xC0-0xC3
    .word cpu_dir, cpu_cpy8,  cpu_dir, cpu_cmp8,  cpu_dir, cpu_dec8,  cpu_idl, cpu_cmp8 // 0xC4-0xC7
    .word cpu_iny8, 0,  cpu_im8, cpu_cmp8,  cpu_dex8, 0,  cpu_wai, 0 // 0xC8-0xCB
    .word cpu_abs, cpu_cpy8,  cpu_abs, cpu_cmp8,  cpu_abs, cpu_dec8,  cpu_lng, cpu_cmp8 // 0xCC-0xCF
    .word cpu_bne, 0,  cpu_idy, cpu_cmp8,  cpu_ind, cpu_cmp8,  cpu_isy, cpu_cmp8 // 0xD0-0xD3
    .word cpu_pei, 0,  cpu_drx, cpu_cmp8,  cpu_drx, cpu_dec8,  cpu_ily, cpu_cmp8 // 0xD4-0xD7
    .word cpu_cld, 0,  cpu_aby, cpu_cmp8,  cpu_phx8, 0,  cpu_stp, 0 // 0xD8-0xDB
    .word cpu_jmlie, 0,  cpu_abx, cpu_cmp8,  cpu_abx, cpu_dec8,  cpu_lnx, cpu_cmp8 // 0xDC-0xDF
    .word cpu_im8, cpu_cpx8,  cpu_idx, cpu_sbc8\d,  cpu_sep, 0,  cpu_drs, cpu_sbc8\d // 0xE0-0xE3
    .word cpu_dir, cpu_cpx8,  cpu_dir, cpu_sbc8\d,  cpu_dir, cpu_inc8,  cpu_idl, cpu_sbc8\d // 0xE4-0xE7
    .word cpu_inx8, 0,  cpu_im8, cpu_sbc8\d,  cpu_nop, 0,  cpu_xba, 0 // 0xE8-0xEB
    .word cpu_abs, cpu_cpx8,  cpu_abs, cpu_sbc8\d,  cpu_abs, cpu_inc8,  cpu_lng, cpu_sbc8\d // 0xEC-0xEF
    .word cpu_beq, 0,  cpu_idy, cpu_sbc8\d,  cpu_ind, cpu_sbc8\d,  cpu_isy, cpu_sbc8\d // 0xF0-0xF3
    .word cpu_pea, 0,  cpu_drx, cpu_sbc8\d,  cpu_drx, cpu_inc8,  cpu_ily, cpu_sbc8\d // 0xF4-0xF7
    .word cpu_sed, 0,  cpu_aby, cpu_sbc8\d,  cpu_plx8, 0,  cpu_xce, 0 // 0xF8-0xFB
    .word cpu_jsrx, 0,  cpu_abx, cpu_sbc8\d,  cpu_abx, cpu_inc8,  cpu_lnx, cpu_sbc8\d // 0xFC-0xFF
.endm

.macro OPS_8 d // Lookup table for full 8-bit mode
    .word cpu_brk, 0,  cpu_idx, cpu_ora8,  cpu_cop, 0,  cpu_drs, cpu_ora8 // 0x00-0x03
    .word cpu_dir, cpu_tsb8,  cpu_dir, cpu_ora8,  cpu_dir, cpu_asl8m,  cpu_idl, cpu_ora8 // 0x04-0x07
    .word cpu_php, 0,  cpu_im8, cpu_ora8,  cpu_asl8, 0,  cpu_phd, 0 // 0x08-0x0B
    .word cpu_abs, cpu_tsb8,  cpu_abs, cpu_ora8,  cpu_abs, cpu_asl8m,  cpu_lng, cpu_ora8 // 0x0C-0x0F
    .word cpu_bpl, 0,  cpu_idy, cpu_ora8,  cpu_ind, cpu_ora8,  cpu_isy, cpu_ora8 // 0x10-0x13
    .word cpu_dir, cpu_trb8,  cpu_drx, cpu_ora8,  cpu_drx, cpu_asl8m,  cpu_ily, cpu_ora8 // 0x14-0x17
    .word cpu_clc, 0,  cpu_aby, cpu_ora8,  cpu_ina8, 0,  cpu_tcs, 0 // 0x18-0x1B
    .word cpu_abs, cpu_trb8,  cpu_abx, cpu_ora8,  cpu_abx, cpu_asl8m,  cpu_lnx, cpu_ora8 // 0x1C-0x1F
    .word cpu_jsr, 0,  cpu_idx, cpu_and8,  cpu_jsl, 0,  cpu_drs, cpu_and8 // 0x20-0x23
    .word cpu_dir, cpu_bit8m,  cpu_dir, cpu_and8,  cpu_dir, cpu_rol8m,  cpu_idl, cpu_and8 // 0x24-0x27
    .word cpu_plp, 0,  cpu_im8, cpu_and8,  cpu_rol8, 0,  cpu_pld, 0 // 0x28-0x2B
    .word cpu_abs, cpu_bit8m,  cpu_abs, cpu_and8,  cpu_abs, cpu_rol8m,  cpu_lng, cpu_and8 // 0x2C-0x2F
    .word cpu_bmi, 0,  cpu_idy, cpu_and8,  cpu_ind, cpu_and8,  cpu_isy, cpu_and8 // 0x30-0x33
    .word cpu_drx, cpu_bit8m,  cpu_drx, cpu_and8,  cpu_drx, cpu_rol8m,  cpu_ily, cpu_and8 // 0x34-0x37
    .word cpu_sec, 0,  cpu_aby, cpu_and8,  cpu_dea8, 0,  cpu_tsc, 0 // 0x38-0x3B
    .word cpu_abx, cpu_bit8m,  cpu_abx, cpu_and8,  cpu_abx, cpu_rol8m,  cpu_lnx, cpu_and8 // 0x3C-0x3F
    .word cpu_rti, 0,  cpu_idx, cpu_eor8,  cpu_wdm, 0,  cpu_drs, cpu_eor8 // 0x40-0x43
    .word cpu_mvp8, 0,  cpu_dir, cpu_eor8,  cpu_dir, cpu_lsr8m,  cpu_idl, cpu_eor8 // 0x44-0x47
    .word cpu_pha8, 0,  cpu_im8, cpu_eor8,  cpu_lsr8, 0,  cpu_phk, 0 // 0x48-0x4B
    .word cpu_jmp, 0,  cpu_abs, cpu_eor8,  cpu_abs, cpu_lsr8m,  cpu_lng, cpu_eor8 // 0x4C-0x4F
    .word cpu_bvc, 0,  cpu_idy, cpu_eor8,  cpu_ind, cpu_eor8,  cpu_isy, cpu_eor8 // 0x50-0x53
    .word cpu_mvn8, 0,  cpu_drx, cpu_eor8,  cpu_drx, cpu_lsr8m,  cpu_ily, cpu_eor8 // 0x54-0x57
    .word cpu_cli, 0,  cpu_aby, cpu_eor8,  cpu_phy8, 0,  cpu_tcd, 0 // 0x58-0x5B
    .word cpu_jml, 0,  cpu_abx, cpu_eor8,  cpu_abx, cpu_lsr8m,  cpu_lnx, cpu_eor8 // 0x5C-0x5F
    .word cpu_rts, 0,  cpu_idx, cpu_adc8\d,  cpu_per, 0,  cpu_drs, cpu_adc8\d // 0x60-0x63
    .word cpu_dir, cpu_stz8,  cpu_dir, cpu_adc8\d,  cpu_dir, cpu_ror8m,  cpu_idl, cpu_adc8\d // 0x64-0x67
    .word cpu_pla8, 0,  cpu_im8, cpu_adc8\d,  cpu_ror8, 0,  cpu_rtl, 0 // 0x68-0x6B
    .word cpu_jmpi, 0,  cpu_abs, cpu_adc8\d,  cpu_abs, cpu_ror8m,  cpu_lng, cpu_adc8\d // 0x6C-0x6F
    .word cpu_bvs, 0,  cpu_idy, cpu_adc8\d,  cpu_ind, cpu_adc8\d,  cpu_isy, cpu_adc8\d // 0x70-0x73
    .word cpu_drx, cpu_stz8,  cpu_drx, cpu_adc8\d,  cpu_drx, cpu_ror8m,  cpu_ily, cpu_adc8\d // 0x74-0x77
    .word cpu_sei, 0,  cpu_aby, cpu_adc8\d,  cpu_ply8, 0,  cpu_tdc, 0 // 0x78-0x7B
    .word cpu_jmpx, 0,  cpu_abx, cpu_adc8\d,  cpu_abx, cpu_ror8m,  cpu_lnx, cpu_adc8\d // 0x7C-0x7F
    .word cpu_bra, 0,  cpu_idx, cpu_sta8,  cpu_brl, 0,  cpu_drs, cpu_sta8 // 0x80-0x83
    .word cpu_dir, cpu_sty8,  cpu_dir, cpu_sta8,  cpu_dir, cpu_stx8,  cpu_idl, cpu_sta8 // 0x84-0x87
    .word cpu_dey8, 0,  cpu_bit8, 0,  cpu_txa8, 0,  cpu_phb, 0 // 0x88-0x8B
    .word cpu_abs, cpu_sty8,  cpu_abs, cpu_sta8,  cpu_abs, cpu_stx8,  cpu_lng, cpu_sta8 // 0x8C-0x8F
    .word cpu_bcc, 0,  cpu_idy, cpu_sta8,  cpu_ind, cpu_sta8,  cpu_isy, cpu_sta8 // 0x90-0x93
    .word cpu_drx, cpu_sty8,  cpu_drx, cpu_sta8,  cpu_dry, cpu_stx8,  cpu_ily, cpu_sta8 // 0x94-0x97
    .word cpu_tya8, 0,  cpu_aby, cpu_sta8,  cpu_txs, 0,  cpu_txy8, 0 // 0x98-0x9B
    .word cpu_abs, cpu_stz8,  cpu_abx, cpu_sta8,  cpu_abx, cpu_stz8,  cpu_lnx, cpu_sta8 // 0x9C-0x9F
    .word cpu_im8, cpu_ldy8,  cpu_idx, cpu_lda8,  cpu_im8, cpu_ldx8,  cpu_drs, cpu_lda8 // 0xA0-0xA3
    .word cpu_dir, cpu_ldy8,  cpu_dir, cpu_lda8,  cpu_dir, cpu_ldx8,  cpu_idl, cpu_lda8 // 0xA4-0xA7
    .word cpu_tay8, 0,  cpu_im8, cpu_lda8,  cpu_tax8, 0,  cpu_plb, 0 // 0xA8-0xAB
    .word cpu_abs, cpu_ldy8,  cpu_abs, cpu_lda8,  cpu_abs, cpu_ldx8,  cpu_lng, cpu_lda8 // 0xAC-0xAF
    .word cpu_bcs, 0,  cpu_idy, cpu_lda8,  cpu_ind, cpu_lda8,  cpu_isy, cpu_lda8 // 0xB0-0xB3
    .word cpu_drx, cpu_ldy8,  cpu_drx, cpu_lda8,  cpu_dry, cpu_ldx8,  cpu_ily, cpu_lda8 // 0xB4-0xB7
    .word cpu_clv, 0,  cpu_aby, cpu_lda8,  cpu_tsx8, 0,  cpu_tyx8, 0 // 0xB8-0xBB
    .word cpu_abx, cpu_ldy8,  cpu_abx, cpu_lda8,  cpu_aby, cpu_ldx8,  cpu_lnx, cpu_lda8 // 0xBC-0xBF
    .word cpu_im8, cpu_cpy8,  cpu_idx, cpu_cmp8,  cpu_rep, 0,  cpu_drs, cpu_cmp8 // 0xC0-0xC3
    .word cpu_dir, cpu_cpy8,  cpu_dir, cpu_cmp8,  cpu_dir, cpu_dec8,  cpu_idl, cpu_cmp8 // 0xC4-0xC7
    .word cpu_iny8, 0,  cpu_im8, cpu_cmp8,  cpu_dex8, 0,  cpu_wai, 0 // 0xC8-0xCB
    .word cpu_abs, cpu_cpy8,  cpu_abs, cpu_cmp8,  cpu_abs, cpu_dec8,  cpu_lng, cpu_cmp8 // 0xCC-0xCF
    .word cpu_bne, 0,  cpu_idy, cpu_cmp8,  cpu_ind, cpu_cmp8,  cpu_isy, cpu_cmp8 // 0xD0-0xD3
    .word cpu_pei, 0,  cpu_drx, cpu_cmp8,  cpu_drx, cpu_dec8,  cpu_ily, cpu_cmp8 // 0xD4-0xD7
    .word cpu_cld, 0,  cpu_aby, cpu_cmp8,  cpu_phx8, 0,  cpu_stp, 0 // 0xD8-0xDB
    .word cpu_jmli, 0,  cpu_abx, cpu_cmp8,  cpu_abx, cpu_dec8,  cpu_lnx, cpu_cmp8 // 0xDC-0xDF
    .word cpu_im8, cpu_cpx8,  cpu_idx, cpu_sbc8\d,  cpu_sep, 0,  cpu_drs, cpu_sbc8\d // 0xE0-0xE3
    .word cpu_dir, cpu_cpx8,  cpu_dir, cpu_sbc8\d,  cpu_dir, cpu_inc8,  cpu_idl, cpu_sbc8\d // 0xE4-0xE7
    .word cpu_inx8, 0,  cpu_im8, cpu_sbc8\d,  cpu_nop, 0,  cpu_xba, 0 // 0xE8-0xEB
    .word cpu_abs, cpu_cpx8,  cpu_abs, cpu_sbc8\d,  cpu_abs, cpu_inc8,  cpu_lng, cpu_sbc8\d // 0xEC-0xEF
    .word cpu_beq, 0,  cpu_idy, cpu_sbc8\d,  cpu_ind, cpu_sbc8\d,  cpu_isy, cpu_sbc8\d // 0xF0-0xF3
    .word cpu_pea, 0,  cpu_drx, cpu_sbc8\d,  cpu_drx, cpu_inc8,  cpu_ily, cpu_sbc8\d // 0xF4-0xF7
    .word cpu_sed, 0,  cpu_aby, cpu_sbc8\d,  cpu_plx8, 0,  cpu_xce, 0 // 0xF8-0xFB
    .word cpu_jsrx, 0,  cpu_abx, cpu_sbc8\d,  cpu_abx, cpu_inc8,  cpu_lnx, cpu_sbc8\d // 0xFC-0xFF
.endm

.macro OPS_R8 d // Lookup table for 8-bit register mode
    .word cpu_brk, 0,  cpu_idx, cpu_ora16,  cpu_cop, 0,  cpu_drs, cpu_ora16 // 0x00-0x03
    .word cpu_dir, cpu_tsb16,  cpu_dir, cpu_ora16,  cpu_dir, cpu_asl16m,  cpu_idl, cpu_ora16 // 0x04-0x07
    .word cpu_php, 0,  cpu_i16, cpu_ora16,  cpu_asl16, 0,  cpu_phd, 0 // 0x08-0x0B
    .word cpu_abs, cpu_tsb16,  cpu_abs, cpu_ora16,  cpu_abs, cpu_asl16m,  cpu_lng, cpu_ora16 // 0x0C-0x0F
    .word cpu_bpl, 0,  cpu_idy, cpu_ora16,  cpu_ind, cpu_ora16,  cpu_isy, cpu_ora16 // 0x10-0x13
    .word cpu_dir, cpu_trb16,  cpu_drx, cpu_ora16,  cpu_drx, cpu_asl16m,  cpu_ily, cpu_ora16 // 0x14-0x17
    .word cpu_clc, 0,  cpu_aby, cpu_ora16,  cpu_ina16, 0,  cpu_tcs, 0 // 0x18-0x1B
    .word cpu_abs, cpu_trb16,  cpu_abx, cpu_ora16,  cpu_abx, cpu_asl16m,  cpu_lnx, cpu_ora16 // 0x1C-0x1F
    .word cpu_jsr, 0,  cpu_idx, cpu_and16,  cpu_jsl, 0,  cpu_drs, cpu_and16 // 0x20-0x23
    .word cpu_dir, cpu_bit16m,  cpu_dir, cpu_and16,  cpu_dir, cpu_rol16m,  cpu_idl, cpu_and16 // 0x24-0x27
    .word cpu_plp, 0,  cpu_i16, cpu_and16,  cpu_rol16, 0,  cpu_pld, 0 // 0x28-0x2B
    .word cpu_abs, cpu_bit16m,  cpu_abs, cpu_and16,  cpu_abs, cpu_rol16m,  cpu_lng, cpu_and16 // 0x2C-0x2F
    .word cpu_bmi, 0,  cpu_idy, cpu_and16,  cpu_ind, cpu_and16,  cpu_isy, cpu_and16 // 0x30-0x33
    .word cpu_drx, cpu_bit16m,  cpu_drx, cpu_and16,  cpu_drx, cpu_rol16m,  cpu_ily, cpu_and16 // 0x34-0x37
    .word cpu_sec, 0,  cpu_aby, cpu_and16,  cpu_dea16, 0,  cpu_tsc, 0 // 0x38-0x3B
    .word cpu_abx, cpu_bit16m,  cpu_abx, cpu_and16,  cpu_abx, cpu_rol16m,  cpu_lnx, cpu_and16 // 0x3C-0x3F
    .word cpu_rti, 0,  cpu_idx, cpu_eor16,  cpu_wdm, 0,  cpu_drs, cpu_eor16 // 0x40-0x43
    .word cpu_mvp8, 0,  cpu_dir, cpu_eor16,  cpu_dir, cpu_lsr16m,  cpu_idl, cpu_eor16 // 0x44-0x47
    .word cpu_pha16, 0,  cpu_i16, cpu_eor16,  cpu_lsr16, 0,  cpu_phk, 0 // 0x48-0x4B
    .word cpu_jmp, 0,  cpu_abs, cpu_eor16,  cpu_abs, cpu_lsr16m,  cpu_lng, cpu_eor16 // 0x4C-0x4F
    .word cpu_bvc, 0,  cpu_idy, cpu_eor16,  cpu_ind, cpu_eor16,  cpu_isy, cpu_eor16 // 0x50-0x53
    .word cpu_mvn8, 0,  cpu_drx, cpu_eor16,  cpu_drx, cpu_lsr16m,  cpu_ily, cpu_eor16 // 0x54-0x57
    .word cpu_cli, 0,  cpu_aby, cpu_eor16,  cpu_phy8, 0,  cpu_tcd, 0 // 0x58-0x5B
    .word cpu_jml, 0,  cpu_abx, cpu_eor16,  cpu_abx, cpu_lsr16m,  cpu_lnx, cpu_eor16 // 0x5C-0x5F
    .word cpu_rts, 0,  cpu_idx, cpu_adc16\d,  cpu_per, 0,  cpu_drs, cpu_adc16\d // 0x60-0x63
    .word cpu_dir, cpu_stz16,  cpu_dir, cpu_adc16\d,  cpu_dir, cpu_ror16m,  cpu_idl, cpu_adc16\d // 0x64-0x67
    .word cpu_pla16, 0,  cpu_i16, cpu_adc16\d,  cpu_ror16, 0,  cpu_rtl, 0 // 0x68-0x6B
    .word cpu_jmpi, 0,  cpu_abs, cpu_adc16\d,  cpu_abs, cpu_ror16m,  cpu_lng, cpu_adc16\d // 0x6C-0x6F
    .word cpu_bvs, 0,  cpu_idy, cpu_adc16\d,  cpu_ind, cpu_adc16\d,  cpu_isy, cpu_adc16\d // 0x70-0x73
    .word cpu_drx, cpu_stz16,  cpu_drx, cpu_adc16\d,  cpu_drx, cpu_ror16m,  cpu_ily, cpu_adc16\d // 0x74-0x77
    .word cpu_sei, 0,  cpu_aby, cpu_adc16\d,  cpu_ply8, 0,  cpu_tdc, 0 // 0x78-0x7B
    .word cpu_jmpx, 0,  cpu_abx, cpu_adc16\d,  cpu_abx, cpu_ror16m,  cpu_lnx, cpu_adc16\d // 0x7C-0x7F
    .word cpu_bra, 0,  cpu_idx, cpu_sta16,  cpu_brl, 0,  cpu_drs, cpu_sta16 // 0x80-0x83
    .word cpu_dir, cpu_sty8,  cpu_dir, cpu_sta16,  cpu_dir, cpu_stx8,  cpu_idl, cpu_sta16 // 0x84-0x87
    .word cpu_dey8, 0,  cpu_bit16, 0,  cpu_txa16, 0,  cpu_phb, 0 // 0x88-0x8B
    .word cpu_abs, cpu_sty8,  cpu_abs, cpu_sta16,  cpu_abs, cpu_stx8,  cpu_lng, cpu_sta16 // 0x8C-0x8F
    .word cpu_bcc, 0,  cpu_idy, cpu_sta16,  cpu_ind, cpu_sta16,  cpu_isy, cpu_sta16 // 0x90-0x93
    .word cpu_drx, cpu_sty8,  cpu_drx, cpu_sta16,  cpu_dry, cpu_stx8,  cpu_ily, cpu_sta16 // 0x94-0x97
    .word cpu_tya16, 0,  cpu_aby, cpu_sta16,  cpu_txs, 0,  cpu_txy8, 0 // 0x98-0x9B
    .word cpu_abs, cpu_stz16,  cpu_abx, cpu_sta16,  cpu_abx, cpu_stz16,  cpu_lnx, cpu_sta16 // 0x9C-0x9F
    .word cpu_im8, cpu_ldy8,  cpu_idx, cpu_lda16,  cpu_im8, cpu_ldx8,  cpu_drs, cpu_lda16 // 0xA0-0xA3
    .word cpu_dir, cpu_ldy8,  cpu_dir, cpu_lda16,  cpu_dir, cpu_ldx8,  cpu_idl, cpu_lda16 // 0xA4-0xA7
    .word cpu_tay8, 0,  cpu_i16, cpu_lda16,  cpu_tax8, 0,  cpu_plb, 0 // 0xA8-0xAB
    .word cpu_abs, cpu_ldy8,  cpu_abs, cpu_lda16,  cpu_abs, cpu_ldx8,  cpu_lng, cpu_lda16 // 0xAC-0xAF
    .word cpu_bcs, 0,  cpu_idy, cpu_lda16,  cpu_ind, cpu_lda16,  cpu_isy, cpu_lda16 // 0xB0-0xB3
    .word cpu_drx, cpu_ldy8,  cpu_drx, cpu_lda16,  cpu_dry, cpu_ldx8,  cpu_ily, cpu_lda16 // 0xB4-0xB7
    .word cpu_clv, 0,  cpu_aby, cpu_lda16,  cpu_tsx8, 0,  cpu_tyx8, 0 // 0xB8-0xBB
    .word cpu_abx, cpu_ldy8,  cpu_abx, cpu_lda16,  cpu_aby, cpu_ldx8,  cpu_lnx, cpu_lda16 // 0xBC-0xBF
    .word cpu_im8, cpu_cpy8,  cpu_idx, cpu_cmp16,  cpu_rep, 0,  cpu_drs, cpu_cmp16 // 0xC0-0xC3
    .word cpu_dir, cpu_cpy8,  cpu_dir, cpu_cmp16,  cpu_dir, cpu_dec16,  cpu_idl, cpu_cmp16 // 0xC4-0xC7
    .word cpu_iny8, 0,  cpu_i16, cpu_cmp16,  cpu_dex8, 0,  cpu_wai, 0 // 0xC8-0xCB
    .word cpu_abs, cpu_cpy8,  cpu_abs, cpu_cmp16,  cpu_abs, cpu_dec16,  cpu_lng, cpu_cmp16 // 0xCC-0xCF
    .word cpu_bne, 0,  cpu_idy, cpu_cmp16,  cpu_ind, cpu_cmp16,  cpu_isy, cpu_cmp16 // 0xD0-0xD3
    .word cpu_pei, 0,  cpu_drx, cpu_cmp16,  cpu_drx, cpu_dec16,  cpu_ily, cpu_cmp16 // 0xD4-0xD7
    .word cpu_cld, 0,  cpu_aby, cpu_cmp16,  cpu_phx8, 0,  cpu_stp, 0 // 0xD8-0xDB
    .word cpu_jmli, 0,  cpu_abx, cpu_cmp16,  cpu_abx, cpu_dec16,  cpu_lnx, cpu_cmp16 // 0xDC-0xDF
    .word cpu_im8, cpu_cpx8,  cpu_idx, cpu_sbc16\d,  cpu_sep, 0,  cpu_drs, cpu_sbc16\d // 0xE0-0xE3
    .word cpu_dir, cpu_cpx8,  cpu_dir, cpu_sbc16\d,  cpu_dir, cpu_inc16,  cpu_idl, cpu_sbc16\d // 0xE4-0xE7
    .word cpu_inx8, 0,  cpu_i16, cpu_sbc16\d,  cpu_nop, 0,  cpu_xba, 0 // 0xE8-0xEB
    .word cpu_abs, cpu_cpx8,  cpu_abs, cpu_sbc16\d,  cpu_abs, cpu_inc16,  cpu_lng, cpu_sbc16\d // 0xEC-0xEF
    .word cpu_beq, 0,  cpu_idy, cpu_sbc16\d,  cpu_ind, cpu_sbc16\d,  cpu_isy, cpu_sbc16\d // 0xF0-0xF3
    .word cpu_pea, 0,  cpu_drx, cpu_sbc16\d,  cpu_drx, cpu_inc16,  cpu_ily, cpu_sbc16\d // 0xF4-0xF7
    .word cpu_sed, 0,  cpu_aby, cpu_sbc16\d,  cpu_plx8, 0,  cpu_xce, 0 // 0xF8-0xFB
    .word cpu_jsrx, 0,  cpu_abx, cpu_sbc16\d,  cpu_abx, cpu_inc16,  cpu_lnx, cpu_sbc16\d // 0xFC-0xFF
.endm

.macro OPS_A8 d // Lookup table for 8-bit accumulator mode
    .word cpu_brk, 0,  cpu_idx, cpu_ora8,  cpu_cop, 0,  cpu_drs, cpu_ora8 // 0x00-0x03
    .word cpu_dir, cpu_tsb8,  cpu_dir, cpu_ora8,  cpu_dir, cpu_asl8m,  cpu_idl, cpu_ora8 // 0x04-0x07
    .word cpu_php, 0,  cpu_im8, cpu_ora8,  cpu_asl8, 0,  cpu_phd, 0 // 0x08-0x0B
    .word cpu_abs, cpu_tsb8,  cpu_abs, cpu_ora8,  cpu_abs, cpu_asl8m,  cpu_lng, cpu_ora8 // 0x0C-0x0F
    .word cpu_bpl, 0,  cpu_idy, cpu_ora8,  cpu_ind, cpu_ora8,  cpu_isy, cpu_ora8 // 0x10-0x13
    .word cpu_dir, cpu_trb8,  cpu_drx, cpu_ora8,  cpu_drx, cpu_asl8m,  cpu_ily, cpu_ora8 // 0x14-0x17
    .word cpu_clc, 0,  cpu_aby, cpu_ora8,  cpu_ina8, 0,  cpu_tcs, 0 // 0x18-0x1B
    .word cpu_abs, cpu_trb8,  cpu_abx, cpu_ora8,  cpu_abx, cpu_asl8m,  cpu_lnx, cpu_ora8 // 0x1C-0x1F
    .word cpu_jsr, 0,  cpu_idx, cpu_and8,  cpu_jsl, 0,  cpu_drs, cpu_and8 // 0x20-0x23
    .word cpu_dir, cpu_bit8m,  cpu_dir, cpu_and8,  cpu_dir, cpu_rol8m,  cpu_idl, cpu_and8 // 0x24-0x27
    .word cpu_plp, 0,  cpu_im8, cpu_and8,  cpu_rol8, 0,  cpu_pld, 0 // 0x28-0x2B
    .word cpu_abs, cpu_bit8m,  cpu_abs, cpu_and8,  cpu_abs, cpu_rol8m,  cpu_lng, cpu_and8 // 0x2C-0x2F
    .word cpu_bmi, 0,  cpu_idy, cpu_and8,  cpu_ind, cpu_and8,  cpu_isy, cpu_and8 // 0x30-0x33
    .word cpu_drx, cpu_bit8m,  cpu_drx, cpu_and8,  cpu_drx, cpu_rol8m,  cpu_ily, cpu_and8 // 0x34-0x37
    .word cpu_sec, 0,  cpu_aby, cpu_and8,  cpu_dea8, 0,  cpu_tsc, 0 // 0x38-0x3B
    .word cpu_abx, cpu_bit8m,  cpu_abx, cpu_and8,  cpu_abx, cpu_rol8m,  cpu_lnx, cpu_and8 // 0x3C-0x3F
    .word cpu_rti, 0,  cpu_idx, cpu_eor8,  cpu_wdm, 0,  cpu_drs, cpu_eor8 // 0x40-0x43
    .word cpu_mvp16, 0,  cpu_dir, cpu_eor8,  cpu_dir, cpu_lsr8m,  cpu_idl, cpu_eor8 // 0x44-0x47
    .word cpu_pha8, 0,  cpu_im8, cpu_eor8,  cpu_lsr8, 0,  cpu_phk, 0 // 0x48-0x4B
    .word cpu_jmp, 0,  cpu_abs, cpu_eor8,  cpu_abs, cpu_lsr8m,  cpu_lng, cpu_eor8 // 0x4C-0x4F
    .word cpu_bvc, 0,  cpu_idy, cpu_eor8,  cpu_ind, cpu_eor8,  cpu_isy, cpu_eor8 // 0x50-0x53
    .word cpu_mvn16, 0,  cpu_drx, cpu_eor8,  cpu_drx, cpu_lsr8m,  cpu_ily, cpu_eor8 // 0x54-0x57
    .word cpu_cli, 0,  cpu_aby, cpu_eor8,  cpu_phy16, 0,  cpu_tcd, 0 // 0x58-0x5B
    .word cpu_jml, 0,  cpu_abx, cpu_eor8,  cpu_abx, cpu_lsr8m,  cpu_lnx, cpu_eor8 // 0x5C-0x5F
    .word cpu_rts, 0,  cpu_idx, cpu_adc8\d,  cpu_per, 0,  cpu_drs, cpu_adc8\d // 0x60-0x63
    .word cpu_dir, cpu_stz8,  cpu_dir, cpu_adc8\d,  cpu_dir, cpu_ror8m,  cpu_idl, cpu_adc8\d // 0x64-0x67
    .word cpu_pla8, 0,  cpu_im8, cpu_adc8\d,  cpu_ror8, 0,  cpu_rtl, 0 // 0x68-0x6B
    .word cpu_jmpi, 0,  cpu_abs, cpu_adc8\d,  cpu_abs, cpu_ror8m,  cpu_lng, cpu_adc8\d // 0x6C-0x6F
    .word cpu_bvs, 0,  cpu_idy, cpu_adc8\d,  cpu_ind, cpu_adc8\d,  cpu_isy, cpu_adc8\d // 0x70-0x73
    .word cpu_drx, cpu_stz8,  cpu_drx, cpu_adc8\d,  cpu_drx, cpu_ror8m,  cpu_ily, cpu_adc8\d // 0x74-0x77
    .word cpu_sei, 0,  cpu_aby, cpu_adc8\d,  cpu_ply16, 0,  cpu_tdc, 0 // 0x78-0x7B
    .word cpu_jmpx, 0,  cpu_abx, cpu_adc8\d,  cpu_abx, cpu_ror8m,  cpu_lnx, cpu_adc8\d // 0x7C-0x7F
    .word cpu_bra, 0,  cpu_idx, cpu_sta8,  cpu_brl, 0,  cpu_drs, cpu_sta8 // 0x80-0x83
    .word cpu_dir, cpu_sty16,  cpu_dir, cpu_sta8,  cpu_dir, cpu_stx16,  cpu_idl, cpu_sta8 // 0x84-0x87
    .word cpu_dey16, 0,  cpu_bit8, 0,  cpu_txa8, 0,  cpu_phb, 0 // 0x88-0x8B
    .word cpu_abs, cpu_sty16,  cpu_abs, cpu_sta8,  cpu_abs, cpu_stx16,  cpu_lng, cpu_sta8 // 0x8C-0x8F
    .word cpu_bcc, 0,  cpu_idy, cpu_sta8,  cpu_ind, cpu_sta8,  cpu_isy, cpu_sta8 // 0x90-0x93
    .word cpu_drx, cpu_sty16,  cpu_drx, cpu_sta8,  cpu_dry, cpu_stx16,  cpu_ily, cpu_sta8 // 0x94-0x97
    .word cpu_tya8, 0,  cpu_aby, cpu_sta8,  cpu_txs, 0,  cpu_txy16, 0 // 0x98-0x9B
    .word cpu_abs, cpu_stz8,  cpu_abx, cpu_sta8,  cpu_abx, cpu_stz8,  cpu_lnx, cpu_sta8 // 0x9C-0x9F
    .word cpu_i16, cpu_ldy16,  cpu_idx, cpu_lda8,  cpu_i16, cpu_ldx16,  cpu_drs, cpu_lda8 // 0xA0-0xA3
    .word cpu_dir, cpu_ldy16,  cpu_dir, cpu_lda8,  cpu_dir, cpu_ldx16,  cpu_idl, cpu_lda8 // 0xA4-0xA7
    .word cpu_tay16, 0,  cpu_im8, cpu_lda8,  cpu_tax16, 0,  cpu_plb, 0 // 0xA8-0xAB
    .word cpu_abs, cpu_ldy16,  cpu_abs, cpu_lda8,  cpu_abs, cpu_ldx16,  cpu_lng, cpu_lda8 // 0xAC-0xAF
    .word cpu_bcs, 0,  cpu_idy, cpu_lda8,  cpu_ind, cpu_lda8,  cpu_isy, cpu_lda8 // 0xB0-0xB3
    .word cpu_drx, cpu_ldy16,  cpu_drx, cpu_lda8,  cpu_dry, cpu_ldx16,  cpu_ily, cpu_lda8 // 0xB4-0xB7
    .word cpu_clv, 0,  cpu_aby, cpu_lda8,  cpu_tsx16, 0,  cpu_tyx16, 0 // 0xB8-0xBB
    .word cpu_abx, cpu_ldy16,  cpu_abx, cpu_lda8,  cpu_aby, cpu_ldx16,  cpu_lnx, cpu_lda8 // 0xBC-0xBF
    .word cpu_i16, cpu_cpy16,  cpu_idx, cpu_cmp8,  cpu_rep, 0,  cpu_drs, cpu_cmp8 // 0xC0-0xC3
    .word cpu_dir, cpu_cpy16,  cpu_dir, cpu_cmp8,  cpu_dir, cpu_dec8,  cpu_idl, cpu_cmp8 // 0xC4-0xC7
    .word cpu_iny16, 0,  cpu_im8, cpu_cmp8,  cpu_dex16, 0,  cpu_wai, 0 // 0xC8-0xCB
    .word cpu_abs, cpu_cpy16,  cpu_abs, cpu_cmp8,  cpu_abs, cpu_dec8,  cpu_lng, cpu_cmp8 // 0xCC-0xCF
    .word cpu_bne, 0,  cpu_idy, cpu_cmp8,  cpu_ind, cpu_cmp8,  cpu_isy, cpu_cmp8 // 0xD0-0xD3
    .word cpu_pei, 0,  cpu_drx, cpu_cmp8,  cpu_drx, cpu_dec8,  cpu_ily, cpu_cmp8 // 0xD4-0xD7
    .word cpu_cld, 0,  cpu_aby, cpu_cmp8,  cpu_phx16, 0,  cpu_stp, 0 // 0xD8-0xDB
    .word cpu_jmli, 0,  cpu_abx, cpu_cmp8,  cpu_abx, cpu_dec8,  cpu_lnx, cpu_cmp8 // 0xDC-0xDF
    .word cpu_i16, cpu_cpx16,  cpu_idx, cpu_sbc8\d,  cpu_sep, 0,  cpu_drs, cpu_sbc8\d // 0xE0-0xE3
    .word cpu_dir, cpu_cpx16,  cpu_dir, cpu_sbc8\d,  cpu_dir, cpu_inc8,  cpu_idl, cpu_sbc8\d // 0xE4-0xE7
    .word cpu_inx16, 0,  cpu_im8, cpu_sbc8\d,  cpu_nop, 0,  cpu_xba, 0 // 0xE8-0xEB
    .word cpu_abs, cpu_cpx16,  cpu_abs, cpu_sbc8\d,  cpu_abs, cpu_inc8,  cpu_lng, cpu_sbc8\d // 0xEC-0xEF
    .word cpu_beq, 0,  cpu_idy, cpu_sbc8\d,  cpu_ind, cpu_sbc8\d,  cpu_isy, cpu_sbc8\d // 0xF0-0xF3
    .word cpu_pea, 0,  cpu_drx, cpu_sbc8\d,  cpu_drx, cpu_inc8,  cpu_ily, cpu_sbc8\d // 0xF4-0xF7
    .word cpu_sed, 0,  cpu_aby, cpu_sbc8\d,  cpu_plx16, 0,  cpu_xce, 0 // 0xF8-0xFB
    .word cpu_jsrx, 0,  cpu_abx, cpu_sbc8\d,  cpu_abx, cpu_inc8,  cpu_lnx, cpu_sbc8\d // 0xFC-0xFF
.endm

.macro OPS_16 d // Lookup table for 16-bit mode
    .word cpu_brk, 0,  cpu_idx, cpu_ora16,  cpu_cop, 0,  cpu_drs, cpu_ora16 // 0x00-0x03
    .word cpu_dir, cpu_tsb16,  cpu_dir, cpu_ora16,  cpu_dir, cpu_asl16m,  cpu_idl, cpu_ora16 // 0x04-0x07
    .word cpu_php, 0,  cpu_i16, cpu_ora16,  cpu_asl16, 0,  cpu_phd, 0 // 0x08-0x0B
    .word cpu_abs, cpu_tsb16,  cpu_abs, cpu_ora16,  cpu_abs, cpu_asl16m,  cpu_lng, cpu_ora16 // 0x0C-0x0F
    .word cpu_bpl, 0,  cpu_idy, cpu_ora16,  cpu_ind, cpu_ora16,  cpu_isy, cpu_ora16 // 0x10-0x13
    .word cpu_dir, cpu_trb16,  cpu_drx, cpu_ora16,  cpu_drx, cpu_asl16m,  cpu_ily, cpu_ora16 // 0x14-0x17
    .word cpu_clc, 0,  cpu_aby, cpu_ora16,  cpu_ina16, 0,  cpu_tcs, 0 // 0x18-0x1B
    .word cpu_abs, cpu_trb16,  cpu_abx, cpu_ora16,  cpu_abx, cpu_asl16m,  cpu_lnx, cpu_ora16 // 0x1C-0x1F
    .word cpu_jsr, 0,  cpu_idx, cpu_and16,  cpu_jsl, 0,  cpu_drs, cpu_and16 // 0x20-0x23
    .word cpu_dir, cpu_bit16m,  cpu_dir, cpu_and16,  cpu_dir, cpu_rol16m,  cpu_idl, cpu_and16 // 0x24-0x27
    .word cpu_plp, 0,  cpu_i16, cpu_and16,  cpu_rol16, 0,  cpu_pld, 0 // 0x28-0x2B
    .word cpu_abs, cpu_bit16m,  cpu_abs, cpu_and16,  cpu_abs, cpu_rol16m,  cpu_lng, cpu_and16 // 0x2C-0x2F
    .word cpu_bmi, 0,  cpu_idy, cpu_and16,  cpu_ind, cpu_and16,  cpu_isy, cpu_and16 // 0x30-0x33
    .word cpu_drx, cpu_bit16m,  cpu_drx, cpu_and16,  cpu_drx, cpu_rol16m,  cpu_ily, cpu_and16 // 0x34-0x37
    .word cpu_sec, 0,  cpu_aby, cpu_and16,  cpu_dea16, 0,  cpu_tsc, 0 // 0x38-0x3B
    .word cpu_abx, cpu_bit16m,  cpu_abx, cpu_and16,  cpu_abx, cpu_rol16m,  cpu_lnx, cpu_and16 // 0x3C-0x3F
    .word cpu_rti, 0,  cpu_idx, cpu_eor16,  cpu_wdm, 0,  cpu_drs, cpu_eor16 // 0x40-0x43
    .word cpu_mvp16, 0,  cpu_dir, cpu_eor16,  cpu_dir, cpu_lsr16m,  cpu_idl, cpu_eor16 // 0x44-0x47
    .word cpu_pha16, 0,  cpu_i16, cpu_eor16,  cpu_lsr16, 0,  cpu_phk, 0 // 0x48-0x4B
    .word cpu_jmp, 0,  cpu_abs, cpu_eor16,  cpu_abs, cpu_lsr16m,  cpu_lng, cpu_eor16 // 0x4C-0x4F
    .word cpu_bvc, 0,  cpu_idy, cpu_eor16,  cpu_ind, cpu_eor16,  cpu_isy, cpu_eor16 // 0x50-0x53
    .word cpu_mvn16, 0,  cpu_drx, cpu_eor16,  cpu_drx, cpu_lsr16m,  cpu_ily, cpu_eor16 // 0x54-0x57
    .word cpu_cli, 0,  cpu_aby, cpu_eor16,  cpu_phy16, 0,  cpu_tcd, 0 // 0x58-0x5B
    .word cpu_jml, 0,  cpu_abx, cpu_eor16,  cpu_abx, cpu_lsr16m,  cpu_lnx, cpu_eor16 // 0x5C-0x5F
    .word cpu_rts, 0,  cpu_idx, cpu_adc16\d,  cpu_per, 0,  cpu_drs, cpu_adc16\d // 0x60-0x63
    .word cpu_dir, cpu_stz16,  cpu_dir, cpu_adc16\d,  cpu_dir, cpu_ror16m,  cpu_idl, cpu_adc16\d // 0x64-0x67
    .word cpu_pla16, 0,  cpu_i16, cpu_adc16\d,  cpu_ror16, 0,  cpu_rtl, 0 // 0x68-0x6B
    .word cpu_jmpi, 0,  cpu_abs, cpu_adc16\d,  cpu_abs, cpu_ror16m,  cpu_lng, cpu_adc16\d // 0x6C-0x6F
    .word cpu_bvs, 0,  cpu_idy, cpu_adc16\d,  cpu_ind, cpu_adc16\d,  cpu_isy, cpu_adc16\d // 0x70-0x73
    .word cpu_drx, cpu_stz16,  cpu_drx, cpu_adc16\d,  cpu_drx, cpu_ror16m,  cpu_ily, cpu_adc16\d // 0x74-0x77
    .word cpu_sei, 0,  cpu_aby, cpu_adc16\d,  cpu_ply16, 0,  cpu_tdc, 0 // 0x78-0x7B
    .word cpu_jmpx, 0,  cpu_abx, cpu_adc16\d,  cpu_abx, cpu_ror16m,  cpu_lnx, cpu_adc16\d // 0x7C-0x7F
    .word cpu_bra, 0,  cpu_idx, cpu_sta16,  cpu_brl, 0,  cpu_drs, cpu_sta16 // 0x80-0x83
    .word cpu_dir, cpu_sty16,  cpu_dir, cpu_sta16,  cpu_dir, cpu_stx16,  cpu_idl, cpu_sta16 // 0x84-0x87
    .word cpu_dey16, 0,  cpu_bit16, 0,  cpu_txa16, 0,  cpu_phb, 0 // 0x88-0x8B
    .word cpu_abs, cpu_sty16,  cpu_abs, cpu_sta16,  cpu_abs, cpu_stx16,  cpu_lng, cpu_sta16 // 0x8C-0x8F
    .word cpu_bcc, 0,  cpu_idy, cpu_sta16,  cpu_ind, cpu_sta16,  cpu_isy, cpu_sta16 // 0x90-0x93
    .word cpu_drx, cpu_sty16,  cpu_drx, cpu_sta16,  cpu_dry, cpu_stx16,  cpu_ily, cpu_sta16 // 0x94-0x97
    .word cpu_tya16, 0,  cpu_aby, cpu_sta16,  cpu_txs, 0,  cpu_txy16, 0 // 0x98-0x9B
    .word cpu_abs, cpu_stz16,  cpu_abx, cpu_sta16,  cpu_abx, cpu_stz16,  cpu_lnx, cpu_sta16 // 0x9C-0x9F
    .word cpu_i16, cpu_ldy16,  cpu_idx, cpu_lda16,  cpu_i16, cpu_ldx16,  cpu_drs, cpu_lda16 // 0xA0-0xA3
    .word cpu_dir, cpu_ldy16,  cpu_dir, cpu_lda16,  cpu_dir, cpu_ldx16,  cpu_idl, cpu_lda16 // 0xA4-0xA7
    .word cpu_tay16, 0,  cpu_i16, cpu_lda16,  cpu_tax16, 0,  cpu_plb, 0 // 0xA8-0xAB
    .word cpu_abs, cpu_ldy16,  cpu_abs, cpu_lda16,  cpu_abs, cpu_ldx16,  cpu_lng, cpu_lda16 // 0xAC-0xAF
    .word cpu_bcs, 0,  cpu_idy, cpu_lda16,  cpu_ind, cpu_lda16,  cpu_isy, cpu_lda16 // 0xB0-0xB3
    .word cpu_drx, cpu_ldy16,  cpu_drx, cpu_lda16,  cpu_dry, cpu_ldx16,  cpu_ily, cpu_lda16 // 0xB4-0xB7
    .word cpu_clv, 0,  cpu_aby, cpu_lda16,  cpu_tsx16, 0,  cpu_tyx16, 0 // 0xB8-0xBB
    .word cpu_abx, cpu_ldy16,  cpu_abx, cpu_lda16,  cpu_aby, cpu_ldx16,  cpu_lnx, cpu_lda16 // 0xBC-0xBF
    .word cpu_i16, cpu_cpy16,  cpu_idx, cpu_cmp16,  cpu_rep, 0,  cpu_drs, cpu_cmp16 // 0xC0-0xC3
    .word cpu_dir, cpu_cpy16,  cpu_dir, cpu_cmp16,  cpu_dir, cpu_dec16,  cpu_idl, cpu_cmp16 // 0xC4-0xC7
    .word cpu_iny16, 0,  cpu_i16, cpu_cmp16,  cpu_dex16, 0,  cpu_wai, 0 // 0xC8-0xCB
    .word cpu_abs, cpu_cpy16,  cpu_abs, cpu_cmp16,  cpu_abs, cpu_dec16,  cpu_lng, cpu_cmp16 // 0xCC-0xCF
    .word cpu_bne, 0,  cpu_idy, cpu_cmp16,  cpu_ind, cpu_cmp16,  cpu_isy, cpu_cmp16 // 0xD0-0xD3
    .word cpu_pei, 0,  cpu_drx, cpu_cmp16,  cpu_drx, cpu_dec16,  cpu_ily, cpu_cmp16 // 0xD4-0xD7
    .word cpu_cld, 0,  cpu_aby, cpu_cmp16,  cpu_phx16, 0,  cpu_stp, 0 // 0xD8-0xDB
    .word cpu_jmli, 0,  cpu_abx, cpu_cmp16,  cpu_abx, cpu_dec16,  cpu_lnx, cpu_cmp16 // 0xDC-0xDF
    .word cpu_i16, cpu_cpx16,  cpu_idx, cpu_sbc16\d,  cpu_sep, 0,  cpu_drs, cpu_sbc16\d // 0xE0-0xE3
    .word cpu_dir, cpu_cpx16,  cpu_dir, cpu_sbc16\d,  cpu_dir, cpu_inc16,  cpu_idl, cpu_sbc16\d // 0xE4-0xE7
    .word cpu_inx16, 0,  cpu_i16, cpu_sbc16\d,  cpu_nop, 0,  cpu_xba, 0 // 0xE8-0xEB
    .word cpu_abs, cpu_cpx16,  cpu_abs, cpu_sbc16\d,  cpu_abs, cpu_inc16,  cpu_lng, cpu_sbc16\d // 0xEC-0xEF
    .word cpu_beq, 0,  cpu_idy, cpu_sbc16\d,  cpu_ind, cpu_sbc16\d,  cpu_isy, cpu_sbc16\d // 0xF0-0xF3
    .word cpu_pea, 0,  cpu_drx, cpu_sbc16\d,  cpu_drx, cpu_inc16,  cpu_ily, cpu_sbc16\d // 0xF4-0xF7
    .word cpu_sed, 0,  cpu_aby, cpu_sbc16\d,  cpu_plx16, 0,  cpu_xce, 0 // 0xF8-0xFB
    .word cpu_jsrx, 0,  cpu_abx, cpu_sbc16\d,  cpu_abx, cpu_inc16,  cpu_lnx, cpu_sbc16\d // 0xFC-0xFF
.endm

// Define each table twice: one for binary mode and one for decimal mode
.align 4
opcodes_e: OPS_E
opcodes_8: OPS_8
opcodes_r8: OPS_R8
opcodes_a8: OPS_A8
opcodes_16: OPS_16
opcodes_ed: OPS_E d
opcodes_8d: OPS_8 d
opcodes_r8d: OPS_R8 d
opcodes_a8d: OPS_A8 d
opcodes_16d: OPS_16 d

.text

cpu_init:
    // Set the initial program counter value (s7)
    move s0, ra // Backup return address
    li s1, 0xFFFC // RESET vector
    MEM_READ16 0(s1)
    move s7, v0

    // Set the initial lookup table (s6), cycle count (s5), status flags (s4), and direct offset (s8)
    la s6, opcodes_e
    li s5, 341 * 4
    li s4, 0x134
    li s8, 0

    // Set the initial APU cycle count (s3) and DSP cycle count (a3)
    move s3, s5
    move a3, s5
    jr s0


set_nz8: // a0: value
    // Set the NZ flags for an 8-bit value
    andi s4, s4, 0xFF7D
    seq t0, a0, 0
    sll t0, t0, 1 // Z
    or s4, s4, t0
    andi t0, a0, 0x80 // N
    or s4, s4, t0

    // Run an APU or PPU event once enough cycles have passed
    ble s5, s3, apu_execute
    blez s5, ppu_event

    // Fetch an opcode and jump to its functions in the lookup table
    MEM_READ8 0(s7)
    sll t0, v0, 3
    add t0, t0, s6
    lw t1, 0(t0)
    lw gp, 4(t0)
    jr t1


set_nz16: // a0: value
    // Set the NZ flags for a 16-bit value
    andi s4, s4, 0xFF7D
    seq t0, a0, 0
    sll t0, t0, 1 // Z
    or s4, s4, t0
    srl t0, a0, 8
    andi t0, t0, 0x80 // N
    or s4, s4, t0

cpu_execute:
    // Run an APU or PPU event once enough cycles have passed
    ble s5, s3, apu_execute
    blez s5, ppu_event

    // Fetch an opcode and jump to its functions in the lookup table
    MEM_READ8 0(s7)
    sll t0, v0, 3
    add t0, t0, s6
    lw t1, 0(t0)
    lw gp, 4(t0)
    jr t1


trigger_nmi: // a1: vector offset
    // Check if currently in emulation mode
    andi s0, s4, 0x100
    lhu s1, stack_ptr
    beqz s0, nmi_notemu

    // Set the vector to jump to for emulation mode
    li s0, 0xFFFA // NMI vector (emulation mode)
    add s0, s0, a1
    b nmi_cont

nmi_notemu:
    // Set the vector to jump to
    li s0, 0xFFEA // NMI vector
    add s0, s0, a1

    // Push the PC bank to the stack
    srl a1, s7, 16
    MEM_WRITE8 0(s1)
    addi s1, s1, -1

nmi_cont:
    // Update the stack pointer
    addi s1, s1, -3
    sh s1, stack_ptr

    // Push the PC to the stack
    move a1, s7
    MEM_WRITE16 2(s1)

    // Push the flags to the stack and modify them
    move a1, s4
    MEM_WRITE8 1(s1)
    ori s4, s4, 0x4 // Set I
    andi s4, s4, 0xFFF7 // Clear D

    // Jump to the NMI vector
    MEM_READ16
    move s7, v0

    // Unhalt the CPU
    andi s4, s4, 0xFDFF
    jr ra


update_mode:
    // Check if the emulation flag is set
    andi t0, s4, 0x100
    beqz t0, not_emu

    // Switch to emulation mode
    la s6, opcodes_e
    andi s7, 0xFFFF // Clear PC bank
    li t0, 0x1
    sb t0, stack_ptr // Reset SP bank
    sb zero, register_x // Clear high byte
    sb zero, register_y // Clear high byte
    move s8, zero // Clear direct offset
    sb zero, data_bank + 1
    b check_bcd

not_emu:
    // Check if both 8-bit flags are set
    li t1, 0x30
    and t0, s4, t1
    bne t0, t1, not_8

    // Switch to full 8-bit mode
    la s6, opcodes_8
    sb zero, register_x // Clear high byte
    sb zero, register_y // Clear high byte
    b check_bcd

not_8:
    // Check if the 8-bit register flag is set
    andi t0, s4, 0x10
    beqz t0, not_r8

    // Switch to 8-bit register mode
    la s6, opcodes_r8
    sb zero, register_x // Clear high byte
    sb zero, register_y // Clear high byte
    b check_bcd

not_r8:
    // Check if the 8-bit accumulator flag is set
    andi t0, s4, 0x20
    beqz t0, not_a8

    // Switch to 8-bit accumulator mode
    la s6, opcodes_a8
    b check_bcd

not_a8:
    // Switch to 16-bit mode
    la s6, opcodes_16

check_bcd:
    // Adjust for decimal mode if the flag is set
    andi t0, s4, 0x8
    beqz t0, cpu_execute
    addi s6, s6, opcodes_ed - opcodes_e
    j cpu_execute
