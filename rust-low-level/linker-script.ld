MEMORY
{
    flash : ORIGIN = 0x08000000, LENGTH = 64k
    ram   : ORIGIN = 0x20000000, LENGTH = 8k
}

/* 
 Specify the entry point so that it does not get removed by the linker as
 an unused section.
*/
ENTRY(Reset)

/* Keep the following symbol even though it is not referenced */
EXTERN(RESET_HANDLER)
   
SECTIONS
{
  .vector_table ORIGIN(flash) :
  {
    LONG(ORIGIN(ram) + LENGTH(ram));     /* Stack Point value      */
    KEEP(*(.vector_table.reset_vector)); /* Reset Function pointer */
  } > flash

  .text : { *(.text .text.*); } > flash
  /* set the location counter to the address (ORIGIN property) of ram  */
  . = ORIGIN(ram);
  /* the output .text section will be starting at the ram address */
  .data : { *(.data) } > ram

  /DISCARD/ :
  {
    *(.ARM.exidx .ARM.exidx.*);
  }
}
