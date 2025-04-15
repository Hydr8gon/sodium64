/*
    Copyright 2021-2025 Hydr8gon

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

#include "macros.h"

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
.set noreorder

.align 5
apu_imm: // #nn
    // Get the 8-bit immediate value
    jal jit_read8
    nop

    // Emit code to load a value
    li t0, ORI(V0, ZERO, 0)
    or t0, t0, v0
    j emit_op
    move ra, gp

.align 5
apu_dira: // aa
    // Choose whether to emit a memory read or just provide an address
    b apu_dir
    li t8, 0
apu_dirr:
    li t8, 1

apu_dir:
    // Get the 8-bit immediate address
    jal jit_read8
    nop

    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to load a value from a zero page address
    EMIT_OP SLL(A0, S1, 3)
    EMIT_OP ANDI(A0, A0, 0x100)
    beqz t8, dir_skip
    nop
    la t0, apu_read8
    jal emit_jal
    nop
dir_skip:
    li t0, ORI(A0, A0, 0)
    or t0, t0, v0
    j emit_op
    move ra, gp

.align 5
apu_drxa: // aa+X
    // Choose whether to emit a memory read or just provide an address
    b apu_drx
    li t8, 0
apu_drxr:
    li t8, 1

apu_drx:
    // Get the 8-bit immediate address
    jal jit_read8
    nop

    // Update the JIT register state
    jal load_reg_x
    nop
    jal load_flags
    nop

    // Emit code to load a value from a zero page address plus register X
    EMIT_OP SLL(A0, S1, 3)
    EMIT_OP ANDI(A0, A0, 0x100)
    li t0, ADDI(T0, T9, 0)
    jal emit_op
    or t0, t0, v0
    EMIT_OP ANDI(T0, T0, 0xFF)
    beqz t8, drx_skip
    nop
    la t0, apu_read8
    jal emit_jal
    nop
drx_skip:
    li t0, OR(A0, A0, T0)
    j emit_op
    move ra, gp

.align 5
apu_drya: // aa+Y
    // Choose whether to emit a memory read or just provide an address
    b apu_dry
    li t8, 0
apu_dryr:
    li t8, 1

apu_dry:
    // Get the 8-bit immediate address
    jal jit_read8
    nop

    // Update the JIT register state
    jal load_reg_y
    nop
    jal load_flags
    nop

    // Emit code to load a value from a zero page address plus register Y
    EMIT_OP SLL(A0, S1, 3)
    EMIT_OP ANDI(A0, A0, 0x100)
    li t0, ADDI(T0, T8, 0)
    jal emit_op
    or t0, t0, v0
    EMIT_OP ANDI(T0, T0, 0xFF)
    beqz t8, dry_skip
    nop
    la t0, apu_read8
    jal emit_jal
    nop
dry_skip:
    li t0, OR(A0, A0, T0)
    j emit_op
    move ra, gp

.align 5
apu_brxa: // (X)
    // Choose whether to emit a memory read or just provide an address
    b apu_brx
    li t8, 0
apu_brxr:
    li t8, 1

apu_brx:
    // Update the JIT register state
    jal load_reg_x
    nop
    jal load_flags
    nop

    // Emit code to load a value from register X as a zero page address
    EMIT_OP SLL(A0, S1, 3)
    EMIT_OP ANDI(A0, A0, 0x100)
    EMIT_OP ANDI(T9, T9, 0xFF)
    beqz t8, brx_skip
    nop
    la t0, apu_read8
    jal emit_jal
    nop
brx_skip:
    li t0, OR(A0, A0, T9)
    j emit_op
    move ra, gp

.align 5
apu_bxpa: // (X)+
    // Choose whether to emit a memory read or just provide an address
    b apu_bxp
    li t8, 0
apu_bxpr:
    li t8, 1

apu_bxp:
    // Update the JIT register state
    jal load_reg_x
    ori s1, s1, FLAG_SX
    jal load_flags
    nop

    // Emit code to load a value from register X as a zero page address with post-increment
    EMIT_OP SLL(A0, S1, 3)
    EMIT_OP ANDI(A0, A0, 0x100)
    EMIT_OP ANDI(T9, T9, 0xFF)
    EMIT_OP OR(A0, A0, T9)
    beqz t8, bxp_skip
    nop
    la t0, apu_read8
    jal emit_jal
    nop
bxp_skip:
    li t0, ADDI(T9, T9, 1)
    j emit_op
    move ra, gp

.align 5
apu_absa: // aaaa
    // Get the 16-bit immediate address
    jal jit_read8
    nop
    jal jit_read8
    move t7, v0
    sll t0, v0, 8
    or t7, t7, t0

    // End the JIT block early if a self-modifying write is detected
    sgt t0, t7, a0
    addi t2, t7, -2
    slt t1, t2, t9
    and t0, t0, t1
    beqz t0, abs_skip
    nop
    move t9, t2

abs_skip:
    // Emit code to load an absolute address
    li t0, ORI(A0, ZERO, 0)
    or t0, t0, t7
    j emit_op
    move ra, gp

.align 5
apu_absr: // aaaa
    // Get the 16-bit immediate address
    jal jit_read8
    nop
    jal jit_read8
    move t7, v0
    sll t0, v0, 8
    or t7, t7, t0

    // Emit code to load a value from an absolute address
    la t0, apu_read8
    jal emit_jal
    nop
    li t0, ORI(A0, ZERO, 0)
    or t0, t0, t7
    j emit_op
    move ra, gp

.align 5
apu_abxa: // aaaa+X
    // Choose whether to emit a memory read or just provide an address
    b apu_abx
    li t8, 0
apu_abxr:
    li t8, 1

apu_abx:
    // Get the 16-bit immediate address
    jal jit_read8
    nop
    jal jit_read8
    move t7, v0
    sll t0, v0, 8

    // Update the JIT register state
    jal load_reg_x
    or t7, t7, t0

    // Emit code to load a value from an absolute address plus register X
    EMIT_OP ANDI(T9, T9, 0xFF)
    li t0, ADDI(A0, T9, 0)
    jal emit_op
    or t0, t0, t7
    beqz t8, abx_skip
    nop
    la t0, apu_read8
    jal emit_jal
    nop
abx_skip:
    li t0, ANDI(A0, A0, 0xFFFF)
    j emit_op
    move ra, gp

.align 5
apu_abya: // aaaa+Y
    // Choose whether to emit a memory read or just provide an address
    b apu_aby
    li t8, 0
apu_abyr:
    li t8, 1

apu_aby:
    // Get the 16-bit immediate address
    jal jit_read8
    nop
    jal jit_read8
    move t7, v0
    sll t0, v0, 8

    // Update the JIT register state
    jal load_reg_y
    or t7, t7, t0

    // Emit code to load a value from an absolute address plus register Y
    EMIT_OP ANDI(T8, T8, 0xFF)
    li t0, ADDI(A0, T8, 0)
    jal emit_op
    or t0, t0, t7
    beqz t8, aby_skip
    nop
    la t0, apu_read8
    jal emit_jal
    nop
aby_skip:
    li t0, ANDI(A0, A0, 0xFFFF)
    j emit_op
    move ra, gp

.align 5
apu_idxa: // [aa+X]
    // Choose whether to emit a memory read or just provide an address
    b apu_idx
    li t8, 0
apu_idxr:
    li t8, 1

apu_idx:
    // Get the 8-bit immediate address
    jal jit_read8
    nop

    // Update the JIT register state
    jal load_reg_x
    nop
    jal load_flags
    nop

    // Emit code to form a zero page address plus register X
    EMIT_OP SLL(A0, S1, 3)
    EMIT_OP ANDI(A0, A0, 0x100)
    li t0, ADDI(T0, T9, 0)
    jal emit_op
    or t0, t0, v0
    EMIT_OP ANDI(T0, T0, 0xFF)
    EMIT_OP OR(A0, A0, T0)

    // Emit code to load a value from a 16-bit address in the zero page
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)
    EMIT_OP SLL(S0, V0, 8)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, -1)
    beqz t8, idx_skip
    nop
    la t0, apu_read8
    jal emit_jal
    nop
idx_skip:
    li t0, OR(A0, S0, V0)
    j emit_op
    move ra, gp

.align 5
apu_idya: // [aa]+Y
    // Choose whether to emit a memory read or just provide an address
    b apu_idy
    li t8, 0
apu_idyr:
    li t8, 1

apu_idy:
    // Get the 8-bit immediate address
    jal jit_read8
    nop

    // Update the JIT register state
    jal load_reg_y
    nop
    jal load_flags
    nop

    // Emit code to form a zero page address
    EMIT_OP SLL(A0, S1, 3)
    EMIT_OP ANDI(A0, A0, 0x100)
    li t0, ORI(A0, A0, 0)
    jal emit_op
    or t0, t0, v0

    // Emit code to load a 16-bit address in the zero page
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, 1)
    EMIT_OP SLL(S0, V0, 8)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP ADDI(A0, A0, -1)
    EMIT_OP OR(A0, S0, V0)

    // Emit code to load a value from an absolute address plus register Y
    EMIT_OP ANDI(T8, T8, 0xFF)
    EMIT_OP ADD(A0, A0, T8)
    beqz t8, idy_skip
    nop
    la t0, apu_read8
    jal emit_jal
    nop
idy_skip:
    li t0, ANDI(A0, A0, 0xFFFF)
    j emit_op
    move ra, gp

.align 5
apu_drb: // aaa.b
    // Get the 16-bit immediate value
    jal jit_read8
    nop
    jal jit_read8
    move t7, v0
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
    nop
    li t0, ORI(A0, ZERO, 0)
    jal emit_op
    or t0, t0, t2
    li t0, ORI(A1, ZERO, 0)
    or t0, t0, t7
    j emit_op
    move ra, gp

.align 5
apu_dri: // aa,#nn
    // Get the 8-bit immediate value and address
    jal jit_read8
    nop
    jal jit_read8
    move t7, v0

    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to load a value
    li t0, ORI(V0, ZERO, 0)
    jal emit_op
    or t0, t0, t7

    // Emit code to form a zero page address
    EMIT_OP SLL(A0, S1, 3)
    EMIT_OP ANDI(A0, A0, 0x100)
    li t0, ORI(A0, A0, 0)
    or t0, t0, v0
    j emit_op
    move ra, gp

.align 5
apu_dr2: // aa,bb
    // Get the two 8-bit immediate addresses
    jal jit_read8
    nop
    jal jit_read8
    move t7, v0

    // Update the JIT register state
    jal load_flags
    nop

    // Emit code to load a value from a zero page address
    EMIT_OP SLL(S0, S1, 3)
    EMIT_OP ANDI(S0, S0, 0x100)
    la t0, apu_read8
    jal emit_jal
    nop
    li t0, ORI(A0, S0, 0)
    jal emit_op
    or t0, t0, t7

    // Emit code to form another zero page address
    li t0, ORI(A0, S0, 0)
    or t0, t0, v0
    j emit_op
    move ra, gp

.align 5
apu_bxy: // (X),(Y)
    // Update the JIT register state
    jal load_reg_x
    nop
    jal load_reg_y
    nop
    jal load_flags
    nop

    // Emit code to load a value from register Y as a zero page address
    EMIT_OP SLL(S0, S1, 3)
    EMIT_OP ANDI(S0, S0, 0x100)
    EMIT_OP ANDI(T8, T8, 0xFF)
    la t0, apu_read8
    jal emit_jal
    nop
    EMIT_OP OR(A0, S0, T8)

    // Emit code to form a zero page address with register X
    li t0, OR(A0, S0, T9)
    j emit_op
    move ra, gp
