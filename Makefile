TOOLPREFIX ?= riscv64-unknown-elf-
AS       := $(TOOLPREFIX)as
OBJCOPY  := $(TOOLPREFIX)objcopy

TB_DIR      := tb/hex
ASM_SRCS    := $(wildcard $(TB_DIR)/*.s)
HEX_TARGETS := $(ASM_SRCS:.s=.txt)

.PHONY: all asm clean FORCE nvimdiff

all: asm

asm: $(HEX_TARGETS)

FORCE:

$(TB_DIR)/%.o: $(TB_DIR)/%.s
	$(AS) -march=rv32i -mabi=ilp32 -o $@ $<

$(TB_DIR)/%.bin: $(TB_DIR)/%.o
	$(OBJCOPY) -O binary $< $@

$(TB_DIR)/%.txt: $(TB_DIR)/%.bin FORCE
	hexdump -v -e '1/4 "%08x\n"' $< > $@

clean:
	rm -f $(TB_DIR)/*.o $(TB_DIR)/*.bin $(TB_DIR)/*.txt

nvimdiff:
	./bin/git-nvim-diff
