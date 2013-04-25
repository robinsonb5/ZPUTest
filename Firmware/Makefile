BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump

BUILD_DIR=zpu_obj

PRJ = countertest
SRC = countertest.c # spi.c
OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(SRC))

LINKMAP  = 
LIBDIR   = 

# Commandline options for each tool.
ZPUOPTS= -mno-poppcrel -mno-compare -mno-byteop -mno-shortop -mno-callpcrel \
  -mno-call -mno-neqbranch -mno-pushspadd \
  -mno-neg -mno-mod -mno-div

ZPUOPTS2= -mno-poppcrel -mno-callpcrel -mno-call -mno-pushspadd -mno-neg

CFLAGS  = -I. -c -O3 $(ZPUOPTS2)
AFLAGS  = 
LFLAGS  =  
CP_HEXFLAGS = -Oihex
CP_SRECFLAGS = -Osrec --gap-fill 0

ROMGEN = zpuromgen

# Libraries.
LIBS       =

# Our target.
all: $(PRJ).rom $(PRJ).mif

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
$(PRJ).srec: $(PRJ).elf
	$(CP) $(CP_SRECFLAGS) $< $@

# Convert SREC to .mif file
$(PRJ).mif: $(PRJ).srec
	srec_cat $< -o $@ -mif 32

# Link - this produces an ELF binary.
$(PRJ).elf: $(OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(PRJ).rom: $(PRJ).bin $(ROMGEN)
	./$(ROMGEN) $< >$@

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS)  -o $@ -c $<

