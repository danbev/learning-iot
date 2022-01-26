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
.equ INTENTSET_OFFSET, 0x304             /* Interrupt Enable Set */
.equ INTENTCLR_OFFSET, 0x308

/* Interrupt Set-Enable Register 0 */
.equ NVIC_ISER0, 0xE000E100
/* Interrupt Clear-Enable Register 0 */
.equ NVIC_ICER0, 0XE000E180
/* Interupt Clear-Pending Register 0 */
.equ NVIC_ICPR0, 0XE000E280
/* Interupt Active-Bit Register 0 */
.equ NVIC_IABR0, 0xE000E300

.equ PRESCALAR_R, TIMER_BASE + PRESCALAR_OFFSET

.equ TASKS_START_R, TIMER_BASE + TASK_START_OFFSET
.equ TASKS_STOP_R, TIMER_BASE + TASK_STOP_OFFSET
.equ TASKS_CAPTURE_R, TIMER_BASE + TASK_CAPTURE_OFFSET
.equ BITMODE_R, TIMER_BASE + BITMODE_OFFSET
.equ MODE_R, TIMER_BASE + MODE_OFFSET
.equ CC_R, TIMER_BASE + CC_OFFSET
.equ EVENTS_COMPARE_R, TIMER_BASE + EVENTS_COMPARE_OFFSET
.equ INTENTSET_R, TIMER_BASE + INTENTSET_OFFSET
.equ INTENTCLR_R, TIMER_BASE + INTENTCLR_OFFSET

.equ STOP, 1 << 0
.equ START, 1 << 0
.equ PRESCALAR, 4 << 0
.equ BITMODE, 0 << 0        /* 0 = 16 bit, 1 = 8 bits, 2 = 24 bits, 3 = 32 bits*/
.equ MODE, 0 << 0           /* Timer mode                                      */
.equ CAPTURE, 1 << 0
.equ CC_VALUE, 0xFF
.equ EVENT_GENERATED, 1 
.equ EVENT_RESET, 0x00000000
.equ INT_ENABLE, 1 << 16

.equ IRQ_8, 1 << 8 

.global start

Vector_Table:                   
  .word     0x20002000          // 0 Initial Stack Pointer value 
  .word     start + 1           // 1 Reset                       
  .word     null_handler + 1    // 2 Non Maskable Interrupt      -14
  .word     null_handler + 1    // 3 Hard Fault                  -13
  .word     null_handler + 1    // 4 Memory Fault                -12
  .word     null_handler + 1    // 5 Bus Fault                   -11
  .word     null_handler + 1    // 6 Usage Fault                 -10
  .word     null_handler + 1    // 7 Reserved                    
  .word     null_handler + 1    // 8 Reserved                    
  .word     null_handler + 1    // 9 Reserved                    
  .word     null_handler + 1    // 10 Reserved                   
  .word     null_handler + 1    // 11 SVCall                     -5
  .word     null_handler + 1    // 12 Reserved for debug         
  .word     null_handler + 1    // 13 Reserved                   
  .word     null_handler + 1    // 14 PendSV                     -2
  .word     null_handler + 1    // 15 SysTick                    -1
  .word     null_handler + 1    // 16 IRQ0                       0
  .word     null_handler + 1    // 17 IRQ1                       1
  .word     null_handler + 1    // 18 IRQ2                       2
  .word     null_handler + 1    // 19 IRQ3                       3
  .word     null_handler + 1    // 20 IRQ4                       4
  .word     null_handler + 1    // 21 IRQ5                       5
  .word     null_handler + 1    // 22 IRQ6                       6
  .word     null_handler + 1    // 23 IRQ7                       7
  .word     timer0_handler + 1  // 24 IRQ8                       8


null_handler:
  bx lr

timer0_handler:
  ldr r1, =EVENTS_COMPARE_R
  ldr r2, =EVENT_RESET
  str r2, [r1]

  push {lr}
  bl led_toggle

  ldr r1, =NVIC_ICPR0
  ldr r2, =IRQ_8
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  pop {pc} 

start:
  bl led_init
  bl timer_init
main_loop:
  b main_loop

timer_init:
  /* Enable IRQ Nr 8 */
  ldr r1, =NVIC_ISER0
  ldr r2, =IRQ_8
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

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

  ldr r1, =INTENTSET_R
  ldr r2, =INT_ENABLE
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

