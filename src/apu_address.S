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

#include "defines.h"

.globl apu_imm
.globl apu_dira
.globl apu_dirr
.globl apu_drxa
.globl apu_drxr
.globl apu_drya
.globl apu_dryr
.globl apu_brxa
.globl apu_brxr
.globl apu_bxpa
.globl apu_bxpr
.globl apu_absa
.globl apu_absr
.globl apu_abxa
.globl apu_abxr
.globl apu_abya
.globl apu_abyr
.globl apu_idxa
.globl apu_idxr
.globl apu_idya
.globl apu_idyr
.globl apu_drb
.globl apu_dri
.globl apu_dr2
.globl apu_bxy

.text

.align 5
apu_imm: // #nn
    // Get the 8-bit immediate value
    jal jit_read8

    // Emit code to load a value
    li t0, ORI(V0, ZERO, 0)
    or t0, t0, v0
    move ra, gp
    j emit_op

.align 5
apu_dira: // aa
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_dir
apu_dirr:
    li t8, 1

apu_dir:
    // Get the 8-bit immediate address
    jal jit_read8

    // Emit code to load a value from a zero page address
    jal load_flags
    li t0, SLL(A0, S1, 3)
    jal emit_op
    li t0, ANDI(A0, A0, 0x100)
    jal emit_op
    beqz t8, dir_skip
    la t0, apu_read8
    jal emit_jal
dir_skip:
    li t0, ORI(A0, A0, 0)
    or t0, t0, v0
    move ra, gp
    j emit_op

.align 5
apu_drxa: // aa+X
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_drx
apu_drxr:
    li t8, 1

apu_drx:
    // Get the 8-bit immediate address
    jal jit_read8

    // Emit code to load a value from a zero page address plus register X
    jal load_reg_x
    jal load_flags
    li t0, SLL(A0, S1, 3)
    jal emit_op
    li t0, ANDI(A0, A0, 0x100)
    jal emit_op
    li t0, ADDI(T0, T9, 0)
    or t0, t0, v0
    jal emit_op
    li t0, ANDI(T0, T0, 0xFF)
    jal emit_op
    beqz t8, drx_skip
    la t0, apu_read8
    jal emit_jal
drx_skip:
    li t0, OR(A0, A0, T0)
    move ra, gp
    j emit_op

.align 5
apu_drya: // aa+Y
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_dry
apu_dryr:
    li t8, 1

apu_dry:
    // Get the 8-bit immediate address
    jal jit_read8

    // Emit code to load a value from a zero page address plus register Y
    jal load_reg_y
    jal load_flags
    li t0, SLL(A0, S1, 3)
    jal emit_op
    li t0, ANDI(A0, A0, 0x100)
    jal emit_op
    li t0, ADDI(T0, T8, 0)
    or t0, t0, v0
    jal emit_op
    li t0, ANDI(T0, T0, 0xFF)
    jal emit_op
    beqz t8, dry_skip
    la t0, apu_read8
    jal emit_jal
dry_skip:
    li t0, OR(A0, A0, T0)
    move ra, gp
    j emit_op

.align 5
apu_brxa: // (X)
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_brx
apu_brxr:
    li t8, 1

apu_brx:
    // Emit code to load a value from register X as a zero page address
    jal load_reg_x
    jal load_flags
    li t0, SLL(A0, S1, 3)
    jal emit_op
    li t0, ANDI(A0, A0, 0x100)
    jal emit_op
    li t0, ANDI(T9, T9, 0xFF)
    jal emit_op
    beqz t8, brx_skip
    la t0, apu_read8
    jal emit_jal
brx_skip:
    li t0, OR(A0, A0, T9)
    move ra, gp
    j emit_op

.align 5
apu_bxpa: // (X)+
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_bxp
apu_bxpr:
    li t8, 1

apu_bxp:
    // Update the JIT register state
    ori s1, s1, FLAG_SX

    // Emit code to load a value from register X as a zero page address with post-increment
    jal load_reg_x
    jal load_flags
    li t0, SLL(A0, S1, 3)
    jal emit_op
    li t0, ANDI(A0, A0, 0x100)
    jal emit_op
    li t0, ANDI(T9, T9, 0xFF)
    jal emit_op
    li t0, OR(A0, A0, T9)
    jal emit_op
    beqz t8, bxp_skip
    la t0, apu_read8
    jal emit_jal
bxp_skip:
    li t0, ADDI(T9, T9, 1)
    move ra, gp
    j emit_op

.align 5
apu_absa: // aaaa
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_abs
apu_absr:
    li t8, 1

apu_abs:
    // Get the 16-bit immediate address
    jal jit_read8
    move t7, v0
    jal jit_read8
    sll t0, v0, 8
    or t7, t7, t0

    // Emit code to load a value from an absolute address
    beqz t8, abs_skip
    la t0, apu_read8
    jal emit_jal
abs_skip:
    li t0, ORI(A0, ZERO, 0)
    or t0, t0, t7
    move ra, gp
    j emit_op

.align 5
apu_abxa: // aaaa+X
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_abx
apu_abxr:
    li t8, 1

apu_abx:
    // Get the 16-bit immediate address
    jal jit_read8
    move t7, v0
    jal jit_read8
    sll t0, v0, 8
    or t7, t7, t0

    // Emit code to load a value from an absolute address plus register X
    jal load_reg_x
    li t0, ANDI(T9, T9, 0xFF)
    jal emit_op
    li t0, ADDI(A0, T9, 0)
    or t0, t0, t7
    jal emit_op
    beqz t8, abx_skip
    la t0, apu_read8
    jal emit_jal
abx_skip:
    li t0, ANDI(A0, A0, 0xFFFF)
    move ra, gp
    j emit_op

.align 5
apu_abya: // aaaa+Y
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_aby
apu_abyr:
    li t8, 1

apu_aby:
    // Get the 16-bit immediate address
    jal jit_read8
    move t7, v0
    jal jit_read8
    sll t0, v0, 8
    or t7, t7, t0

    // Emit code to load a value from an absolute address plus register Y
    jal load_reg_y
    li t0, ANDI(T8, T8, 0xFF)
    jal emit_op
    li t0, ADDI(A0, T8, 0)
    or t0, t0, t7
    jal emit_op
    beqz t8, aby_skip
    la t0, apu_read8
    jal emit_jal
aby_skip:
    li t0, ANDI(A0, A0, 0xFFFF)
    move ra, gp
    j emit_op

.align 5
apu_idxa: // [aa+X]
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_idx
apu_idxr:
    li t8, 1

apu_idx:
    // Get the 8-bit immediate address
    jal jit_read8

    // Emit code to form a zero page address plus register X
    jal load_reg_x
    jal load_flags
    li t0, SLL(A0, S1, 3)
    jal emit_op
    li t0, ANDI(A0, A0, 0x100)
    jal emit_op
    li t0, ADDI(T0, T9, 0)
    or t0, t0, v0
    jal emit_op
    li t0, ANDI(T0, T0, 0xFF)
    jal emit_op
    li t0, OR(A0, A0, T0)
    jal emit_op

    // Emit code to load a value from a 16-bit address in the zero page
    la t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, 1)
    jal emit_op
    li t0, SLL(S0, V0, 8)
    jal emit_op
    la t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, -1)
    jal emit_op
    beqz t8, idx_skip
    la t0, apu_read8
    jal emit_jal
idx_skip:
    li t0, OR(A0, S0, V0)
    move ra, gp
    j emit_op

.align 5
apu_idya: // [aa]+Y
    // Choose whether to emit a memory read or just provide an address
    li t8, 0
    b apu_idy
apu_idyr:
    li t8, 1

apu_idy:
    // Get the 8-bit immediate address
    jal jit_read8

    // Emit code to form a zero page address
    jal load_flags
    li t0, SLL(A0, S1, 3)
    jal emit_op
    li t0, ANDI(A0, A0, 0x100)
    jal emit_op
    li t0, ORI(A0, A0, 0)
    or t0, t0, v0
    jal emit_op

    // Emit code to load a 16-bit address in the zero page
    la t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, 1)
    jal emit_op
    li t0, SLL(S0, V0, 8)
    jal emit_op
    la t0, apu_read8
    jal emit_jal
    li t0, ADDI(A0, A0, -1)
    jal emit_op
    li t0, OR(A0, S0, V0)
    jal emit_op

    // Emit code to load a value from an absolute address plus register Y
    jal load_reg_y
    li t0, ANDI(T8, T8, 0xFF)
    jal emit_op
    li t0, ADD(A0, A0, T8)
    jal emit_op
    beqz t8, idy_skip
    la t0, apu_read8
    jal emit_jal
idy_skip:
    li t0, ANDI(A0, A0, 0xFFFF)
    move ra, gp
    j emit_op

.align 5
apu_drb: // aaa.b
    // Get the 16-bit immediate value
    jal jit_read8
    move t7, v0
    jal jit_read8
    sll t0, v0, 8
    or t7, t7, t0

    // Get aaa as an address and b as a bitmask
    andi t2, t7, 0x1FFF
    li t0, 1
    srl t7, t7, 13
    sll t7, t0, t7

    // Emit code to load a bitmask and a value from an address
    la t0, apu_read8
    jal emit_jal
    li t0, ORI(A0, ZERO, 0)
    or t0, t0, t2
    jal emit_op
    li t0, ORI(A1, ZERO, 0)
    or t0, t0, t7
    move ra, gp
    j emit_op

.align 5
apu_dri: // aa,#nn
    // Get the 8-bit immediate value and address
    jal jit_read8
    move t7, v0
    jal jit_read8

    // Emit code to load a value
    li t0, ORI(V0, ZERO, 0)
    or t0, t0, t7
    jal emit_op

    // Emit code to form a zero page address
    jal load_flags
    li t0, SLL(A0, S1, 3)
    jal emit_op
    li t0, ANDI(A0, A0, 0x100)
    jal emit_op
    li t0, ORI(A0, A0, 0)
    or t0, t0, v0
    move ra, gp
    j emit_op

.align 5
apu_dr2: // aa,bb
    // Get the two 8-bit immediate addresses
    jal jit_read8
    move t7, v0
    jal jit_read8

    // Emit code to load a value from a zero page address
    jal load_flags
    li t0, SLL(S0, S1, 3)
    jal emit_op
    li t0, ANDI(S0, S0, 0x100)
    jal emit_op
    la t0, apu_read8
    jal emit_jal
    li t0, ORI(A0, S0, 0)
    or t0, t0, t7
    jal emit_op

    // Emit code to form another zero page address
    li t0, ORI(A0, S0, 0)
    or t0, t0, v0
    move ra, gp
    j emit_op

.align 5
apu_bxy: // (X),(Y)
    // Emit code to load a value from register Y as a zero page address
    jal load_reg_y
    jal load_flags
    li t0, SLL(S0, S1, 3)
    jal emit_op
    li t0, ANDI(S0, S0, 0x100)
    jal emit_op
    li t0, ANDI(T8, T8, 0xFF)
    jal emit_op
    la t0, apu_read8
    jal emit_jal
    li t0, OR(A0, S0, T8)
    jal emit_op

    // Emit code to form a zero page address with register X
    jal load_reg_x
    li t0, OR(A0, S0, T9)
    move ra, gp
    j emit_op
