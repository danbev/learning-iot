.thumb
.text

.global start

Vector_Table:    
  .word     0x20002000

ResetVector:
  .word     start + 1

start:
  mov r1, #2
  bl uart_init
main_loop:
  bl delay
  mov r0, #0x41 // #'A' /* hex: 0x41 */
  bl uart_write_char
  b main_loop
