/*
 Example of initializing global variables.
*/
.syntax unified
.thumb

.data

one: .word 1
two: .word 2
three: .word 3

.text

.global start

Vector_Table:                   // Exception Nr  Handler               IRQ Nr
  .word     0x20002000          // 0             Initial SP value
  .word     start + 1           // 1             Reset

start:
  ldr r0, =one
  ldr r1, =_end_text    // end of .text segment in Flash memory.
  ldr r2, =_start_data  // start of .data segment in RAM memory.
  ldr r3, =_end_data    // end of .data segment in RAM memory.

copy_loop:  
  cmp r2, r3
  bge no_copy
  
  ldr r4, [r1], #4
  str r4, [r2], #4
  b copy_loop

no_copy:
  ldr r1, =one
  ldr r2, =two
  ldr r3, =three
  bl .
