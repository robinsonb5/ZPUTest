BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump

BUILD_DIR=zpu_obj

MINSTARTUP_SRC = ../Common/mincrt0.s
MINSTARTUP_OBJ = $(patsubst ../Common/%.s,$(BUILD_DIR)/%.o,$(MINSTARTUP_SRC))

COMMON_SRC = ../Common/minisoc_hardware.c ../Common/small_printf.c
COMMON_OBJ = $(patsubst ../Common/%.c,$(BUILD_DIR)/%.o,$(COMMON_SRC))

BOOT_PRJ = boot
BOOT_SRC = boot.c spi.c spi.h fat.c fat.h minisoc_hardware.c swap.c # spi.c
BOOT_OBJ = $(COMMON_OBJ) $(patsubst %.c,$(BUILD_DIR)/%.o,$(BOOT_SRC))

FBTEST_PRJ = fbtest
FBTEST_SRC = fbtest.c minisoc_hardware.c minisoc_hardware.h small_printf.c small_printf.h
FBTEST_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(FBTEST_SRC))

LINKMAP  = boot.ld
LIBDIR   = 

# Commandline options for each tool.
#ZPUOPTS= -mno-poppcrel -mno-compare -mno-byteop -mno-shortop -mno-callpcrel \
#  -mno-call -mno-neqbranch -mno-pushspadd \
#  -mno-neg -mno-mod -mno-div

ZPUOPTS= -mno-poppcrel -mno-pushspadd -mno-callpcrel -mno-byteop -mno-shortop -mno-neg # No-neg requires bugfixed toolchain

CFLAGS  = -I. -I../Common/ -c -Os $(ZPUOPTS) -DPRINTF_HEX_ONLY -DDISABLE_PRINTF -DDISABLE_UART
AFLAGS  = 
LFLAGS  = -Wl,--relax -nostdlib -Os
CP_HEXFLAGS = -Oihex
CP_SRECFLAGS = -Osrec --gap-fill 0

# Libraries.
LIBS       =

# Our target.
all: $(BUILD_DIR) $(BOOT_PRJ).bin $(BOOT_PRJ).rpt

mif: $(BOOT_PRJ).mif

clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.elf *.map *.lst *.srec $(BOOT_PRJ).mif $(BOOT_PRJ).rom *~ */*.o *.bin

link:
	rm -f $(BOOT_PRJ).mif $(BOOT_PRJ).elf
	make

# Convert ELF binary to bin file.
%.bin: %.elf
	$(CP) -O binary $< $@

# Convert ELF binary to Intel HEX file.
%.hex: %.elf
	$(CP) $(CPFLAGS) $< $@

# Convert ELF binary to SREC file
%.srec: %.elf
	$(CP) $(CP_SRECFLAGS) $< $@

# Convert SREC to .mif file
%.mif: %.srec
	srec_cat $< -offset=-0x04000000 -o $@ -mif 32

%.rpt: %.elf
	$(DUMP) -x $< | grep _romend   #  End of Boot ROM
	$(DUMP) -x $< | grep __bss_start__   #  Start of BSS data in SDRAM
	$(DUMP) -x $< | grep __bss_end__   #  End of BSS data in SDRAM

# Link - this produces an ELF binary.

$(BOOT_PRJ).elf: $(MINSTARTUP_OBJ) $(BOOT_OBJ) $(COMMON_OBJ)
	$(LD) $(LFLAGS) -T boot.ld -o $@ $+ $(LIBS)

$(FBTEST_PRJ).elf: $(STARTUP_OBJ) $(FBTEST_OBJ)
	$(LD) $(LFLAGS) -T fbtest.ld -o $@ $+ $(LIBS)

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: ../Common/%.c
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) -o $@ $<

$(BUILD_DIR)/%.o: ../Common/%.s
	$(AS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

