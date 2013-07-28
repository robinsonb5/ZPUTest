#ifndef MINISOC_HARDWARE_H
#define MINISOC_HARDWARE_H

/* Hardware registers for the ZPU MiniSOC project.
   Based on the similar TG68MiniSOC project, but with
   changes to suit the ZPU's archicture */

#define VGABASE 0xE0000000

#define FRAMEBUFFERPTR 0

#define SP0PTR 0x100
#define SP0XPOS 0x104
#define SP0YPOS 0x108

#define HW_VGA(x) *(volatile unsigned long *)(VGABASE+x)
#define VGA_INT_VBLANK 1

/*
4	Word	Even row modulo (not yet implemented)

6	Word	Odd row modulo (not yet implemented)

8	Word	HTotal -  the total number of pixel clocks in a scanline (not yet implemented)

A	Word	HSize – number of horizontal pixels displayed (not yet implemented)

C	Word	HBStart – start of the horizontal blank (not yet implemented)

E	Word	HBStop – end of the horizontal blanking period. (Not yet implemented)

10	Word	Vtotal – the number of scanlines in a frame (not yet implemented)

12	Word	Vsize – the number of displayed scanlines  (not yet implemented)

14	Word	Vbstart – start of the vertical blanking period  (not yet implemented)

16	Word	Vbstop – end of the vertical blanking period  (not yet implemented)

18	Word	Control  (not yet implemented)
		bit 7	Character overlay on/off  (not yet implemented)
		bit 1	resolution – 1: high, 0: low   (not yet implemented)
		bit 0	visible.  (not yet implemented)
*/


#define PERIPHERALBASE 0xFFFFFF00
#define HW_PER(x) *(volatile unsigned int *)(PERIPHERALBASE+x)
#define HW_PER_L(x) *(volatile unsigned int *)(PERIPHERALBASE+x)

#define PER_UART 0x84
#define PER_UART_CLKDIV 0x88

#define PER_UART_RXINT 9
#define PER_UART_TXREADY 8

#define PER_FLAGS 0x8c  /* Currently only contains ROM overlay */
#define PER_FLAGS_OVERLAY 0

#define PER_HEX 0x90

#define PER_PS2_KEYBOARD 0x94
#define PER_PS2_MOUSE 0x98

/* PS2 Status bits */
#define PER_PS2_RECV 11
#define PER_PS2_CTS 10

/* Timers */

/* Millisecond counter */
#define PER_MILLISECONDS 0xc0

/* SPI register */
#define PER_SPI_CS 0xc4	/* CS bits are write-only, but bit 15 reads as the SPI busy signal */
#define PER_SPI 0xc8 /* Blocks on both reads and writes, making BUSY signal redundant. */
#define PER_SPI_PUMP 0xcc /* Push 16-bits through SPI in one instruction */

#define PER_CS_SD 0
#define PER_CS_LCD 1
#define PER_SPI_FAST 8
#define PER_SPI_BUSY 15

#define PER_MANIFEST1 0xf8 /* First four characters of Manifest filename */
#define PER_MANIFEST2 0xfc /* Second four characters of Manifest filename */

/* LCD registers */

#define PER_LCD_DATA 0xD0
#define PER_LCD_CMD_B 31 /* High bit set indicates that this is a command. */
#define PER_LCD_CMD (1<<PER_LCD_CMD_B)

/* Interrupts */

#define PER_INT_UART 2
#define PER_INT_TIMER 3
#define PER_INT_PS2 4

void mdelay(int msecs);

#ifndef DISABLE_UART_TX
void putcserial(char c);
void putserial(char *msg);
#else
#define putserial(x)
#endif

#ifndef DISABLE_UART_RX
char getserial();
#else
#define getserial 0
#endif

#endif

