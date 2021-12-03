.global delay

.equ DELAY_LENGTH, 100000
delay:
  ldr r0,=DELAY_LENGTH
dloop:
  sub r0, r0, #1
  bne dloop
  bx  lr
