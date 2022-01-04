.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

.equ GPIOC_BASE, 0x48000800

/* SysTick Control and Status Register */
.equ SYST_CSR, 0xE000E010
/* SysTick Reload Value Register */
.equ SYST_RVR, 0xE000E014
/* SysTick Current Value Register */
.equ SYST_CVR, 0xE000E018
/* SysTick Calibration Value Register */
.equ SYST_CALIB, 0xE000E01C

.equ GPIOC_ODR_OFFSET, 0x14
.equ GPIOC_ODR, GPIOC_BASE + GPIOC_ODR_OFFSET

.equ GPIOC_ODR_PC7, 1 << 7
.equ BSRR_9_RESET, 1 << 23

/* Enable the timer */
.equ SYST_CSR_ENABLE, 1 << 0
/* 0 = external clock source, 1 = processor clock source */
.equ SYST_CSR_CLK_SOURCE, 1 << 2
/* 0 = does not assert the SysTick exception (interrupt),
   1 = does assert the SysTick exception (interrupt). */
.equ SYST_CSR_TICKINT, 1 << 1
/* Determines if the timer has counted down to zero since last read. */
.equ SYST_CSR_COUNT_FLAG, 1 << 16

/* Reload Value */
.equ SYST_RVR_VALUE, 4000000 - 1

.global start

Vector_Table:                        // Vector                     Exception Nr 
  .word     0x20002000               // Initial Stack Pointer value       -
  .word     start + 1                // Reset                             1
  .word     null_handler + 1         // Non Maskable Interrupt            2
  .word     null_handler + 1         // Hard Fault                        3
  .word     null_handler + 1         // Memory Fault                      4
  .word     null_handler + 1         // Bus Fault                         5
  .word     null_handler + 1         // Usage Fault                       6
  .word     null_handler + 1         // Reserved                          7
  .word     null_handler + 1         // Reserved                          8
  .word     null_handler + 1         // Reserved                          9
  .word     null_handler + 1         // Reserved                         10
  .word     null_handler + 1         // SVCall                           11
  .word     null_handler + 1         // Debug Monitor                    12
  .word     null_handler + 1         // Reserved                         13
  .word     null_handler + 1         // Reserved for debug               14
  .word     systick_handler + 1      // SysTick                          15

null_handler:
  bx lr
                                                                                
systick_handler:
  push {lr}
  ldr r1,=GPIOC_ODR
  ldr r2,=GPIOC_ODR_PC7
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, #0x00
  beq turn_on
  bl turn_led_off
  pop {pc}
turn_on:
  bl turn_led_on
  pop {pc} 

start:
  bl led_init
  bl systick_init

main_loop:
  b main_loop

systick_init:
  /* Clear the SysTick Control Register */
  ldr r1, =SYST_CSR
  mov r2, #0
  str r2, [r1]

  /* Reload Value Register configuration */
  ldr r1, =SYST_RVR
  ldr r2, =SYST_RVR_VALUE
  str r2, [r1]

  /* Current Value Register configuration */
  ldr r1, =SYST_CVR
  mov r2, #0
  str r2, [r1]

  /* Control and Status Register configuration */
  ldr r1, =SYST_CSR
  mov r2, #(SYST_CSR_CLK_SOURCE + SYST_CSR_ENABLE + SYST_CSR_TICKINT)
  str r2, [r1]

  bx lr
