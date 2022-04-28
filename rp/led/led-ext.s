/* Raspberry PI Pico external LED example */
.thumb
.text

.global start

.equ GPIO_BASE, 0xd0000000
.equ GPIO0_CTRL, CPIO_BASE + 0x004

Vector_Table:
  .word     0x20000000
  .word     start + 1

start:
  b .
