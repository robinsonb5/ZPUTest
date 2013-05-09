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


int LoadImage(const char *fn, unsigned char *buf)
{
	fileTYPE *file=(fileTYPE *)0x1f000;
	if(FileOpen(file,fn))
	{
		putserial("Opened file, loading...\n");
		short imgsize=file->size/512;
		int c=0;
		while(c<imgsize)
		{
			if(FileRead(file, buf))
			{
				FileNextSector(file);
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
	HW_PER(PER_UART_CLKDIV)=1330000/1152;
	HW_VGA(FRAMEBUFFERPTR)=0x20000;
//	putserial("Initialising SD card\n");

//	SD_Boot("ZPUFirmware.bin",0);
	if(SDCardInit())
	{
		while(1)
		{
			LoadImage("TEST    IMG",0x20000);
			LoadImage("TEST2   IMG",0x20000);
		}
	}

	return(0);
}

