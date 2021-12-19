/*
Controller Area Network (CAN) Controller.
*/
.thumb
.text

.equ CAN_MCR_OFFSET, 0x00
.equ CAN_MCR, CAN_BASE + CAN_MCR_OFFSET

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  bl can_init
  bl can_controller_init
  b .

can_controller_init:
  bx lr
