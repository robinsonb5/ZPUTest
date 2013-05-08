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
		puts("Calling FindDrive\n");
		FindDrive();
		puts("FindDrive() returned\n");

//		ChangeDirectory(DIRECTORY_ROOT);
//		puts("Changed directory\n");
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
		fileTYPE *file=(fileTYPE *)0x1f000;
		if(FileOpen(file,"TEST    IMG"))
		{
			char *fbptr=(char *)0x20000;
			short imgsize=file->size/512;
			int c=0;
			while(c<imgsize)
			{
				if(FileRead(file, fbptr))
				{
					FileNextSector(file);
					fbptr+=512;
					++c;
				}	
			}
		}
	}

	return(0);
}

