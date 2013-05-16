#include "minisoc_hardware.h"
#include "small_printf.h"

#define FRAMEBUFFER 0x200000
#define FB_WIDTH 640
#define FB_HEIGHT 480


void ClearFramebuffer()
{
	int *fb=(int *)FRAMEBUFFER;
	int c=FB_WIDTH*FB_HEIGHT/2;
	while(--c)
		*fb++=0;
}


void FillFramebuffer(int s)
{
	short *fb=(short *)FRAMEBUFFER;
	int c=FB_WIDTH*FB_HEIGHT;
	while(--c)
	{
		if((s & 255)<128)
			*fb++=s++;
		else
			*fb++=0xffff-s++;
	}
}


int main(int argc,char *argv)
{
	long p=0;
	int counter;
	HW_PER(PER_UART_CLKDIV)=1330000/1152;
	putserial("Hello world!\n");
	HW_VGA(FRAMEBUFFERPTR)=FRAMEBUFFER;
	ClearFramebuffer();
	counter=0;
	while(1)
	{
		HW_PER(PER_HEX)=counter++;
		FillFramebuffer(counter);
	}
	return(0);
}

