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

.globl oraimm_8
.globl oradir_8
.globl oradrx_8
.globl oradrs_8
.globl oraabs_8
.globl oraabx_8
.globl oraaby_8
.globl oralng_8
.globl oralnx_8
.globl oraind_8
.globl oraidx_8
.globl oraidy_8
.globl oraisy_8
.globl oraidl_8
.globl oraily_8
.globl oraimm_16
.globl oradir_16
.globl oradrx_16
.globl oradrs_16
.globl oraabs_16
.globl oraabx_16
.globl oraaby_16
.globl oralng_16
.globl oralnx_16
.globl oraind_16
.globl oraidx_16
.globl oraidy_16
.globl oraisy_16
.globl oraidl_16
.globl oraily_16
.globl andimm_8
.globl anddir_8
.globl anddrx_8
.globl anddrs_8
.globl andabs_8
.globl andabx_8
.globl andaby_8
.globl andlng_8
.globl andlnx_8
.globl andind_8
.globl andidx_8
.globl andidy_8
.globl andisy_8
.globl andidl_8
.globl andily_8
.globl andimm_16
.globl anddir_16
.globl anddrx_16
.globl anddrs_16
.globl andabs_16
.globl andabx_16
.globl andaby_16
.globl andlng_16
.globl andlnx_16
.globl andind_16
.globl andidx_16
.globl andidy_16
.globl andisy_16
.globl andidl_16
.globl andily_16
.globl eorimm_8
.globl eordir_8
.globl eordrx_8
.globl eordrs_8
.globl eorabs_8
.globl eorabx_8
.globl eoraby_8
.globl eorlng_8
.globl eorlnx_8
.globl eorind_8
.globl eoridx_8
.globl eoridy_8
.globl eorisy_8
.globl eoridl_8
.globl eorily_8
.globl eorimm_16
.globl eordir_16
.globl eordrx_16
.globl eordrs_16
.globl eorabs_16
.globl eorabx_16
.globl eoraby_16
.globl eorlng_16
.globl eorlnx_16
.globl eorind_16
.globl eoridx_16
.globl eoridy_16
.globl eorisy_16
.globl eoridl_16
.globl eorily_16
.globl adcimm_8
.globl adcdir_8
.globl adcdrx_8
.globl adcdrs_8
.globl adcabs_8
.globl adcabx_8
.globl adcaby_8
.globl adclng_8
.globl adclnx_8
.globl adcind_8
.globl adcidx_8
.globl adcidy_8
.globl adcisy_8
.globl adcidl_8
.globl adcily_8
.globl adcimm_16
.globl adcdir_16
.globl adcdrx_16
.globl adcdrs_16
.globl adcabs_16
.globl adcabx_16
.globl adcaby_16
.globl adclng_16
.globl adclnx_16
.globl adcind_16
.globl adcidx_16
.globl adcidy_16
.globl adcisy_16
.globl adcidl_16
.globl adcily_16
.globl adcimm_8d
.globl adcdir_8d
.globl adcdrx_8d
.globl adcdrs_8d
.globl adcabs_8d
.globl adcabx_8d
.globl adcaby_8d
.globl adclng_8d
.globl adclnx_8d
.globl adcind_8d
.globl adcidx_8d
.globl adcidy_8d
.globl adcisy_8d
.globl adcidl_8d
.globl adcily_8d
.globl adcimm_16d
.globl adcdir_16d
.globl adcdrx_16d
.globl adcdrs_16d
.globl adcabs_16d
.globl adcabx_16d
.globl adcaby_16d
.globl adclng_16d
.globl adclnx_16d
.globl adcind_16d
.globl adcidx_16d
.globl adcidy_16d
.globl adcisy_16d
.globl adcidl_16d
.globl adcily_16d
.globl sbcimm_8
.globl sbcdir_8
.globl sbcdrx_8
.globl sbcdrs_8
.globl sbcabs_8
.globl sbcabx_8
.globl sbcaby_8
.globl sbclng_8
.globl sbclnx_8
.globl sbcind_8
.globl sbcidx_8
.globl sbcidy_8
.globl sbcisy_8
.globl sbcidl_8
.globl sbcily_8
.globl sbcimm_16
.globl sbcdir_16
.globl sbcdrx_16
.globl sbcdrs_16
.globl sbcabs_16
.globl sbcabx_16
.globl sbcaby_16
.globl sbclng_16
.globl sbclnx_16
.globl sbcind_16
.globl sbcidx_16
.globl sbcidy_16
.globl sbcisy_16
.globl sbcidl_16
.globl sbcily_16
.globl sbcimm_8d
.globl sbcdir_8d
.globl sbcdrx_8d
.globl sbcdrs_8d
.globl sbcabs_8d
.globl sbcabx_8d
.globl sbcaby_8d
.globl sbclng_8d
.globl sbclnx_8d
.globl sbcind_8d
.globl sbcidx_8d
.globl sbcidy_8d
.globl sbcisy_8d
.globl sbcidl_8d
.globl sbcily_8d
.globl sbcimm_16d
.globl sbcdir_16d
.globl sbcdrx_16d
.globl sbcdrs_16d
.globl sbcabs_16d
.globl sbcabx_16d
.globl sbcaby_16d
.globl sbclng_16d
.globl sbclnx_16d
.globl sbcind_16d
.globl sbcidx_16d
.globl sbcidy_16d
.globl sbcisy_16d
.globl sbcidl_16d
.globl sbcily_16d
.globl cmpimm_8
.globl cmpdir_8
.globl cmpdrx_8
.globl cmpdrs_8
.globl cmpabs_8
.globl cmpabx_8
.globl cmpaby_8
.globl cmplng_8
.globl cmplnx_8
.globl cmpind_8
.globl cmpidx_8
.globl cmpidy_8
.globl cmpisy_8
.globl cmpidl_8
.globl cmpily_8
.globl cmpimm_16
.globl cmpdir_16
.globl cmpdrx_16
.globl cmpdrs_16
.globl cmpabs_16
.globl cmpabx_16
.globl cmpaby_16
.globl cmplng_16
.globl cmplnx_16
.globl cmpind_16
.globl cmpidx_16
.globl cmpidy_16
.globl cmpisy_16
.globl cmpidl_16
.globl cmpily_16
.globl cpximm_8
.globl cpxdir_8
.globl cpxabs_8
.globl cpximm_16
.globl cpxdir_16
.globl cpxabs_16
.globl cpyimm_8
.globl cpydir_8
.globl cpyabs_8
.globl cpyimm_16
.globl cpydir_16
.globl cpyabs_16
.globl bit_8
.globl bit_16
.globl bitdir_8
.globl bitdrx_8
.globl bitabs_8
.globl bitabx_8
.globl bitdir_16
.globl bitdrx_16
.globl bitabs_16
.globl bitabx_16
.globl incdir_8
.globl incdrx_8
.globl incabs_8
.globl incabx_8
.globl incdir_16
.globl incdrx_16
.globl incabs_16
.globl incabx_16
.globl inx_8
.globl inx_16
.globl iny_8
.globl iny_16
.globl ina_8
.globl ina_16
.globl decdir_8
.globl decdrx_8
.globl decabs_8
.globl decabx_8
.globl decdir_16
.globl decdrx_16
.globl decabs_16
.globl decabx_16
.globl dex_8
.globl dex_16
.globl dey_8
.globl dey_16
.globl dea_8
.globl dea_16
.globl tsbdir_8
.globl tsbabs_8
.globl tsbdir_16
.globl tsbabs_16
.globl trbdir_8
.globl trbabs_8
.globl trbdir_16
.globl trbabs_16
.globl asl_8
.globl asl_16
.globl asldir_8
.globl asldrx_8
.globl aslabs_8
.globl aslabx_8
.globl asldir_16
.globl asldrx_16
.globl aslabs_16
.globl aslabx_16
.globl lsr_8
.globl lsr_16
.globl lsrdir_8
.globl lsrdrx_8
.globl lsrabs_8
.globl lsrabx_8
.globl lsrdir_16
.globl lsrdrx_16
.globl lsrabs_16
.globl lsrabx_16
.globl rol_8
.globl rol_16
.globl roldir_8
.globl roldrx_8
.globl rolabs_8
.globl rolabx_8
.globl roldir_16
.globl roldrx_16
.globl rolabs_16
.globl rolabx_16
.globl ror_8
.globl ror_16
.globl rordir_8
.globl rordrx_8
.globl rorabs_8
.globl rorabx_8
.globl rordir_16
.globl rordrx_16
.globl rorabs_16
.globl rorabx_16

.text

.macro ORA_8 // ORA op (8-bit)
    // Bitwise or a value with the accumulator and set flags (8-bit)
    MEM_READ8
    lbu a0, accumulator + 1
    or a0, a0, v0
    sb a0, accumulator + 1
    j set_nz8
.endm

oraimm_8: IM8; ORA_8 // ORA #nn (8-bit)
oradir_8: DIR; ORA_8 // ORA nn (8-bit)
oradrx_8: DRX; ORA_8 // ORA nn,X (8-bit)
oradrs_8: DRS; ORA_8 // ORA nn,S (8-bit)
oraabs_8: ABS; ORA_8 // ORA nnnn (8-bit)
oraabx_8: ABX; ORA_8 // ORA nnnn,X (8-bit)
oraaby_8: ABY; ORA_8 // ORA nnnn,Y (8-bit)
oralng_8: LNG; ORA_8 // ORA nnnnnn (8-bit)
oralnx_8: LNX; ORA_8 // ORA nnnnnn,X (8-bit)
oraind_8: IND; ORA_8 // ORA (nn) (8-bit)
oraidx_8: IDX; ORA_8 // ORA (nn,X) (8-bit)
oraidy_8: IDY; ORA_8 // ORA (nn),Y (8-bit)
oraisy_8: ISY; ORA_8 // ORA (nn,S),Y (8-bit)
oraidl_8: IDL; ORA_8 // ORA [nn] (8-bit)
oraily_8: ILY; ORA_8 // ORA [nn],Y (8-bit)


.macro ORA_16 // ORA op (16-bit)
    // Bitwise or a value with the accumulator and set flags (16-bit)
    MEM_READ16
    lhu a0, accumulator
    or a0, a0, v0
    sh a0, accumulator
    j set_nz16
.endm

oraimm_16: I16; ORA_16 // ORA #nnnn (16-bit)
oradir_16: DIR; ORA_16 // ORA nn (16-bit)
oradrx_16: DRX; ORA_16 // ORA nn,X (16-bit)
oradrs_16: DRS; ORA_16 // ORA nn,S (16-bit)
oraabs_16: ABS; ORA_16 // ORA nnnn (16-bit)
oraabx_16: ABX; ORA_16 // ORA nnnn,X (16-bit)
oraaby_16: ABY; ORA_16 // ORA nnnn,Y (16-bit)
oralng_16: LNG; ORA_16 // ORA nnnnnn (16-bit)
oralnx_16: LNX; ORA_16 // ORA nnnnnn,X (16-bit)
oraind_16: IND; ORA_16 // ORA (nn) (16-bit)
oraidx_16: IDX; ORA_16 // ORA (nn,X) (16-bit)
oraidy_16: IDY; ORA_16 // ORA (nn),Y (16-bit)
oraisy_16: ISY; ORA_16 // ORA (nn,S),Y (16-bit)
oraidl_16: IDL; ORA_16 // ORA [nn] (16-bit)
oraily_16: ILY; ORA_16 // ORA [nn],Y (16-bit)


.macro AND_8 // AND op (8-bit)
    // Bitwise and a value with the accumulator and set flags (8-bit)
    MEM_READ8
    lbu a0, accumulator + 1
    and a0, a0, v0
    sb a0, accumulator + 1
    j set_nz8
.endm

andimm_8: IM8; AND_8 // AND #nn (8-bit)
anddir_8: DIR; AND_8 // AND nn (8-bit)
anddrx_8: DRX; AND_8 // AND nn,X (8-bit)
anddrs_8: DRS; AND_8 // AND nn,S (8-bit)
andabs_8: ABS; AND_8 // AND nnnn (8-bit)
andabx_8: ABX; AND_8 // AND nnnn,X (8-bit)
andaby_8: ABY; AND_8 // AND nnnn,Y (8-bit)
andlng_8: LNG; AND_8 // AND nnnnnn (8-bit)
andlnx_8: LNX; AND_8 // AND nnnnnn,X (8-bit)
andind_8: IND; AND_8 // AND (nn) (8-bit)
andidx_8: IDX; AND_8 // AND (nn,X) (8-bit)
andidy_8: IDY; AND_8 // AND (nn),Y (8-bit)
andisy_8: ISY; AND_8 // AND (nn,S),Y (8-bit)
andidl_8: IDL; AND_8 // AND [nn] (8-bit)
andily_8: ILY; AND_8 // AND [nn],Y (8-bit)


.macro AND_16 // AND op (16-bit)
    // Bitwise and a value with the accumulator and set flags (16-bit)
    MEM_READ16
    lhu a0, accumulator
    and a0, a0, v0
    sh a0, accumulator
    j set_nz16
.endm

andimm_16: I16; AND_16 // AND #nnnn (16-bit)
anddir_16: DIR; AND_16 // AND nn (16-bit)
anddrx_16: DRX; AND_16 // AND nn,X (16-bit)
anddrs_16: DRS; AND_16 // AND nn,S (16-bit)
andabs_16: ABS; AND_16 // AND nnnn (16-bit)
andabx_16: ABX; AND_16 // AND nnnn,X (16-bit)
andaby_16: ABY; AND_16 // AND nnnn,Y (16-bit)
andlng_16: LNG; AND_16 // AND nnnnnn (16-bit)
andlnx_16: LNX; AND_16 // AND nnnnnn,X (16-bit)
andind_16: IND; AND_16 // AND (nn) (16-bit)
andidx_16: IDX; AND_16 // AND (nn,X) (16-bit)
andidy_16: IDY; AND_16 // AND (nn),Y (16-bit)
andisy_16: ISY; AND_16 // AND (nn,S),Y (16-bit)
andidl_16: IDL; AND_16 // AND [nn] (16-bit)
andily_16: ILY; AND_16 // AND [nn],Y (16-bit)


.macro EOR_8 // EOR op (8-bit)
    // Bitwise exclusive-or a value with the accumulator and set flags (8-bit)
    MEM_READ8
    lbu a0, accumulator + 1
    xor a0, a0, v0
    sb a0, accumulator + 1
    j set_nz8
.endm

eorimm_8: IM8; EOR_8 // EOR #nn (8-bit)
eordir_8: DIR; EOR_8 // EOR nn (8-bit)
eordrx_8: DRX; EOR_8 // EOR nn,X (8-bit)
eordrs_8: DRS; EOR_8 // EOR nn,S (8-bit)
eorabs_8: ABS; EOR_8 // EOR nnnn (8-bit)
eorabx_8: ABX; EOR_8 // EOR nnnn,X (8-bit)
eoraby_8: ABY; EOR_8 // EOR nnnn,Y (8-bit)
eorlng_8: LNG; EOR_8 // EOR nnnnnn (8-bit)
eorlnx_8: LNX; EOR_8 // EOR nnnnnn,X (8-bit)
eorind_8: IND; EOR_8 // EOR (nn) (8-bit)
eoridx_8: IDX; EOR_8 // EOR (nn,X) (8-bit)
eoridy_8: IDY; EOR_8 // EOR (nn),Y (8-bit)
eorisy_8: ISY; EOR_8 // EOR (nn,S),Y (8-bit)
eoridl_8: IDL; EOR_8 // EOR [nn] (8-bit)
eorily_8: ILY; EOR_8 // EOR [nn],Y (8-bit)


.macro EOR_16 // EOR op (16-bit)
    // Bitwise exclusive-or a value with the accumulator and set flags (16-bit)
    MEM_READ16
    lhu a0, accumulator
    xor a0, a0, v0
    sh a0, accumulator
    j set_nz16
.endm

eorimm_16: I16; EOR_16 // EOR #nnnn (16-bit)
eordir_16: DIR; EOR_16 // EOR nn (16-bit)
eordrx_16: DRX; EOR_16 // EOR nn,X (16-bit)
eordrs_16: DRS; EOR_16 // EOR nn,S (16-bit)
eorabs_16: ABS; EOR_16 // EOR nnnn (16-bit)
eorabx_16: ABX; EOR_16 // EOR nnnn,X (16-bit)
eoraby_16: ABY; EOR_16 // EOR nnnn,Y (16-bit)
eorlng_16: LNG; EOR_16 // EOR nnnnnn (16-bit)
eorlnx_16: LNX; EOR_16 // EOR nnnnnn,X (16-bit)
eorind_16: IND; EOR_16 // EOR (nn) (16-bit)
eoridx_16: IDX; EOR_16 // EOR (nn,X) (16-bit)
eoridy_16: IDY; EOR_16 // EOR (nn),Y (16-bit)
eorisy_16: ISY; EOR_16 // EOR (nn,S),Y (16-bit)
eoridl_16: IDL; EOR_16 // EOR [nn] (16-bit)
eorily_16: ILY; EOR_16 // EOR [nn],Y (16-bit)


.macro ADC_8 // ADC op (8-bit)
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
    andi a0, a0, 0xFF
    j set_nz8
.endm

adcimm_8: IM8; ADC_8 // ADC #nn (8-bit)
adcdir_8: DIR; ADC_8 // ADC nn (8-bit)
adcdrx_8: DRX; ADC_8 // ADC nn,X (8-bit)
adcdrs_8: DRS; ADC_8 // ADC nn,S (8-bit)
adcabs_8: ABS; ADC_8 // ADC nnnn (8-bit)
adcabx_8: ABX; ADC_8 // ADC nnnn,X (8-bit)
adcaby_8: ABY; ADC_8 // ADC nnnn,Y (8-bit)
adclng_8: LNG; ADC_8 // ADC nnnnnn (8-bit)
adclnx_8: LNX; ADC_8 // ADC nnnnnn,X (8-bit)
adcind_8: IND; ADC_8 // ADC (nn) (8-bit)
adcidx_8: IDX; ADC_8 // ADC (nn,X) (8-bit)
adcidy_8: IDY; ADC_8 // ADC (nn),Y (8-bit)
adcisy_8: ISY; ADC_8 // ADC (nn,S),Y (8-bit)
adcidl_8: IDL; ADC_8 // ADC [nn] (8-bit)
adcily_8: ILY; ADC_8 // ADC [nn],Y (8-bit)


.macro ADC_16 // ADC op (16-bit)
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
    andi a0, a0, 0xFFFF
    j set_nz16
.endm

adcimm_16: I16; ADC_16 // ADC #nnnn (16-bit)
adcdir_16: DIR; ADC_16 // ADC nn (16-bit)
adcdrx_16: DRX; ADC_16 // ADC nn,X (16-bit)
adcdrs_16: DRS; ADC_16 // ADC nn,S (16-bit)
adcabs_16: ABS; ADC_16 // ADC nnnn (16-bit)
adcabx_16: ABX; ADC_16 // ADC nnnn,X (16-bit)
adcaby_16: ABY; ADC_16 // ADC nnnn,Y (16-bit)
adclng_16: LNG; ADC_16 // ADC nnnnnn (16-bit)
adclnx_16: LNX; ADC_16 // ADC nnnnnn,X (16-bit)
adcind_16: IND; ADC_16 // ADC (nn) (16-bit)
adcidx_16: IDX; ADC_16 // ADC (nn,X) (16-bit)
adcidy_16: IDY; ADC_16 // ADC (nn),Y (16-bit)
adcisy_16: ISY; ADC_16 // ADC (nn,S),Y (16-bit)
adcidl_16: IDL; ADC_16 // ADC [nn] (16-bit)
adcily_16: ILY; ADC_16 // ADC [nn],Y (16-bit)


.macro ADC_8D num // ADC op (8-bit BCD)
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
    blt a0, 0xA, adc8_dec2\num
    addi a0, a0, 0x6
    andi a0, a0, 0xF
    addi a0, a0, 0x10

adc8_dec2\num:
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
    blt a0, 0xA0, adc8_end\num
    addi a0, a0, 0x60

adc8_end\num:
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
    andi a0, a0, 0xFF
    j set_nz8
.endm

adcimm_8d: IM8; ADC_8D 1 // ADC #nn (8-bit BCD)
adcdir_8d: DIR; ADC_8D 2 // ADC nn (8-bit BCD)
adcdrx_8d: DRX; ADC_8D 3 // ADC nn,X (8-bit BCD)
adcdrs_8d: DRS; ADC_8D 4 // ADC nn,S (8-bit BCD)
adcabs_8d: ABS; ADC_8D 5 // ADC nnnn (8-bit BCD)
adcabx_8d: ABX; ADC_8D 6 // ADC nnnn,X (8-bit BCD)
adcaby_8d: ABY; ADC_8D 7 // ADC nnnn,Y (8-bit BCD)
adclng_8d: LNG; ADC_8D 8 // ADC nnnnnn (8-bit BCD)
adclnx_8d: LNX; ADC_8D 9 // ADC nnnnnn,X (8-bit BCD)
adcind_8d: IND; ADC_8D A // ADC (nn) (8-bit BCD)
adcidx_8d: IDX; ADC_8D B // ADC (nn,X) (8-bit BCD)
adcidy_8d: IDY; ADC_8D C // ADC (nn),Y (8-bit BCD)
adcisy_8d: ISY; ADC_8D D // ADC (nn,S),Y (8-bit BCD)
adcidl_8d: IDL; ADC_8D E // ADC [nn] (8-bit BCD)
adcily_8d: ILY; ADC_8D F // ADC [nn],Y (8-bit BCD)


.macro ADC_16D num // ADC op (16-bit BCD)
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
    blt a0, 0xA, adc16_dec2\num
    addi a0, a0, 0x6
    andi a0, a0, 0xF
    addi a0, a0, 0x10

adc16_dec2\num:
    // Add the second decimal digit
    andi t2, t0, 0xF0
    andi t3, v0, 0xF0
    add t2, t2, t3
    add a0, a0, t2

    // Adjust the second digit on overflow
    blt a0, 0xA0, adc16_dec3\num
    addi a0, a0, 0x60
    andi a0, a0, 0xFF
    addi a0, a0, 0x100

adc16_dec3\num:
    // Add the third decimal digit
    andi t2, t0, 0xF00
    andi t3, v0, 0xF00
    add t2, t2, t3
    add a0, a0, t2

    // Adjust the third digit on overflow
    blt a0, 0xA00, adc16_dec4\num
    addi a0, a0, 0x600
    andi a0, a0, 0xFFF
    addi a0, a0, 0x1000

adc16_dec4\num:
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
    blt a0, 0xA000, adc16_end\num
    addi a0, a0, 0x6000

adc16_end\num:
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
    andi a0, a0, 0xFFFF
    j set_nz16
.endm

adcimm_16d: I16; ADC_16D 1 // ADC #nnnn (16-bit BCD)
adcdir_16d: DIR; ADC_16D 2 // ADC nn (16-bit BCD)
adcdrx_16d: DRX; ADC_16D 3 // ADC nn,X (16-bit BCD)
adcdrs_16d: DRS; ADC_16D 4 // ADC nn,S (16-bit BCD)
adcabs_16d: ABS; ADC_16D 5 // ADC nnnn (16-bit BCD)
adcabx_16d: ABX; ADC_16D 6 // ADC nnnn,X (16-bit BCD)
adcaby_16d: ABY; ADC_16D 7 // ADC nnnn,Y (16-bit BCD)
adclng_16d: LNG; ADC_16D 8 // ADC nnnnnn (16-bit BCD)
adclnx_16d: LNX; ADC_16D 9 // ADC nnnnnn,X (16-bit BCD)
adcind_16d: IND; ADC_16D A // ADC (nn) (16-bit BCD)
adcidx_16d: IDX; ADC_16D B // ADC (nn,X) (16-bit BCD)
adcidy_16d: IDY; ADC_16D C // ADC (nn),Y (16-bit BCD)
adcisy_16d: ISY; ADC_16D D // ADC (nn,S),Y (16-bit BCD)
adcidl_16d: IDL; ADC_16D E // ADC [nn] (16-bit BCD)
adcily_16d: ILY; ADC_16D F // ADC [nn],Y (16-bit BCD)


.macro SBC_8 // SBC op (8-bit)
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
    andi a0, a0, 0xFF
    j set_nz8
.endm

sbcimm_8: IM8; SBC_8 // SBC #nn (8-bit)
sbcdir_8: DIR; SBC_8 // SBC nn (8-bit)
sbcdrx_8: DRX; SBC_8 // SBC nn,X (8-bit)
sbcdrs_8: DRS; SBC_8 // SBC nn,S (8-bit)
sbcabs_8: ABS; SBC_8 // SBC nnnn (8-bit)
sbcabx_8: ABX; SBC_8 // SBC nnnn,X (8-bit)
sbcaby_8: ABY; SBC_8 // SBC nnnn,Y (8-bit)
sbclng_8: LNG; SBC_8 // SBC nnnnnn (8-bit)
sbclnx_8: LNX; SBC_8 // SBC nnnnnn,X (8-bit)
sbcind_8: IND; SBC_8 // SBC (nn) (8-bit)
sbcidx_8: IDX; SBC_8 // SBC (nn,X) (8-bit)
sbcidy_8: IDY; SBC_8 // SBC (nn),Y (8-bit)
sbcisy_8: ISY; SBC_8 // SBC (nn,S),Y (8-bit)
sbcidl_8: IDL; SBC_8 // SBC [nn] (8-bit)
sbcily_8: ILY; SBC_8 // SBC [nn],Y (8-bit)


.macro SBC_16 // SBC op (16-bit)
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
    andi a0, a0, 0xFFFF
    j set_nz16
.endm

sbcimm_16: I16; SBC_16 // SBC #nnnn (16-bit)
sbcdir_16: DIR; SBC_16 // SBC nn (16-bit)
sbcdrx_16: DRX; SBC_16 // SBC nn,X (16-bit)
sbcdrs_16: DRS; SBC_16 // SBC nn,S (16-bit)
sbcabs_16: ABS; SBC_16 // SBC nnnn (16-bit)
sbcabx_16: ABX; SBC_16 // SBC nnnn,X (16-bit)
sbcaby_16: ABY; SBC_16 // SBC nnnn,Y (16-bit)
sbclng_16: LNG; SBC_16 // SBC nnnnnn (16-bit)
sbclnx_16: LNX; SBC_16 // SBC nnnnnn,X (16-bit)
sbcind_16: IND; SBC_16 // SBC (nn) (16-bit)
sbcidx_16: IDX; SBC_16 // SBC (nn,X) (16-bit)
sbcidy_16: IDY; SBC_16 // SBC (nn),Y (16-bit)
sbcisy_16: ISY; SBC_16 // SBC (nn,S),Y (16-bit)
sbcidl_16: IDL; SBC_16 // SBC [nn] (16-bit)
sbcily_16: ILY; SBC_16 // SBC [nn],Y (16-bit)


.macro SBC_8D num // SBC op (8-bit BCD)
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
    bgez a0, sbc8_dec2\num
    addi a0, a0, -0x6
    andi a0, a0, 0xF
    addi a0, a0, -0x10

sbc8_dec2\num:
    // Subtract the last decimal digit (8-bit)
    andi t2, t0, 0xF0
    andi t3, v0, 0xF0
    sub t2, t2, t3
    add a0, a0, t2

    // Adjust the last digit on overflow (8-bit)
    bgez a0, sbc8_end\num
    addi a0, a0, -0x60

sbc8_end\num:
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
    andi a0, a0, 0xFF
    j set_nz8
.endm

sbcimm_8d: IM8; SBC_8D 1 // SBC #nn (8-bit BCD)
sbcdir_8d: DIR; SBC_8D 2 // SBC nn (8-bit BCD)
sbcdrx_8d: DRX; SBC_8D 3 // SBC nn,X (8-bit BCD)
sbcdrs_8d: DRS; SBC_8D 4 // SBC nn,S (8-bit BCD)
sbcabs_8d: ABS; SBC_8D 5 // SBC nnnn (8-bit BCD)
sbcabx_8d: ABX; SBC_8D 6 // SBC nnnn,X (8-bit BCD)
sbcaby_8d: ABY; SBC_8D 7 // SBC nnnn,Y (8-bit BCD)
sbclng_8d: LNG; SBC_8D 8 // SBC nnnnnn (8-bit BCD)
sbclnx_8d: LNX; SBC_8D 9 // SBC nnnnnn,X (8-bit BCD)
sbcind_8d: IND; SBC_8D A // SBC (nn) (8-bit BCD)
sbcidx_8d: IDX; SBC_8D B // SBC (nn,X) (8-bit BCD)
sbcidy_8d: IDY; SBC_8D C // SBC (nn),Y (8-bit BCD)
sbcisy_8d: ISY; SBC_8D D // SBC (nn,S),Y (8-bit BCD)
sbcidl_8d: IDL; SBC_8D E // SBC [nn] (8-bit BCD)
sbcily_8d: ILY; SBC_8D F // SBC [nn],Y (8-bit BCD)


.macro SBC_16D num // SBC op (16-bit BCD)
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
    bgez a0, sbc16_dec2\num
    addi a0, a0, -0x6
    andi a0, a0, 0xF
    addi a0, a0, -0x10

sbc16_dec2\num:
    // Subtract the second decimal digit
    andi t2, t0, 0xF0
    andi t3, v0, 0xF0
    sub t2, t2, t3
    add a0, a0, t2

    // Adjust the second digit on overflow
    bgez a0, sbc16_dec3\num
    addi a0, a0, -0x60
    andi a0, a0, 0xFF
    addi a0, a0, -0x100

sbc16_dec3\num:
    // Subtract the third decimal digit
    andi t2, t0, 0xF00
    andi t3, v0, 0xF00
    sub t2, t2, t3
    add a0, a0, t2

    // Adjust the third digit on overflow
    bgez a0, sbc16_dec4\num
    addi a0, a0, -0x600
    andi a0, a0, 0xFFF
    addi a0, a0, -0x1000

sbc16_dec4\num:
    // Subtract the last decimal digit (16-bit)
    andi t2, t0, 0xF000
    andi t3, v0, 0xF000
    sub t2, t2, t3
    add a0, a0, t2

    // Adjust the last digit on overflow (16-bit)
    bgez a0, sbc16_end\num
    addi a0, a0, -0x6000

sbc16_end\num:
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
    andi a0, a0, 0xFFFF
    j set_nz16
.endm

sbcimm_16d: I16; SBC_16D 1 // SBC #nnnn (16-bit BCD)
sbcdir_16d: DIR; SBC_16D 2 // SBC nn (16-bit BCD)
sbcdrx_16d: DRX; SBC_16D 3 // SBC nn,X (16-bit BCD)
sbcdrs_16d: DRS; SBC_16D 4 // SBC nn,S (16-bit BCD)
sbcabs_16d: ABS; SBC_16D 5 // SBC nnnn (16-bit BCD)
sbcabx_16d: ABX; SBC_16D 6 // SBC nnnn,X (16-bit BCD)
sbcaby_16d: ABY; SBC_16D 7 // SBC nnnn,Y (16-bit BCD)
sbclng_16d: LNG; SBC_16D 8 // SBC nnnnnn (16-bit BCD)
sbclnx_16d: LNX; SBC_16D 9 // SBC nnnnnn,X (16-bit BCD)
sbcind_16d: IND; SBC_16D A // SBC (nn) (16-bit BCD)
sbcidx_16d: IDX; SBC_16D B // SBC (nn,X) (16-bit BCD)
sbcidy_16d: IDY; SBC_16D C // SBC (nn),Y (16-bit BCD)
sbcisy_16d: ISY; SBC_16D D // SBC (nn,S),Y (16-bit BCD)
sbcidl_16d: IDL; SBC_16D E // SBC [nn] (16-bit BCD)
sbcily_16d: ILY; SBC_16D F // SBC [nn],Y (16-bit BCD)


.macro CMP_8 // CMP op (8-bit)
    // Compare a value with the accumulator and set flags (8-bit)
    MEM_READ8
    lbu t0, accumulator + 1
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    andi a0, a0, 0xFF
    j set_nz8
.endm

cmpimm_8: IM8; CMP_8 // CMP #nn (8-bit)
cmpdir_8: DIR; CMP_8 // CMP nn (8-bit)
cmpdrx_8: DRX; CMP_8 // CMP nn,X (8-bit)
cmpdrs_8: DRS; CMP_8 // CMP nn,S (8-bit)
cmpabs_8: ABS; CMP_8 // CMP nnnn (8-bit)
cmpabx_8: ABX; CMP_8 // CMP nnnn,X (8-bit)
cmpaby_8: ABY; CMP_8 // CMP nnnn,Y (8-bit)
cmplng_8: LNG; CMP_8 // CMP nnnnnn (8-bit)
cmplnx_8: LNX; CMP_8 // CMP nnnnnn,X (8-bit)
cmpind_8: IND; CMP_8 // CMP (nn) (8-bit)
cmpidx_8: IDX; CMP_8 // CMP (nn,X) (8-bit)
cmpidy_8: IDY; CMP_8 // CMP (nn),Y (8-bit)
cmpisy_8: ISY; CMP_8 // CMP (nn,S),Y (8-bit)
cmpidl_8: IDL; CMP_8 // CMP [nn] (8-bit)
cmpily_8: ILY; CMP_8 // CMP [nn],Y (8-bit)


.macro CMP_16 // CMP op (16-bit)
    // Compare a value with the accumulator and set flags (16-bit)
    MEM_READ16
    lhu t0, accumulator
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    andi a0, a0, 0xFFFF
    j set_nz16
.endm

cmpimm_16: I16; CMP_16 // CMP #nnnn (16-bit)
cmpdir_16: DIR; CMP_16 // CMP nn (16-bit)
cmpdrx_16: DRX; CMP_16 // CMP nn,X (16-bit)
cmpdrs_16: DRS; CMP_16 // CMP nn,S (16-bit)
cmpabs_16: ABS; CMP_16 // CMP nnnn (16-bit)
cmpabx_16: ABX; CMP_16 // CMP nnnn,X (16-bit)
cmpaby_16: ABY; CMP_16 // CMP nnnn,Y (16-bit)
cmplng_16: LNG; CMP_16 // CMP nnnnnn (16-bit)
cmplnx_16: LNX; CMP_16 // CMP nnnnnn,X (16-bit)
cmpind_16: IND; CMP_16 // CMP (nn) (16-bit)
cmpidx_16: IDX; CMP_16 // CMP (nn,X) (16-bit)
cmpidy_16: IDY; CMP_16 // CMP (nn),Y (16-bit)
cmpisy_16: ISY; CMP_16 // CMP (nn,S),Y (16-bit)
cmpidl_16: IDL; CMP_16 // CMP [nn] (16-bit)
cmpily_16: ILY; CMP_16 // CMP [nn],Y (16-bit)


.macro CPX_8 // CPX op (8-bit)
    // Compare a value with register X and set flags (8-bit)
    MEM_READ8
    lbu t0, register_x + 1
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    andi a0, a0, 0xFF
    j set_nz8
.endm

cpximm_8: IM8; CPX_8 // CPX #nn (8-bit)
cpxdir_8: DIR; CPX_8 // CPX nn (8-bit)
cpxabs_8: ABS; CPX_8 // CPX nnnn (8-bit)


.macro CPX_16 // CPX op (16-bit)
    // Compare a value with register X and set flags (16-bit)
    MEM_READ16
    lhu t0, register_x
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    andi a0, a0, 0xFFFF
    j set_nz16
.endm

cpximm_16: I16; CPX_16 // CPX #nnnn (16-bit)
cpxdir_16: DIR; CPX_16 // CPX nn (16-bit)
cpxabs_16: ABS; CPX_16 // CPX nnnn (16-bit)


.macro CPY_8 // CPY op (8-bit)
    // Compare a value with register Y and set flags (8-bit)
    MEM_READ8
    lbu t0, register_y + 1
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    andi a0, a0, 0xFF
    j set_nz8
.endm

cpyimm_8: IM8; CPY_8 // CPY #nn (8-bit)
cpydir_8: DIR; CPY_8 // CPY nn (8-bit)
cpyabs_8: ABS; CPY_8 // CPY nnnn (8-bit)


.macro CPY_16 // CPY op (16-bit)
    // Compare a value with register Y and set flags (16-bit)
    MEM_READ16
    lhu t0, register_y
    sub a0, t0, v0
    andi s4, s4, 0xFFFE
    sleu t0, a0, t0 // C
    or s4, s4, t0
    andi a0, a0, 0xFFFF
    j set_nz16
.endm

cpyimm_16: I16; CPY_16 // CPY #nnnn (16-bit)
cpydir_16: DIR; CPY_16 // CPY nn (16-bit)
cpyabs_16: ABS; CPY_16 // CPY nnnn (16-bit)


bit_8: // BIT #nn (8-bit)
    // Test the accumulator bits against an immediate value (8-bit)
    MEM_READ8 1(s7)
    lbu t0, accumulator + 1
    and t0, t0, v0

    // Set the Z flag for bit test
    andi s4, s4, 0xFFFD
    seq t0, t0, 0
    sll t0, t0, 1 // Z
    or s4, s4, t0
    addi s7, s7, 2
    j cpu_execute


bit_16: // BIT #nnnn (16-bit)
    // Test the accumulator bits against an immediate value (16-bit)
    MEM_READ16 1(s7)
    lhu t0, accumulator
    and t0, t0, v0

    // Set the Z flag for bit test
    andi s4, s4, 0xFFFD
    seq t0, t0, 0
    sll t0, t0, 1 // Z
    or s4, s4, t0
    addi s7, s7, 3
    j cpu_execute


.macro BIT_8 // BIT op (8-bit)
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
    or s4, s4, t0
    j cpu_execute
.endm

bitdir_8: DIR; BIT_8 // BIT nn (8-bit)
bitdrx_8: DRX; BIT_8 // BIT nn,X (8-bit)
bitabs_8: ABS; BIT_8 // BIT nnnn (8-bit)
bitabx_8: ABX; BIT_8 // BIT nnnn,X (8-bit)


.macro BIT_16 // BIT op (16-bit)
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
    or s4, s4, t0
    j cpu_execute
.endm

bitdir_16: DIR; BIT_16 // BIT nn (16-bit)
bitdrx_16: DRX; BIT_16 // BIT nn,X (16-bit)
bitabs_16: ABS; BIT_16 // BIT nnnn (16-bit)
bitabx_16: ABX; BIT_16 // BIT nnnn,X (16-bit)


.macro INC_8 // INC op (8-bit)
    // Increment a value in memory and set flags (8-bit)
    MEM_READ8
    addi a1, v0, 1
    MEM_WRITE8
    andi a0, a1, 0xFF
    j set_nz8
.endm

incdir_8: DIR; INC_8 // INC nn (8-bit)
incdrx_8: DRX; INC_8 // INC nn,X (8-bit)
incabs_8: ABS; INC_8 // INC nnnn (8-bit)
incabx_8: ABX; INC_8 // INC nnnn,X (8-bit)


.macro INC_16 // INC op (16-bit)
    // Increment a value in memory and set flags (16-bit)
    MEM_READ16
    addi a1, v0, 1
    MEM_WRITE16
    andi a0, a1, 0xFFFF
    j set_nz16
.endm

incdir_16: DIR; INC_16 // INC nn (16-bit)
incdrx_16: DRX; INC_16 // INC nn,X (16-bit)
incabs_16: ABS; INC_16 // INC nnnn (16-bit)
incabx_16: ABX; INC_16 // INC nnnn,X (16-bit)


inx_8: // INX (8-bit)
    // Increment register X and set flags (8-bit)
    lbu a0, register_x + 1
    addi a0, a0, 1
    sb a0, register_x + 1
    andi a0, a0, 0xFF
    addi s7, s7, 1
    j set_nz8


inx_16: // INX (16-bit)
    // Increment register X and set flags (16-bit)
    lhu a0, register_x
    addi a0, a0, 1
    sh a0, register_x
    andi a0, a0, 0xFFFF
    addi s7, s7, 1
    j set_nz16


iny_8: // INY (8-bit)
    // Increment register Y and set flags (8-bit)
    lbu a0, register_y + 1
    addi a0, a0, 1
    sb a0, register_y + 1
    andi a0, a0, 0xFF
    addi s7, s7, 1
    j set_nz8


iny_16: // INY (16-bit)
    // Increment register Y and set flags (16-bit)
    lhu a0, register_y
    addi a0, a0, 1
    sh a0, register_y
    andi a0, a0, 0xFFFF
    addi s7, s7, 1
    j set_nz16


ina_8: // INA (8-bit)
    // Increment the accumulator and set flags (8-bit)
    lbu a0, accumulator + 1
    addi a0, a0, 1
    sb a0, accumulator + 1
    andi a0, a0, 0xFF
    addi s7, s7, 1
    j set_nz8


ina_16: // INA (16-bit)
    // Increment the accumulator and set flags (16-bit)
    lhu a0, accumulator
    addi a0, a0, 1
    sh a0, accumulator
    andi a0, a0, 0xFFFF
    addi s7, s7, 1
    j set_nz16


.macro DEC_8 // DEC op (8-bit)
    // Decrement a value in memory and set flags (8-bit)
    MEM_READ8
    addi a1, v0, -1
    MEM_WRITE8
    andi a0, a1, 0xFF
    j set_nz8
.endm

decdir_8: DIR; DEC_8 // DEC nn (8-bit)
decdrx_8: DRX; DEC_8 // DEC nn,X (8-bit)
decabs_8: ABS; DEC_8 // DEC nnnn (8-bit)
decabx_8: ABX; DEC_8 // DEC nnnn,X (8-bit)


.macro DEC_16 // DEC op (16-bit)
    // Decrement a value in memory and set flags (16-bit)
    MEM_READ16
    addi a1, v0, -1
    MEM_WRITE16
    andi a0, a1, 0xFFFF
    j set_nz16
.endm

decdir_16: DIR; DEC_16 // DEC nn (16-bit)
decdrx_16: DRX; DEC_16 // DEC nn,X (16-bit)
decabs_16: ABS; DEC_16 // DEC nnnn (16-bit)
decabx_16: ABX; DEC_16 // DEC nnnn,X (16-bit)


dex_8: // DEX (8-bit)
    // Decrement register X and set flags (8-bit)
    lbu a0, register_x + 1
    addi a0, a0, -1
    sb a0, register_x + 1
    andi a0, a0, 0xFF
    addi s7, s7, 1
    j set_nz8


dex_16: // DEX (16-bit)
    // Decrement register X and set flags (16-bit)
    lhu a0, register_x
    addi a0, a0, -1
    sh a0, register_x
    andi a0, a0, 0xFFFF
    addi s7, s7, 1
    j set_nz16


dey_8: // DEY (8-bit)
    // Decrement register Y and set flags (8-bit)
    lbu a0, register_y + 1
    addi a0, a0, -1
    sb a0, register_y + 1
    andi a0, a0, 0xFF
    addi s7, s7, 1
    j set_nz8


dey_16: // DEY (16-bit)
    // Decrement register Y and set flags (16-bit)
    lhu a0, register_y
    addi a0, a0, -1
    sh a0, register_y
    andi a0, a0, 0xFFFF
    addi s7, s7, 1
    j set_nz16


dea_8: // DEA (8-bit)
    // Decrement the accumulator and set flags (8-bit)
    lbu a0, accumulator + 1
    addi a0, a0, -1
    sb a0, accumulator + 1
    andi a0, a0, 0xFF
    addi s7, s7, 1
    j set_nz8


dea_16: // DEA (16-bit)
    // Decrement the accumulator and set flags (16-bit)
    lhu a0, accumulator
    addi a0, a0, -1
    sh a0, accumulator
    andi a0, a0, 0xFFFF
    addi s7, s7, 1
    j set_nz16


.macro TSB_8 // TSB op (8-bit)
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
.endm

tsbdir_8: DIR; TSB_8 // TSB nn (8-bit)
tsbabs_8: ABS; TSB_8 // TSB nnnn (8-bit)


.macro TSB_16 // TSB op (16-bit)
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
.endm

tsbdir_16: DIR; TSB_16 // TSB nn (16-bit)
tsbabs_16: ABS; TSB_16 // TSB nnnn (16-bit)


.macro TRB_8 // TRB op (8-bit)
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
.endm

trbdir_8: DIR; TRB_8 // TRB nn (8-bit)
trbabs_8: ABS; TRB_8 // TRB nnnn (8-bit)


.macro TRB_16 // TRB op (16-bit)
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
.endm

trbdir_16: DIR; TRB_16 // TRB nn (16-bit)
trbabs_16: ABS; TRB_16 // TRB nnnn (16-bit)


asl_8: // ASL A (8-bit)
    // Shift the accumulator left and set flags (8-bit)
    lbu t0, accumulator + 1
    sll a0, t0, 1
    sb a0, accumulator + 1
    andi s4, s4, 0xFFFE
    srl t0, t0, 7 // C
    or s4, s4, t0
    andi a0, a0, 0xFF
    addi s7, s7, 1
    j set_nz8


asl_16: // ASL A (16-bit)
    // Shift the accumulator left and set flags (16-bit)
    lhu t0, accumulator
    sll a0, t0, 1
    sh a0, accumulator
    andi s4, s4, 0xFFFE
    srl t0, t0, 15 // C
    or s4, s4, t0
    andi a0, a0, 0xFFFF
    addi s7, s7, 1
    j set_nz16


.macro ASL_8 // ASL op (8-bit)
    // Shift a value in memory left and set flags (8-bit)
    MEM_READ8
    sll a1, v0, 1
    andi s4, s4, 0xFFFE
    srl t0, v0, 7 // C
    or s4, s4, t0
    MEM_WRITE8
    andi a0, a1, 0xFF
    j set_nz8
.endm

asldir_8: DIR; ASL_8 // ASL nn (8-bit)
asldrx_8: DRX; ASL_8 // ASL nn,X (8-bit)
aslabs_8: ABS; ASL_8 // ASL nnnn (8-bit)
aslabx_8: ABX; ASL_8 // ASL nnnn,X (8-bit)


.macro ASL_16 // ASL op (16-bit)
    // Shift a value in memory left and set flags (16-bit)
    MEM_READ16
    sll a1, v0, 1
    andi s4, s4, 0xFFFE
    srl t0, v0, 15 // C
    or s4, s4, t0
    MEM_WRITE16
    andi a0, a1, 0xFFFF
    j set_nz16
.endm

asldir_16: DIR; ASL_16 // ASL nn (16-bit)
asldrx_16: DRX; ASL_16 // ASL nn,X (16-bit)
aslabs_16: ABS; ASL_16 // ASL nnnn (16-bit)
aslabx_16: ABX; ASL_16 // ASL nnnn,X (16-bit)


lsr_8: // LSR A (8-bit)
    // Shift the accumulator right and set flags (8-bit)
    lbu t0, accumulator + 1
    srl a0, t0, 1
    sb a0, accumulator + 1
    andi s4, s4, 0xFFFE
    andi t0, t0, 0x1 // C
    or s4, s4, t0
    addi s7, s7, 1
    j set_nz8


lsr_16: // LSR A (16-bit)
    // Shift the accumulator right and set flags (16-bit)
    lhu t0, accumulator
    srl a0, t0, 1
    sh a0, accumulator
    andi s4, s4, 0xFFFE
    andi t0, t0, 0x1 // C
    or s4, s4, t0
    addi s7, s7, 1
    j set_nz16


.macro LSR_8 // LSR op (8-bit)
    // Shift a value in memory right and set flags (8-bit)
    MEM_READ8
    srl a1, v0, 1
    andi s4, s4, 0xFFFE
    andi t0, v0, 0x1 // C
    or s4, s4, t0
    MEM_WRITE8
    move a0, a1
    j set_nz8
.endm

lsrdir_8: DIR; LSR_8 // LSR nn (8-bit)
lsrdrx_8: DRX; LSR_8 // LSR nn,X (8-bit)
lsrabs_8: ABS; LSR_8 // LSR nnnn (8-bit)
lsrabx_8: ABX; LSR_8 // LSR nnnn,X (8-bit)


.macro LSR_16 // LSR op (16-bit)
    // Shift a value in memory right and set flags (16-bit)
    MEM_READ16
    srl a1, v0, 1
    andi s4, s4, 0xFFFE
    andi t0, v0, 0x1 // C
    or s4, s4, t0
    MEM_WRITE16
    move a0, a1
    j set_nz16
.endm

lsrdir_16: DIR; LSR_16 // LSR nn (16-bit)
lsrdrx_16: DRX; LSR_16 // LSR nn,X (16-bit)
lsrabs_16: ABS; LSR_16 // LSR nnnn (16-bit)
lsrabx_16: ABX; LSR_16 // LSR nnnn,X (16-bit)


rol_8: // ROL A (8-bit)
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
    addi s7, s7, 1
    j set_nz8


rol_16: // ROL A (16-bit)
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
    addi s7, s7, 1
    j set_nz16


.macro ROL_8 // ROL op (8-bit)
    // Rotate a value in memory left and set flags (8-bit)
    MEM_READ8
    sll a1, v0, 1
    andi t0, s4, 0x1
    or a1, a1, t0
    andi s4, s4, 0xFFFE
    srl t0, v0, 7 // C
    or s4, s4, t0
    MEM_WRITE8
    andi a0, a1, 0xFF
    j set_nz8
.endm

roldir_8: DIR; ROL_8 // ROL nn (8-bit)
roldrx_8: DRX; ROL_8 // ROL nn,X (8-bit)
rolabs_8: ABS; ROL_8 // ROL nnnn (8-bit)
rolabx_8: ABX; ROL_8 // ROL nnnn,X (8-bit)


.macro ROL_16 // ROL op (16-bit)
    // Rotate a value in memory left and set flags (16-bit)
    MEM_READ16
    sll a1, v0, 1
    andi t0, s4, 0x1
    or a1, a1, t0
    andi s4, s4, 0xFFFE
    srl t0, v0, 15 // C
    or s4, s4, t0
    MEM_WRITE16
    andi a0, a1, 0xFFFF
    j set_nz16
.endm

roldir_16: DIR; ROL_16 // ROL nn (16-bit)
roldrx_16: DRX; ROL_16 // ROL nn,X (16-bit)
rolabs_16: ABS; ROL_16 // ROL nnnn (16-bit)
rolabx_16: ABX; ROL_16 // ROL nnnn,X (16-bit)


ror_8: // ROR A (8-bit)
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
    addi s7, s7, 1
    j set_nz8


ror_16: // ROR A (16-bit)
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
    addi s7, s7, 1
    j set_nz16


.macro ROR_8 // ROR op (8-bit)
    // Rotate a value in memory right and set flags (8-bit)
    MEM_READ8
    srl a1, v0, 1
    sll t0, s4, 7
    or a1, a1, t0
    andi s4, s4, 0xFFFE
    andi t0, v0, 0x1 // C
    or s4, s4, t0
    MEM_WRITE8
    andi a0, a1, 0xFF
    j set_nz8
.endm

rordir_8: DIR; ROR_8 // ROR nn (8-bit)
rordrx_8: DRX; ROR_8 // ROR nn,X (8-bit)
rorabs_8: ABS; ROR_8 // ROR nnnn (8-bit)
rorabx_8: ABX; ROR_8 // ROR nnnn,X (8-bit)


.macro ROR_16 // ROR op (16-bit)
    // Rotate a value in memory right and set flags (16-bit)
    MEM_READ16
    srl a1, v0, 1
    sll t0, s4, 15
    or a1, a1, t0
    andi s4, s4, 0xFFFE
    andi t0, v0, 0x1 // C
    or s4, s4, t0
    MEM_WRITE16
    andi a0, a1, 0xFFFF
    j set_nz16
.endm

rordir_16: DIR; ROR_16 // ROR nn (16-bit)
rordrx_16: DRX; ROR_16 // ROR nn,X (16-bit)
rorabs_16: ABS; ROR_16 // ROR nnnn (16-bit)
rorabx_16: ABX; ROR_16 // ROR nnnn,X (16-bit)
