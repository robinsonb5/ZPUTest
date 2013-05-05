#include "spi.h"

unsigned char *buf;

int _volstart;
int FindVolume(int superfloppy)
{
	buf=(unsigned char *)0x7fff00;
	if(!sd_read_sector(0,buf))	// Read partition table
	{
		return(0);
	}

	if(buf[0x1fe]!=0x55 || buf[0x1ff]!=0xaa)	// Valid DOS signature?
	{
		return(0);
	}

	if(!superfloppy)	// Partitioned?
	{
		unsigned char *p=buf+0x1be;
		_volstart=(p[11]<<24)|(p[10]<<16)|(p[9]<<8)|p[8]; // LBA address
		sd_read_sector(_volstart,buf);
		if(buf[0x1fe]!=0x55 || buf[0x1ff]!=0xaa)	// Valid DOS signature?
		{
			return(0);
		}
	}

}


int SD_Boot(const char *filename,unsigned char *addr)
{
	if(!FindVolume(1))	// Try and find a superfloppy
	{
		// No?  OK check for a partition then
		if(!FindVolume(0))	// Try and find a superfloppy
		{
			// Still no?  Bail out then.
			return(0);
		}
	}

	// if(FAT_CDRoot())
	{
		// if(FAT_FindFile(const char *fn))
		{
			// if(FAT_LoadFile(unsigned char *addr))
			{
				return(1);
			}
		}
	}
	return(0);
}

