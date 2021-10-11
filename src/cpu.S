#include <regdef.h>

.globl accumulator
.globl register_x
.globl register_y
.globl stack_ptr
.globl direct_ofs
.globl data_bank

.globl cpu_init
.globl set_nz8
.globl set_nz16
.globl cpu_execute
.globl update_mode

.data

accumulator: .hword 0x0000
register_x:  .hword 0x0000
register_y:  .hword 0x0000
stack_ptr:   .hword 0x01FF
direct_ofs:  .hword 0x0000
data_bank:   .byte  0x00

opcodes_emu: // Lookup table for 6502 emulation mode
    .word brk_e, unimp,    cop_e,    unimp,    unimp,    unimp,    unimp,    unimp,    php,   unimp,    unimp, phd,   unimp,    unimp,    unimp,    unimp    // 0x00-0x0F
    .word bpl,   unimp,    unimp,    unimp,    unimp,    unimp,    unimp,    unimp,    clc,   unimp,    unimp, tcs_e, unimp,    unimp,    unimp,    unimp    // 0x10-0x1F
    .word jsr,   unimp,    jsl_e,    unimp,    unimp,    unimp,    unimp,    unimp,    plp,   unimp,    unimp, pld,   unimp,    unimp,    unimp,    unimp    // 0x20-0x2F
    .word bmi,   unimp,    unimp,    unimp,    unimp,    unimp,    unimp,    unimp,    sec,   unimp,    unimp, tsc,   unimp,    unimp,    unimp,    unimp    // 0x30-0x3F
    .word rti_e, unimp,    wdm,      unimp,    mvp_8,    unimp,    unimp,    unimp,    pha_8, unimp,    unimp, phk,   jmp,      unimp,    unimp,    unimp    // 0x40-0x4F
    .word bvc,   unimp,    unimp,    unimp,    mvn_8,    unimp,    unimp,    unimp,    cli,   unimp,    phy_8, tcd,   jml_e,    unimp,    unimp,    unimp    // 0x50-0x5F
    .word rts,   unimp,    per,      unimp,    stzdir_8, unimp,    unimp,    unimp,    pla_8, unimp,    unimp, rtl_e, jmpind,   unimp,    unimp,    unimp    // 0x60-0x6F
    .word bvs,   unimp,    unimp,    unimp,    stzdrx_8, unimp,    unimp,    unimp,    sei,   unimp,    ply_8, tdc,   jmpidx,   unimp,    unimp,    unimp    // 0x70-0x7F
    .word bra,   staidx_8, brl,      stadrs_8, stydir_8, stadir_8, stxdir_8, staidl_8, unimp, unimp,    txa_8, phb,   styabs_8, staabs_8, stxabs_8, stalng_8 // 0x80-0x8F
    .word bcc,   staidy_8, staind_8, staisy_8, stydrx_8, stadrx_8, stxdry_8, staily_8, tya_8, staaby_8, txs_e, txy_8, stzabs_8, staabx_8, stzabx_8, stalnx_8 // 0x90-0x9F
    .word ldy_8, ldaidx_8, ldx_8,    ldadrs_8, ldydir_8, ldadir_8, ldxdir_8, ldaidl_8, tay_8, lda_8,    tax_8, plb,   ldyabs_8, ldaabs_8, ldxabs_8, ldalng_8 // 0xA0-0xAF
    .word bcs,   ldaidy_8, ldaind_8, ldaisy_8, ldydrx_8, ldadrx_8, ldxdry_8, ldaily_8, clv,   ldaaby_8, tsx_8, tyx_8, ldyabx_8, ldaabx_8, ldxaby_8, ldalnx_8 // 0xB0-0xBF
    .word unimp, unimp,    rep,      unimp,    unimp,    unimp,    unimp,    unimp,    unimp, unimp,    unimp, wai,   unimp,    unimp,    unimp,    unimp    // 0xC0-0xCF
    .word bne,   unimp,    unimp,    unimp,    pei,      unimp,    unimp,    unimp,    cld,   unimp,    phx_8, stp,   jmlind_e, unimp,    unimp,    unimp    // 0xD0-0xDF
    .word unimp, unimp,    sep,      unimp,    unimp,    unimp,    unimp,    unimp,    unimp, unimp,    nop,   xba,   unimp,    unimp,    unimp,    unimp    // 0xE0-0xEF
    .word beq,   unimp,    unimp,    unimp,    pea,      unimp,    unimp,    unimp,    sed,   unimp,    plx_8, xce,   jsridx,   unimp,    unimp,    unimp    // 0xF0-0xFF

opcodes_8: // Lookup table for full 8-bit mode
    .word brk,   unimp,    cop,      unimp,    unimp,    unimp,    unimp,    unimp,    php,   unimp,    unimp, phd,   unimp,    unimp,    unimp,    unimp    // 0x00-0x0F
    .word bpl,   unimp,    unimp,    unimp,    unimp,    unimp,    unimp,    unimp,    clc,   unimp,    unimp, tcs,   unimp,    unimp,    unimp,    unimp    // 0x10-0x1F
    .word jsr,   unimp,    jsl,      unimp,    unimp,    unimp,    unimp,    unimp,    plp,   unimp,    unimp, pld,   unimp,    unimp,    unimp,    unimp    // 0x20-0x2F
    .word bmi,   unimp,    unimp,    unimp,    unimp,    unimp,    unimp,    unimp,    sec,   unimp,    unimp, tsc,   unimp,    unimp,    unimp,    unimp    // 0x30-0x3F
    .word rti,   unimp,    wdm,      unimp,    mvp_8,    unimp,    unimp,    unimp,    pha_8, unimp,    unimp, phk,   jmp,      unimp,    unimp,    unimp    // 0x40-0x4F
    .word bvc,   unimp,    unimp,    unimp,    mvn_8,    unimp,    unimp,    unimp,    cli,   unimp,    phy_8, tcd,   jml,      unimp,    unimp,    unimp    // 0x50-0x5F
    .word rts,   unimp,    per,      unimp,    stzdir_8, unimp,    unimp,    unimp,    pla_8, unimp,    unimp, rtl,   jmpind,   unimp,    unimp,    unimp    // 0x60-0x6F
    .word bvs,   unimp,    unimp,    unimp,    stzdrx_8, unimp,    unimp,    unimp,    sei,   unimp,    ply_8, tdc,   jmpidx,   unimp,    unimp,    unimp    // 0x70-0x7F
    .word bra,   staidx_8, brl,      stadrs_8, stydir_8, stadir_8, stxdir_8, staidl_8, unimp, unimp,    txa_8, phb,   styabs_8, staabs_8, stxabs_8, stalng_8 // 0x80-0x8F
    .word bcc,   staidy_8, staind_8, staisy_8, stydrx_8, stadrx_8, stxdry_8, staily_8, tya_8, staaby_8, txs,   txy_8, stzabs_8, staabx_8, stzabx_8, stalnx_8 // 0x90-0x9F
    .word ldy_8, ldaidx_8, ldx_8,    ldadrs_8, ldydir_8, ldadir_8, ldxdir_8, ldaidl_8, tay_8, lda_8,    tax_8, plb,   ldyabs_8, ldaabs_8, ldxabs_8, ldalng_8 // 0xA0-0xAF
    .word bcs,   ldaidy_8, ldaind_8, ldaisy_8, ldydrx_8, ldadrx_8, ldxdry_8, ldaily_8, clv,   ldaaby_8, tsx_8, tyx_8, ldyabx_8, ldaabx_8, ldxaby_8, ldalnx_8 // 0xB0-0xBF
    .word unimp, unimp,    rep,      unimp,    unimp,    unimp,    unimp,    unimp,    unimp, unimp,    unimp, wai,   unimp,    unimp,    unimp,    unimp    // 0xC0-0xCF
    .word bne,   unimp,    unimp,    unimp,    pei,      unimp,    unimp,    unimp,    cld,   unimp,    phx_8, stp,   jmlind,   unimp,    unimp,    unimp    // 0xD0-0xDF
    .word unimp, unimp,    sep,      unimp,    unimp,    unimp,    unimp,    unimp,    unimp, unimp,    nop,   xba,   unimp,    unimp,    unimp,    unimp    // 0xE0-0xEF
    .word beq,   unimp,    unimp,    unimp,    pea,      unimp,    unimp,    unimp,    sed,   unimp,    plx_8, xce,   jsridx,   unimp,    unimp,    unimp    // 0xF0-0xFF

opcodes_r8: // Lookup table for 8-bit register mode
    .word brk,   unimp,     cop,       unimp,     unimp,     unimp,     unimp,    unimp,     php,    unimp,     unimp,  phd,   unimp,     unimp,     unimp,     unimp     // 0x00-0x0F
    .word bpl,   unimp,     unimp,     unimp,     unimp,     unimp,     unimp,    unimp,     clc,    unimp,     unimp,  tcs,   unimp,     unimp,     unimp,     unimp     // 0x10-0x1F
    .word jsr,   unimp,     jsl,       unimp,     unimp,     unimp,     unimp,    unimp,     plp,    unimp,     unimp,  pld,   unimp,     unimp,     unimp,     unimp     // 0x20-0x2F
    .word bmi,   unimp,     unimp,     unimp,     unimp,     unimp,     unimp,    unimp,     sec,    unimp,     unimp,  tsc,   unimp,     unimp,     unimp,     unimp     // 0x30-0x3F
    .word rti,   unimp,     wdm,       unimp,     mvp_8,     unimp,     unimp,    unimp,     pha_16, unimp,     unimp,  phk,   jmp,       unimp,     unimp,     unimp     // 0x40-0x4F
    .word bvc,   unimp,     unimp,     unimp,     mvn_8,     unimp,     unimp,    unimp,     cli,    unimp,     phy_8,  tcd,   jml,       unimp,     unimp,     unimp     // 0x50-0x5F
    .word rts,   unimp,     per,       unimp,     stzdir_16, unimp,     unimp,    unimp,     pla_16, unimp,     unimp,  rtl,   jmpind,    unimp,     unimp,     unimp     // 0x60-0x6F
    .word bvs,   unimp,     unimp,     unimp,     stzdrx_16, unimp,     unimp,    unimp,     sei,    unimp,     ply_8,  tdc,   jmpidx,    unimp,     unimp,     unimp     // 0x70-0x7F
    .word bra,   staidx_16, brl,       stadrs_16, stydir_8,  stadir_16, stxdir_8, staidl_16, unimp,  unimp,     txa_16, phb,   styabs_8,  staabs_16, stxabs_8,  stalng_16 // 0x80-0x8F
    .word bcc,   staidy_16, staind_16, staisy_16, stydrx_8,  stadrx_16, stxdry_8, staily_16, tya_16, staaby_16, txs,    txy_8, stzabs_16, staabx_16, stzabx_16, stalnx_16 // 0x90-0x9F
    .word ldy_8, ldaidx_16, ldx_8,     ldadrs_16, ldydir_8,  ldadir_16, ldxdir_8, ldaidl_16, tay_8,  lda_16,    tax_8,  plb,   ldyabs_8,  ldaabs_16, ldxabs_8,  ldalng_16 // 0xA0-0xAF
    .word bcs,   ldaidy_16, ldaind_16, ldaisy_16, ldydrx_8,  ldadrx_16, ldxdry_8, ldaily_16, clv,    ldaaby_16, tsx_8,  tyx_8, ldyabx_8,  ldaabx_16, ldxaby_8,  ldalnx_16 // 0xB0-0xBF
    .word unimp, unimp,     rep,       unimp,     unimp,     unimp,     unimp,    unimp,     unimp,  unimp,     unimp,  wai,   unimp,     unimp,     unimp,     unimp     // 0xC0-0xCF
    .word bne,   unimp,     unimp,     unimp,     pei,       unimp,     unimp,    unimp,     cld,    unimp,     phx_8,  stp,   jmlind,    unimp,     unimp,     unimp     // 0xD0-0xDF
    .word unimp, unimp,     sep,       unimp,     unimp,     unimp,     unimp,    unimp,     unimp,  unimp,     nop,    xba,   unimp,     unimp,     unimp,     unimp     // 0xE0-0xEF
    .word beq,   unimp,     unimp,     unimp,     pea,       unimp,     unimp,    unimp,     sed,    unimp,     plx_8,  xce,   jsridx,    unimp,     unimp,     unimp     // 0xF0-0xFF

opcodes_a8: // Lookup table for 8-bit accumulator mode
    .word brk,    unimp,    cop,      unimp,    unimp,     unimp,    unimp,     unimp,    php,    unimp,    unimp,  phd,    unimp,     unimp,    unimp,     unimp    // 0x00-0x0F
    .word bpl,    unimp,    unimp,    unimp,    unimp,     unimp,    unimp,     unimp,    clc,    unimp,    unimp,  tcs,    unimp,     unimp,    unimp,     unimp    // 0x10-0x1F
    .word jsr,    unimp,    jsl,      unimp,    unimp,     unimp,    unimp,     unimp,    plp,    unimp,    unimp,  pld,    unimp,     unimp,    unimp,     unimp    // 0x20-0x2F
    .word bmi,    unimp,    unimp,    unimp,    unimp,     unimp,    unimp,     unimp,    sec,    unimp,    unimp,  tsc,    unimp,     unimp,    unimp,     unimp    // 0x30-0x3F
    .word rti,    unimp,    wdm,      unimp,    mvp_16,    unimp,    unimp,     unimp,    pha_8,  unimp,    unimp,  phk,    jmp,       unimp,    unimp,     unimp    // 0x40-0x4F
    .word bvc,    unimp,    unimp,    unimp,    mvn_16,    unimp,    unimp,     unimp,    cli,    unimp,    phy_16, tcd,    jml,       unimp,    unimp,     unimp    // 0x50-0x5F
    .word rts,    unimp,    per,      unimp,    stzdir_8,  unimp,    unimp,     unimp,    pla_8,  unimp,    unimp,  rtl,    jmpind,    unimp,    unimp,     unimp    // 0x60-0x6F
    .word bvs,    unimp,    unimp,    unimp,    stzdrx_8,  unimp,    unimp,     unimp,    sei,    unimp,    ply_16, tdc,    jmpidx,    unimp,    unimp,     unimp    // 0x70-0x7F
    .word bra,    staidx_8, brl,      stadrs_8, stydir_16, stadir_8, stxdir_16, staidl_8, unimp,  unimp,    txa_8,  phb,    styabs_16, staabs_8, stxabs_16, stalng_8 // 0x80-0x8F
    .word bcc,    staidy_8, staind_8, staisy_8, stydrx_16, stadrx_8, stxdry_16, staily_8, tya_8,  staaby_8, txs,    txy_16, stzabs_8,  staabx_8, stzabx_8,  stalnx_8 // 0x90-0x9F
    .word ldy_16, ldaidx_8, ldx_16,   ldadrs_8, ldydir_16, ldadir_8, ldxdir_16, ldaidl_8, tay_16, lda_8,    tax_16, plb,    ldyabs_16, ldaabs_8, ldxabs_16, ldalng_8 // 0xA0-0xAF
    .word bcs,    ldaidy_8, ldaind_8, ldaisy_8, ldydrx_16, ldadrx_8, ldxdry_16, ldaily_8, clv,    ldaaby_8, tsx_16, tyx_16, ldyabx_16, ldaabx_8, ldxaby_16, ldalnx_8 // 0xB0-0xBF
    .word unimp,  unimp,    rep,      unimp,    unimp,     unimp,    unimp,     unimp,    unimp,  unimp,    unimp,  wai,    unimp,     unimp,    unimp,     unimp    // 0xC0-0xCF
    .word bne,    unimp,    unimp,    unimp,    pei,       unimp,    unimp,     unimp,    cld,    unimp,    phx_16, stp,    jmlind,    unimp,    unimp,     unimp    // 0xD0-0xDF
    .word unimp,  unimp,    sep,      unimp,    unimp,     unimp,    unimp,     unimp,    unimp,  unimp,    nop,    xba,    unimp,     unimp,    unimp,     unimp    // 0xE0-0xEF
    .word beq,    unimp,    unimp,    unimp,    pea,       unimp,    unimp,     unimp,    sed,    unimp,    plx_16, xce,    jsridx,    unimp,    unimp,     unimp    // 0xF0-0xFF

opcodes_16: // Lookup table for 16-bit mode
    .word brk,    unimp,     cop,       unimp,     unimp,     unimp,     unimp,     unimp,     php,    unimp,     unimp,  phd,    unimp,     unimp,     unimp,     unimp     // 0x00-0x0F
    .word bpl,    unimp,     unimp,     unimp,     unimp,     unimp,     unimp,     unimp,     clc,    unimp,     unimp,  tcs,    unimp,     unimp,     unimp,     unimp     // 0x10-0x1F
    .word jsr,    unimp,     jsl,       unimp,     unimp,     unimp,     unimp,     unimp,     plp,    unimp,     unimp,  pld,    unimp,     unimp,     unimp,     unimp     // 0x20-0x2F
    .word bmi,    unimp,     unimp,     unimp,     unimp,     unimp,     unimp,     unimp,     sec,    unimp,     unimp,  tsc,    unimp,     unimp,     unimp,     unimp     // 0x30-0x3F
    .word rti,    unimp,     wdm,       unimp,     mvp_16,    unimp,     unimp,     unimp,     pha_16, unimp,     unimp,  phk,    jmp,       unimp,     unimp,     unimp     // 0x40-0x4F
    .word bvc,    unimp,     unimp,     unimp,     mvn_16,    unimp,     unimp,     unimp,     cli,    unimp,     phy_16, tcd,    jml,       unimp,     unimp,     unimp     // 0x50-0x5F
    .word rts,    unimp,     per,       unimp,     stzdir_16, unimp,     unimp,     unimp,     pla_16, unimp,     unimp,  rtl,    jmpind,    unimp,     unimp,     unimp     // 0x60-0x6F
    .word bvs,    unimp,     unimp,     unimp,     stzdrx_16, unimp,     unimp,     unimp,     sei,    unimp,     ply_16, tdc,    jmpidx,    unimp,     unimp,     unimp     // 0x70-0x7F
    .word bra,    staidx_16, brl,       stadrs_16, stydir_16, stadir_16, stxdir_16, staidl_16, unimp,  unimp,     txa_16, phb,    styabs_16, staabs_16, stxabs_16, stalng_16 // 0x80-0x8F
    .word bcc,    staidy_16, staind_16, staisy_16, stydrx_16, stadrx_16, stxdry_16, staily_16, tya_16, staaby_16, txs,    txy_16, stzabs_16, staabx_16, stzabx_16, stalnx_16 // 0x90-0x9F
    .word ldy_16, ldaidx_16, ldx_16,    ldadrs_16, ldydir_16, ldadir_16, ldxdir_16, ldaidl_16, tay_16, lda_16,    tax_16, plb,    ldyabs_16, ldaabs_16, ldxabs_16, ldalng_16 // 0xA0-0xAF
    .word bcs,    ldaidy_16, ldaind_16, ldaisy_16, ldydrx_16, ldadrx_16, ldxdry_16, ldaily_16, clv,    ldaaby_16, tsx_16, tyx_16, ldyabx_16, ldaabx_16, ldxaby_16, ldalnx_16 // 0xB0-0xBF
    .word unimp,  unimp,     rep,       unimp,     unimp,     unimp,     unimp,     unimp,     unimp,  unimp,     unimp,  wai,    unimp,     unimp,     unimp,     unimp     // 0xC0-0xCF
    .word bne,    unimp,     unimp,     unimp,     pei,       unimp,     unimp,     unimp,     cld,    unimp,     phx_16, stp,    jmlind,    unimp,     unimp,     unimp     // 0xD0-0xDF
    .word unimp,  unimp,     sep,       unimp,     unimp,     unimp,     unimp,     unimp,     unimp,  unimp,     nop,    xba,    unimp,     unimp,     unimp,     unimp     // 0xE0-0xEF
    .word beq,    unimp,     unimp,     unimp,     pea,       unimp,     unimp,     unimp,     sed,    unimp,     plx_16, xce,    jsridx,    unimp,     unimp,     unimp     // 0xF0-0xFF

.text

cpu_init:
    // Set the initial program counter value (s7)
    move s0, ra     // Backup return address
    li   a0, 0xFFFC // RESET vector
    jal  memory_read16
    move s7, v0

    // Set the initial lookup table (s6), cycle count (s5), and status flags (s4)
    la   s6, opcodes_emu
    li   s5, 0
    li   s4, 0x100
    jr   s0


set_nz8: // a0: value
    // Adjust the value for 16-bit logic
    sll  a0, a0, 8

set_nz16: // a0: value
    // Set the NZ flags and fall directly back into execution
    andi s4, s4, ~0x82 & 0xFFFF
    bne  a0, zero, not_zero
    ori  s4, s4, 0x02 // Z
not_zero:
    srl  a0, a0, 8
    andi a0, a0, 0x80 // N
    or   s4, s4, a0


cpu_execute:
    // Fetch the current opcode
    move a0, s7
    jal  memory_read8

    // Jump to the opcode's function in the lookup table
    sll  t0, v0, 2 // Table offset
    add  t0, t0, s6
    lw   t0, (t0)
    jr   t0


update_mode:
    // Check if the emulation flag is set
    andi t0, s4, 0x100
    beq  t0, zero, not_emu

    // Switch to emulation mode
    la   s6, opcodes_emu
    andi s7, 0xFFFF       // Clear PC bank
    li   t0, 0x01
    sb   t0, stack_ptr    // Reset SP bank
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    sh   zero, direct_ofs
    sb   zero, data_bank
    j    cpu_execute

    // Check if both 8-bit flags are set
not_emu:
    li   t1, 0x30
    and  t0, s4, t1
    bne  t0, t1, not_8

    // Switch to full 8-bit mode
    la   s6, opcodes_8
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    j    cpu_execute

    // Check if the 8-bit register flag is set
not_8:
    andi t0, s4, 0x10
    beq  t0, zero, not_r8

    // Switch to 8-bit register mode
    la   s6, opcodes_r8
    sb   zero, register_x // Clear high byte
    sb   zero, register_y // Clear high byte
    j    cpu_execute

    // Check if the 8-bit accumulator flag is set
not_r8:
    andi t0, s4, 0x20
    beq  t0, zero, not_a8

    // Switch to 8-bit accumulator mode
    la   s6, opcodes_a8
    j    cpu_execute

    // Switch to 16-bit mode
not_a8:
    la   s6, opcodes_16
    j    cpu_execute


unimp:
    // Placeholder for unimplemented opcodes
    j    unimp
