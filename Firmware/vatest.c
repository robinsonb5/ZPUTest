#include "minisoc_hardware.h"
#include "stdarg.h"

#ifdef TEST
void putserial(char *msg)
{
	puts(msg);
}
#else
void putserial(char *msg)
{
	while(*msg)
	{
		while(!(HW_PER(PER_UART)&(1<<PER_UART_TXREADY)))
			;
		HW_PER(PER_UART)=*msg++;
	}
}
#endif

void vatest(char *s1,...)
{
	putserial("In vatest\n");
	va_list ap;
	int arg1;
	char *s;

	va_start(ap, s1);
//	putserial("Called va_start\n");
	for (s = s1; s != 0; s = va_arg(ap, char *))
		putserial(s);
//	putserial("Written args\n");
	va_end(ap);
//	putserial("Done\n");
}


int main(int argc,char **argv)
{
#ifndef TEST
	HW_PER(PER_UART_CLKDIV)=1330000/1152;
#endif
//	putserial("Initialised\n");
	vatest("Hello world\n","Hello again\n","Third string\n",0);
	return(0);
}
