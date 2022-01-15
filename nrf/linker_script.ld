MEMORY
{
    FLASH_SOFTDEVICE (rx) : ORIGIN = 0x00001000, LENGTH = 0x00023000
    FLASH (rx) : ORIGIN = 0x24000, LENGTH = 0x6CA00
    SRAM_SOFTDEVICE (rwx) : ORIGIN = 0x20000000, LENGTH = 0x0005C10
    RAM (rwx) :  ORIGIN = 0x20005C11, LENGTH = 0x9D6F
}

SECTIONS
{
  /* set the location counter to the address (ORIGIN property) of flash  */
  . = ORIGIN(FLASH);
  /* the output .text section will be starting at the flash address */
  .text : { *(.text) } > FLASH
  /* set the location counter to the address (ORIGIN property) of ram  */
  . = ORIGIN(RAM);
  /* the output .text section will be starting at the ram address */
  .data : { *(.data) } > RAM
}
