MEMORY
{
    /*
     * nRF5233 has 512 kB (128 pages of 4 kB) of flash memory
     *
     * First in flash memory is the SoftDevice binary which provides the nRF
     * wireless protocol stack which is called SoftDevice.
     */
    /*FLASH_SOFTDEVICE (rx) : ORIGIN = 0x00001000, LENGTH = 23k*/
    /*FLASH (rx) : ORIGIN = 0x24000, LENGTH = 0x6CA00*/
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 0x80000
    /* 128 kB of RAM memory */
    /*SRAM_SOFTDEVICE (rwx) : ORIGIN = 0x20000000, LENGTH = 0x0005C10*/
    RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 0x10000
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
