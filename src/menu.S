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

#include "defines.h"

.globl layer_set
.globl precision_set
.globl skipped_set
.globl audio_set

.globl update_menu

.data

.align 4
counter_set: .byte 0 << 2
layer_set: .byte 0 << 2
precision_set: .byte 2 << 2
skipped_set: .byte 0 << 2
audio_set: .byte 1 << 2
left_str: .string "<"
right_str: .string ">"

.align 4
title_str: .string "SODIUM64 SETTINGS"
counter_str: .string "FPS COUNTER"
layer_str: .string "SUB LAYER ORDER"
precision_str: .string "FRAME PRECISION"
skipped_str: .string "FRAMES SKIPPED"
audio_str: .string "AUDIO OUTPUT"

.align 4
on_str: .string "     ON "
off_str: .string "    OFF "
back_str: .string "   BACK "
front_str: .string "  FRONT "
lower_str: .string "  LOWER "
low_str: .string "    LOW "
medium_str: .string " MEDIUM "
high_str: .string "   HIGH "
higher_str: .string " HIGHER "
max_str: .string "    MAX "
zero_str: .string "      0 "
one_str: .string "      1 "
two_str: .string "      2 "
three_str: .string "      3 "

.align 4
menu_items: .word counter_str, layer_str, precision_str, skipped_str, audio_str, 0
menu_opts: .word toggle_opts, layer_opts, precision_opts, skipped_opts, toggle_opts
menu_sets: .word counter_set, layer_set, precision_set, skipped_set, audio_set

.align 4
toggle_opts: .word off_str, on_str, 0
layer_opts: .word back_str, front_str, 0
precision_opts: .word lower_str, low_str, medium_str, high_str, higher_str, max_str, 0
skipped_opts: .word zero_str, one_str, two_str, three_str, 0

.text
.set noreorder

.macro DRAW line
    // Copy a line of character pixels to the framebuffer
    ld t0, \line * 16 + 0(t2)
    ld t1, \line * 16 + 8(t2)
    sd t0, \line * 560 + 0(a1)
    sd t1, \line * 560 + 8(a1)
.endm

.align 5
draw_char: // a0: char, a1: top-left offset
    // Look up a character sprite if it's within bounds
    la t2, char_sp
    addi t0, a0, -0x20
    bgtu t0, 0x40, unk_char
    sll t0, t0, 2
    lw t2, char_lookup(t0)

unk_char:
    // Copy the sprite to the framebuffer
    DRAW 0
    DRAW 1
    DRAW 2
    DRAW 3
    DRAW 4
    DRAW 5
    DRAW 6
    DRAW 7
    jr ra
    nop

.align 5
draw_value: // a0: value, a1: top-right offset
    // Isolate the lowest base-10 digit and draw its character
    li t1, 10
    div a0, t1
    addi a1, a1, -16
    move t9, ra
    mfhi t2
    jal draw_char
    addi a0, t2, 0x30

    // Move to the next digit until they're all drawn
    mflo a0
    bnez a0, draw_value
    move ra, t9
    jr ra
    nop

.align 5
draw_string: // a0: string, a1: top-left offset
    // Initialize values for drawing a string
    move t9, ra
    move t8, a0
    addi a1, a1, -16
    la ra, string_loop

string_loop:
    // Draw each character in the string until terminated
    lbu a0, (t8)
    beqz a0, end_string
    addi t8, t8, 1
    j draw_char
    addi a1, a1, 16
end_string:
    jr t9
    nop

.align 5
update_menu: // a0: framebuffer
    // Open the settings menu if start is pressed
    jal get_pressed
    li v1, 0 // Index
    andi t0, v0, 0x10 // Start
    bnez t0, draw_menu
    move t7, a0

    // Draw the FPS counter if running and enabled
    lbu t0, counter_set
    beqz t0, menu_return
    nop
    lbu a0, fps_display
    jal draw_value
    addi a1, t7, 23 * 560 + 44 * 2
    b menu_return
    nop

draw_menu:
    // Wait until there are no extra frames queued
    lbu t0, frame_count
    bnez t0, draw_menu
    nop
    lw t7, framebuffer

    // Clear the current framebuffer
    move t0, t7
    add t1, t0, FRAMEBUFFER2 - FRAMEBUFFER1
clear_buffer:
    sd zero, (t0)
    bne t0, t1, clear_buffer
    addi t0, t0, 8

    // Draw the title and initialize values for menu items
    la a0, title_str
    jal draw_string
    addi a1, t7, 47 * 560 + 72 * 2
    addi t7, t7, 47 * 560 + 48 * 2
    li t3, 0

menu_loop:
    // Draw a menu item on the left
    lw a0, menu_items(t3)
    beqz a0, menu_idle
    addi t7, t7, 24 * 560
    jal draw_string
    move a1, t7

    // Draw the item's setting on the right
    lw t0, menu_sets(t3)
    lw t1, menu_opts(t3)
    lbu t0, (t0)
    add t1, t1, t0
    lw a0, (t1)
    jal draw_string
    addi a1, t7, 128 * 2

    // Move to the next item if not selected
    bne t3, v1, menu_loop
    addi t3, t3, 4

    // Draw selectors around the current item
    la a0, left_str
    jal draw_string
    addi a1, t7, 128 * 2
    la a0, right_str
    jal draw_string
    addi a1, t7, 184 * 2
    b menu_loop
    nop

menu_idle:
    // Close the menu if start is pressed
    jal get_pressed
    nop
    andi t0, v0, 0x10 // Start
    bnez t0, menu_return

    // Move to an upper item if up is pressed
    andi t0, v0, 0x8 // Up
    beqz t0, check_down
    sltu t0, zero, v1
    sll t0, t0, 2
    b draw_menu
    sub v1, v1, t0

check_down:
    // Move to a lower item if down is pressed
    andi t0, v0, 0x4 // Down
    beqz t0, check_left
    nop
    lw t0, menu_items + 4(v1)
    beqz t0, menu_idle
    nop
    b draw_menu
    addi v1, v1, 4

check_left:
    // Decrease a setting value if left is pressed
    andi t0, v0, 0x2 // Left
    beqz t0, check_right
    nop
    lw t0, menu_sets(v1)
    lbu t1, (t0)
    sltu t2, zero, t1
    sll t2, t2, 2
    sub t1, t1, t2
    b draw_menu
    sb t1, (t0)

check_right:
    // Increase a setting value if left is pressed
    andi t0, v0, 0x1 // Right
    beqz t0, menu_idle
    nop
    lw t0, menu_sets(v1)
    lbu t1, (t0)
    lw t2, menu_opts(v1)
    add t2, t2, t1
    lw t2, 4(t2)
    beqz t2, menu_idle
    nop
    addi t1, t1, 4
    b draw_menu
    sb t1, (t0)
