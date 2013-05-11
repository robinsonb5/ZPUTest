
/* Memory Definitions */

MEMORY
{
  BOOT (rx) : ORIGIN = 0x00000000, LENGTH = 0x00002000 /* 8192 bytes */
  SDRAM (rw)  : ORIGIN = 0x07ff000, LENGTH = 0x00010000 /* 128k at top end of DE1's SDRAM */
  STACK (rw) : ORIGIN = 0x40000000, LENGTH = 0x00000400 /* 1024 bytes */
}


/* Section Definitions */

SECTIONS
{
  /* first section is .fixed_vectors which is used for startup code */
  . = 0x0000000;
  .fixed_vectors :
  {
    *(.fixed_vectors)
  }>BOOT

  . = ALIGN(4);
  /* Remaining code sections */
  .text :
  {
    *(.text)                   /* remaining code */
  } >BOOT

  . = ALIGN(4);

  /* .rodata section which is used for read-only data (constants) */

  .rodata :
  {
    *(.rodata)
  } >BOOT

  . = ALIGN(4);

  _etext = . ;
  PROVIDE (etext = .);

  /* .data section which is used for initialized data */

  .data : AT (_etext)
  {
    _data = . ;
    *(.data)
    SORT(CONSTRUCTORS)
    . = ALIGN(4);
  } >BOOT
  . = ALIGN(4);

  _edata = . ;
   PROVIDE (edata = .);

  /* .bss section which is used for uninitialized data */

  .bss :
  {
    __bss_start = . ;
    __bss_start__ = . ;
    *(.bss)
    *(COMMON)
  } >SDRAM
  . = ALIGN(4);
  __bss_end__ = . ;
  __end__ = . ;
  _end = .;
  PROVIDE (end = .);
}
