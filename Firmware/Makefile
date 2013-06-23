all: zpuromgen Dhrystone.gen SDBootstrap.gen RS232Bootstrap.gen VampireDiag.gen

clean:
	make -C SDBootstrap clean
	make -C RS232Bootstrap clean
	make -C Dhrystone clean
	rm *.vhd

zpuromgen: zpuromgen.c
	gcc -o zpuromgen zpuromgen.c

# Generic rom-generation rule - only works if the Project directories are carefully named

%.gen: 
	make -C $*/
	sed 's/dualportram/$*_ROM/' >$*_ROM.vhd <rom_prologue
	./zpuromgen $*/$*.bin >>$*_ROM.vhd
	cat >>$*_ROM.vhd rom_epilogue

#boot.gen:
#	make -C SDBootstrap/
#	sed 's/dualportram/sdbootstrap_rom/' >sdbootstrap_rom.vhd <rom_prologue
#	./zpuromgen SDBootstrap/boot.bin >>sdbootstrap_rom.vhd
#	cat >>sdbootstrap_rom.vhd rom_epilogue

#rs232boot.gen:
#	make -C RS232Bootstrap/
#	sed 's/dualportram/rs232bootstrap_rom/' >rs232bootstrap_rom.vhd <rom_prologue
#	./zpuromgen RS232Bootstrap/boot.bin >>rs232bootstrap_rom.vhd
#	cat >>rs232bootstrap_rom.vhd rom_epilogue

#dhry.gen:
#	make -C Dhrystone/
#	sed 's/dualportram/dhrystone_rom/' >dhrystone_rom.vhd <rom_prologue
#	./zpuromgen Dhrystone/dhry.bin >>dhrystone_rom.vhd
#	cat >>dhrystone_rom.vhd rom_epilogue

