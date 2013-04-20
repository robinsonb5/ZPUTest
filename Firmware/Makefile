BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump

PRJ = countertest
SRC = countertest.c
OBJ = $(SRC:.c=.o)

LINKMAP  = 
LIBDIR   = 

# Commandline options for each tool.
CFLAGS  = -I. -c -fno-common -O3
AFLAGS  = 
LFLAGS  = 
CPFLAGS = 

ROMGEN = zpuromgen

# Libraries.
LIBS       =

# Our target.
all: $(PRJ).rom

clean:
	rm -f *.o *.hex *.elf *.map *.lst *~ */*.o $(ROMGEN) *.bin

$(ROMGEN): $(ROMGEN).c
	gcc  -o $@ $<

# Convert ELF binary to bin file.
$(PRJ).bin: $(PRJ).elf
	$(CP) -O binary $< $@

# Convert ELF binary to Intel HEX file.
$(PRJ).hex: $(PRJ).elf
	$(CP) $(CPFLAGS) $< $@

# Link - this produces an ELF binary.
$(PRJ).elf: $(OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(PRJ).rom: $(PRJ).bin $(ROMGEN)
	./$(ROMGEN) $< >$@

%.o: %.c
	$(CC) $(CFLAGS)  -o $@ -c $<

