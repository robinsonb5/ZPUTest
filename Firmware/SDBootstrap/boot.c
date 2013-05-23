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
	else
	{
		printf("Can't open %s\n",fn);
		return(0);
	}
	return(1);
}


void _boot();

/* Load files named in a manifest file */

static unsigned char Manifest[2048];

int main(int argc,char **argv)
{
	int i;
	HW_PER(PER_UART_CLKDIV)=1250000/1152;

	HW_VGA(FRAMEBUFFERPTR)=0x20000;

	if(spi_init())
	{
		FindDrive();
		if(LoadFile("MANIFESTTXT",Manifest))
		{
			unsigned char *buffer=Manifest;
			int ptr;
			puts("Parsing manifest\n");
			while(1)
			{
				unsigned char c;
				ptr=0;
				// Parse address
				while((c=*buffer++)!=' ')
				{
					if(c=='#') // Comment line?
						break;
					if(c=='\n')
						_boot();

					c=(c&~32)-('0'-32); // Convert to upper case
					if(c>='9')
						c-='A'-'0';
					ptr<<=4;
					ptr|=c;
				}
				// Parse filename
				if(c!='#')
				{
					int i;
					while((c=*buffer++)==' ')
						;
					--buffer;
					// c-1 is now the filename pointer

//					printf("Loading file %s to %d\n",fn,(long)ptr);
					LoadFile(buffer,(unsigned char *)ptr);
				}

				// Hunt for newline character
				while((c=*buffer++)!='\n')
					;
			}
		}
	}

	return(0);
}

