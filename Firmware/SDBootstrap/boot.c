/* Firmware for loading files from SD card.
   Part of the ZPUTest project by Alastair M. Robinson.
   SPI and FAT code borrowed from the Minimig project.

   The low 64k of RAM currently goes to BlockRAM
   (smaller ROMs are aliased to fill the 64k)
   and halfword and byte writes to BlockRAM aren't
   currently supported.
   For this reason, initialised global variables should be
   declared as int, not short or char.
   Uninitialised globals will automatically end up
   in SDRAM thanks to the linker script, which in most
   cases solves the problem.
*/


#include "minisoc_hardware.h"
#include "stdarg.h"

#include "sdboot.h"
#include "spi.h"
#include "fat.h"
#include "small_printf.h"


int SDCardInit()
{
	puts("Initialising SD card\n");
	if(spi_init())
	{
		FindDrive();
	}
	return(1);
}


fileTYPE file;

int LoadImage(const char *fn, unsigned char *buf)
{
	if(FileOpen(&file,fn))
	{
		putserial("Opened file, loading...\n");
		short imgsize=file.size/512;
		int c=0;
		while(c<imgsize)
		{
			if(FileRead(&file, buf))
			{
				FileNextSector(&file);
				buf+=512;
				++c;
			}
			else
			{
				putserial("File load failed\n");
				return(0);
			}
		}
	}
	return(1);
}


int main(int argc,char **argv)
{
	int i;
	int *sprite=(int *)0x1ff80;
	HW_PER(PER_UART_CLKDIV)=1330000/1152;

	HW_VGA(SP0PTR)=sprite;
	for(i=0;i<32;++i)
		*sprite++=0;

	HW_VGA(FRAMEBUFFERPTR)=0x20000;
//	putserial("Initialising SD card\n");

//	SD_Boot("ZPUFirmware.bin",0);
	if(SDCardInit())
	{
		while(1)
		{
			LoadImage("PIC1    RAW",(unsigned char *)0x20000);
			LoadImage("PIC2    RAW",(unsigned char *)0x20000);
			LoadImage("PIC3    RAW",(unsigned char *)0x20000);
			LoadImage("PIC4    RAW",(unsigned char *)0x20000);
			LoadImage("PIC5    RAW",(unsigned char *)0x20000);
		}
	}

	return(0);
}

