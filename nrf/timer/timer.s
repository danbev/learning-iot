.thumb
.text

.equ TIMER_BASE, 0x40008000
.equ PRESCALAR_OFFSET, 0x510
.equ TASK_START_OFFSET, 0x0000
.equ TASK_STOP_OFFSET, 0x0004
.equ TASK_CAPTURE_OFFSET, 0x040
.equ BITMODE_OFFSET, 0x508
.equ MODE_OFFSET, 0x504
.equ CC_OFFSET, 0x540
.equ EVENTS_COMPARE_OFFSET, 0x140

.equ PRESCALAR_R, TIMER_BASE + PRESCALAR_OFFSET

.equ TASKS_START_R, TIMER_BASE + TASK_START_OFFSET
.equ TASKS_STOP_R, TIMER_BASE + TASK_STOP_OFFSET
.equ TASKS_CAPTURE_R, TIMER_BASE + TASK_CAPTURE_OFFSET
.equ BITMODE_R, TIMER_BASE + BITMODE_OFFSET
.equ MODE_R, TIMER_BASE + MODE_OFFSET
.equ CC_R, TIMER_BASE + CC_OFFSET
.equ EVENTS_COMPARE_R, TIMER_BASE + EVENTS_COMPARE_OFFSET

.equ STOP, 1 << 0
.equ START, 1 << 0
.equ PRESCALAR, 4 << 0
.equ BITMODE, 0 << 0        /* 0 = 16 bit, 1 = 8 bits, 2 = 24 bits, 3 = 32 bits*/
.equ MODE, 0 << 0           /* Timer mode                                      */
.equ CAPTURE, 1 << 0
.equ CC_VALUE, 0xFF
.equ EVENT_GENERATED, 1 
.equ EVENT_RESET, 0x00000000

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1 

start:
  bl led_init
  bl timer_init

main_loop:
  bl timer_wait
  bl led_turn_on
  bl timer_wait
  bl led_turn_off
  b main_loop

timer_wait:
  ldr r1, =EVENTS_COMPARE_R
  ldr r2, [r1]
  cmp r2, #0
  beq timer_wait
  ldr r3, =EVENT_RESET
  str r3, [r1]
  bx lr

timer_init:
  ldr r1, =TASKS_STOP_R
  ldr r2, =STOP
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =TASKS_CAPTURE_R
  ldr r2, =CAPTURE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =CC_R
  ldr r2, =CC_VALUE
  str r2, [r1]

  ldr r1, =PRESCALAR_R
  ldr r2, =PRESCALAR
  str r2, [r1]

  ldr r1, =BITMODE_R
  ldr r2, =BITMODE
  str r2, [r1]

  ldr r1, =MODE_R
  ldr r2, =MODE
  str r2, [r1]

  ldr r1, =TASKS_START_R
  ldr r2, =START
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr

