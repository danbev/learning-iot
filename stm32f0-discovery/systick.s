.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000
/* Univeral Serial Asynchronous Receiver Transmitter Base address */
.equ USART1_BASE, 0x40013800
/* General Purpose IO Port A base register */
.equ GPIOA_BASE, 0x48000000
/* SysTick Control and Status Register */
.equ SYST_CSR, 0xE000E010
/* SysTick Reload Value Register */
.equ SYST_RVR, 0xE000E014
/* SysTick Current Value Register */
.equ SYST_CVR, 0xE000E018
/* SysTick Calibration Value Register */
.equ SYST_CALIB, 0xE000E01C

/* Advanced Peripheral Bus 1 Enable Register Offset (from RCC_BASE) */
.equ RCC_APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + RCC_APB1ENR_OFFSET

.equ RCC_APB2ENR_OFFSET, 0x18
.equ RCC_APB2ENR, RCC_BASE + RCC_APB2ENR_OFFSET

/* Mode Register Offset for Port A (from GPIO_BASE) */
.equ GPIOA_MODER_OFFSET, 0x00
/* Mode Register for GPIO Port A */
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

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
.equ SYST_CSR_CLK_SOURCE, 1 << 3
/* 0 = does not assert the SysTick exception (interrupt),
   1 = does assert the SysTick exception (interrupt). */
.equ SYST_CSR_TICKINT, 1 << 1
/* Determines if the timer has counted down to zero since last read. */
.equ SYST_CSR_COUNT_FLAG, 1 << 16
/* 24 bits is the max number of bits for the reload value */
.equ SYST_RVR_VALUE, 0x00FFFFFF

.equ TEN_MS, 160000

.global start

Vector_Table:    
  .word     0x20002000

ResetVector:
  .word     start + 1

start:
  bl gpio_init
  bl systick_init
main_loop:
  mov r0, #100
  bl systick_wait_ten_ms
  bl turn_led_on
  bl systick_wait_ten_ms
  bl turn_led_off
  b main_loop

/* The passed in argument in r0 is the number of clock cycles to wait */
systick_wait:
  ldr r1, =SYST_RVR
  sub r0, #1
  str r0, [r1]
  ldr r1, =SYST_CSR

wait_loop:
  ldr r3, [r1]
  ldr r2, =#0x0001
  and r3, r3, r2
  beq wait_loop   /* COUNT_FLAG will be 1 only if the timer counted to zero since the last read */
  bx lr

systick_wait_ten_ms:
  mov r4, r0 
  BEQ done
wait_loop2:
  ldr r0, =TEN_MS
  bl systick_wait
  sub r4, #1
  bhi wait_loop2

done:
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

systick_init:
  ldr r1, =SYST_CSR
  /* start by clearning the SysTick Control Register */
  mov r0, #0
  str r0, [r1]

  ldr r1, =SYST_RVR
  ldr r0, =SYST_RVR_VALUE
  str r0, [r1]

  /* Current Value Register */
  ldr r1, =SYST_CVR
  mov r0, #0
  str r0, [r1]

  ldr r1, =SYST_CSR
  mov r0, #(SYST_CSR_CLK_SOURCE + SYST_CSR_ENABLE)
  str r0, [r1]

/*
  ldr r2, =SYST_CSR_CLK_SOURCE
  orr r0, r0, r2

  ldr r2, =SYST_CSR_ENABLE
  orr r0, r0, r2

  ldr r2, =SYST_CSR_ENABLE
  orr r0, r0, r2

  ldr r2, =SYST_CSR_TICKINT
  orr r0, r0, r2
  str r0, [r1]
*/

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

.equ DELAY_LENGTH, 100000
delay:
  ldr r0,=DELAY_LENGTH
dloop:
  sub r0, r0, #1
  bne dloop      /* branch while the Z (zero) flag is not equal to zero */
  bx  lr
