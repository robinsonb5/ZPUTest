all: zpuromgen dhry.gen boot.gen

clean:
	make -C SDBootstrap clean
	make -C Dhrystone clean
	rm *.vhd

zpuromgen: zpuromgen.c
	gcc -o zpuromgen zpuromgen.c

boot.gen:
	make -C SDBootstrap/
	sed 's/dualportram/sdbootstrap_rom/' >sdbootstrap_rom.vhd <rom_prologue
	./zpuromgen SDBootstrap/boot.bin >>sdbootstrap_rom.vhd
	cat >>sdbootstrap_rom.vhd rom_epilogue

dhry.gen:
	make -C Dhrystone/
	sed 's/dualportram/dhrystone_rom/' >dhrystone_rom.vhd <rom_prologue
	./zpuromgen Dhrystone/dhry.bin >>dhrystone_rom.vhd
	cat >>dhrystone_rom.vhd rom_epilogue

