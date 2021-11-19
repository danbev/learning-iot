MEMORY
{
    flash : ORIGIN = 0x08000000, LENGTH = 64k
    ram   : ORIGIN = 0x20000000, LENGTH = 8k
}
   
SECTIONS
{
  /* set the location counter to the address (ORIGIN property) of flash  */
  . = ORIGIN(flash);
  /* the output .text section will be starting at the flash address */
  .text : { *(.text) } > flash
  /* set the location counter to the address (ORIGIN property) of ram  */
  . = ORIGIN(ram);
  /* the output .text section will be starting at the ram address */
  .data : { *(.data) } > ram
}
