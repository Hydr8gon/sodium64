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
#define ROM_BUFFER 0xA0200000
#define TILE_CACHE_BG4 (ROM_BUFFER - 0x10000)
#define TILE_CACHE_BG3 (TILE_CACHE_BG4 - 0x10000)
#define TILE_CACHE_BG2 (TILE_CACHE_BG3 - 0x10000)
#define TILE_CACHE_BG1 (TILE_CACHE_BG2 - 0x10000)
#define TILE_CACHE_OBJ (TILE_CACHE_BG1 - 0x8000)
#define TILE_STATS_BG4 (TILE_CACHE_OBJ - 0x400)
#define TILE_STATS_BG3 (TILE_STATS_BG4 - 0x400)
#define TILE_STATS_BG2 (TILE_STATS_BG3 - 0x400)
#define TILE_STATS_BG1 (TILE_STATS_BG2 - 0x400)
#define TILE_STATS_OBJ (TILE_STATS_BG1 - 0x200)
#define SECTION_QUEUE2 (TILE_STATS_OBJ - 0x5000)
#define SECTION_QUEUE1 (SECTION_QUEUE2 - 0x5000)
#define VRAM_QUEUE2 (SECTION_QUEUE1 - 0x10000)
#define VRAM_QUEUE1 (VRAM_QUEUE2 - 0x10000)
#define DIRTY_QUEUE2 (VRAM_QUEUE1 - 0x400)
#define DIRTY_QUEUE1 (DIRTY_QUEUE2 - 0x400)
#define OAM_QUEUE2 (DIRTY_QUEUE1 - 0x220)
#define OAM_QUEUE1 (OAM_QUEUE2 - 0x220)
#define PALETTE_QUEUE2 (OAM_QUEUE1 - 0x800)
#define PALETTE_QUEUE1 (PALETTE_QUEUE2 - 0x800)
#define MODE7_TEXTURE (PALETTE_QUEUE1 - 0x1000)
#define FRAMEBUFFER3 (MODE7_TEXTURE - 0x20D00)
#define FRAMEBUFFER2 (FRAMEBUFFER3 - 0x20D00)
#define FRAMEBUFFER1 (FRAMEBUFFER2 - 0x20D00)

// RSP addresses of data in DMEM; used to avoid setting the upper address
#define TEXTURE 0x000
#define TILE_TABLE (TEXTURE + 0x40)
#define VRAM_TABLE (TILE_TABLE + 0x400)
#define OAM (VRAM_TABLE + 0x400)
#define SCRN_DATA (OAM + 0x220)
#define CHAR_DATA (SCRN_DATA + 0x80)
#define MODE7_BOUNDS (CHAR_DATA + 0x80)
#define CACHE_BASES (MODE7_BOUNDS + 0x10)
// Start of section values
#define OBJ_SIZE (CACHE_BASES + 0x10)
#define OBJCHARBASE (OBJ_SIZE + 0x4)
#define OAMADD (OBJCHARBASE + 0x2)
#define BGSCRNBASE (OAMADD + 0x2)
#define BGBASEOFSH (BGSCRNBASE + 0x8)
#define BGBASEOFSV (BGBASEOFSH + 0x8)
#define BGCHARBASE (BGBASEOFSV + 0x8)
#define BGHOFS (BGCHARBASE + 0x8)
#define BGVOFS (BGHOFS + 0x8)
#define M7HOFS (BGVOFS + 0x8)
#define M7VOFS (M7HOFS + 0x2)
#define M7A (M7VOFS + 0x2)
#define M7B (M7A + 0x2)
#define M7C (M7B + 0x2)
#define M7D (M7C + 0x2)
#define M7X (M7D + 0x2)
#define M7Y (M7X + 0x2)
#define FILLER (M7Y + 0x2)
#define FORCE_BLANK (FILLER + 0x2)
#define BG_MODE (FORCE_BLANK + 0x1)
#define SUB_MASK (BG_MODE + 0x1)
#define MAIN_MASK (SUB_MASK + 0x1)
#define M7_NOWRAP (MAIN_MASK + 0x1)
#define SPLIT_LINE (M7_NOWRAP + 0x1)
// Start of frame values
#define MASK_OFS (SPLIT_LINE + 0x1)
#define FILL_COLOR (MASK_OFS + 0x8)
#define FB_BORDER (FILL_COLOR + 0x8)
#define FRAME_END (FB_BORDER + 0x8)
#define PALETTE_PTR (FRAME_END + 0x8)
#define OAM_PTR (PALETTE_PTR + 0x8)
#define DIRTY_PTR (OAM_PTR + 0x8)
#define VRAM_PTR (DIRTY_PTR + 0x8)
#define SECTION_PTR (VRAM_PTR + 0x8)
#define FRAMEBUFFER (SECTION_PTR + 0x8)
// End of frame values
#define RDP_INIT (FRAMEBUFFER + 0x8)
#define RDP_MODE7 (RDP_INIT + 0x20)
#define RDP_FRAME (RDP_MODE7 + 0x18)
#define RDP_SECTION (RDP_FRAME + 0x18)
#define RDP_TILE (RDP_SECTION + 0x30)
#define TILE_JUMPS (RDP_TILE + 0x78)
#define TILE_PARAMS (TILE_JUMPS + 0xC)
#define LAYER_CHART (TILE_PARAMS + 0x40)
#define ALIGN_GAP (LAYER_CHART + 0x90)
#define VEC_DATA 0xF80

// Macro that converts an RSP DMEM address to a CPU address
#define DMEM(addr) (0xA4000000 + (addr))

// Macro that converts a cached address to uncached
#define UNCACHED(addr) ((addr) + 0x20000000)
