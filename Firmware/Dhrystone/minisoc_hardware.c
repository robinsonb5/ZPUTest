#include "minisoc_hardware.h"

#ifndef DISABLE_UART
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


