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

data_bank:   .word  0x000000
accumulator: .hword 0x0000
register_x:  .hword 0x0000
register_y:  .hword 0x0000
stack_ptr:   .hword 0x01FF

.macro OPS_E d // Lookup table for 6502 emulation mode
    .word brk_e, oraidx_8,   cop_e,      oradrs_8,   tsbdir_8, oradir_8,   asldir_8, oraidl_8   // 0x00-0x07
    .word php,   ora_8,      asl_8,      phd,        tsbabs_8, oraabs_8,   aslabs_8, oralng_8   // 0x08-0x0F
    .word bpl,   oraidy_8,   oraind_8,   oraisy_8,   trbdir_8, oradrx_8,   asldrx_8, oraily_8   // 0x10-0x17
    .word clc,   oraaby_8,   ina_8,      tcs_e,      trbabs_8, oraabx_8,   aslabx_8, oralnx_8   // 0x18-0x1F
    .word jsr,   andidx_8,   jsl_e,      anddrs_8,   bitdir_8, anddir_8,   roldir_8, andidl_8   // 0x20-0x27
    .word plp,   and_8,      rol_8,      pld,        bitabs_8, andabs_8,   rolabs_8, andlng_8   // 0x28-0x2F
    .word bmi,   andidy_8,   andind_8,   andisy_8,   bitdrx_8, anddrx_8,   roldrx_8, andily_8   // 0x30-0x37
    .word sec,   andaby_8,   dea_8,      tsc,        bitabx_8, andabx_8,   rolabx_8, andlnx_8   // 0x38-0x3F
    .word rti_e, eoridx_8,   wdm,        eordrs_8,   mvp_8,    eordir_8,   lsrdir_8, eoridl_8   // 0x40-0x47
    .word pha_8, eor_8,      lsr_8,      phk,        jmp,      eorabs_8,   lsrabs_8, eorlng_8   // 0x48-0x4F
    .word bvc,   eoridy_8,   eorind_8,   eorisy_8,   mvn_8,    eordrx_8,   lsrdrx_8, eorily_8   // 0x50-0x57
    .word cli,   eoraby_8,   phy_8,      tcd,        jml_e,    eorabx_8,   lsrabx_8, eorlnx_8   // 0x58-0x5F
    .word rts,   adcidx_8\d, per,        adcdrs_8\d, stzdir_8, adcdir_8\d, rordir_8, adcidl_8\d // 0x60-0x67
    .word pla_8, adc_8\d,    ror_8,      rtl_e,      jmpind,   adcabs_8\d, rorabs_8, adclng_8\d // 0x68-0x6F
    .word bvs,   adcidy_8\d, adcind_8\d, adcisy_8\d, stzdrx_8, adcdrx_8\d, rordrx_8, adcily_8\d // 0x70-0x77
    .word sei,   adcaby_8\d, ply_8,      tdc,        jmpidx,   adcabx_8\d, rorabx_8, adclnx_8\d // 0x78-0x7F
    .word bra,   staidx_8,   brl,        stadrs_8,   stydir_8, stadir_8,   stxdir_8, staidl_8   // 0x80-0x87
    .word dey_8, bit_8,      txa_8,      phb,        styabs_8, staabs_8,   stxabs_8, stalng_8   // 0x88-0x8F
    .word bcc,   staidy_8,   staind_8,   staisy_8,   stydrx_8, stadrx_8,   stxdry_8, staily_8   // 0x90-0x97
    .word tya_8, staaby_8,   txs_e,      txy_8,      stzabs_8, staabx_8,   stzabx_8, stalnx_8   // 0x98-0x9F
    .word ldy_8, ldaidx_8,   ldx_8,      ldadrs_8,   ldydir_8, ldadir_8,   ldxdir_8, ldaidl_8   // 0xA0-0xA7
    .word tay_8, lda_8,      tax_8,      plb,        ldyabs_8, ldaabs_8,   ldxabs_8, ldalng_8   // 0xA8-0xAF
    .word bcs,   ldaidy_8,   ldaind_8,   ldaisy_8,   ldydrx_8, ldadrx_8,   ldxdry_8, ldaily_8   // 0xB0-0xB7
    .word clv,   ldaaby_8,   tsx_8,      tyx_8,      ldyabx_8, ldaabx_8,   ldxaby_8, ldalnx_8   // 0xB8-0xBF
    .word cpy_8, cmpidx_8,   rep,        cmpdrs_8,   cpydir_8, cmpdir_8,   decdir_8, cmpidl_8   // 0xC0-0xC7
    .word iny_8, cmp_8,      dex_8,      wai,        cpyabs_8, cmpabs_8,   decabs_8, cmplng_8   // 0xC8-0xCF
    .word bne,   cmpidy_8,   cmpind_8,   cmpisy_8,   pei,      cmpdrx_8,   decdrx_8, cmpily_8   // 0xD0-0xD7
    .word cld,   cmpaby_8,   phx_8,      stp,        jmlind_e, cmpabx_8,   decabx_8, cmplnx_8   // 0xD8-0xDF
    .word cpx_8, sbcidx_8\d, sep,        sbcdrs_8\d, cpxdir_8, sbcdir_8\d, incdir_8, sbcidl_8\d // 0xE0-0xE7
    .word inx_8, sbc_8\d,    nop,        xba,        cpxabs_8, sbcabs_8\d, incabs_8, sbclng_8\d // 0xE8-0xEF
    .word beq,   sbcidy_8\d, sbcind_8\d, sbcisy_8\d, pea,      sbcdrx_8\d, incdrx_8, sbcily_8\d // 0xF0-0xF7
    .word sed,   sbcaby_8\d, plx_8,      xce,        jsridx,   sbcabx_8\d, incabx_8, sbclnx_8\d // 0xF8-0xFF
.endm

.macro OPS_8 d // Lookup table for full 8-bit mode
    .word brk,   oraidx_8,   cop,        oradrs_8,   tsbdir_8, oradir_8,   asldir_8, oraidl_8   // 0x00-0x07
    .word php,   ora_8,      asl_8,      phd,        tsbabs_8, oraabs_8,   aslabs_8, oralng_8   // 0x08-0x0F
    .word bpl,   oraidy_8,   oraind_8,   oraisy_8,   trbdir_8, oradrx_8,   asldrx_8, oraily_8   // 0x10-0x17
    .word clc,   oraaby_8,   ina_8,      tcs,        trbabs_8, oraabx_8,   aslabx_8, oralnx_8   // 0x18-0x1F
    .word jsr,   andidx_8,   jsl,        anddrs_8,   bitdir_8, anddir_8,   roldir_8, andidl_8   // 0x20-0x27
    .word plp,   and_8,      rol_8,      pld,        bitabs_8, andabs_8,   rolabs_8, andlng_8   // 0x28-0x2F
    .word bmi,   andidy_8,   andind_8,   andisy_8,   bitdrx_8, anddrx_8,   roldrx_8, andily_8   // 0x30-0x37
    .word sec,   andaby_8,   dea_8,      tsc,        bitabx_8, andabx_8,   rolabx_8, andlnx_8   // 0x38-0x3F
    .word rti,   eoridx_8,   wdm,        eordrs_8,   mvp_8,    eordir_8,   lsrdir_8, eoridl_8   // 0x40-0x47
    .word pha_8, eor_8,      lsr_8,      phk,        jmp,      eorabs_8,   lsrabs_8, eorlng_8   // 0x48-0x4F
    .word bvc,   eoridy_8,   eorind_8,   eorisy_8,   mvn_8,    eordrx_8,   lsrdrx_8, eorily_8   // 0x50-0x57
    .word cli,   eoraby_8,   phy_8,      tcd,        jml,      eorabx_8,   lsrabx_8, eorlnx_8   // 0x58-0x5F
    .word rts,   adcidx_8\d, per,        adcdrs_8\d, stzdir_8, adcdir_8\d, rordir_8, adcidl_8\d // 0x60-0x67
    .word pla_8, adc_8\d,    ror_8,      rtl,        jmpind,   adcabs_8\d, rorabs_8, adclng_8\d // 0x68-0x6F
    .word bvs,   adcidy_8\d, adcind_8\d, adcisy_8\d, stzdrx_8, adcdrx_8\d, rordrx_8, adcily_8\d // 0x70-0x77
    .word sei,   adcaby_8\d, ply_8,      tdc,        jmpidx,   adcabx_8\d, rorabx_8, adclnx_8\d // 0x78-0x7F
    .word bra,   staidx_8,   brl,        stadrs_8,   stydir_8, stadir_8,   stxdir_8, staidl_8   // 0x80-0x87
    .word dey_8, bit_8,      txa_8,      phb,        styabs_8, staabs_8,   stxabs_8, stalng_8   // 0x88-0x8F
    .word bcc,   staidy_8,   staind_8,   staisy_8,   stydrx_8, stadrx_8,   stxdry_8, staily_8   // 0x90-0x97
    .word tya_8, staaby_8,   txs,        txy_8,      stzabs_8, staabx_8,   stzabx_8, stalnx_8   // 0x98-0x9F
    .word ldy_8, ldaidx_8,   ldx_8,      ldadrs_8,   ldydir_8, ldadir_8,   ldxdir_8, ldaidl_8   // 0xA0-0xA7
    .word tay_8, lda_8,      tax_8,      plb,        ldyabs_8, ldaabs_8,   ldxabs_8, ldalng_8   // 0xA8-0xAF
    .word bcs,   ldaidy_8,   ldaind_8,   ldaisy_8,   ldydrx_8, ldadrx_8,   ldxdry_8, ldaily_8   // 0xB0-0xB7
    .word clv,   ldaaby_8,   tsx_8,      tyx_8,      ldyabx_8, ldaabx_8,   ldxaby_8, ldalnx_8   // 0xB8-0xBF
    .word cpy_8, cmpidx_8,   rep,        cmpdrs_8,   cpydir_8, cmpdir_8,   decdir_8, cmpidl_8   // 0xC0-0xC7
    .word iny_8, cmp_8,      dex_8,      wai,        cpyabs_8, cmpabs_8,   decabs_8, cmplng_8   // 0xC8-0xCF
    .word bne,   cmpidy_8,   cmpind_8,   cmpisy_8,   pei,      cmpdrx_8,   decdrx_8, cmpily_8   // 0xD0-0xD7
    .word cld,   cmpaby_8,   phx_8,      stp,        jmlind,   cmpabx_8,   decabx_8, cmplnx_8   // 0xD8-0xDF
    .word cpx_8, sbcidx_8\d, sep,        sbcdrs_8\d, cpxdir_8, sbcdir_8\d, incdir_8, sbcidl_8\d // 0xE0-0xE7
    .word inx_8, sbc_8\d,    nop,        xba,        cpxabs_8, sbcabs_8\d, incabs_8, sbclng_8\d // 0xE8-0xEF
    .word beq,   sbcidy_8\d, sbcind_8\d, sbcisy_8\d, pea,      sbcdrx_8\d, incdrx_8, sbcily_8\d // 0xF0-0xF7
    .word sed,   sbcaby_8\d, plx_8,      xce,        jsridx,   sbcabx_8\d, incabx_8, sbclnx_8\d // 0xF8-0xFF
.endm

.macro OPS_R8 d // Lookup table for 8-bit register mode
    .word brk,    oraidx_16,   cop,         oradrs_16,   tsbdir_16, oradir_16,   asldir_16, oraidl_16   // 0x00-0x07
    .word php,    ora_16,      asl_16,      phd,         tsbabs_16, oraabs_16,   aslabs_16, oralng_16   // 0x08-0x0F
    .word bpl,    oraidy_16,   oraind_16,   oraisy_16,   trbdir_16, oradrx_16,   asldrx_16, oraily_16   // 0x10-0x17
    .word clc,    oraaby_16,   ina_16,      tcs,         trbabs_16, oraabx_16,   aslabx_16, oralnx_16   // 0x18-0x1F
    .word jsr,    andidx_16,   jsl,         anddrs_16,   bitdir_16, anddir_16,   roldir_16, andidl_16   // 0x20-0x27
    .word plp,    and_16,      rol_16,      pld,         bitabs_16, andabs_16,   rolabs_16, andlng_16   // 0x28-0x2F
    .word bmi,    andidy_16,   andind_16,   andisy_16,   bitdrx_16, anddrx_16,   roldrx_16, andily_16   // 0x30-0x37
    .word sec,    andaby_16,   dea_16,      tsc,         bitabx_16, andabx_16,   rolabx_16, andlnx_16   // 0x38-0x3F
    .word rti,    eoridx_16,   wdm,         eordrs_16,   mvp_8,     eordir_16,   lsrdir_16, eoridl_16   // 0x40-0x47
    .word pha_16, eor_16,      lsr_16,      phk,         jmp,       eorabs_16,   lsrabs_16, eorlng_16   // 0x48-0x4F
    .word bvc,    eoridy_16,   eorind_16,   eorisy_16,   mvn_8,     eordrx_16,   lsrdrx_16, eorily_16   // 0x50-0x57
    .word cli,    eoraby_16,   phy_8,       tcd,         jml,       eorabx_16,   lsrabx_16, eorlnx_16   // 0x58-0x5F
    .word rts,    adcidx_16\d, per,         adcdrs_16\d, stzdir_16, adcdir_16\d, rordir_16, adcidl_16\d // 0x60-0x67
    .word pla_16, adc_16\d,    ror_16,      rtl,         jmpind,    adcabs_16\d, rorabs_16, adclng_16\d // 0x68-0x6F
    .word bvs,    adcidy_16\d, adcind_16\d, adcisy_16\d, stzdrx_16, adcdrx_16\d, rordrx_16, adcily_16\d // 0x70-0x77
    .word sei,    adcaby_16\d, ply_8,       tdc,         jmpidx,    adcabx_16\d, rorabx_16, adclnx_16\d // 0x78-0x7F
    .word bra,    staidx_16,   brl,         stadrs_16,   stydir_8,  stadir_16,   stxdir_8,  staidl_16   // 0x80-0x87
    .word dey_8,  bit_16,      txa_16,      phb,         styabs_8,  staabs_16,   stxabs_8,  stalng_16   // 0x88-0x8F
    .word bcc,    staidy_16,   staind_16,   staisy_16,   stydrx_8,  stadrx_16,   stxdry_8,  staily_16   // 0x90-0x97
    .word tya_16, staaby_16,   txs,         txy_8,       stzabs_16, staabx_16,   stzabx_16, stalnx_16   // 0x98-0x9F
    .word ldy_8,  ldaidx_16,   ldx_8,       ldadrs_16,   ldydir_8,  ldadir_16,   ldxdir_8,  ldaidl_16   // 0xA0-0xA7
    .word tay_8,  lda_16,      tax_8,       plb,         ldyabs_8,  ldaabs_16,   ldxabs_8,  ldalng_16   // 0xA8-0xAF
    .word bcs,    ldaidy_16,   ldaind_16,   ldaisy_16,   ldydrx_8,  ldadrx_16,   ldxdry_8,  ldaily_16   // 0xB0-0xB7
    .word clv,    ldaaby_16,   tsx_8,       tyx_8,       ldyabx_8,  ldaabx_16,   ldxaby_8,  ldalnx_16   // 0xB8-0xBF
    .word cpy_8,  cmpidx_16,   rep,         cmpdrs_16,   cpydir_8,  cmpdir_16,   decdir_16, cmpidl_16   // 0xC0-0xC7
    .word iny_8,  cmp_16,      dex_8,       wai,         cpyabs_8,  cmpabs_16,   decabs_16, cmplng_16   // 0xC8-0xCF
    .word bne,    cmpidy_16,   cmpind_16,   cmpisy_16,   pei,       cmpdrx_16,   decdrx_16, cmpily_16   // 0xD0-0xD7
    .word cld,    cmpaby_16,   phx_8,       stp,         jmlind,    cmpabx_16,   decabx_16, cmplnx_16   // 0xD8-0xDF
    .word cpx_8,  sbcidx_16\d, sep,         sbcdrs_16\d, cpxdir_8,  sbcdir_16\d, incdir_16, sbcidl_16\d // 0xE0-0xE7
    .word inx_8,  sbc_16\d,    nop,         xba,         cpxabs_8,  sbcabs_16\d, incabs_16, sbclng_16\d // 0xE8-0xEF
    .word beq,    sbcidy_16\d, sbcind_16\d, sbcisy_16\d, pea,       sbcdrx_16\d, incdrx_16, sbcily_16\d // 0xF0-0xF7
    .word sed,    sbcaby_16\d, plx_8,       xce,         jsridx,    sbcabx_16\d, incabx_16, sbclnx_16\d // 0xF8-0xFF
.endm

.macro OPS_A8 d // Lookup table for 8-bit accumulator mode
    .word brk,    oraidx_8,   cop,        oradrs_8,   tsbdir_8,  oradir_8,   asldir_8,  oraidl_8   // 0x00-0x07
    .word php,    ora_8,      asl_8,      phd,        tsbabs_8,  oraabs_8,   aslabs_8,  oralng_8   // 0x08-0x0F
    .word bpl,    oraidy_8,   oraind_8,   oraisy_8,   trbdir_8,  oradrx_8,   asldrx_8,  oraily_8   // 0x10-0x17
    .word clc,    oraaby_8,   ina_8,      tcs,        trbabs_8,  oraabx_8,   aslabx_8,  oralnx_8   // 0x18-0x1F
    .word jsr,    andidx_8,   jsl,        anddrs_8,   bitdir_8,  anddir_8,   roldir_8,  andidl_8   // 0x20-0x27
    .word plp,    and_8,      rol_8,      pld,        bitabs_8,  andabs_8,   rolabs_8,  andlng_8   // 0x28-0x2F
    .word bmi,    andidy_8,   andind_8,   andisy_8,   bitdrx_8,  anddrx_8,   roldrx_8,  andily_8   // 0x30-0x37
    .word sec,    andaby_8,   dea_8,      tsc,        bitabx_8,  andabx_8,   rolabx_8,  andlnx_8   // 0x38-0x3F
    .word rti,    eoridx_8,   wdm,        eordrs_8,   mvp_16,    eordir_8,   lsrdir_8,  eoridl_8   // 0x40-0x47
    .word pha_8,  eor_8,      lsr_8,      phk,        jmp,       eorabs_8,   lsrabs_8,  eorlng_8   // 0x48-0x4F
    .word bvc,    eoridy_8,   eorind_8,   eorisy_8,   mvn_16,    eordrx_8,   lsrdrx_8,  eorily_8   // 0x50-0x57
    .word cli,    eoraby_8,   phy_16,     tcd,        jml,       eorabx_8,   lsrabx_8,  eorlnx_8   // 0x58-0x5F
    .word rts,    adcidx_8\d, per,        adcdrs_8\d, stzdir_8,  adcdir_8\d, rordir_8,  adcidl_8\d // 0x60-0x67
    .word pla_8,  adc_8\d,    ror_8,      rtl,        jmpind,    adcabs_8\d, rorabs_8,  adclng_8\d // 0x68-0x6F
    .word bvs,    adcidy_8\d, adcind_8\d, adcisy_8\d, stzdrx_8,  adcdrx_8\d, rordrx_8,  adcily_8\d // 0x70-0x77
    .word sei,    adcaby_8\d, ply_16,     tdc,        jmpidx,    adcabx_8\d, rorabx_8,  adclnx_8\d // 0x78-0x7F
    .word bra,    staidx_8,   brl,        stadrs_8,   stydir_16, stadir_8,   stxdir_16, staidl_8   // 0x80-0x87
    .word dey_16, bit_8,      txa_8,      phb,        styabs_16, staabs_8,   stxabs_16, stalng_8   // 0x88-0x8F
    .word bcc,    staidy_8,   staind_8,   staisy_8,   stydrx_16, stadrx_8,   stxdry_16, staily_8   // 0x90-0x97
    .word tya_8,  staaby_8,   txs,        txy_16,     stzabs_8,  staabx_8,   stzabx_8,  stalnx_8   // 0x98-0x9F
    .word ldy_16, ldaidx_8,   ldx_16,     ldadrs_8,   ldydir_16, ldadir_8,   ldxdir_16, ldaidl_8   // 0xA0-0xA7
    .word tay_16, lda_8,      tax_16,     plb,        ldyabs_16, ldaabs_8,   ldxabs_16, ldalng_8   // 0xA8-0xAF
    .word bcs,    ldaidy_8,   ldaind_8,   ldaisy_8,   ldydrx_16, ldadrx_8,   ldxdry_16, ldaily_8   // 0xB0-0xB7
    .word clv,    ldaaby_8,   tsx_16,     tyx_16,     ldyabx_16, ldaabx_8,   ldxaby_16, ldalnx_8   // 0xB8-0xBF
    .word cpy_16, cmpidx_8,   rep,        cmpdrs_8,   cpydir_16, cmpdir_8,   decdir_8,  cmpidl_8   // 0xC0-0xC7
    .word iny_16, cmp_8,      dex_16,     wai,        cpyabs_16, cmpabs_8,   decabs_8,  cmplng_8   // 0xC8-0xCF
    .word bne,    cmpidy_8,   cmpind_8,   cmpisy_8,   pei,       cmpdrx_8,   decdrx_8,  cmpily_8   // 0xD0-0xD7
    .word cld,    cmpaby_8,   phx_16,     stp,        jmlind,    cmpabx_8,   decabx_8,  cmplnx_8   // 0xD8-0xDF
    .word cpx_16, sbcidx_8\d, sep,        sbcdrs_8\d, cpxdir_16, sbcdir_8\d, incdir_8,  sbcidl_8\d // 0xE0-0xE7
    .word inx_16, sbc_8\d,    nop,        xba,        cpxabs_16, sbcabs_8\d, incabs_8,  sbclng_8\d // 0xE8-0xEF
    .word beq,    sbcidy_8\d, sbcind_8\d, sbcisy_8\d, pea,       sbcdrx_8\d, incdrx_8,  sbcily_8\d // 0xF0-0xF7
    .word sed,    sbcaby_8\d, plx_16,     xce,        jsridx,    sbcabx_8\d, incabx_8,  sbclnx_8\d // 0xF8-0xFF
.endm

.macro OPS_16 d // Lookup table for 16-bit mode
    .word brk,    oraidx_16,   cop,         oradrs_16,   tsbdir_16, oradir_16,   asldir_16, oraidl_16   // 0x00-0x07
    .word php,    ora_16,      asl_16,      phd,         tsbabs_16, oraabs_16,   aslabs_16, oralng_16   // 0x08-0x0F
    .word bpl,    oraidy_16,   oraind_16,   oraisy_16,   trbdir_16, oradrx_16,   asldrx_16, oraily_16   // 0x10-0x17
    .word clc,    oraaby_16,   ina_16,      tcs,         trbabs_16, oraabx_16,   aslabx_16, oralnx_16   // 0x18-0x1F
    .word jsr,    andidx_16,   jsl,         anddrs_16,   bitdir_16, anddir_16,   roldir_16, andidl_16   // 0x20-0x27
    .word plp,    and_16,      rol_16,      pld,         bitabs_16, andabs_16,   rolabs_16, andlng_16   // 0x28-0x2F
    .word bmi,    andidy_16,   andind_16,   andisy_16,   bitdrx_16, anddrx_16,   roldrx_16, andily_16   // 0x30-0x37
    .word sec,    andaby_16,   dea_16,      tsc,         bitabx_16, andabx_16,   rolabx_16, andlnx_16   // 0x38-0x3F
    .word rti,    eoridx_16,   wdm,         eordrs_16,   mvp_16,    eordir_16,   lsrdir_16, eoridl_16   // 0x40-0x47
    .word pha_16, eor_16,      lsr_16,      phk,         jmp,       eorabs_16,   lsrabs_16, eorlng_16   // 0x48-0x4F
    .word bvc,    eoridy_16,   eorind_16,   eorisy_16,   mvn_16,    eordrx_16,   lsrdrx_16, eorily_16   // 0x50-0x57
    .word cli,    eoraby_16,   phy_16,      tcd,         jml,       eorabx_16,   lsrabx_16, eorlnx_16   // 0x58-0x5F
    .word rts,    adcidx_16\d, per,         adcdrs_16\d, stzdir_16, adcdir_16\d, rordir_16, adcidl_16\d // 0x60-0x67
    .word pla_16, adc_16\d,    ror_16,      rtl,         jmpind,    adcabs_16\d, rorabs_16, adclng_16\d // 0x68-0x6F
    .word bvs,    adcidy_16\d, adcind_16\d, adcisy_16\d, stzdrx_16, adcdrx_16\d, rordrx_16, adcily_16\d // 0x70-0x77
    .word sei,    adcaby_16\d, ply_16,      tdc,         jmpidx,    adcabx_16\d, rorabx_16, adclnx_16\d // 0x78-0x7F
    .word bra,    staidx_16,   brl,         stadrs_16,   stydir_16, stadir_16,   stxdir_16, staidl_16   // 0x80-0x87
    .word dey_16, bit_16,      txa_16,      phb,         styabs_16, staabs_16,   stxabs_16, stalng_16   // 0x88-0x8F
    .word bcc,    staidy_16,   staind_16,   staisy_16,   stydrx_16, stadrx_16,   stxdry_16, staily_16   // 0x90-0x97
    .word tya_16, staaby_16,   txs,         txy_16,      stzabs_16, staabx_16,   stzabx_16, stalnx_16   // 0x98-0x9F
    .word ldy_16, ldaidx_16,   ldx_16,      ldadrs_16,   ldydir_16, ldadir_16,   ldxdir_16, ldaidl_16   // 0xA0-0xA7
    .word tay_16, lda_16,      tax_16,      plb,         ldyabs_16, ldaabs_16,   ldxabs_16, ldalng_16   // 0xA8-0xAF
    .word bcs,    ldaidy_16,   ldaind_16,   ldaisy_16,   ldydrx_16, ldadrx_16,   ldxdry_16, ldaily_16   // 0xB0-0xB7
    .word clv,    ldaaby_16,   tsx_16,      tyx_16,      ldyabx_16, ldaabx_16,   ldxaby_16, ldalnx_16   // 0xB8-0xBF
    .word cpy_16, cmpidx_16,   rep,         cmpdrs_16,   cpydir_16, cmpdir_16,   decdir_16, cmpidl_16   // 0xC0-0xC7
    .word iny_16, cmp_16,      dex_16,      wai,         cpyabs_16, cmpabs_16,   decabs_16, cmplng_16   // 0xC8-0xCF
    .word bne,    cmpidy_16,   cmpind_16,   cmpisy_16,   pei,       cmpdrx_16,   decdrx_16, cmpily_16   // 0xD0-0xD7
    .word cld,    cmpaby_16,   phx_16,      stp,         jmlind,    cmpabx_16,   decabx_16, cmplnx_16   // 0xD8-0xDF
    .word cpx_16, sbcidx_16\d, sep,         sbcdrs_16\d, cpxdir_16, sbcdir_16\d, incdir_16, sbcidl_16\d // 0xE0-0xE7
    .word inx_16, sbc_16\d,    nop,         xba,         cpxabs_16, sbcabs_16\d, incabs_16, sbclng_16\d // 0xE8-0xEF
    .word beq,    sbcidy_16\d, sbcind_16\d, sbcisy_16\d, pea,       sbcdrx_16\d, incdrx_16, sbcily_16\d // 0xF0-0xF7
    .word sed,    sbcaby_16\d, plx_16,      xce,         jsridx,    sbcabx_16\d, incabx_16, sbclnx_16\d // 0xF8-0xFF
.endm

// Define each table twice: one for binary mode and one for decimal mode
opcodes_e:   OPS_E
opcodes_8:   OPS_8
opcodes_r8:  OPS_R8
opcodes_a8:  OPS_A8
opcodes_16:  OPS_16
opcodes_ed:  OPS_E d
opcodes_8d:  OPS_8 d
opcodes_r8d: OPS_R8 d
opcodes_a8d: OPS_A8 d
opcodes_16d: OPS_16 d

.text

cpu_init:
    // Set the initial program counter value (s7)
    move s0, ra     // Backup return address
    li   s1, 0xFFFC // RESET vector
    MEM_READ16 0(s1)
    move s7, v0

    // Set the initial lookup table (s6), cycle count (s5), status flags (s4), and direct offset (s8)
    la   s6, opcodes_e
    li   s5, 341 * 4
    li   s4, 0x134
    li   s8, 0

    // Set the initial APU cycle count (s3) and DSP cycle count (a3)
    move s3, s5
    move a3, s5
    jr   s0


set_nz8: // a0: value
    // Set the NZ flags for an 8-bit value
    andi s4, s4, ~0x82 & 0xFFFF
    seq  t0, a0, 0
    sll  t0, t0, 1    // Z
    or   s4, s4, t0
    andi t0, a0, 0x80 // N
    or   s4, s4, t0

    // Run an APU or PPU event once enough cycles have passed
    ble  s5, s3, apu_execute
    blez s5, ppu_event

    // Fetch an opcode and jump to its function in the lookup table
    MEM_READ8 0(s7)
    sll  t0, v0, 2 // Word offset
    add  t0, t0, s6
    lw   t0, (t0)
    jr   t0


set_nz16: // a0: value
    // Set the NZ flags for a 16-bit value
    andi s4, s4, ~0x82 & 0xFFFF
    seq  t0, a0, 0
    sll  t0, t0, 1    // Z
    or   s4, s4, t0
    srl  t0, a0, 8
    andi t0, t0, 0x80 // N
    or   s4, s4, t0

cpu_execute:
    // Run an APU or PPU event once enough cycles have passed
    ble  s5, s3, apu_execute
    blez s5, ppu_event

    // Fetch an opcode and jump to its function in the lookup table
    MEM_READ8 0(s7)
    sll  t0, v0, 2 // Word offset
    add  t0, t0, s6
    lw   t0, (t0)
    jr   t0


trigger_nmi: // a1: vector offset
    // Check if currently in emulation mode
    andi s0, s4, 0x100
    lhu  s1, stack_ptr
    beqz s0, nmi_notemu

    // Set the vector to jump to for emulation mode
    li   s0, 0xFFFA // NMI vector (emulation mode)
    add  s0, s0, a1
    b    nmi_cont

nmi_notemu:
    // Set the vector to jump to
    li   s0, 0xFFEA // NMI vector
    add  s0, s0, a1

    // Push the PC bank to the stack
    srl  a1, s7, 16
    MEM_WRITE8 0(s1)
    addi s1, s1, -1

nmi_cont:
    // Update the stack pointer
    addi s1, s1, -3
    sh   s1, stack_ptr

    // Push the PC to the stack
    move a1, s7
    MEM_WRITE16 2(s1)

    // Push the flags to the stack and modify them
    move a1, s4
    MEM_WRITE8 1(s1)
    ori  s4, s4, 0x04           // I
    andi s4, s4, ~0x08 & 0xFFFF // D

    // Jump to the NMI vector
    MEM_READ16
    move s7, v0

    // Unhalt the CPU
    andi s4, s4, ~0x200 & 0xFFFF
    jr   ra


update_mode:
    // Check if the emulation flag is set
    andi t0, s4, 0x100
    beqz t0, not_emu

    // Switch to emulation mode
    la   s6, opcodes_e
    andi s7, 0xFFFF       // Clear PC bank
    li   t0, 0x01
    sb   t0, stack_ptr    // Reset SP bank
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    move s8, zero         // Clear direct offset
    sb   zero, data_bank + 1
    b    check_bcd

not_emu:
    // Check if both 8-bit flags are set
    li   t1, 0x30
    and  t0, s4, t1
    bne  t0, t1, not_8

    // Switch to full 8-bit mode
    la   s6, opcodes_8
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    b    check_bcd

not_8:
    // Check if the 8-bit register flag is set
    andi t0, s4, 0x10
    beqz t0, not_r8

    // Switch to 8-bit register mode
    la   s6, opcodes_r8
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    b    check_bcd

not_r8:
    // Check if the 8-bit accumulator flag is set
    andi t0, s4, 0x20
    beqz t0, not_a8

    // Switch to 8-bit accumulator mode
    la   s6, opcodes_a8
    b    check_bcd

not_a8:
    // Switch to 16-bit mode
    la   s6, opcodes_16

check_bcd:
    // Adjust for decimal mode if the flag is set
    andi t0, s4, 0x08
    beqz t0, cpu_execute
    addi s6, s6, opcodes_ed - opcodes_e
    j    cpu_execute
