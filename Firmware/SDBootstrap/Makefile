BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump

BUILD_DIR=zpu_obj

STARTUP_SRC = crt0.s
STARTUP_OBJ = $(patsubst %.s,$(BUILD_DIR)/%.o,$(STARTUP_SRC))

BOOT_PRJ = boot
BOOT_SRC = boot.c spi.c sdboot.c spi.h minisoc_hardware.c minisoc_hardware.h # spi.c
BOOT_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(BOOT_SRC))

LINKMAP  = 
LIBDIR   = 

# Commandline options for each tool.
ZPUOPTS= -mno-poppcrel -mno-compare -mno-byteop -mno-shortop -mno-callpcrel \
  -mno-call -mno-neqbranch -mno-pushspadd \
  -mno-neg -mno-mod -mno-div

ZPUOPTS2= -mno-poppcrel -mno-callpcrel -mno-call -mno-pushspadd -mno-neg

CFLAGS  = -I. -c -Os
AFLAGS  = 
LFLAGS  = -nostdlib -Os
CP_HEXFLAGS = -Oihex
CP_SRECFLAGS = -Osrec --gap-fill 0

ROMGEN = zpuromgen

# Libraries.
LIBS       =

# Our target.
all: $(BUILD_DIR) $(BOOT_PRJ).mif $(BOOT_PRJ).bin $(BOOT_PRJ).srec

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

# Link - this produces an ELF binary.

$(BOOT_PRJ).elf: $(STARTUP_OBJ) $(BOOT_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

%.rom: %.bin $(ROMGEN)
	./$(ROMGEN) $< >$@

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

