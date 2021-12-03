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

.equ DELAY_LENGTH, 100000
delay:
  ldr r0,=DELAY_LENGTH
dloop:
  sub r0, r0, #1
  bne dloop      /* branch while the Z (zero) flag is not equal to zero */
  bx  lr
