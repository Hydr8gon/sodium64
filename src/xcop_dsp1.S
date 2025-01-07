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

.globl read_dsp1sr
.globl read_dsp1dr
.globl write_dsp1dr

.data

.align 4
cmd_func: .word 0
cmd_count: .word 0
dsp1_sr: .hword 0x8400
dsp1_dr: .hword 0x80
sr_toggle: .byte 0

.align 4
input_buf: .hword 0:8
output_buf: .hword 0:8
matrix_a: .hword 0:9
matrix_b: .hword 0:9
matrix_c: .hword 0:9

.align 4
les: .hword 0
les_c: .hword 0
les_e: .hword 0
aas_sin: .hword 0
aas_cos: .hword 0
azs_sin: .hword 0
azs_cos: .hword 0
azsc_sin: .hword 0
azsc_cos: .hword 0
azs_sec1c: .hword 0
azs_sec1e: .hword 0
azs_sec2c: .hword 0
azs_sec2e: .hword 0
v_offset: .hword 0

.align 4
center_x: .hword 0
center_y: .hword 0
center_z: .hword 0
center_zc: .hword 0
center_ze: .hword 0
global_x: .hword 0
global_y: .hword 0
global_z: .hword 0
normal_x: .hword 0
normal_y: .hword 0
normal_z: .hword 0
vert_x: .hword 0
vert_y: .hword 0
vert_z: .hword 0
hori_x: .hword 0
hori_y: .hword 0

.align 4
azsc_bounds:
    .hword 0x38B4, 0x38B7, 0x38BA, 0x38BE, 0x38C0, 0x38C4, 0x38C7, 0x38CA
    .hword 0x38CE, 0x38D0, 0x38D4, 0x38D7, 0x38DA, 0x38DD, 0x38E0, 0x38E4

.align 4
dsp1_cmds: // Lookup table for DSP1 command functions and parameter counts
    .word dsp1_multip, 0x20001,  dsp1_atti_a, 0x40000,  dsp1_params, 0x70004,  dsp1_subj_a, 0x30003 // 0x00-0x03
    .word dsp1_triang, 0x20002,  dsp1_atti_a, 0x40000,  dsp1_projec, 0x30003,  dsp1_unimpl, 0x10001 // 0x04-0x07
    .word dsp1_radius, 0x30002,  dsp1_obje_a, 0x30003,  dsp1_raster, 0x10004,  dsp1_unimpl, 0x30001 // 0x08-0x0B
    .word dsp1_rotate, 0x30002,  dsp1_obje_a, 0x30003,  dsp1_target, 0x20002,  dsp1_unimpl, 0x10001 // 0x0C-0x0F
    .word dsp1_unimpl, 0x20002,  dsp1_atti_b, 0x40000,  dsp1_params, 0x70004,  dsp1_subj_b, 0x30003 // 0x10-0x13
    .word dsp1_gyrate, 0x60003,  dsp1_atti_b, 0x40000,  dsp1_projec, 0x30003,  dsp1_unimpl, 0x10400 // 0x14-0x17
    .word dsp1_unimpl, 0x40001,  dsp1_obje_b, 0x30003,  dsp1_unimpl, 0x00000,  dsp1_unimpl, 0x30001 // 0x18-0x1B
    .word dsp1_unimpl, 0x60003,  dsp1_obje_b, 0x30003,  dsp1_target, 0x20002,  dsp1_unimpl, 0x10400 // 0x1C-0x1F
    .word dsp1_unimpl, 0x20001,  dsp1_atti_c, 0x40000,  dsp1_params, 0x70004,  dsp1_subj_c, 0x30003 // 0x20-0x23
    .word dsp1_triang, 0x20002,  dsp1_atti_c, 0x40000,  dsp1_projec, 0x30003,  dsp1_unimpl, 0x10001 // 0x24-0x27
    .word dsp1_distan, 0x30001,  dsp1_obje_c, 0x30003,  dsp1_unimpl, 0x00000,  dsp1_unimpl, 0x30001 // 0x28-0x2B
    .word dsp1_rotate, 0x30002,  dsp1_obje_c, 0x30003,  dsp1_target, 0x20002,  dsp1_unimpl, 0x10001 // 0x2C-0x2F
    .word dsp1_unimpl, 0x20002,  dsp1_atti_a, 0x40000,  dsp1_params, 0x70004,  dsp1_subj_a, 0x30003 // 0x30-0x33
    .word dsp1_gyrate, 0x60003,  dsp1_atti_a, 0x40000,  dsp1_projec, 0x30003,  dsp1_unimpl, 0x10400 // 0x34-0x37
    .word dsp1_unimpl, 0x40001,  dsp1_obje_a, 0x30003,  dsp1_unimpl, 0x00000,  dsp1_unimpl, 0x30001 // 0x38-0x3B
    .word dsp1_unimpl, 0x60003,  dsp1_obje_a, 0x30003,  dsp1_target, 0x20002,  dsp1_unimpl, 0x10400 // 0x3C-0x3F

.align 4
data_rom: // Data ROM from bsnes containing lookup tables and constants
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    .hword 0x0000, 0x0000, 0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020
    .hword 0x0040, 0x0080, 0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000
    .hword 0x4000, 0x7FFF, 0x4000, 0x2000, 0x1000, 0x0800, 0x0400, 0x0200
    .hword 0x0100, 0x0080, 0x0040, 0x0020, 0x0010, 0x0008, 0x0004, 0x0002
    .hword 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    .hword 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    .hword 0x0000, 0x0000, 0x8000, 0xFFE5, 0x0100, 0x7FFF, 0x7F02, 0x7E08
    .hword 0x7D12, 0x7C1F, 0x7B30, 0x7A45, 0x795D, 0x7878, 0x7797, 0x76BA
    .hword 0x75DF, 0x7507, 0x7433, 0x7361, 0x7293, 0x71C7, 0x70FE, 0x7038
    .hword 0x6F75, 0x6EB4, 0x6DF6, 0x6D3A, 0x6C81, 0x6BCA, 0x6B16, 0x6A64
    .hword 0x69B4, 0x6907, 0x685B, 0x67B2, 0x670B, 0x6666, 0x65C4, 0x6523
    .hword 0x6484, 0x63E7, 0x634C, 0x62B3, 0x621C, 0x6186, 0x60F2, 0x6060
    .hword 0x5FD0, 0x5F41, 0x5EB5, 0x5E29, 0x5D9F, 0x5D17, 0x5C91, 0x5C0C
    .hword 0x5B88, 0x5B06, 0x5A85, 0x5A06, 0x5988, 0x590B, 0x5890, 0x5816
    .hword 0x579D, 0x5726, 0x56B0, 0x563B, 0x55C8, 0x5555, 0x54E4, 0x5474
    .hword 0x5405, 0x5398, 0x532B, 0x52BF, 0x5255, 0x51EC, 0x5183, 0x511C
    .hword 0x50B6, 0x5050, 0x4FEC, 0x4F89, 0x4F26, 0x4EC5, 0x4E64, 0x4E05
    .hword 0x4DA6, 0x4D48, 0x4CEC, 0x4C90, 0x4C34, 0x4BDA, 0x4B81, 0x4B28
    .hword 0x4AD0, 0x4A79, 0x4A23, 0x49CD, 0x4979, 0x4925, 0x48D1, 0x487F
    .hword 0x482D, 0x47DC, 0x478C, 0x473C, 0x46ED, 0x469F, 0x4651, 0x4604
    .hword 0x45B8, 0x456C, 0x4521, 0x44D7, 0x448D, 0x4444, 0x43FC, 0x43B4
    .hword 0x436D, 0x4326, 0x42E0, 0x429A, 0x4255, 0x4211, 0x41CD, 0x4189
    .hword 0x4146, 0x4104, 0x40C2, 0x4081, 0x4040, 0x3FFF, 0x41F7, 0x43E1
    .hword 0x45BD, 0x478D, 0x4951, 0x4B0B, 0x4CBB, 0x4E61, 0x4FFF, 0x5194
    .hword 0x5322, 0x54A9, 0x5628, 0x57A2, 0x5914, 0x5A81, 0x5BE9, 0x5D4A
    .hword 0x5EA7, 0x5FFF, 0x6152, 0x62A0, 0x63EA, 0x6530, 0x6672, 0x67B0
    .hword 0x68EA, 0x6A20, 0x6B53, 0x6C83, 0x6DAF, 0x6ED9, 0x6FFF, 0x7122
    .hword 0x7242, 0x735F, 0x747A, 0x7592, 0x76A7, 0x77BA, 0x78CB, 0x79D9
    .hword 0x7AE5, 0x7BEE, 0x7CF5, 0x7DFA, 0x7EFE, 0x7FFF, 0x0000, 0x0324
    .hword 0x0647, 0x096A, 0x0C8B, 0x0FAB, 0x12C8, 0x15E2, 0x18F8, 0x1C0B
    .hword 0x1F19, 0x2223, 0x2528, 0x2826, 0x2B1F, 0x2E11, 0x30FB, 0x33DE
    .hword 0x36BA, 0x398C, 0x3C56, 0x3F17, 0x41CE, 0x447A, 0x471C, 0x49B4
    .hword 0x4C3F, 0x4EBF, 0x5133, 0x539B, 0x55F5, 0x5842, 0x5A82, 0x5CB4
    .hword 0x5ED7, 0x60EC, 0x62F2, 0x64E8, 0x66CF, 0x68A6, 0x6A6D, 0x6C24
    .hword 0x6DCA, 0x6F5F, 0x70E2, 0x7255, 0x73B5, 0x7504, 0x7641, 0x776C
    .hword 0x7884, 0x798A, 0x7A7D, 0x7B5D, 0x7C29, 0x7CE3, 0x7D8A, 0x7E1D
    .hword 0x7E9D, 0x7F09, 0x7F62, 0x7FA7, 0x7FD8, 0x7FF6, 0x7FFF, 0x7FF6
    .hword 0x7FD8, 0x7FA7, 0x7F62, 0x7F09, 0x7E9D, 0x7E1D, 0x7D8A, 0x7CE3
    .hword 0x7C29, 0x7B5D, 0x7A7D, 0x798A, 0x7884, 0x776C, 0x7641, 0x7504
    .hword 0x73B5, 0x7255, 0x70E2, 0x6F5F, 0x6DCA, 0x6C24, 0x6A6D, 0x68A6
    .hword 0x66CF, 0x64E8, 0x62F2, 0x60EC, 0x5ED7, 0x5CB4, 0x5A82, 0x5842
    .hword 0x55F5, 0x539B, 0x5133, 0x4EBF, 0x4C3F, 0x49B4, 0x471C, 0x447A
    .hword 0x41CE, 0x3F17, 0x3C56, 0x398C, 0x36BA, 0x33DE, 0x30FB, 0x2E11
    .hword 0x2B1F, 0x2826, 0x2528, 0x2223, 0x1F19, 0x1C0B, 0x18F8, 0x15E2
    .hword 0x12C8, 0x0FAB, 0x0C8B, 0x096A, 0x0647, 0x0324, 0x7FFF, 0x7FF6
    .hword 0x7FD8, 0x7FA7, 0x7F62, 0x7F09, 0x7E9D, 0x7E1D, 0x7D8A, 0x7CE3
    .hword 0x7C29, 0x7B5D, 0x7A7D, 0x798A, 0x7884, 0x776C, 0x7641, 0x7504
    .hword 0x73B5, 0x7255, 0x70E2, 0x6F5F, 0x6DCA, 0x6C24, 0x6A6D, 0x68A6
    .hword 0x66CF, 0x64E8, 0x62F2, 0x60EC, 0x5ED7, 0x5CB4, 0x5A82, 0x5842
    .hword 0x55F5, 0x539B, 0x5133, 0x4EBF, 0x4C3F, 0x49B4, 0x471C, 0x447A
    .hword 0x41CE, 0x3F17, 0x3C56, 0x398C, 0x36BA, 0x33DE, 0x30FB, 0x2E11
    .hword 0x2B1F, 0x2826, 0x2528, 0x2223, 0x1F19, 0x1C0B, 0x18F8, 0x15E2
    .hword 0x12C8, 0x0FAB, 0x0C8B, 0x096A, 0x0647, 0x0324, 0x0000, 0xFCDC
    .hword 0xF9B9, 0xF696, 0xF375, 0xF055, 0xED38, 0xEA1E, 0xE708, 0xE3F5
    .hword 0xE0E7, 0xDDDD, 0xDAD8, 0xD7DA, 0xD4E1, 0xD1EF, 0xCF05, 0xCC22
    .hword 0xC946, 0xC674, 0xC3AA, 0xC0E9, 0xBE32, 0xBB86, 0xB8E4, 0xB64C
    .hword 0xB3C1, 0xB141, 0xAECD, 0xAC65, 0xAA0B, 0xA7BE, 0xA57E, 0xA34C
    .hword 0xA129, 0x9F14, 0x9D0E, 0x9B18, 0x9931, 0x975A, 0x9593, 0x93DC
    .hword 0x9236, 0x90A1, 0x8F1E, 0x8DAB, 0x8C4B, 0x8AFC, 0x89BF, 0x8894
    .hword 0x877C, 0x8676, 0x8583, 0x84A3, 0x83D7, 0x831D, 0x8276, 0x81E3
    .hword 0x8163, 0x80F7, 0x809E, 0x8059, 0x8028, 0x800A, 0x6488, 0x0080
    .hword 0x03FF, 0x0116, 0x0002, 0x0080, 0x4000, 0x3FD7, 0x3FAF, 0x3F86
    .hword 0x3F5D, 0x3F34, 0x3F0C, 0x3EE3, 0x3EBA, 0x3E91, 0x3E68, 0x3E40
    .hword 0x3E17, 0x3DEE, 0x3DC5, 0x3D9C, 0x3D74, 0x3D4B, 0x3D22, 0x3CF9
    .hword 0x3CD0, 0x3CA7, 0x3C7F, 0x3C56, 0x3C2D, 0x3C04, 0x3BDB, 0x3BB2
    .hword 0x3B89, 0x3B60, 0x3B37, 0x3B0E, 0x3AE5, 0x3ABC, 0x3A93, 0x3A69
    .hword 0x3A40, 0x3A17, 0x39EE, 0x39C5, 0x399C, 0x3972, 0x3949, 0x3920
    .hword 0x38F6, 0x38CD, 0x38A4, 0x387A, 0x3851, 0x3827, 0x37FE, 0x37D4
    .hword 0x37AA, 0x3781, 0x3757, 0x372D, 0x3704, 0x36DA, 0x36B0, 0x3686
    .hword 0x365C, 0x3632, 0x3609, 0x35DF, 0x35B4, 0x358A, 0x3560, 0x3536
    .hword 0x350C, 0x34E1, 0x34B7, 0x348D, 0x3462, 0x3438, 0x340D, 0x33E3
    .hword 0x33B8, 0x338D, 0x3363, 0x3338, 0x330D, 0x32E2, 0x32B7, 0x328C
    .hword 0x3261, 0x3236, 0x320B, 0x31DF, 0x31B4, 0x3188, 0x315D, 0x3131
    .hword 0x3106, 0x30DA, 0x30AE, 0x3083, 0x3057, 0x302B, 0x2FFF, 0x2FD2
    .hword 0x2FA6, 0x2F7A, 0x2F4D, 0x2F21, 0x2EF4, 0x2EC8, 0x2E9B, 0x2E6E
    .hword 0x2E41, 0x2E14, 0x2DE7, 0x2DBA, 0x2D8D, 0x2D60, 0x2D32, 0x2D05
    .hword 0x2CD7, 0x2CA9, 0x2C7B, 0x2C4D, 0x2C1F, 0x2BF1, 0x2BC3, 0x2B94
    .hword 0x2B66, 0x2B37, 0x2B09, 0x2ADA, 0x2AAB, 0x2A7C, 0x2A4C, 0x2A1D
    .hword 0x29ED, 0x29BE, 0x298E, 0x295E, 0x292E, 0x28FE, 0x28CE, 0x289D
    .hword 0x286D, 0x283C, 0x280B, 0x27DA, 0x27A9, 0x2777, 0x2746, 0x2714
    .hword 0x26E2, 0x26B0, 0x267E, 0x264C, 0x2619, 0x25E7, 0x25B4, 0x2581
    .hword 0x254D, 0x251A, 0x24E6, 0x24B2, 0x247E, 0x244A, 0x2415, 0x23E1
    .hword 0x23AC, 0x2376, 0x2341, 0x230B, 0x22D6, 0x229F, 0x2269, 0x2232
    .hword 0x21FC, 0x21C4, 0x218D, 0x2155, 0x211D, 0x20E5, 0x20AD, 0x2074
    .hword 0x203B, 0x2001, 0x1FC7, 0x1F8D, 0x1F53, 0x1F18, 0x1EDD, 0x1EA1
    .hword 0x1E66, 0x1E29, 0x1DED, 0x1DB0, 0x1D72, 0x1D35, 0x1CF6, 0x1CB8
    .hword 0x1C79, 0x1C39, 0x1BF9, 0x1BB8, 0x1B77, 0x1B36, 0x1AF4, 0x1AB1
    .hword 0x1A6E, 0x1A2A, 0x19E6, 0x19A1, 0x195C, 0x1915, 0x18CE, 0x1887
    .hword 0x183F, 0x17F5, 0x17AC, 0x1761, 0x1715, 0x16C9, 0x167C, 0x162E
    .hword 0x15DF, 0x158E, 0x153D, 0x14EB, 0x1497, 0x1442, 0x13EC, 0x1395
    .hword 0x133C, 0x12E2, 0x1286, 0x1228, 0x11C9, 0x1167, 0x1104, 0x109E
    .hword 0x1036, 0x0FCC, 0x0F5F, 0x0EEF, 0x0E7B, 0x0E04, 0x0D89, 0x0D0A
    .hword 0x0C86, 0x0BFD, 0x0B6D, 0x0AD6, 0x0A36, 0x098D, 0x08D7, 0x0811
    .hword 0x0736, 0x063E, 0x0519, 0x039A, 0x0000, 0x7FFF, 0x0100, 0x0080
    .hword 0x021D, 0x00C8, 0x00CE, 0x0048, 0x0A26, 0x277A, 0x00CE, 0x6488
    .hword 0x14AC, 0x0001, 0x00F9, 0x00FC, 0x00FF, 0x00FC, 0x00F9, 0xFFFF
    .hword 0xFFFF:0xD0

.text
.set noreorder

.align 5
dsp1_execute: // a0: status
    // Check if the data register is in 8-bit mode, waiting for a command
    andi t0, a0, 0x400 // DRC
    beqz t0, check_input
    move v1, ra

    // Look up and reload a DSP1 command function and its parameter counts
    lbu t0, dsp1_dr + 1
    andi t1, t0, 0xC0
    bnez t1, skip_cmd
    sll t0, t0, 3
    ld t0, dsp1_cmds(t0)
    xori a0, a0, 0x400 // DRC
    sd t0, cmd_func
    sh a0, dsp1_sr
    jr v1

check_input:
    // Do nothing unless the upper byte was accessed
    xori a0, a0, 0x1000 // DRS
    sh a0, dsp1_sr
    andi t0, a0, 0x1000 // DRS
    bnez t0, skip_cmd
    nop

    // Write a value to the input buffer if there's anything to send
    lhu t0, cmd_count + 0
    beqz t0, check_output
    addi t0, t0, -1
    sh t0, cmd_count + 0
    lhu t1, dsp1_dr
    sll t0, t0, 1
    sh t1, input_buf(t0)

    // Execute a command once all input has been sent
    bnez t0, skip_cmd
    nop
loop_cmd:
    lw t0, cmd_func
    jr t0
    nop

check_output:
    // Read a value from the output buffer if there's anything to receive
    lhu t0, cmd_count + 2
    beqz t0, check_cmd
    addi t0, t0, -1
    sh t0, cmd_count + 2
    sll t0, t0, 1
    andi t0, t0, 0xE
    lhu t1, output_buf(t0)
    sh t1, dsp1_dr
    jr v1
    nop

check_cmd:
    // Check if running a raster command, or if an end value was sent
    lw t0, cmd_func
    la t1, dsp1_raster
    bne t0, t1, finish_cmd
    li t1, 0x8000
    lhu t0, dsp1_dr
    beq t0, t1, finish_cmd
    nop

    // Increment the input and loop the raster command
    lhu t0, input_buf + 0
    li t1, 4
    addi t0, t0, 1
    sh t0, input_buf + 0
    sh t1, cmd_count + 2
    b loop_cmd
    nop

finish_cmd:
    // Report command completion and wait for the next one
    lhu a0, dsp1_sr
    li t0, 0x80
    sh t0, dsp1_dr
    ori a0, a0, 0x400 // DRC
    sh a0, dsp1_sr
skip_cmd:
    jr v1
    nop

.align 5
calc_sin: // a0: angle - a0: result
    // Handle special cases and negate the 16-bit angle if it's negative
    bne a0, -0x8000, sin_valid
    slt t4, a0, zero
    jr ra
    li a0, 0
sin_valid:
    sub t5, zero, t4
    xor a0, a0, t5
    add a0, a0, t4

    // Look up values in the sine table and wrap/negate on overflow
    srl t0, a0, 8
    sll t0, t0, 1
    lh t1, data_rom + 0x22C(t0)
    addi t0, t0, 0x80
    andi t3, t0, 0x100 // Negate
    sub t0, t0, t3
    lh t2, data_rom + 0x22C(t0)
    srl t3, t3, 8
    sub t0, zero, t3
    xor t2, t2, t0
    add t2, t2, t3

    // Calculate the result
    li t0, 0x3244 // Pi << 12
    andi t3, a0, 0xFF
    mult t0, t3
    mflo t0
    sra t0, t0, 12
    mult t0, t2
    mflo t0
    sra t0, t0, 15
    add a0, t0, t1

    // Check for overflow and negate if the angle was negative
    ble a0, 0x7FFF, sin_under
    nop
    li a0, 0x7FFF
sin_under:
    xor a0, a0, t5
    jr ra
    add a0, a0, t4

.align 5
calc_cos: // a0: angle - a0: result
    // Handle special cases and negate the 16-bit angle if it's negative
    bne a0, -0x8000, cos_valid
    slt t4, a0, zero
    jr ra
    li a0, -0x8000
cos_valid:
    sub t0, zero, t4
    xor a0, a0, t0
    add a0, a0, t4

    // Look up values in the sine table and wrap/negate on overflow
    srl t0, a0, 8
    sll t0, t0, 1
    lh t1, data_rom + 0x22C(t0)
    addi t0, t0, 0x80
    andi t3, t0, 0x100 // Negate
    sub t0, t0, t3
    lh t2, data_rom + 0x22C(t0)
    srl t3, t3, 8
    sub t0, zero, t3
    xor t2, t2, t0
    add t2, t2, t3

    // Calculate the result
    li t0, 0x3244 // Pi << 12
    andi t3, a0, 0xFF
    mult t0, t3
    mflo t0
    sra t0, t0, 12
    mult t0, t1
    mflo t0
    sra t0, t0, 15
    sub a0, t2, t0

    // Check for underflow in the result
    bgt a0, -0x8000, cos_over
    nop
    li a0, -0x7FFF
cos_over:
    jr ra
    nop

.align 5
calc_normal: // a0: number, a1: exponent - a0: coefficient, a1: exponent
    // Set initial values for normalizing a 16-bit number with range -1 to 1
    li t0, 0
    li t1, 0x4000
    sra t2, a0, 31
    xor t2, t2, a0 // Absolute

normal_loop:
    // Count leading zeros in the absolute value of the number
    and t3, t2, t1
    bnez t3, normal_coeff
    srl t1, t1, 1
    beqz t1, normal_coeff
    addi t0, t0, 1
    b normal_loop
    nop

normal_coeff:
    // Use a lookup table to calculate the coefficient and adjust its exponent
    beqz t0, normal_same
    sll t1, t0, 1
    lh t1, data_rom + 0x42(t1)
    mult a0, t1
    mflo a0
    sll a0, a0, 1
normal_same:
    jr ra
    sub a1, a1, t0

.align 5
calc_norm32: // a0: number - a0: coefficient, a1: exponent
    // Set initial values for normalizing a 32-bit number with range -1 to 1
    li a1, 0
    li t1, 0x4000
    sra t2, a0, 31
    andi t3, a0, 0x7FFF
    sra a0, a0, 15
    xor t4, t2, a0 // Absolute
    xor t2, t2, t3 // Absolute

norm32_loop:
    // Count leading zeros in the absolute upper value of the number
    and t0, t4, t1
    bnez t0, norm32_coeff
    srl t1, t1, 1
    beqz t1, norm32_coeff
    addi a1, a1, 1
    b norm32_loop
    nop

norm32_coeff:
    // Use a lookup table to calculate the upper coefficient
    beqz a1, norm32_done
    sll t1, a1, 1
    lh t1, data_rom + 0x42(t1)
    sll t1, t1, 1
    mult a0, t1
    mflo a0

    // Adjust the coefficient for the lower value if upper isn't empty
    bge a1, 15, norm16_count
    sll t0, a1, 1
    sub t0, zero, t0
    lh t0, data_rom + 0x80(t0)
    mult t0, t3
    mflo t0
    sra t0, t0, 15
    b norm32_done
    add a0, a0, t0

norm16_count:
    // Count leading zeros in the absolute lower value of the number
    li t1, 0x4000
norm16_loop:
    and t0, t2, t1
    bnez t0, norm16_coeff
    srl t1, t1, 1
    beqz t1, norm16_coeff
    addi a1, a1, 1
    b norm16_loop
    nop

norm16_coeff:
    // Adjust the coefficient for the lower value if upper is empty
    ble a1, 15, norm32_done
    add a0, a0, t3
    sll t0, a1, 1
    lh t0, data_rom + 0x24(t0)
    mult t0, t3
    mflo a0
    sll a0, a0, 1

norm32_done:
    // Ensure the 16-bit result is properly sign-extended
    sll a0, a0, 16
    jr ra
    sra a0, a0, 16

.align 5
calc_denorm: // a0: coefficient, a1: exponent - a0: result
    // Use a lookup table to denormalize a 16-bit coefficient with its exponent
    bgez a1, denorm_pos
    sll t0, a1, 1
    lh t0, data_rom + 0x62(t0)
    mult a0, t0
    mflo t0
    jr ra
    sra a0, t0, 15

denorm_pos:
    // Handle positive exponents and other special cases
    beqz a1, denorm_end
    nop
    beqz a0, denorm_end
    nop
    bgtz a0, denorm_end
    li a0, 0x7FFF
    li a0, -0x7FFF
denorm_end:
    jr ra
    nop

.align 5
calc_inverse: // a0: coefficient, a1: exponent - a0: coefficient, a1: exponent
    // Handle cases where the coefficient is zero
    bnez a0, inverse_valid
    nop
    li a0, 0x7FFF
    jr ra
    li a1, 0x2F

inverse_valid:
    // Negate the 16-bit coefficient if it's negative
    slti t0, a0, -0x7FFF
    add a0, a0, t0 // Prevent overflow
    slt t4, a0, zero
    sub t5, zero, t4
    xor a0, a0, t5
    add a0, a0, t4

inverse_loop:
    // Normalize the coefficient
    bge a0, 0x4000, inverse_case
    nop
    sll a0, a0, 1
    b inverse_loop
    addi a1, a1, -1

inverse_case:
    // Handle other special cases
    bne a0, 0x4000, inverse_guess
    nop
    beqz t4, inverse_exp
    li a0, 0x7FFF
    li a0, -0x4000
    b inverse_exp
    addi a1, a1, -1

inverse_guess:
    // Use a lookup table to get an initial guess of the inverse
    srl t0, a0, 7
    sll t0, t0, 1
    lh t0, data_rom - 0x36(t0)
    li t3, 1

inverse_refine:
    // Refine the guess with two iterations of Newton's Method
    mult a0, t0
    sub t2, zero, t0
    mflo t1
    sra t1, t1, 15
    mult t1, t2
    mflo t1
    sra t1, t1, 15
    add t0, t0, t1
    sll t0, t0, 1
    bnez t3, inverse_refine
    addi t3, t3, -1

    // Negate if the input was negative and invert the exponent
    xor a0, t0, t5
    add a0, a0, t4
inverse_exp:
    sub a1, zero, a1
    jr ra
    addi a1, a1, 1

.align 5
dsp1_multip:
    // Multiply two 16-bit values
    lh t0, input_buf + 2
    lh t1, input_buf + 0
    mult t0, t1
    mflo t0
    sra t0, t0, 15
    sh t0, output_buf + 0
    j check_output
    nop

.align 5
dsp1_triang:
    // Calculate the X component of a 2D vector using angle and radius
    lh t9, input_buf + 2
    lh t8, input_buf + 0
    jal calc_cos
    move a0, t9
    mult a0, t8
    mflo t0
    sra t0, t0, 15
    sh t0, output_buf + 0

    // Calculate the Y component of a 2D vector using angle and radius
    jal calc_sin
    move a0, t9
    mult a0, t8
    mflo t0
    sra t0, t0, 15
    sh t0, output_buf + 2
    j check_output
    nop

.align 5
dsp1_rotate:
    // Get the sine and cosine of the input angle
    lh a0, input_buf + 4
    jal calc_sin
    move t9, a0
    move t8, a0
    jal calc_cos
    move a0, t9

    // Calculate the rotated X-coordinate from the input coordinates
    lh t0, input_buf + 0
    mult t0, t8
    lh t1, input_buf + 2
    mflo t2
    mult t1, a0
    sra t2, t2, 15
    mflo t3
    sra t3, t3, 15
    add t2, t2, t3
    sh t2, output_buf + 2

    // Calculate the rotated Y-coordinate from the input coordinates
    mult t0, a0
    mflo t2
    mult t1, t8
    sra t2, t2, 15
    mflo t3
    sra t3, t3, 15
    sub t2, t2, t3
    sh t2, output_buf + 0
    j check_output
    nop

.align 5
dsp1_radius:
    // Calculate the 32-bit squared normal of a 3D vector
    lh t0, input_buf + 4
    mult t0, t0
    lh t1, input_buf + 2
    mflo t0
    mult t1, t1
    lh t2, input_buf + 0
    mflo t1
    mult t2, t2
    add t0, t0, t1
    mflo t2
    add t0, t0, t2
    sll t0, t0, 1

    // Output the result as two 16-bit halves
    sh t0, output_buf + 2
    sra t0, t0, 16
    sh t0, output_buf + 0
    j check_output
    nop

.align 5
dsp1_distan:
    // Calculate the 32-bit squared normal of a 3D vector
    lh t0, input_buf + 4
    mult t0, t0
    lh t1, input_buf + 2
    mflo t0
    mult t1, t1
    lh t2, input_buf + 0
    mflo t1
    mult t2, t2
    add t0, t0, t1
    mflo t2
    add a0, t0, t2
    beqz a0, distan_set
    nop

    // Normalize and look up points for square root interpolation
    jal calc_norm32
    nop
    andi t0, a1, 0x1
    sra a0, a0, t0
    sra t0, a0, 9
    sll t0, t0, 1
    lh t1, data_rom + 0x1AC(t0)
    lh t0, data_rom + 0x1AA(t0)

    // Calculate the square root to get the length of the vector
    sub t2, t1, t0
    andi a0, a0, 0x1FF
    mult t2, a0
    mflo t2
    sra t2, t2, 9
    add a0, t2, t0
    sra t0, a1, 1
    sra a0, a0, t0
distan_set:
    sh a0, output_buf + 0
    j check_output
    nop

.align 5
dsp1_atti_a:
    // Choose which matrix to calculate based on the command
    b dsp1_attitu
    li t0, 9 * 0
dsp1_atti_b:
    b dsp1_attitu
    li t0, 9 * 2
dsp1_atti_c:
    li t0, 9 * 4
dsp1_attitu:
    la a1, matrix_a
    add a1, a1, t0

    // Calculate the sine and cosine of each input angle
    lh sp, input_buf + 0
    jal calc_sin
    move a0, sp
    move t9, a0
    jal calc_cos
    move a0, sp
    move t8, a0
    lh sp, input_buf + 2
    jal calc_sin
    move a0, sp
    move t7, a0
    jal calc_cos
    move a0, sp
    move t6, a0
    lh sp, input_buf + 4
    jal calc_sin
    move a0, sp
    move t5, a0
    jal calc_cos
    move a0, sp
    lh sp, input_buf + 6
    sra sp, sp, 1

    // Calculate the first row of an attitude matrix
    mult sp, a0
    mflo a0
    sra a0, a0, 15
    mult a0, t6
    mflo t0
    sra t0, t0, 15
    sh t0, 0(a1)
    mult sp, t5
    mflo t5
    sra t5, t5, 15
    mult t5, t8
    mflo t0
    mult a0, t9
    sra t0, t0, 15
    mflo t1
    sra t1, t1, 15
    mult t1, t7
    mflo t1
    sra t1, t1, 15
    add t0, t0, t1
    sh t0, 2(a1)
    mult t5, t9
    mflo t0
    mult a0, t8
    sra t0, t0, 15
    mflo t1
    sra t1, t1, 15
    mult t1, t7
    mflo t1
    sra t1, t1, 15
    sub t0, t0, t1
    sh t0, 4(a1)

    // Calculate the second row of an attitude matrix
    mult t5, t6
    mflo t0
    sra t0, t0, 15
    sub t0, zero, t0
    sh t0, 6(a1)
    mult a0, t8
    mflo t0
    mult t5, t9
    sra t0, t0, 15
    mflo t1
    sra t1, t1, 15
    mult t1, t7
    mflo t1
    sra t1, t1, 15
    add t0, t0, t1
    sh t0, 8(a1)
    mult a0, t9
    mflo t0
    mult t5, t8
    sra t0, t0, 15
    mflo t1
    sra t1, t1, 15
    mult t1, t7
    mflo t1
    sra t1, t1, 15
    add t0, t0, t1
    sh t0, 10(a1)

    // Calculate the third row of an attitude matrix
    mult sp, t7
    mflo t0
    sra t0, t0, 15
    sh t0, 12(a1)
    mult sp, t9
    mflo t0
    sra t0, t0, 15
    mult t0, t6
    mflo t0
    sra t0, t0, 15
    sub t0, zero, t0
    sh t0, 14(a1)
    mult sp, t8
    mflo t0
    sra t0, t0, 15
    mult t0, t6
    mflo t0
    sra t0, t0, 15
    j check_output
    sh t0, 16(a1)

.align 5
dsp1_subj_a:
    // Choose which matrix to use based on the command
    b dsp1_subjec
    li t0, 9 * 0
dsp1_subj_b:
    b dsp1_subjec
    li t0, 9 * 2
dsp1_subj_c:
    li t0, 9 * 4
dsp1_subjec:
    la a1, matrix_a
    add a1, a1, t0

    // Multiply object coordinates with a matrix to get a global X-coordinate
    lh t9, input_buf + 4
    lh t0, 0(a1)
    lh t8, input_buf + 2
    mult t0, t9
    lh t7, input_buf + 0
    mflo t0
    lh t1, 2(a1)
    sra t0, t0, 15
    mult t1, t8
    lh t2, 4(a1)
    mflo t1
    mult t2, t7
    sra t1, t1, 15
    add t0, t0, t1
    mflo t2
    sra t2, t2, 15
    add t0, t0, t2
    sh t0, output_buf + 4

    // Multiply object coordinates with a matrix to get a global Y-coordinate
    lh t0, 6(a1)
    mult t0, t9
    lh t1, 8(a1)
    mflo t0
    sra t0, t0, 15
    mult t1, t8
    lh t2, 10(a1)
    mflo t1
    mult t2, t7
    sra t1, t1, 15
    add t0, t0, t1
    mflo t2
    sra t2, t2, 15
    add t0, t0, t2
    sh t0, output_buf + 2

    // Multiply object coordinates with a matrix to get a global Z-coordinate
    lh t0, 12(a1)
    mult t0, t9
    lh t1, 14(a1)
    mflo t0
    sra t0, t0, 15
    mult t1, t8
    lh t2, 16(a1)
    mflo t1
    mult t2, t7
    sra t1, t1, 15
    add t0, t0, t1
    mflo t2
    sra t2, t2, 15
    add t0, t0, t2
    sh t0, output_buf + 0
    j check_output
    nop

.align 5
dsp1_obje_a:
    // Choose which matrix to use based on the command
    b dsp1_object
    li t0, 9 * 0
dsp1_obje_b:
    b dsp1_object
    li t0, 9 * 2
dsp1_obje_c:
    li t0, 9 * 4
dsp1_object:
    la a1, matrix_a
    add a1, a1, t0

    // Multiply global coordinates with a matrix to get an object F-coordinate
    lh t9, input_buf + 4
    lh t0, 0(a1)
    lh t8, input_buf + 2
    mult t0, t9
    lh t7, input_buf + 0
    mflo t0
    lh t1, 6(a1)
    sra t0, t0, 15
    mult t1, t8
    lh t2, 12(a1)
    mflo t1
    mult t2, t7
    sra t1, t1, 15
    add t0, t0, t1
    mflo t2
    sra t2, t2, 15
    add t0, t0, t2
    sh t0, output_buf + 4

    // Multiply global coordinates with a matrix to get an object L-coordinate
    lh t0, 2(a1)
    mult t0, t9
    lh t1, 8(a1)
    mflo t0
    sra t0, t0, 15
    mult t1, t8
    lh t2, 14(a1)
    mflo t1
    mult t2, t7
    sra t1, t1, 15
    add t0, t0, t1
    mflo t2
    sra t2, t2, 15
    add t0, t0, t2
    sh t0, output_buf + 2

    // Multiply global coordinates with a matrix to get an object U-coordinate
    lh t0, 4(a1)
    mult t0, t9
    lh t1, 10(a1)
    mflo t0
    sra t0, t0, 15
    mult t1, t8
    lh t2, 16(a1)
    mflo t1
    mult t2, t7
    sra t1, t1, 15
    add t0, t0, t1
    mflo t2
    sra t2, t2, 15
    add t0, t0, t2
    sh t0, output_buf + 0
    j check_output
    nop

.align 5
dsp1_gyrate:
    // Calculate the X-angle secant and Y-angle sine and cosine
    lh a0, input_buf + 8
    jal calc_cos
    nop
    jal calc_inverse
    li a1, 0
    move t8, a0
    move t9, a1
    lh a0, input_buf + 6
    jal calc_cos
    move t7, a0
    move t6, a0
    jal calc_sin
    move a0, t7
    move t5, a0

    // Rotate the X-angle by the minor angular displacements
    lh t3, input_buf + 4
    mult t3, t5
    lh t4, input_buf + 2
    mflo t0
    mult t4, t6
    lh t2, input_buf + 8
    mflo t1
    sra t0, t0, 15
    add t0, t0, t2
    sra t1, t1, 15
    add t0, t0, t1
    sh t0, output_buf + 2

    // Rotate the Z-angle by the minor angular displacements
    mult t3, t6
    mflo t6
    mult t4, t5
    mflo t5
    jal calc_norm32
    sub a0, t6, t5
    mult a0, t8
    sub a1, t9, a1
    mflo a0
    jal calc_normal
    sra a0, a0, 15
    jal calc_denorm
    nop
    lh t0, input_buf + 10
    add t0, t0, a0
    sh t0, output_buf + 4

    // Rotate the Y-angle by the minor angular displacements
    jal calc_norm32
    add a0, t6, t5
    move t7, a0
    lh a0, input_buf + 8
    jal calc_sin
    sub a1, t9, a1
    jal calc_normal
    nop
    mult t8, a0
    mflo t0
    sra t0, t0, 15
    mult t0, t7
    mflo t0
    sra t0, t0, 15
    jal calc_normal
    sub a0, zero, t0
    jal calc_denorm
    nop
    lh t0, input_buf + 6
    lh t1, input_buf + 0
    add t0, t0, a0
    add t0, t0, t1
    sh t0, output_buf + 0
    j check_output
    nop

.align 5
dsp1_params:
    // Save the sine and cosine of the azimuth angle
    lh t9, input_buf + 2
    jal calc_sin
    move a0, t9
    sh a0, aas_sin
    move t6, a0
    jal calc_cos
    move a0, t9
    sh a0, aas_cos
    move t7, a0

    // Save the sine and cosine of the zenith angle
    lh t9, input_buf + 0
    jal calc_sin
    move a0, t9
    sh a0, azs_sin
    move t8, a0
    jal calc_cos
    move a0, t9
    sh a0, azs_cos
    move t9, a0

    // Save the base point to screen distance and normalize it
    lh a0, input_buf + 4
    sh a0, les
    move t5, a0
    jal calc_normal
    li a1, 0
    sh a0, les_c
    sh a1, les_e

    // Save the screen normal, projection center, and screen center X-coordinates
    sub t0, zero, t6
    mult t8, t0
    lh t3, input_buf + 6
    mflo t0
    sra t0, t0, 15
    sh t0, normal_x
    mult t3, t0
    lh t2, input_buf + 12
    mflo t1
    sra t1, t1, 15
    add t1, t1, t2
    sh t1, center_x
    mult t5, t0
    mflo t2
    sra t2, t2, 15
    sub t2, t1, t2
    sh t2, global_x

    // Save the screen normal, projection center, and screen center Y-coordinates
    mult t8, t7
    li t4, 0x7FFF
    mflo t0
    sra t0, t0, 15
    sh t0, normal_y
    mult t3, t0
    lh t2, input_buf + 10
    mflo t1
    sra t1, t1, 15
    add t1, t1, t2
    sh t1, center_y
    mult t5, t0
    mflo t2
    sra t2, t2, 15
    sub t2, t1, t2
    sh t2, global_y

    // Save the screen normal, projection center, and screen center Z-coordinates
    mult t9, t4
    mflo t0
    sra t0, t0, 15
    sh t0, normal_z
    mult t3, t0
    lh t2, input_buf + 8
    mflo t1
    sra t1, t1, 15
    add a0, t1, t2
    sh a0, center_z
    mult t5, t0
    mflo t2
    sra t2, t2, 15
    sub t2, a0, t2
    sh t2, global_z

    // Save the normalized projection center Z-coordinate
    jal calc_normal
    li a1, 0
    sh a0, center_zc
    sh a1, center_ze

    // Save the screen's vertical vector
    sub t0, zero, t6
    mult t9, t0
    sub t3, zero, t8
    mflo t0
    sra t0, t0, 15
    sh t0, vert_x
    mult t9, t7
    mflo t0
    sra t0, t0, 15
    sh t0, vert_y
    mult t3, t4
    mflo t0
    sra t0, t0, 15
    sh t0, vert_z

    // Save the screen's horizontal vector
    mult t7, t4
    mflo t0
    sra t0, t0, 15
    sh t0, hori_x
    mult t6, t4
    mflo t0
    sra t0, t0, 15
    sh t0, hori_y

    // Clip the zenith angle based on the center Z-exponent
    lh t9, input_buf + 0
    sub t8, zero, a1
    sll t8, t8, 1
    lh t8, azsc_bounds(t8)
    bgez t9, azsc_pos
    sub t0, zero, t8
    addi t0, t0, 1
    bge t9, t0, azsc_sincos
    addi t8, t0, -1
    b azsc_sincos
    move t9, t0
azsc_pos:
    bge t8, t9, azsc_sincos
    nop
    move t9, t8

azsc_sincos:
    // Save the sine, cosine, and secant of the clipped zenith angle
    jal calc_sin
    move a0, t9
    sh a0, azsc_sin
    move t7, a0
    jal calc_cos
    move a0, t9
    sh a0, azsc_cos
    move t6, a0
    jal calc_inverse
    li a1, 0
    sh a0, azs_sec1c
    sh a1, azs_sec1e

    // Calculate separation between the center and its projection over the ground
    lh t0, center_zc
    lh t1, center_ze
    mult a0, t0
    add a1, a1, t1
    mflo a0
    jal calc_normal
    sra a0, a0, 15
    jal calc_denorm
    nop
    mult a0, t7
    mflo a0
    sra a0, a0, 15

    // Adjust the projection center based on the azimuth angle
    lh t0, aas_sin
    mult t0, a0
    lh t1, center_x
    mflo t0
    sra t0, t0, 15
    add t1, t1, t0
    sh t1, center_x
    lh t0, aas_cos
    sh t1, output_buf + 2
    mult t0, a0
    lh t1, center_y
    mflo t0
    sra t0, t0, 15
    sub t1, t1, t0
    sh t1, center_y
    sh t1, output_buf + 0

    // Check if clipping corrections should be done and set the imaginary center line
    lh t0, input_buf + 0
    bne t0, t9, clip_correct
    li t5, 0
    beq t0, t8, clip_correct
    nop
clip_return:
    sh t5, output_buf + 6

    // Calculate the horizon line and save the vertical screen offset
    lh t9, les
    mult t9, t6
    mflo t9
    sra t9, t9, 15
    move a0, t7
    jal calc_inverse
    li a1, 0
    move t8, a0
    jal calc_normal
    move a0, t9
    mult a0, t8
    sh t9, v_offset
    mflo a0
    jal calc_normal
    sra a0, a0, 15

    // Handle special cases and set the denormalized horizon line
    bne a0, -0x8000, horiz_valid
    sub a0, zero, a0
    sra a0, a0, 1
    addi a1, a1, 1
horiz_valid:
    jal calc_denorm
    nop
    sh a0, output_buf + 4

    // Save the secant of the clipped zenith angle after correction
    move a0, t6
    jal calc_inverse
    li a1, 0
    sh a0, azs_sec2c
    sh a1, azs_sec2e
    j check_output
    nop

clip_correct:
    // TODO
    j clip_return
    nop

.align 5
dsp1_raster:
    // Calculate the vertical offset between projection point and raster line
    lh t0, input_buf + 0
    lh t1, azs_sin
    mult t0, t1
    lh t2, v_offset
    mflo a0
    sra a0, a0, 15
    add a0, a0, t2
    jal calc_inverse
    li a1, 7

    // Scale the offset by the projection center Z-coordinate
    lh t0, center_zc
    lh t1, center_ze
    mult a0, t0
    add a1, a1, t1
    move t9, a1
    mflo a0
    sra a0, a0, 15
    jal calc_normal
    move t8, a0
    jal calc_denorm
    nop

    // Calculate rotscale parameters A and C for the current line
    lh t7, aas_cos
    mult a0, t7
    lh t6, aas_sin
    mflo t0
    sra t0, t0, 15
    mult a0, t6
    sh t0, output_buf + 6
    mflo t1
    sra t1, t1, 15
    sh t1, output_buf + 2

    // Scale the offset by the secant of the clipped zenith angle
    lh t0, azs_sec2c
    lh t1, azs_sec2e
    mult t8, t0
    mflo a0
    sra a0, a0, 15
    jal calc_normal
    add a1, t9, t1
    jal calc_denorm
    sub t6, zero, t6

    // Calculate rotscale parameters B and D for the current line
    mult a0, t6
    mflo t0
    sra t0, t0, 15
    mult a0, t7
    sh t0, output_buf + 4
    mflo t1
    sra t1, t1, 15
    sh t1, output_buf + 0
    j check_output
    nop

.align 5
dsp1_target:
    // Calculate the base value for projecting a vector over the ground
    lh t9, input_buf + 0
    lh t1, azs_sin
    mult t9, t1
    lh t2, v_offset
    mflo a0
    sra a0, a0, 15
    add a0, a0, t2
    jal calc_inverse
    li a1, 8

    // Apply the center Z-coordinate and calculate horizontal length
    lh t0, center_zc
    lh t1, center_ze
    mult a0, t0
    add a1, a1, t1
    mflo t8
    jal calc_normal
    sra a0, t8, 15
    lh t7, input_buf + 2
    jal calc_denorm
    sll t7, t7, 8
    mult a0, t7
    mflo a0
    sra a0, a0, 15

    // Add projected horizontal offsets to the center coordinates
    lh t2, aas_cos
    lh t0, center_x
    mult a0, t2
    lh t3, aas_sin
    mflo t2
    sra t2, t2, 15
    mult a0, t3
    lh t1, center_y
    mflo t3
    sra t3, t3, 15
    add t6, t0, t2
    sub t7, t1, t3

    // Apply the zenith angle secant and calculate vertical length
    sra a0, t8, 15
    lh t0, azs_sec1c
    lh t1, azs_sec1e
    mult a0, t0
    add a1, a1, t1
    mflo a0
    jal calc_normal
    sra a0, a0, 15
    jal calc_denorm
    sll t9, t9, 8
    mult a0, t9
    mflo a0
    sra a0, a0, 15

    // Add projected vertical offsets to the final coordinates
    lh t2, aas_sin
    mult a0, t2
    lh t3, aas_cos
    mflo t2
    mult a0, t3
    sra t2, t2, 15
    mflo t3
    sra t3, t3, 15
    sub t6, t6, t2
    add t7, t7, t3
    la t0, output_buf
    sh t6, 2(t0)
    j check_output
    sh t7, 0(t0)

.align 5
dsp1_projec:
    // Normalize the offset of a 3D point from the screen center
    lh t0, input_buf + 4
    lh t1, global_x
    jal calc_norm32
    sub a0, t0, t1
    addi t9, a1, -1
    sra t8, a0, 1
    lh t0, input_buf + 2
    lh t1, global_y
    jal calc_norm32
    sub a0, t0, t1
    addi t7, a1, -1
    sra t6, a0, 1
    lh t0, input_buf + 0
    lh t1, global_z
    jal calc_norm32
    sub a0, t0, t1
    addi t5, a1, -1
    sra t4, a0, 1

    // Find the lowest common exponent between the components
    blt t7, t9, low_exp1
    move t0, t7
    move t0, t9
low_exp1:
    blt t0, t5, low_exp2
    nop
    move t0, t5
low_exp2:
    sub t9, t9, t0
    sub t7, t7, t0
    sub t5, t5, t0

    // Adjust the coefficients so they all use the same exponent
    sll t9, t9, 1
    lh t9, data_rom + 0x62(t9)
    mult t8, t9
    sll t7, t7, 1
    lh t7, data_rom + 0x62(t7)
    mflo t8
    sra t8, t8, 15
    mult t6, t7
    sll t5, t5, 1
    lh t5, data_rom + 0x62(t5)
    mflo t6
    mult t4, t5
    sra t6, t6, 15
    mflo t4
    sra sp, t4, 15

    // Calculate the dot product of the point and the normal vector
    lh t9, normal_x
    mult t9, t8
    lh t7, normal_y
    mflo t9
    sra t9, t9, 15
    mult t7, t6
    lh t5, normal_z
    mflo t7
    sra t7, t7, 15
    mult t5, sp
    sub t1, zero, t9
    sub t1, t1, t7
    mflo t5
    sra t5, t5, 15
    sub t1, t1, t5

    // Denormalize the product to a 32-bit value
    li t9, 16
    sub t9, t9, t0
    bgez t9, shift_pos
    sub t0, zero, t9
    b shift_neg
    sra t1, t1, t0
shift_pos:
    sll t1, t1, t9
shift_neg:
    addi t1, t1, 1
    sltu t0, zero, t1
    sub t1, t1, t0
    sra t1, t1, 1

    // Calculate the scale factor and denormalize it
    lhu t0, les
    lh t7, les_e
    jal calc_norm32
    add a0, t0, t1
    addi t7, t7, -15
    add t7, t7, a1
    jal calc_inverse
    li a1, 0
    lh t0, les_c
    mult t0, a0
    mflo t5
    sra t5, t5, 15
    jal calc_normal
    move a0, t5
    add a1, a1, t7
    jal calc_denorm
    addi a1, a1, -7
    sh a0, output_buf + 0

    // Calculate the vertical projection and denormalize it
    lh t0, vert_x
    mult t0, t8
    lh t1, vert_y
    mflo t0
    sra t0, t0, 15
    mult t1, t6
    lh t2, vert_z
    mflo t1
    mult t2, sp
    sra t1, t1, 15
    add t0, t0, t1
    mflo t2
    sra t2, t2, 15
    add t0, t0, t2
    mult t0, t5
    mflo a0
    sra a0, a0, 15
    jal calc_normal
    li a1, 0
    add a1, a1, t7
    jal calc_denorm
    add a1, a1, t9
    sh a0, output_buf + 2

    // Calculate the horizontal projection and denormalize it
    lh t0, hori_x
    mult t0, t8
    lh t1, hori_y
    mflo t0
    mult t1, t6
    sra t0, t0, 15
    mflo t1
    sra t1, t1, 15
    add t0, t0, t1
    mult t0, t5
    mflo a0
    sra a0, a0, 15
    jal calc_normal
    li a1, 0
    add a1, a1, t7
    jal calc_denorm
    add a1, a1, t9
    sh a0, output_buf + 4
    j check_output
    nop

.align 5
dsp1_unimpl:
    // Do nothing for unimplemented DSP1 commands
    la t0, output_buf
    sd zero, 0(t0)
    j check_output
    sd zero, 8(t0)

.align 5
read_dsp1sr: // v0: value
    // Alternate between reading the status register's low and high bytes
    lbu t0, sr_toggle
    xori t0, t0, 0x1
    sb t0, sr_toggle
    lbu v0, dsp1_sr(t0)
    jr ra
    nop

.align 5
read_dsp1dr: // v0: value
    // Read from the data register's low or high byte and run the DSP1
    lhu a0, dsp1_sr
    andi t0, a0, 0x1000 // DRS
    srl t0, t0, 12
    xori t0, t0, 0x1
    lbu v0, dsp1_dr(t0)
    j dsp1_execute
    nop

.align 5
write_dsp1dr: // a1: value
    // Write to the data register's low or high byte and run the DSP1
    lhu a0, dsp1_sr
    andi t0, a0, 0x1000 // DRS
    srl t0, t0, 12
    xori t0, t0, 0x1
    sb a1, dsp1_dr(t0)
    j dsp1_execute
    nop
