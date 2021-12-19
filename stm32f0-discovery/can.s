/*
Controller Area Network (CAN)
*/
.thumb
.text

.equ RCC_BASE, 0x40021000
.equ CAN_BASE, 0x40006400
.equ GPIOA_BASE, 0x48000000

.equ GPIOA_MODER_OFFSET, 0x00
.equ GPIOA_AFRH_OFFSET, 0x24

.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET
.equ GPIOA_AFRH, GPIOA_BASE + GPIOA_AFRH_OFFSET

.equ APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + APB1ENR_OFFSET

.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ RCC_APB1ENR_CAN, 1 << 25
.equ GPIO_PORTA_ENABLE, 1 << 17

.equ GPIOA_MODER_11, 2 << 22
.equ GPIOA_MODER_12, 2 << 18
.equ GPIOA_AFRH_PA11_AF4, 4 << 12
.equ GPIOA_AFRH_PA12_AF4, 4 << 16

.global can_init, CAN_BASE

can_init:
  ldr r1, =RCC_APB1ENR
  ldr r2, =RCC_APB1ENR_CAN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTA_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]

  ldr r1, =GPIOA_MODER
  ldr r2, =(GPIOA_MODER_11 + GPIOA_MODER_12)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_AFRH
  ldr r2, =(GPIOA_AFRH_PA11_AF4 + GPIOA_AFRH_PA12_AF4)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
