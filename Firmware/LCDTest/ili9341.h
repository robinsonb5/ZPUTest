#ifndef ILI9341_H
#define ILI9341_H

#include "minisoc_hardware.h"

#define lcd_sel(x) HW_PER(PER_SPI_CS)=(x ? (1<<PER_CS_LCD) : 0)
#define lcd_reset(x) HW_PER(PER_SPI_CS)=(x ? (1<<PER_CS_LCD) | (1<<PER_CS_LCDRESET) : 0)
#define lcd_write_data(x)  HW_PER(PER_LCD_DATA)=((x)&0xff)|PER_LCD_CMD
#define lcd_write_cmd(x)  HW_PER(PER_LCD_DATA)=((x)&0xff)
#define lcd_read() HW_PER(PER_LCD_DATA)

#define MEM_Y   (7) //MY row address order
#define MEM_X   (6) //MX column address order
#define MEM_V   (5) //MV row / column exchange
#define MEM_L   (4) //ML vertical refresh order
#define MEM_H   (2) //MH horizontal refresh order
#define MEM_BGR (3) //RGB-BGR Order

#define LCD_CMD_RESET                  0x01
#define LCD_CMD_READ_DISPLAY_ID        0x04
#define LCD_CMD_READ_DISPLAY_STATUS    0x09
#define LCD_CMD_READ_DISPLAY_POWER_MODE 0x0a
#define LCD_CMD_SLEEPOUT               0x11
#define LCD_CMD_DISPLAY_OFF            0x28
#define LCD_CMD_DISPLAY_ON             0x29
#define LCD_CMD_MEMACCESS_CTRL         0x36
#define LCD_CMD_PIXEL_FORMAT           0x3A
#define LCD_CMD_FRAME_CTRL             0xB1 //normal mode
#define LCD_CMD_DISPLAY_CTRL           0xB6
#define LCD_CMD_ENTRY_MODE             0xB7
#define LCD_CMD_POWER_CTRL1            0xC0
#define LCD_CMD_POWER_CTRL2            0xC1
#define LCD_CMD_VCOM_CTRL1             0xC5
#define LCD_CMD_VCOM_CTRL2             0xC7
#define LCD_CMD_POWER_CTRLA            0xCB
#define LCD_CMD_POWER_CTRLB            0xCF
#define LCD_CMD_POWERON_SEQ_CTRL       0xED
#define LCD_CMD_DRV_TIMING_CTRLA       0xE8
#define LCD_CMD_DRV_TIMING_CTRLB       0xEA
#define LCD_CMD_PUMP_RATIO_CTRL        0xF7

#define FBTFT_NOP 0x00
#define FBTFT_SWRESET 0x01
#define FBTFT_RDDID 0x04
#define FBTFT_RDDST 0x09
#define FBTFT_CASET 0x2A
#define FBTFT_RASET 0x2B
#define FBTFT_RAMWR 0x2C

int init_display();
void set_addr_win(int xs, int ys, int xe, int ye);

#endif

