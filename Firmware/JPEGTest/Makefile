BASE	= zpu-elf
BUILD_DIR=zpu_obj
ARCH = board=phi

CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump


JPEGTEST_PRJ = JPEGTest
COMMON_SRC = ../Common/minisoc_hardware.c ../Common/minisoc_hardware.h ../Common/small_printf.c ../Common/small_printf.h \
	../Common/spi.c ../Common/spi.h ../Common/swap.c ../Common/swap.h

COMMON_OBJ = $(patsubst ../Common/%.c,$(BUILD_DIR)/%.o,$(COMMON_SRC))

JPEGDIR = jpeg-6b

JPEGTEST_SRC_C = main.c syscalls.c malloc.c malloc.h fat.c fat.h rafile.c rafile.h junixio.c
JPEGTEST_OBJ_C = $(patsubst %.c,$(BUILD_DIR)/%.o,$(JPEGTEST_SRC_C))
JPEGLIB_OBJ = jpeg-6b/libjpeg.a
JPEGTEST_OBJ = $(JPEGTEST_OBJ_C) $(COMMON_OBJ) $(JPEGLIB_OBJ)

LINKMAP  = JPEGTest-$(BASE).ld
LIBDIR   = 

# Commandline options for each tool.
#ZPUOPTS= -mno-poppcrel -mno-compare -mno-byteop -mno-shortop -mno-callpcrel \
#  -mno-call -mno-neqbranch -mno-pushspadd \
#  -mno-neg -mno-mod -mno-div

ZPUOPTS= # -mno-poppcrel -mno-pushspadd -mno-callpcrel -mno-mult -mno-div # -mno-neg

INCLUDE = -I. -I../Common/ -Ijpeg-6b/
CFLAGS  = -m$(ARCH) $(INCLUDE) -c -O6 $(ZPUOPTS) -DRAMTOP=0x7FFFFF -DPRINTF_HEX_ONLY # -DDISABLE_PRINTF -DDISABLE_UART
AFLAGS  = 
LFLAGS  = -T$(LINKMAP) -m$(ARCH) -O6 -Wl,--relax
CP_HEXFLAGS = -Oihex
CP_SRECFLAGS = -Osrec --gap-fill 0

# Libraries.
LIBS       =

# Our target.
all: $(BUILD_DIR) $(JPEGTEST_PRJ).bin $(JPEGTEST_PRJ).srec

$(JPEGDIR)/libjpeg.a:
	make -C $(JPEGDIR) libjpeg.a

mif: $(JPEGTEST_PRJ).mif

clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.elf *.map *.lst *.srec $(PRJ).mif *~ */*.o *.bin
	make -C $(JPEGDIR) clean

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

$(JPEGTEST_PRJ).elf: $(JPEGTEST_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(BUILD_DIR)/%.o: ../Common/%.c
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)


