
/* Memory Definitions */

MEMORY
{
  BOOT (rx) : ORIGIN = 0x00000000, LENGTH = 0x00002000 /* 8192 bytes */
  TRAP (rx) : ORIGIN = 0x00008000, LENGTH = 0x00000000 /* Dummy region to ensure we don't have any Initialized writable data */
  SDRAM (rw)  : ORIGIN = 0x007ff000, LENGTH = 0x00001000 /* 4k at top end of DE1's SDRAM */
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

  /* Remaining code sections */
  . = ALIGN(4);
  .text :
  {
    *(.text)                   /* remaining code */
  } >BOOT

  /* .rodata section which is used for read-only data (constants) */
  . = ALIGN(4);
  .rodata :
  {
    *(.rodata)
  } >BOOT
  . = ALIGN(4);
  _romend = . ;

  /* .data section which is used for initialized data.
     Since we don't want any writable data within the ROM
     itself, we put this stuff in a "trap" section. */
  . = ALIGN(4);
  .data :
  {
    _data = . ;
    *(.data)
    SORT(CONSTRUCTORS)
    . = ALIGN(4);
  } >TRAP

  /* .bss section which is used for uninitialized data */
  . = ALIGN(4);
  .bss :
  {
    __bss_start = . ;
    __bss_start__ = . ;
    *(.bss)
    *(COMMON)
  } >SDRAM
  __bss_end__ = . ;
}
