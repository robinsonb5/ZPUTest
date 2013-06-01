/* Firmware for bootstrapping larger firmware from RS232. */

#include "minisoc_hardware.h"

#include "small_printf.h"

void _boot();
void _break();


int main(int argc,char **argv)
{
	int i;
	HW_PER(PER_UART_CLKDIV)=1250000/1152;
	puts("Hello, world\n");

	while(1)
	{
		int c=getserial();
		putcserial(c);
	}
	return(0);
}

