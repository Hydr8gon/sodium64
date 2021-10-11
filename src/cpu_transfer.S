#include <regdef.h>

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
    lhu  a0, direct_ofs
    sh   a0, accumulator
    addi s7, s7, 1
    j    set_nz16


tcd: // TCD
    // Transfer the accumulator to the direct offset and set flags
    lhu  a0, accumulator
    sh   a0, direct_ofs
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


lda_8: // LDA #nn (8-bit)
    // Load an immediate value to the accumulator and set flags (8-bit)
    addi a0, s7, 1
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


lda_16: // LDA #nnnn (16-bit)
    // Load an immediate value to the accumulator and set flags (16-bit)
    addi a0, s7, 1
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 3
    j    set_nz16


ldadir_8: // LDA nn (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


ldadir_16: // LDA nn (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 2
    j    set_nz16


ldadrx_8: // LDA nn,X (8-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


ldadrx_16: // LDA nn,X (16-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 2
    j    set_nz16


ldadrs_8: // LDA nn,S (8-bit)
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


ldadrs_16: // LDA nn,S (16-bit)
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 2
    j    set_nz16


ldaabs_8: // LDA nnnn (8-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 3
    j    set_nz8


ldaabs_16: // LDA nnnn (16-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 3
    j    set_nz16


ldaabx_8: // LDA nnnn,X (8-bit)
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 3
    j    set_nz8


ldaabx_16: // LDA nnnn,X (16-bit)
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 3
    j    set_nz16


ldaaby_8: // LDA nnnn,Y (8-bit)
    // Get the 16-bit immediate value plus register Y added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_y
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 3
    j    set_nz8


ldaaby_16: // LDA nnnn,Y (16-bit)
    // Get the 16-bit immediate value plus register Y added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_y
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 3
    j    set_nz16


ldalng_8: // LDA nnnnnn (8-bit)
    // Get the 24-bit immediate value as an address
    addi a0, s7, 1
    jal  memory_read16
    move s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 4
    j    set_nz8


ldalng_16: // LDA nnnnnn (16-bit)
    // Get the 24-bit immediate value as an address
    addi a0, s7, 1
    jal  memory_read16
    move s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 4
    j    set_nz16


ldalnx_8: // LDA nnnnnn,X (8-bit)
    // Get the 24-bit immediate value plus register X as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  s0, register_x
    add  s0, s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 4
    j    set_nz8


ldalnx_16: // LDA nnnnnn,X (16-bit)
    // Get the 24-bit immediate value plus register X as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  s0, register_x
    add  s0, s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 4
    j    set_nz16


ldaind_8: // LDA (nn) (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


ldaind_16: // LDA (nn) (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 2
    j    set_nz16


ldaidx_8: // LDA (nn,X) (8-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


ldaidx_16: // LDA (nn,X) (16-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 2
    j    set_nz16


ldaidy_8: // LDA (nn),Y (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


ldaidy_16: // LDA (nn),Y (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 2
    j    set_nz16


ldaisy_8: // LDA (nn,S),Y (8-bit)
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


ldaisy_16: // LDA (nn,S),Y (16-bit)
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 2
    j    set_nz16


ldaidl_8: // LDA [nn] (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory as an address
    jal  memory_read16
    move s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


ldaidl_16: // LDA [nn] (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory as an address
    jal  memory_read16
    move s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 2
    j    set_nz16


ldaily_8: // LDA [nn],y (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  s0, register_y
    add  s0, s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Load a value to the accumulator and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 2
    j    set_nz8


ldaily_16: // LDA [nn],y (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  s0, register_y
    add  s0, s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Load a value to the accumulator and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 2
    j    set_nz16


ldx_8: // LDX #nn (8-bit)
    // Load an immediate value to register X and set flags (8-bit)
    addi a0, s7, 1
    jal  memory_read8
    move a0, v0
    sb   a0, register_x + 1
    addi s7, s7, 2
    j    set_nz8


ldx_16: // LDX #nnnn (16-bit)
    // Load an immediate value to register X and set flags (16-bit)
    addi a0, s7, 1
    jal  memory_read16
    move a0, v0
    sh   a0, register_x
    addi s7, s7, 3
    j    set_nz16


ldxdir_8: // LDX nn (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Load a value to register X and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, register_x + 1
    addi s7, s7, 2
    j    set_nz8


ldxdir_16: // LDX nn (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Load a value to register X and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, register_x
    addi s7, s7, 2
    j    set_nz16


ldxdry_8: // LDX nn,Y (8-bit)
    // Get the 8-bit immediate value plus register Y added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_y
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Load a value to register X and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, register_x + 1
    addi s7, s7, 2
    j    set_nz8


ldxdry_16: // LDX nn,Y (16-bit)
    // Get the 8-bit immediate value plus register Y added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_y
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Load a value to register X and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, register_x
    addi s7, s7, 2
    j    set_nz16


ldxabs_8: // LDX nnnn (8-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Load a value to register X and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, register_x + 1
    addi s7, s7, 3
    j    set_nz8


ldxabs_16: // LDX nnnn (16-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Load a value to register X and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, register_x
    addi s7, s7, 3
    j    set_nz16


ldxaby_8: // LDX nnnn,Y (8-bit)
    // Get the 16-bit immediate value plus register Y added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_y
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Load a value to register X and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, register_x + 1
    addi s7, s7, 3
    j    set_nz8


ldxaby_16: // LDX nnnn,Y (16-bit)
    // Get the 16-bit immediate value plus register Y added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_y
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Load a value to register X and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, register_x
    addi s7, s7, 3
    j    set_nz16


ldy_8: // LDY #nn (8-bit)
    // Load an immediate value to register Y and set flags (8-bit)
    addi a0, s7, 1
    jal  memory_read8
    move a0, v0
    sb   a0, register_y + 1
    addi s7, s7, 2
    j    set_nz8


ldy_16: // LDY #nnnn (16-bit)
    // Load an immediate value to register Y and set flags (16-bit)
    addi a0, s7, 1
    jal  memory_read16
    move a0, v0
    sh   a0, register_y
    addi s7, s7, 3
    j    set_nz16


ldydir_8: // LDY nn (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Load a value to register Y and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, register_y + 1
    addi s7, s7, 2
    j    set_nz8


ldydir_16: // LDY nn (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Load a value to register Y and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, register_y
    addi s7, s7, 2
    j    set_nz16


ldydrx_8: // LDY nn,X (8-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Load a value to register Y and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, register_y + 1
    addi s7, s7, 2
    j    set_nz8


ldydrx_16: // LDY nn,X (16-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Load a value to register Y and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, register_y
    addi s7, s7, 2
    j    set_nz16


ldyabs_8: // LDY nnnn (8-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Load a value to register Y and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, register_y + 1
    addi s7, s7, 3
    j    set_nz8


ldyabs_16: // LDY nnnn (16-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Load a value to register Y and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, register_y
    addi s7, s7, 3
    j    set_nz16


ldyabx_8: // LDY nnnn,X (8-bit)
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Load a value to register Y and set flags (8-bit)
    jal  memory_read8
    move a0, v0
    sb   a0, register_y + 1
    addi s7, s7, 3
    j    set_nz8


ldyabx_16: // LDY nnnn,X (16-bit)
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Load a value to register Y and set flags (16-bit)
    jal  memory_read16
    move a0, v0
    sh   a0, register_y
    addi s7, s7, 3
    j    set_nz16


stzdir_8: // STZ nn (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Store zero to memory (8-bit)
    li   a1, 0
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


stzdir_16: // STZ nn (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Store zero to memory (16-bit)
    li   a1, 0
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


stzdrx_8: // STZ nn,X (8-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Store zero to memory (8-bit)
    li   a1, 0
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


stzdrx_16: // STZ nn,X (16-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Store zero to memory (16-bit)
    li   a1, 0
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


stzabs_8: // STZ nnnn (8-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Store zero to memory (8-bit)
    li   a1, 0
    jal  memory_write8
    addi s7, s7, 3
    j    cpu_execute


stzabs_16: // STZ nnnn (16-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Store zero to memory (16-bit)
    li   a1, 0
    jal  memory_write16
    addi s7, s7, 3
    j    cpu_execute


stzabx_8: // STZ nnnn,X (8-bit)
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Store zero to memory (8-bit)
    li   a1, 0
    jal  memory_write8
    addi s7, s7, 3
    j    cpu_execute


stzabx_16: // STZ nnnn,X (16-bit)
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Store zero to memory (16-bit)
    li   a1, 0
    jal  memory_write16
    addi s7, s7, 3
    j    cpu_execute


stadir_8: // STA nn (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


stadir_16: // STA nn (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


stadrx_8: // STA nn,X (8-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


stadrx_16: // STA nn,X (16-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


stadrs_8: // STA nn,S (8-bit)
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


stadrs_16: // STA nn,S (16-bit)
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


staabs_8: // STA nnnn (8-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 3
    j    cpu_execute


staabs_16: // STA nnnn (16-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 3
    j    cpu_execute


staabx_8: // STA nnnn,X (8-bit)
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 3
    j    cpu_execute


staabx_16: // STA nnnn,X (16-bit)
    // Get the 16-bit immediate value plus register X added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_x
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 3
    j    cpu_execute


staaby_8: // STA nnnn,Y (8-bit)
    // Get the 16-bit immediate value plus register Y added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_y
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 3
    j    cpu_execute


staaby_16: // STA nnnn,Y (16-bit)
    // Get the 16-bit immediate value plus register Y added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  t0, register_y
    add  t0, t0, v0
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, t0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 3
    j    cpu_execute


stalng_8: // STA nnnnnn (8-bit)
    // Get the 24-bit immediate value as an address
    addi a0, s7, 1
    jal  memory_read16
    move s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 4
    j    cpu_execute


stalng_16: // STA nnnnnn (16-bit)
    // Get the 24-bit immediate value as an address
    addi a0, s7, 1
    jal  memory_read16
    move s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 4
    j    cpu_execute


stalnx_8: // STA nnnnnn,X (8-bit)
    // Get the 24-bit immediate value plus register X as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  s0, register_x
    add  s0, s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 4
    j    cpu_execute


stalnx_16: // STA nnnnnn,X (16-bit)
    // Get the 24-bit immediate value plus register X as an address
    addi a0, s7, 1
    jal  memory_read16
    lhu  s0, register_x
    add  s0, s0, v0
    addi a0, s7, 3
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 4
    j    cpu_execute


staind_8: // STA (nn) (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


staind_16: // STA (nn) (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


staidx_8: // STA (nn,X) (8-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


staidx_16: // STA (nn,X) (16-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Read a 16-bit value from memory as an address
    jal  memory_read16
    move a0, v0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


staidy_8: // STA (nn),Y (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


staidy_16: // STA (nn),Y (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


staisy_8: // STA (nn,S),Y (8-bit)
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


staisy_16: // STA (nn,S),Y (16-bit)
    // Get the 8-bit immediate value added to the stack pointer as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, stack_ptr
    add  a0, a0, v0

    // Read a 16-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  a0, register_y
    add  a0, a0, v0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


staidl_8: // STA [nn] (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory as an address
    jal  memory_read16
    move s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


staidl_16: // STA [nn] (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory as an address
    jal  memory_read16
    move s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


staily_8: // STA [nn],y (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  s0, register_y
    add  s0, s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Store the accumulator to memory (8-bit)
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


staily_16: // STA [nn],y (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Read a 24-bit value from memory plus register Y as an address
    jal  memory_read16
    lhu  s0, register_y
    add  s0, s0, v0
    addi a0, a0, 2
    jal  memory_read8
    sll  a0, v0, 16
    add  a0, a0, s0

    // Store the accumulator to memory (16-bit)
    lhu  a1, accumulator
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


stxdir_8: // STX nn (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Store register X to memory (8-bit)
    lbu  a1, register_x + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


stxdir_16: // STX nn (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Store register X to memory (16-bit)
    lhu  a1, register_x
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


stxdry_8: // STX nn,Y (8-bit)
    // Get the 8-bit immediate value plus register Y added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_y
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Store register X to memory (8-bit)
    lbu  a1, register_x + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


stxdry_16: // STX nn,Y (16-bit)
    // Get the 8-bit immediate value plus register Y added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_y
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Store register X to memory (16-bit)
    lhu  a1, register_x
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


stxabs_8: // STX nnnn (8-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Store register X to memory (8-bit)
    lbu  a1, register_x + 1
    jal  memory_write8
    addi s7, s7, 3
    j    cpu_execute


stxabs_16: // STX nnnn (16-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Store register X to memory (16-bit)
    lhu  a1, register_x
    jal  memory_write16
    addi s7, s7, 3
    j    cpu_execute


stydir_8: // STY nn (8-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Store register Y to memory (8-bit)
    lbu  a1, register_y + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


stydir_16: // STY nn (16-bit)
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Store register Y to memory (16-bit)
    lhu  a1, register_y
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


stydrx_8: // STY nn,X (8-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Store register Y to memory (8-bit)
    lbu  a1, register_y + 1
    jal  memory_write8
    addi s7, s7, 2
    j    cpu_execute


stydrx_16: // STY nn,X (16-bit)
    // Get the 8-bit immediate value plus register X added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  t0, register_x
    add  t0, t0, v0
    andi t0, t0, 0xFF
    lhu  a0, direct_ofs
    add  a0, a0, t0

    // Store register Y to memory (16-bit)
    lhu  a1, register_y
    jal  memory_write16
    addi s7, s7, 2
    j    cpu_execute


styabs_8: // STY nnnn (8-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Store register Y to memory (8-bit)
    lbu  a1, register_y + 1
    jal  memory_write8
    addi s7, s7, 3
    j    cpu_execute


styabs_16: // STY nnnn (16-bit)
    // Get the 16-bit immediate value added to the data bank as an address
    addi a0, s7, 1
    jal  memory_read16
    lbu  a0, data_bank
    sll  a0, a0, 16
    add  a0, a0, v0

    // Store register Y to memory (16-bit)
    lhu  a1, register_y
    jal  memory_write16
    addi s7, s7, 3
    j    cpu_execute


pha_8: // PHA (8-bit)
    // Push the accumulator to the stack (8-bit)
    lhu  a0, stack_ptr
    lbu  a1, accumulator + 1
    jal  memory_write8
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


pha_16: // PHA (16-bit)
    // Push the accumulator to the stack (16-bit)
    lhu  a0, stack_ptr
    addi a0, a0, -1
    lhu  a1, accumulator
    jal  memory_write16
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phx_8: // PHX (8-bit)
    // Push register X to the stack (8-bit)
    lhu  a0, stack_ptr
    lbu  a1, register_x + 1
    jal  memory_write8
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phx_16: // PHX (16-bit)
    // Push register X to the stack (16-bit)
    lhu  a0, stack_ptr
    addi a0, a0, -1
    lhu  a1, register_x
    jal  memory_write16
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phy_8: // PHY (8-bit)
    // Push register Y to the stack (8-bit)
    lhu  a0, stack_ptr
    lbu  a1, register_y + 1
    jal  memory_write8
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phy_16: // PHY (16-bit)
    // Push register Y to the stack (16-bit)
    lhu  a0, stack_ptr
    addi a0, a0, -1
    lhu  a1, register_y
    jal  memory_write16
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


php: // PHP
    // Push the flags to the stack
    lhu  a0, stack_ptr
    andi a1, s4, 0xFF
    jal  memory_write8
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phb: // PHB
    // Push the data bank to the stack
    lhu  a0, stack_ptr
    lbu  a1, data_bank
    jal  memory_write8
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phk: // PHK
    // Push the PC bank to the stack
    lhu  a0, stack_ptr
    srl  a1, s7, 16
    jal  memory_write8
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


phd: // PHD
    // Push the direct offset to the stack
    lhu  a0, stack_ptr
    addi a0, a0, -1
    lhu  a1, direct_ofs
    jal  memory_write16
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 1
    j    cpu_execute


pei: // PEI nn
    // Get the 8-bit immediate value added to the direct offset as an address
    addi a0, s7, 1
    jal  memory_read8
    lhu  a0, direct_ofs
    add  a0, a0, v0

    // Load a 16-bit value from memory and push it to the stack
    jal  memory_read16
    lhu  a0, stack_ptr
    addi a0, a0, -1
    move a1, v0
    jal  memory_write16
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 2
    j    cpu_execute


pea: // PEA #nnnn
    // Push a 16-bit immediate value to the stack
    addi a0, s7, 1
    jal  memory_read16
    lhu  a0, stack_ptr
    addi a0, a0, -1
    move a1, v0
    jal  memory_write16
    addi t0, a0, -1
    sh   t0, stack_ptr
    addi s7, s7, 3
    j    cpu_execute


per: // PER disp16
    // Add a sign-extended 16-bit immediate value to the PC
    addi a0, s7, 1
    jal  memory_read16
    sll  t0, v0, 16
    sra  t0, t0, 16
    addi s7, s7, 3
    add  a1, s7, t0

    // Push the resulting value to the stack
    lhu  a0, stack_ptr
    addi a0, a0, -1
    jal  memory_write16
    addi t0, a0, -1
    sh   t0, stack_ptr
    j    cpu_execute


pla_8: // PLA (8-bit)
    // Pop the accumulator from the stack and set flags (8-bit)
    lhu  a0, stack_ptr
    addi a0, a0, 1
    jal  memory_read8
    sh   a0, stack_ptr
    move a0, v0
    sb   a0, accumulator + 1
    addi s7, s7, 1
    j    set_nz8


pla_16: // PLA (16-bit)
    // Pop the accumulator from the stack and set flags (16-bit)
    lhu  a0, stack_ptr
    addi a0, a0, 1
    jal  memory_read16
    addi a0, a0, 1
    sh   a0, stack_ptr
    move a0, v0
    sh   a0, accumulator
    addi s7, s7, 1
    j    set_nz16


plx_8: // PLX (8-bit)
    // Pop register X from the stack and set flags (8-bit)
    lhu  a0, stack_ptr
    addi a0, a0, 1
    jal  memory_read8
    sh   a0, stack_ptr
    move a0, v0
    sb   a0, register_x + 1
    addi s7, s7, 1
    j    set_nz8


plx_16: // PLX (16-bit)
    // Pop register X from the stack and set flags (16-bit)
    lhu  a0, stack_ptr
    addi a0, a0, 1
    jal  memory_read16
    addi a0, a0, 1
    sh   a0, stack_ptr
    move a0, v0
    sh   a0, register_x
    addi s7, s7, 1
    j    set_nz16


ply_8: // PLY (8-bit)
    // Pop register Y from the stack and set flags (8-bit)
    lhu  a0, stack_ptr
    addi a0, a0, 1
    jal  memory_read8
    sh   a0, stack_ptr
    move a0, v0
    sb   a0, register_y + 1
    addi s7, s7, 1
    j    set_nz8


ply_16: // PLY (16-bit)
    // Pop register Y from the stack and set flags (16-bit)
    lhu  a0, stack_ptr
    addi a0, a0, 1
    jal  memory_read16
    addi a0, a0, 1
    sh   a0, stack_ptr
    move a0, v0
    sh   a0, register_y
    addi s7, s7, 1
    j    set_nz16


pld: // PLD
    // Pop the direct offset from the stack and set flags
    lhu  a0, stack_ptr
    addi a0, a0, 1
    jal  memory_read16
    addi a0, a0, 1
    sh   a0, stack_ptr
    move a0, v0
    sh   a0, direct_ofs
    addi s7, s7, 1
    j    set_nz16


plb: // PLB
    // Pop the data bank from the stack and set flags
    lhu  a0, stack_ptr
    addi a0, a0, 1
    jal  memory_read8
    sh   a0, stack_ptr
    move a0, v0
    sb   a0, data_bank
    addi s7, s7, 1
    j    set_nz8


plp: // PLP
    // Pop the flags from the stack
    lhu  a0, stack_ptr
    addi a0, a0, 1
    jal  memory_read8
    sh   a0, stack_ptr
    andi s4, s4, 0xFF00
    or   s4, s4, v0
    addi s7, s7, 1
    j    update_mode


mvp_8: // MVP ss,dd (8-bit)
    // Get the immediate 8-bit value plus register Y as the destination address (8-bit)
    addi a0, s7, 1
    jal  memory_read8
    sll  s0, v0, 16
    lbu  t0, register_y + 1
    add  s0, s0, t0

    // Get the next immediate 8-bit value plus register Y as the source address (8-bit)
    addi a0, s7, 2
    jal  memory_read8
    sll  s1, v0, 16
    lbu  t0, register_x + 1
    add  s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    move a0, s1
    jal  memory_read8
    move a0, s0
    move a1, v0
    jal  memory_write8

    // Decrement the registers (8-bit)
    addi t0, s1, -1
    sb   t0, register_x + 1
    addi t0, s0, -1
    sb   t0, register_y + 1

    // Decrement the accumulator and don't increment the PC until it underflows
    lhu  t0, accumulator
    addi t1, t0, -1
    sh   t1, accumulator
    bne  t0, zero, mvp8_cont
    addi s7, s7, 3
mvp8_cont:
    j    cpu_execute


mvp_16: // MVP ss,dd (16-bit)
    // Get the immediate 8-bit value plus register Y as the destination address (16-bit)
    addi a0, s7, 1
    jal  memory_read8
    sll  s0, v0, 16
    lhu  t0, register_y
    add  s0, s0, t0

    // Get the next immediate 8-bit value plus register Y as the source address (16-bit)
    addi a0, s7, 2
    jal  memory_read8
    sll  s1, v0, 16
    lhu  t0, register_x
    add  s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    move a0, s1
    jal  memory_read8
    move a0, s0
    move a1, v0
    jal  memory_write8

    // Decrement the registers (16-bit)
    addi t0, s1, -1
    sh   t0, register_x
    addi t0, s0, -1
    sh   t0, register_y

    // Decrement the accumulator and don't increment the PC until it underflows
    lhu  t0, accumulator
    addi t1, t0, -1
    sh   t1, accumulator
    bne  t0, zero, mvp16_cont
    addi s7, s7, 3
mvp16_cont:
    j    cpu_execute


mvn_8: // MVN ss,dd (8-bit)
    // Get the immediate 8-bit value plus register Y as the destination address (8-bit)
    addi a0, s7, 1
    jal  memory_read8
    sll  s0, v0, 16
    lbu  t0, register_y + 1
    add  s0, s0, t0

    // Get the next immediate 8-bit value plus register Y as the source address (8-bit)
    addi a0, s7, 2
    jal  memory_read8
    sll  s1, v0, 16
    lbu  t0, register_x + 1
    add  s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    move a0, s1
    jal  memory_read8
    move a0, s0
    move a1, v0
    jal  memory_write8

    // Increment the registers (8-bit)
    addi t0, s1, 1
    sb   t0, register_x + 1
    addi t0, s0, 1
    sb   t0, register_y + 1

    // Decrement the accumulator and don't increment the PC until it underflows
    lhu  t0, accumulator
    addi t1, t0, -1
    sh   t1, accumulator
    bne  t0, zero, mvn8_cont
    addi s7, s7, 3
mvn8_cont:
    j    cpu_execute


mvn_16: // MVN ss,dd (16-bit)
    // Get the immediate 8-bit value plus register Y as the destination address (16-bit)
    addi a0, s7, 1
    jal  memory_read8
    sll  s0, v0, 16
    lhu  t0, register_y
    add  s0, s0, t0

    // Get the next immediate 8-bit value plus register Y as the source address (16-bit)
    addi a0, s7, 2
    jal  memory_read8
    sll  s1, v0, 16
    lhu  t0, register_x
    add  s1, s1, t0

    // Transfer an 8-bit value from the source to the destination
    move a0, s1
    jal  memory_read8
    move a0, s0
    move a1, v0
    jal  memory_write8

    // Increment the registers (16-bit)
    addi t0, s1, 1
    sh   t0, register_x
    addi t0, s0, 1
    sh   t0, register_y

    // Decrement the accumulator and don't increment the PC until it underflows
    lhu  t0, accumulator
    addi t1, t0, -1
    sh   t1, accumulator
    bne  t0, zero, mvn16_cont
    addi s7, s7, 3
mvn16_cont:
    j    cpu_execute
