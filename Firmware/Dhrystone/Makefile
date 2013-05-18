BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump

BUILD_DIR=zpu_obj

DHRY_PRJ = dhry
DHRY_SRC_C = dhry_1.c dhry_2.c minisoc_hardware.c minisoc_hardware.h small_printf.c small_printf.h
DHRY_SRC_S = crt0.s
DHRY_OBJ_C = $(patsubst %.c,$(BUILD_DIR)/%.o,$(DHRY_SRC_C))
DHRY_OBJ_S = $(patsubst %.s,$(BUILD_DIR)/%.o,$(DHRY_SRC_S))
DHRY_OBJ = $(DHRY_OBJ_C)

LINKMAP  = dhry.ld
LIBDIR   = 

# Commandline options for each tool.
#ZPUOPTS= -mno-poppcrel -mno-compare -mno-byteop -mno-shortop -mno-callpcrel \
#  -mno-call -mno-neqbranch -mno-pushspadd \
#  -mno-neg -mno-mod -mno-div

ZPUOPTS= -mno-poppcrel -mno-pushspadd -mno-callpcrel -mno-mult -mno-div # -mno-neg

CFLAGS  = -I. -c -O6 $(ZPUOPTS) -DPRINTF_HEX_ONLY # -DDISABLE_PRINTF -DDISABLE_UART
AFLAGS  = 
LFLAGS  = -mboard=abel -O6 -Wl,--relax
CP_HEXFLAGS = -Oihex
CP_SRECFLAGS = -Osrec --gap-fill 0

ROMGEN = zpuromgen

# Libraries.
LIBS       =

# Our target.
all: $(BUILD_DIR) $(DHRY_PRJ).mif $(DHRY_PRJ).bin $(DHRY_PRJ).srec $(DHRY_PRJ).rpt

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
#	$(DUMP) -x $< | grep _romend   #  End of Boot ROM
#	$(DUMP) -x $< | grep __bss_start__   #  Start of BSS data in SDRAM
#	$(DUMP) -x $< | grep __bss_end__   #  End of BSS data in SDRAM
	echo done

# Link - this produces an ELF binary.

$(DHRY_PRJ).elf: $(DHRY_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

%.rom: %.bin $(ROMGEN)
	./$(ROMGEN) $< >$@

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

