#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>

#include "fat.h"
#include "small_printf.h"

fileTYPE *file;

char string[]="Hello world!\n";

static struct stat statbuf;

int main(int argc, char **argv)
{
	file=malloc(sizeof(fileTYPE));

	int fd=open("SPLASH  RAW",0,O_RDONLY);
	printf("open() returned %d\n",fd);
	if((fd>0)&&!fstat(fd,&statbuf))
	{
		char *imagebuf;
		printf("File size: %d\n",statbuf.st_size);
		if((imagebuf=malloc(statbuf.st_size)))
		{
			HW_VGA(FRAMEBUFFERPTR)=imagebuf;
			read(fd,imagebuf,statbuf.st_size);
		}
	}
	return(0);
}
