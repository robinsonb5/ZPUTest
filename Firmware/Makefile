BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump

BUILD_DIR=zpu_obj

CT_PRJ = countertest
CT_SRC = countertest.c # spi.c
CT_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(CT_SRC))

FB_PRJ = fbtest
FB_SRC = fbtest.c textbuffer.c minisoc_hardware.c # spi.c
FB_ASM = spritedata.s
FB_C_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(FB_SRC))
FB_ASM_OBJ = $(patsubst %.s,$(BUILD_DIR)/%.o,$(FB_ASM))
FB_OBJ = $(FB_C_OBJ) $(FB_ASM_OBJ)

VA_PRJ = vatest
VA_SRC = vatest.c # spi.c
VA_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(VA_SRC))

LINKMAP  = 
LIBDIR   = 

# Commandline options for each tool.
ZPUOPTS= -mno-poppcrel -mno-compare -mno-byteop -mno-shortop -mno-callpcrel \
  -mno-call -mno-neqbranch -mno-pushspadd \
  -mno-neg -mno-mod -mno-div

ZPUOPTS2= -mno-poppcrel -mno-callpcrel -mno-call -mno-pushspadd -mno-neg

CFLAGS  = -I. -c -Os
AFLAGS  = 
LFLAGS  = -Os
CP_HEXFLAGS = -Oihex
CP_SRECFLAGS = -Osrec --gap-fill 0

ROMGEN = zpuromgen

# Libraries.
LIBS       =

# Our target.
all: $(BUILD_DIR) $(CT_PRJ).mif $(FB_PRJ).mif $(VA_PRJ).mif

clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.elf *.map *.lst *.srec $(PRJ).mif $(PRJ).rom *~ */*.o $(ROMGEN) *.bin

$(ROMGEN): $(ROMGEN).c
	gcc  -o $@ $<

# Convert ELF binary to bin file.
$(PRJ).bin: $(PRJ).elf
	$(CP) -O binary $< $@

# Convert ELF binary to Intel HEX file.
$(PRJ).hex: $(PRJ).elf
	$(CP) $(CPFLAGS) $< $@

# Convert ELF binary to SREC file
%.srec: %.elf
	$(CP) $(CP_SRECFLAGS) $< $@

# Convert SREC to .mif file
%.mif: %.srec
	srec_cat $< -o $@ -mif 32

# Link - this produces an ELF binary.
$(CT_PRJ).elf: $(CT_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(FB_PRJ).elf: $(FB_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(VA_PRJ).elf: $(VA_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

%.rom: %.bin $(ROMGEN)
	./$(ROMGEN) $< >$@

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

