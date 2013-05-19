BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump

BUILD_DIR=zpu_obj

MINSTARTUP_SRC = mincrt0.s
MINSTARTUP_OBJ = $(patsubst %.s,$(BUILD_DIR)/%.o,$(MINSTARTUP_SRC))

STARTUP_SRC = crt0.s
STARTUP_OBJ = $(patsubst %.s,$(BUILD_DIR)/%.o,$(STARTUP_SRC))

BOOT_PRJ = boot
BOOT_SRC = boot.c spi.c sdboot.c spi.h fat.c fat.h minisoc_hardware.c minisoc_hardware.h small_printf.c small_printf.h swap.c # spi.c
BOOT_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(BOOT_SRC))

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

CFLAGS  = -I. -c -Os $(ZPUOPTS) -DPRINTF_HEX_ONLY # -DDISABLE_PRINTF -DDISABLE_UART
AFLAGS  = 
LFLAGS  = -Wl,--relax -nostdlib -Os
CP_HEXFLAGS = -Oihex
CP_SRECFLAGS = -Osrec --gap-fill 0

ROMGEN = zpuromgen

# Libraries.
LIBS       =

# Our target.
all: $(BUILD_DIR) $(BOOT_PRJ).mif $(BOOT_PRJ).bin $(BOOT_PRJ).srec $(BOOT_PRJ).rpt \
		$(FBTEST_PRJ).bin $(FBTEST_PRJ).rpt
clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.elf *.map *.lst *.srec $(PRJ).mif $(PRJ).rom *~ */*.o $(ROMGEN) *.bin

$(ROMGEN): $(ROMGEN).c
	gcc  -o $@ $<

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
	srec_cat $< -o $@ -mif 32

%.rpt: %.elf
	$(DUMP) -x $< | grep _romend   #  End of Boot ROM
	$(DUMP) -x $< | grep __bss_start__   #  Start of BSS data in SDRAM
	$(DUMP) -x $< | grep __bss_end__   #  End of BSS data in SDRAM

# Link - this produces an ELF binary.

$(BOOT_PRJ).elf: $(MINSTARTUP_OBJ) $(BOOT_OBJ)
	$(LD) $(LFLAGS) -T boot.ld -o $@ $+ $(LIBS)

$(FBTEST_PRJ).elf: $(STARTUP_OBJ) $(FBTEST_OBJ)
	$(LD) $(LFLAGS) -T fbtest.ld -o $@ $+ $(LIBS)

%.rom: %.bin $(ROMGEN)
	./$(ROMGEN) $< >$@

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

