all: zpuromgen dhry.vhd boot.vhd

clean:
	rm *.vhd

zpuromgen: zpuromgen.c
	gcc -o zpuromgen zpuromgen.c

boot.vhd:
	make -C SDBootstrap/
	cat >boot.vhd rom_prologue
	./zpuromgen SDBootstrap/boot.bin >>boot.vhd
	cat >>boot.vhd rom_epilogue

dhry.vhd:
	make -C Dhrystone/
	cat >dhry.vhd rom_prologue
	./zpuromgen Dhrystone/dhry.bin >dhry.vhd
	cat >>dhry.vhd rom_epilogue

