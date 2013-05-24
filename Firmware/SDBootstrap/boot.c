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


void _boot();
void _break();

/* Load files named in a manifest file */

static unsigned char Manifest[2048];

int main(int argc,char **argv)
{
	int i;
	HW_PER(PER_UART_CLKDIV)=1250000/1152;

	HW_VGA(FRAMEBUFFERPTR)=0x00000;

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
					if(c=='G')
						_boot();

					if(c=='\n')
						_break(); // Halt CPU

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
					HW_VGA(FRAMEBUFFERPTR)=ptr;
				}

				// Hunt for newline character
				while((c=*buffer++)!='\n')
					;
			}
		}
	}

	return(0);
}

