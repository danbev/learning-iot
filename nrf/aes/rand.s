/*
 Example of using the Random Number Generator.
*/
.thumb
.text

.equ RND_BASE, 0x4000D000

.equ TASK_START, RND_BASE + 0x000
.equ EVENTS_VALRDY, RND_BASE + 0x100
.equ VALUE, RND_BASE + 0x508
.equ TASK_STOP, RND_BASE + 0x004

.equ START, 1 << 0
.equ VALRDY, 1

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  ldr r1, =TASK_START
  ldr r2, =START
  str r2, [r1]

wait_value:
  ldr r1, =EVENTS_VALRDY
  ldr r2, =VALRDY
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_value
  
  /* Value will be in the VALUE Register */
  ldr r1, =VALUE
  
  bl .

