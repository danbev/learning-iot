MEMORY
{
  /*
   The names here like 'iram' are taken from Section 1.3 Addrress Map of the
   esp32-c3 Technical Reference Manual.
  */

  /* Instruction Address Map (IRAM) */
  IRAM (rx): ORIGIN = 0x42000000, LENGTH = 0x400000
  /* Data Address Map (DRAM) */
  DRAM (rwx): ORIGIN = 0x38000000, LENGTH = 0x400000
}

SECTIONS
{
  /* set the location counter to the address (ORIGIN property) of IRAM  */
  . = ORIGIN(IRAM);
  /* the output .text section will be starting at the IRAM address */
  .text : {
	  *(.text)
	  *(.rodata*)
	  _end_text = .;
  } > IRAM
  /* set the location counter to the address (ORIGIN property) of DRAM  */
  . = ORIGIN(DRAM);
  /* the output .data section will be starting at the DRAM address */
  .data : AT (_end_text) {
	  _start_data = .;
	  *(.data)
	  _end_data = .;
   } > DRAM
}
