#include "small_printf.h"
#include "minisoc_hardware.h"

#include "ili9341.h"

int main(int argc,char **argv)
{
	HW_PER(PER_UART_CLKDIV)=1250000/1152;

	return(0);
}
