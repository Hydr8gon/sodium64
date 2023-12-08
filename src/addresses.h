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

// Addresses of data in RDRAM that are shared between CPU and RSP
#define FRAMEBUFFER1 0xA0127AC0
#define FRAMEBUFFER2 0xA01487C0
#define FRAMEBUFFER3 0xA01694C0
#define MODE7_TEXTURE 0xA018A1C0
#define PALETTE_QUEUE1 0xA018B1C0
#define PALETTE_QUEUE2 0xA018B9C0
#define OAM_QUEUE1 0xA018C1C0
#define OAM_QUEUE2 0xA018C3E0
#define DIRTY_QUEUE1 0xA018C600
#define DIRTY_QUEUE2 0xA018CA00
#define VRAM_QUEUE1 0xA018CE00
#define VRAM_QUEUE2 0xA019CE00
#define SECTION_QUEUE1 0xA01ACE00
#define SECTION_QUEUE2 0xA01B1E00
#define TILE_STATS_OBJ 0xA01B6E00
#define TILE_STATS_BG1 0xA01B7000
#define TILE_STATS_BG2 0xA01B7400
#define TILE_STATS_BG3 0xA01B7800
#define TILE_STATS_BG4 0xA01B7C00
#define TILE_CACHE_OBJ 0xA01B8000
#define TILE_CACHE_BG1 0xA01C0000
#define TILE_CACHE_BG2 0xA01D0000
#define TILE_CACHE_BG3 0xA01E0000
#define TILE_CACHE_BG4 0xA01F0000

// Addresses of RSP data in DMEM; used to avoid setting the upper address
#define TEXTURE 0x000
#define TILE_TABLE 0x040
#define VRAM_TABLE 0x440
#define OAM 0x840
#define SCRN_DATA 0xA60
#define CHAR_DATA 0xAE0
#define VEC_DATA 0xB60
#define RDP_INIT 0xBE0
#define RDP_MODE7 0xC00
#define RDP_FRAME 0xC18
#define RDP_SECTION 0xC30
#define RDP_TILE 0xC60
#define LAYER_CHART 0xCD8
#define TILE_PARAMS 0xD68
#define TILE_JUMPS 0xDA8
#define MODE7_BOUNDS 0xDB4
#define CACHE_BASES 0xDC4
#define MASK_OFS 0xDD0
#define FILL_COLOR 0xDD8
#define FB_BORDER 0xDE0
#define FRAME_END 0xDE8
#define PALETTE_PTR 0xDF0
#define OAM_PTR 0xDF8
#define DIRTY_PTR 0xE00
#define VRAM_PTR 0xE08
#define SECTION_PTR 0xE10
#define FRAMEBUFFER 0xE18
#define OBJ_SIZE 0xFB0
#define OBJCHARBASE 0xFB4
#define OAMADD 0xFB6
#define BGSCRNBASE 0xFB8
#define BGBASEOFSH 0xFC0
#define BGBASEOFSV 0xFC8
#define BGCHARBASE 0xFD0
#define BGHOFS 0xFD8
#define BGVOFS 0xFE0
#define M7HOFS 0xFE8
#define M7VOFS 0xFEA
#define M7A 0xFEC
#define M7B 0xFEE
#define M7C 0xFF0
#define M7D 0xFF2
#define M7X 0xFF4
#define M7Y 0xFF6
#define FILLER 0xFF8
#define FORCE_BLANK 0xFFA
#define BG_MODE 0xFFB
#define SUB_MASK 0xFFC
#define MAIN_MASK 0xFFD
#define M7_NOWRAP 0xFFE
#define SPLIT_LINE 0xFFF

// Macro that converts an RSP DMEM address to a CPU address
#define DMEM(addr) (0xA4000000 + (addr))
