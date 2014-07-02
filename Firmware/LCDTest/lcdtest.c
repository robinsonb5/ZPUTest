#include "small_printf.h"
#include "minisoc_hardware.h"

#include "ili9341.h"

int main(int argc,char **argv)
{
	int i;
	HW_PER(PER_UART_CLKDIV)=1250000/1152;

//	printf("Resetting display\n");
//	lcd_reset(1);
//	mdelay(2);
//	lcd_reset(0);
//	mdelay(100);

	lcd_sel(1);
//	lcd_write_cmd(0x01); // Reset
	mdelay(10);

	lcd_write_cmd(0x04);
	// Discard first response
	printf("%d, ", lcd_read());
	printf("%d, ", lcd_read());
	printf("%d, ", lcd_read());
	printf("%d\n", lcd_read());

//	puts("Initialising display\n");
//	init_display();
//	puts("Setting display window\n");
//	set_addr_win(0,0,319,239);

	lcd_write_cmd(0x09);
	printf("%d, ", lcd_read());
	printf("%d, ", lcd_read());
	printf("%d, ", lcd_read());
	printf("%d\n", lcd_read());

//    lcd_write_cmd(FBTFT_RAMWR);

//	while(1)
//	{
//		++i;
//		lcd_write_data(i);
//	}
	lcd_sel(0);

	while(1)
		;

	return(0);
}
