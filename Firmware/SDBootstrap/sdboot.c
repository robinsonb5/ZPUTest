#include "spi.h"

unsigned char *buf;

int _volstart;
int _fatstart;
int _fstype;
int _rootcluster;
int _rootsector;
int _rootdirentries;

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

	_fstype=0;
	int *p;
	short *pw;

	p=(int *)&buf[0x36];
	if(p[0]==0x46415431)
	{
		if(p[1]==0x32202020)
			_fstype=12;
		if(p[1]==0x36202020)
			_fstype=16;
	}
	else if(p[0]==0x46415431 && p[1]==0x32202020)
	{
		_fstype=32;
	}
	if(!_fstype)
		return(0);

	p=(int*)&buf[0x08];
	if((p[0]&0xff)!=0 || (p[1]&0xff00)!=0x200)
		return(0);

	pw=(short *)&buf[0xe];
	_fatstart+=buf[0xf]<<8|buf[0xe];

	switch(_fstype)
	{
		int i;
		int t;

		case 12:
		case 16:
			_rootcluster=0;
			_rootsector=_fatstart;
			i=buf[10];
			t=buf[17]<<8|buf[16];
			while(--i)
			{
				_rootsector+=t;
			}
			_rootdirentries=buf[12]<<8|buf[11];
			
//			lsr.w		#4,d0
//			add.l		d0,d1
			break;

		case 32:
//		move.l		$2c(a0),d0	; cluster of root directory
//		ror.w		#8,d0
//		swap		d0
//		ror.w		#8,d0
//		move.l		d0,_rootcluster
//; find start of clusters
//		move.l		$24(a0),d0	;FAT Size
//		ror.w		#8,d0
//		swap		d0
//		ror.w		#8,d0
//_add_start32		
//		add.l		d0,d1
//		subq.b		#1,$10(a0)
//		bne		_add_start32
//		bra		subcluster
			break;

		default:
			break;
	}
}

#if 0
	
;@fat32:
		
_fat16
subcluster:	
			moveq		#0,d0
			move.b		$d(a0),d0
			move.w		d0,_clustersize
			sub.l		d0,d1					; subtract two clusters to compensate
			sub.l		d0,d1					; for reserved values 0 and 1
			move.l		d1,_datastart			;start of clusters
			
fat_ex:
			move.w	#$0205,HEX
			moveq		#0,d0
			rts
}
#endif 

int FAT_CDRoot()
{

}


int FAT_FindFile(const char *fn)
{

}


int FAT_LoadFile(unsigned char *addr)
{

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

	if(FAT_CDRoot())
	{
		if(FAT_FindFile(filename))
		{
			if(FAT_LoadFile(addr))
			{
				return(1);
			}
		}
	}
	return(0);
}

