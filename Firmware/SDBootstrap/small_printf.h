#ifndef SMALL_PRINTF_H
#define SMALL_PRINTF_H

int small_printf(const char *fmt, ...);

#define printf small_printf
#define puts(x) putserial(x)

#endif

