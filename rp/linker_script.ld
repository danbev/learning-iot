MEMORY
{
    FLASH(rx) : ORIGIN = 0x10000000, LENGTH = 2048k
    RAM(rwx) : ORIGIN =  0x20000000, LENGTH = 256k
}

SECTIONS
{
  /* set the location counter to the address (ORIGIN property) of flash  */
  . = ORIGIN(FLASH);
  /* the output .text section will be starting at the flash address */
  .text : {
	  *(.text)
	  *(.rodata*)
	  _end_text = .;
  } > FLASH
  /* set the location counter to the address (ORIGIN property) of ram  */
  . = ORIGIN(RAM);
  /* the output .data section will be starting at the ram address */
  .data : AT (_end_text) {
	  _start_data = .;
	  *(.data)
	  _end_data = .;
   } > RAM
}
