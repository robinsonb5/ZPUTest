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

int LoadFile(const char *fn, unsigned char *buf)
{
	if(FileOpen(&file,fn))
	{
		putserial("Opened file, loading...\n");
		short imgsize=(file.size+511)/512;
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


void _boot();
#if 0
void CopyImage(int *src,int *dst)
{
	int x,y;
	for(y=0;y<480;++y)
	{
		for(x=0;x<640;x+=2)
		{
			*dst++=*src++^0xffffffff;
		}
	}
}


void MemTest()
{
	int *p=0x100000;
	int c=0x100000;
	printf("Checking memory starting at %d\n",p);
	while(--c)
	{
		*p++=c;
	}
	printf("Write done, reading\n");
	p=0x100000;
	c=0x100000;
	while(--c)
	{
		int t=*p++;
		if(t!=c)
			printf("Error at %d, got %d\n",c,t);
	}
	printf("Memory test completed\n");
}
#endif

int main(int argc,char **argv)
{
	int i;
//	int *sprite=(int *)0x1ff80;
	HW_PER(PER_UART_CLKDIV)=1330000/1152;

//	HW_VGA(SP0PTR)=sprite;
//	for(i=0;i<32;++i)
//		*sprite++=0;

	HW_VGA(FRAMEBUFFERPTR)=0x100000;
//	putserial("Initialising SD card\n");

//	MemTest();

	if(SDCardInit())
	{
		LoadFile("SPLASH  RAW",(unsigned char *)0x100000);
//		CopyImage(0x100000,0x100000);
//		LoadFile("PIC2    RAW",(unsigned char *)0x100000);
//		CopyImage(0x100000,0x100000);
//		LoadFile("PIC3    RAW",(unsigned char *)0x100000);
//		CopyImage(0x100000,0x100000);
		LoadFile("DHRY    BIN",(unsigned char *)0x0);
		_boot();
	}

	return(0);
}

