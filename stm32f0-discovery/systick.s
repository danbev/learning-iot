.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

/* SysTick Control and Status Register */
.equ SYST_CSR, 0xE000E010
/* SysTick Reload Value Register */
.equ SYST_RVR, 0xE000E014
/* SysTick Current Value Register */
.equ SYST_CVR, 0xE000E018
/* SysTick Calibration Value Register */
.equ SYST_CALIB, 0xE000E01C

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ GPIO_PORTC_ENABLE, 1 << 19
.equ GPIOC_MODER_MASK, 1 << 14
.equ GPIOC_MODER_OFFSET, 0x00
.equ GPIOC_MODER, GPIOC_BASE + GPIOC_MODER_OFFSET
.equ GPIOC_BASE, 0x48000800
.equ GPIOC_BSRR_OFFSET, 0x18
.equ GPIOC_BSRR, GPIOC_BASE + GPIOC_BSRR_OFFSET
.equ BSRR_9_SET, 1 << 7
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
.equ SYST_RVR_VALUE, 8000000 - 1

.global start

Vector_Table:              /* Vector                       Exception Nr */
  .word     0x20002000     /* Initial Stack Pointer value             - */
ResetHandler:              /* Reset                                   1 */
  .word     start + 1 

start:
  bl gpio_init
  bl systick_init

main_loop:
  bl systick_wait_clock_cycles
  bl turn_led_on
  bl systick_wait_clock_cycles
  bl turn_led_off
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
  mov r2, #(SYST_CSR_CLK_SOURCE + SYST_CSR_ENABLE)
  str r2, [r1]

  bx lr

systick_wait_clock_cycles:
  ldr r1, =SYST_CSR

count_flag_wait:
  ldr r3, [r1]
  ldr r2, =SYST_CSR_COUNT_FLAG
  and r3, r3, r2
  beq count_flag_wait   /* COUNT_FLAG will be 1 only if the timer counted to zero since the last read */
  bx lr

gpio_init:
  /* Enable Port C clock */
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTC_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOC_MODER
  ldr r2, =GPIOC_MODER_MASK
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr

turn_led_on:
  ldr r1,=GPIOC_BSRR
  ldr r2,=BSRR_9_SET
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
  bx lr

turn_led_off:
  ldr r1,=GPIOC_BSRR
  ldr r2,=BSRR_9_RESET
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
  bx lr
