/* LED external example */
.thumb
.text

.equ RCC_BASE, 0x40021000
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ GPIOA_BASE, 0x48000000

.equ GPIOA_MODER_OFFSET, 0x00
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

.equ GPIOA_OTYPER_OFFSET, 0x04
.equ GPIOA_OTYPER, GPIOA_BASE + GPIOA_OTYPER_OFFSET

.equ GPIOA_IDR_OFFSET, 0x10
.equ GPIOA_IDR, GPIOA_BASE + GPIOA_IDR_OFFSET

.equ GPIOA_ODR_OFFSET, 0x14
.equ GPIOA_ODR, GPIOA_BASE + GPIOA_ODR_OFFSET

.equ GPIOA_PUPDR_OFFSET, 0x0C
.equ GPIOA_PUPDR, GPIOA_BASE + GPIOA_PUPDR_OFFSET

.equ GPIOA_SPEEDR_OFFSET, 0x08
.equ GPIOA_SPEEDR, GPIOA_BASE + GPIOA_SPEEDR_OFFSET

.equ GPIO_PORTA_ENABLE, 1 << 17
.equ GPIOA_MODER_PA4, 1 << 8
.equ GPIOA_OTYPER_PA4, 0 << 4
.equ GPIOA_SPEEDR_PA4, 1 << 8
.equ GPIOA_PUPDR_PA4, 0x00 << 8
.equ GPIOA_IDR_PA4, 1 << 4
.equ GPIOA_ODR_PA4, 1 << 4

.global start

Vector_Table:    
  .word     0x20002000
  .word     start + 1

start:
  bl pull_up_pin_init

main_loop:
  bl delay

  ldr r1, =GPIOA_ODR
  ldr r2, =GPIOA_ODR_PA4
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bl delay

  ldr r1, =GPIOA_ODR
  ldr r2, =GPIOA_ODR_PA4
  ldr r0, [r1]
  bic r0, r0, r2
  str r0, [r1]
  
  b main_loop

pull_up_pin_init:
  /* Enable Port A clock */
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTA_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]

  ldr r1, =GPIOA_MODER
  ldr r2, =GPIOA_MODER_PA4
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_OTYPER
  ldr r2, =GPIOA_OTYPER_PA4
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_PUPDR
  ldr r2, =GPIOA_PUPDR_PA4
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_SPEEDR
  ldr r2, =GPIOA_SPEEDR_PA4
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
