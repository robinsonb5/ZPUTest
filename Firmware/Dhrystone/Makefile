BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump

BUILD_DIR=zpu_obj

DH_PRJ = dhrystone
DH_SRC = dhry_1.c dhry_2.c
DH_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(DH_SRC))

LINKMAP  = 
LIBDIR   = 

# Commandline options for each tool.
ZPUOPTS= -mno-poppcrel -mno-compare -mno-byteop -mno-shortop -mno-callpcrel \
  -mno-call -mno-neqbranch -mno-pushspadd \
  -mno-neg -mno-mod -mno-div

ZPUOPTS2= -mno-poppcrel -mno-callpcrel -mno-call -mno-pushspadd -mno-neg

CFLAGS  = -I../ -I. -c -Os -DTINY
AFLAGS  = 
LFLAGS  = -Os
CP_HEXFLAGS = -Oihex
CP_SRECFLAGS = -Osrec --gap-fill 0

ROMGEN = zpuromgen

# Libraries.
LIBS       =

# Our target.
all: $(BUILD_DIR) $(DH_PRJ).mif

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
$(DH_PRJ).elf: $(DH_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

%.rom: %.bin $(ROMGEN)
	./$(ROMGEN) $< >$@

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

