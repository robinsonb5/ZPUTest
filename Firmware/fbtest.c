#include "minisoc_hardware.h"

#define COUNTER *(volatile unsigned int *)(0xFFFFFF80)
#define SWITCHES *(volatile unsigned int *)(0xFFFFFF84)

#define FRAMEBUFFER 0x10000
#define FB_WIDTH 640
#define FB_HEIGHT 480

void putserial(char *msg)
{
	while(*msg)
	{
		while(!(HW_PER(PER_UART)&(1<<PER_UART_TXREADY)))
			;
		HW_PER(PER_UART)=*msg++;
	}
}


void ClearFramebuffer()
{
	int *fb=(int *)FRAMEBUFFER;
	int c=FB_WIDTH*FB_HEIGHT/2;
	while(--c)
		*fb++=0;
}


void FillFramebuffer(int s)
{
	int *fb=(int *)FRAMEBUFFER;
	int c=FB_WIDTH*FB_HEIGHT/2;
	while(--c)
		*fb++=s++;
}


int main(int argc,char *argv)
{
	int c=0;
	long p=0;
	HW_PER(PER_UART_CLKDIV)=1000000/1152;
	putserial("Hello world!\n");
	HW_VGA(FRAMEBUFFERPTR)=FRAMEBUFFER;
	ClearFramebuffer();
	while(1)
	{
		HW_PER(PER_HEX)=c;
		FillFramebuffer(++c);
	}
	return(0);
}

