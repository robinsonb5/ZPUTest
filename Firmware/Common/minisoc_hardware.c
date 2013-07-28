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
	int r=0;
	while(!(r&(1<<PER_UART_RXINT)))
		r=HW_PER(PER_UART);
	return(r);
}
#endif

#ifndef DISABLE_TIMER
void mdelay(int msecs)
{
	int t=HW_PER(PER_MILLISECONDS);
	while(msecs)
	{
		int t2=t;
		while(t2==t)
			t2=HW_PER(PER_MILLISECONDS);
		t=t2;
		--msecs;
	}
}
#endif
