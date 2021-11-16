PROJ_NAME := sodium64
BUILD_DIR := build
SRC_DIRS  := src

SFILES := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.S))
HFILES := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.h))
OFILES := $(patsubst %.S,$(BUILD_DIR)/%.o,$(SFILES))

include $(N64_INST)/include/n64.mk

all: $(PROJ_NAME).z64

$(PROJ_NAME).z64: N64_ROM_TITLE = "$(PROJ_NAME)"
$(PROJ_NAME).z64: N64_ROM_SAVETYPE = sram256k

$(BUILD_DIR)/$(PROJ_NAME).elf: $(OFILES)

$(OFILES): $(HFILES)

clean:
	rm -rf $(BUILD_DIR) $(PROJ_NAME).z64

-include $(wildcard $(BUILD_DIR)/*.d)

.PHONY: all clean
