# Based on n64.mk from libdragon

PROJ_NAME := sodium64
BUILD_DIR := build
SRC_DIRS := src

SFILES := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.S))
HFILES := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.h))
OFILES := $(patsubst %.S,$(BUILD_DIR)/%.o,$(SFILES))

N64_ROM_TITLE = "$(PROJ_NAME)"
N64_ROM_SAVETYPE = sram256k

# Override this to use a toolchain installed separately from libdragon
N64_GCCPREFIX ?= $(N64_INST)
N64_ROOTDIR = $(N64_INST)
N64_BINDIR = $(N64_ROOTDIR)/bin
N64_INCLUDEDIR = $(N64_ROOTDIR)/mips64-elf/include
N64_LIBDIR = $(N64_ROOTDIR)/mips64-elf/lib
N64_GCCPREFIX_TRIPLET = $(N64_GCCPREFIX)/bin/mips64-elf-

COMMA := ,

N64_CC = $(N64_GCCPREFIX_TRIPLET)gcc
N64_CXX = $(N64_GCCPREFIX_TRIPLET)g++
N64_AS = $(N64_GCCPREFIX_TRIPLET)as
N64_AR = $(N64_GCCPREFIX_TRIPLET)ar
N64_LD = $(N64_GCCPREFIX_TRIPLET)ld
N64_OBJCOPY = $(N64_GCCPREFIX_TRIPLET)objcopy
N64_OBJDUMP = $(N64_GCCPREFIX_TRIPLET)objdump
N64_SIZE = $(N64_GCCPREFIX_TRIPLET)size
N64_NM = $(N64_GCCPREFIX_TRIPLET)nm
N64_STRIP = $(N64_GCCPREFIX_TRIPLET)strip

N64_CHKSUM = $(N64_BINDIR)/chksum64
N64_ED64ROMCONFIG = $(N64_BINDIR)/ed64romconfig
N64_MKDFS = $(N64_BINDIR)/mkdfs
N64_TOOL = $(N64_BINDIR)/n64tool
N64_SYM = $(N64_BINDIR)/n64sym
N64_ELFCOMPRESS = $(N64_BINDIR)/n64elfcompress
N64_AUDIOCONV = $(N64_BINDIR)/audioconv64
N64_MKSPRITE = $(N64_BINDIR)/mksprite

N64_ASFLAGS = -mtune=vr4300 -march=vr4300 -Wa,--fatal-warnings
N64_RSPASFLAGS = -march=mips1 -mabi=32 -Wa,--fatal-warnings
N64_LDFLAGS = -L$(N64_LIBDIR) -Tn64.ld --gc-sections
N64_TOOLFLAGS = --title $(N64_ROM_TITLE)
N64_ED64ROMCONFIGFLAGS = --savetype $(N64_ROM_SAVETYPE) --regionfree

COMMA := ,

# Change the dependency chain of .z64 ROMs to use the N64 toolchain
%.z64: CC=$(N64_CC)
%.z64: CXX=$(N64_CXX)
%.z64: AS=$(N64_AS)
%.z64: LD=$(N64_LD)
%.z64: ASFLAGS+=$(N64_ASFLAGS)
%.z64: RSPASFLAGS+=$(N64_RSPASFLAGS)
%.z64: LDFLAGS+=$(N64_LDFLAGS)
%.z64: $(BUILD_DIR)/%.elf
	@echo "    [Z64] $@"
	$(N64_SYM) $< $<.sym
	cp $< $<.stripped
	$(N64_STRIP) -s $<.stripped
	$(N64_ELFCOMPRESS) -o $(dir $<) -c 1 $<.stripped
	@rm -f $@
	DFS_FILE="$(filter %.dfs, $^)"; \
	if [ -z "$$DFS_FILE" ]; then \
		$(N64_TOOL) $(N64_TOOLFLAGS) --toc --output $@ --align 256 $<.stripped --align 8 $<.sym; \
	else \
		$(N64_TOOL) $(N64_TOOLFLAGS) --toc --output $@ --align 256 $<.stripped --align 8 $<.sym --align 16 "$$DFS_FILE"; \
	fi
	if [ ! -z "$(strip $(N64_ED64ROMCONFIGFLAGS))" ]; then \
		$(N64_ED64ROMCONFIG) $(N64_ED64ROMCONFIGFLAGS) $@; \
	fi

# Assembly rule. We use .S for both RSP and MIPS assembly code, and we differentiate
# using the prefix of the filename: if it starts with "rsp", it is RSP ucode, otherwise
# it's a standard MIPS assembly file.
$(BUILD_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	set -e; \
	FILENAME="$(notdir $(basename $@))"; \
	if case "$$FILENAME" in "rsp"*) true;; *) false;; esac; then \
		SYMPREFIX="$(subst .,_,$(subst /,_,$(basename $@)))"; \
		TEXTSECTION="$(basename $@).text"; \
		DATASECTION="$(basename $@).data"; \
		BINARY="$(basename $@).elf"; \
		echo "    [RSP] $<"; \
		$(N64_CC) $(RSPASFLAGS) -L$(N64_LIBDIR) -nostartfiles -Wl,-Trsp.ld -Wl,--gc-sections  -Wl,-Map=$(BUILD_DIR)/$(notdir $(basename $@)).map -o $@ $<; \
		mv "$@" $$BINARY; \
		$(N64_OBJCOPY) -O binary -j .text $$BINARY $$TEXTSECTION.bin; \
		$(N64_OBJCOPY) -O binary -j .data $$BINARY $$DATASECTION.bin; \
		$(N64_OBJCOPY) -I binary -O elf32-bigmips -B mips4300 \
				--redefine-sym _binary_$${SYMPREFIX}_text_bin_start=$${FILENAME}_text_start \
				--redefine-sym _binary_$${SYMPREFIX}_text_bin_end=$${FILENAME}_text_end \
				--redefine-sym _binary_$${SYMPREFIX}_text_bin_size=$${FILENAME}_text_size \
				--set-section-alignment .data=8 \
				--rename-section .text=.data $$TEXTSECTION.bin $$TEXTSECTION.o; \
		$(N64_OBJCOPY) -I binary -O elf32-bigmips -B mips4300 \
				--redefine-sym _binary_$${SYMPREFIX}_data_bin_start=$${FILENAME}_data_start \
				--redefine-sym _binary_$${SYMPREFIX}_data_bin_end=$${FILENAME}_data_end \
				--redefine-sym _binary_$${SYMPREFIX}_data_bin_size=$${FILENAME}_data_size \
				--set-section-alignment .data=8 \
				--rename-section .text=.data $$DATASECTION.bin $$DATASECTION.o; \
		$(N64_SIZE) -G $$BINARY; \
		$(N64_LD) -relocatable $$TEXTSECTION.o $$DATASECTION.o -o $@; \
		rm $$TEXTSECTION.bin $$DATASECTION.bin $$TEXTSECTION.o $$DATASECTION.o; \
	else \
		echo "    [AS] $<"; \
		$(CC) -c $(ASFLAGS) -o $@ $<; \
	fi

%.elf: $(N64_LIBDIR)/n64.ld
	@mkdir -p $(dir $@)
	@echo "    [LD] $@"
	$(CXX) -o $@ $(filter-out $(N64_LIBDIR)/n64.ld,$^) -lc $(patsubst %,-Wl$(COMMA)%,$(LDFLAGS)) -Wl,-Map=$(BUILD_DIR)/$(notdir $(basename $@)).map
	$(N64_SIZE) -G $@

.SILENT:

all: $(PROJ_NAME).z64

$(BUILD_DIR)/$(PROJ_NAME).elf: $(OFILES)

$(OFILES): $(HFILES)

clean:
	rm -rf $(BUILD_DIR) $(PROJ_NAME).z64

.PHONY: all clean
