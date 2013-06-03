#include <stdlib.h>

#include "fat.h"
#include "small_printf.h"

fileTYPE *file;

int main(int argc, char **argv)
{
	file=malloc(sizeof(fileTYPE));
	if(spi_init())
	{
		FindDrive();
	}

	return(0);
}
