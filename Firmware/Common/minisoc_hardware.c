#include "minisoc_hardware.h"

#ifndef DISABLE_UART_TX
__inline void putcserial(char c)
{
	while(!(HW_PER(PER_UART)&(1<<PER_UART_TXREADY)))
		;
	HW_PER(PER_UART)=c;
}

void putserial(char *msg)
{
	while(*msg)
		putcserial(*msg++);
}
#endif

#ifndef DISABLE_UART_RX
char getserial()
{
	while(!(HW_PER(PER_UART)&(1<<PER_UART_RXINT)))
		;
	return(HW_PER(PER_UART));
}
#endif

