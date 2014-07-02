#include "small_printf.h"
#include "ili9341.h"


int init_display()
{
	puts("In init_display, innit\n");
	lcd_sel(1);
	mdelay(1);

	puts("Delayed\n");

    lcd_write_cmd(LCD_CMD_DISPLAY_OFF);
    mdelay(20);

	puts("Turned off display\n");

    //send init commands
    lcd_write_cmd(LCD_CMD_POWER_CTRLB);
    lcd_write_data(0x00);
    lcd_write_data(0x83); //83 81 AA
    lcd_write_data(0x30);

	puts("Sent init command\n");

    lcd_write_cmd(LCD_CMD_POWERON_SEQ_CTRL);
    lcd_write_data(0x64); //64 67
    lcd_write_data(0x03);
    lcd_write_data(0x12);
    lcd_write_data(0x81);

	puts("Sent poweron seq command\n");

    lcd_write_cmd(LCD_CMD_DRV_TIMING_CTRLA);
    lcd_write_data(0x85);
    lcd_write_data(0x01);
    lcd_write_data(0x79); //79 78

	puts("Timing ctrl A\n");

    lcd_write_cmd(LCD_CMD_POWER_CTRLA);
    lcd_write_data(0x39);
    lcd_write_data(0X2C);
    lcd_write_data(0x00);
    lcd_write_data(0x34);
    lcd_write_data(0x02);

    lcd_write_cmd(LCD_CMD_PUMP_RATIO_CTRL);
    lcd_write_data(0x20);

    lcd_write_cmd(LCD_CMD_DRV_TIMING_CTRLB);
    lcd_write_data(0x00);
    lcd_write_data(0x00);

    lcd_write_cmd(LCD_CMD_POWER_CTRL1);
    lcd_write_data(0x26); //26 25

    lcd_write_cmd(LCD_CMD_POWER_CTRL2);
    lcd_write_data(0x11);

    lcd_write_cmd(LCD_CMD_VCOM_CTRL1);
    lcd_write_data(0x35);
    lcd_write_data(0x3E);

    lcd_write_cmd(LCD_CMD_VCOM_CTRL2);
    lcd_write_data(0xBE); //BE 94

    lcd_write_cmd(LCD_CMD_FRAME_CTRL);
    lcd_write_data(0x00);
    lcd_write_data(0x1B); //1B 70

    lcd_write_cmd(LCD_CMD_DISPLAY_CTRL);
    lcd_write_data(0x0A);
    lcd_write_data(0x82);
    lcd_write_data(0x27);
    lcd_write_data(0x00);

    lcd_write_cmd(LCD_CMD_ENTRY_MODE);
    lcd_write_data(0x07);

    lcd_write_cmd(LCD_CMD_PIXEL_FORMAT);
    lcd_write_data(0x55); //16bit

    // orientation
    lcd_write_cmd(LCD_CMD_MEMACCESS_CTRL);
    lcd_write_data((1<<MEM_X));

    lcd_write_cmd(LCD_CMD_SLEEPOUT);
    mdelay(120);

    lcd_write_cmd(LCD_CMD_DISPLAY_ON);
    mdelay(20);
	lcd_sel(0);
	puts("Returning from init_display()\n");
}


void set_addr_win(int xs, int ys, int xe, int ye)
{
    int xsl, xsh, xel, xeh, ysl, ysh, yel, yeh;

	lcd_sel(1);
	mdelay(1);
    xsl = (xs & 0xff);
    xsh = ((xs >> 8) & 0xff);
    xel = (xe & 0xff);
    xeh = ((xe >> 8) & 0xff);

    ysl = (ys & 0xff);
    ysh = ((ys >> 8) & 0xff);
    yel = (ye & 0xff);
    yeh = ((ye >> 8) & 0xff);

    lcd_write_cmd(FBTFT_CASET);
    lcd_write_data(xsh);
    lcd_write_data(xsl);
    lcd_write_data(xeh);
    lcd_write_data(xel);

    lcd_write_cmd(FBTFT_RASET);
    lcd_write_data(ysh);
    lcd_write_data(ysl);
    lcd_write_data(yeh);
    lcd_write_data(yel);

    lcd_write_cmd(FBTFT_RAMWR);
	mdelay(1);
	lcd_sel(0);
}


