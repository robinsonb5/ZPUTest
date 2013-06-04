#include <stdlib.h>
#include <string.h>

#include "fat.h"
#include "small_printf.h"

fileTYPE *file;

char string[]="Hello world!\n";

int main(int argc, char **argv)
{
	file=malloc(sizeof(fileTYPE));

	write(1,string,strlen(string));
	read(0,string,strlen(string));
	write(1,string,strlen(string));

	return(0);
}
