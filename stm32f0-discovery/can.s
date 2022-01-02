/*
Controller Area Network (CAN)
*/
.thumb
.text

.equ RCC_BASE, 0x40021000
.equ CAN_BASE, 0x40006400
.equ GPIOA_BASE, 0x48000000
.equ GPIOB_BASE, 0x48000400

.equ GPIO_MODER_OFFSET, 0x00
.equ GPIO_AFRH_OFFSET, 0x24

.equ GPIOA_MODER, GPIOA_BASE + GPIO_MODER_OFFSET
.equ GPIOA_AFRH, GPIOA_BASE + GPIO_AFRH_OFFSET

.equ GPIOB_MODER, GPIOB_BASE + GPIO_MODER_OFFSET
.equ GPIOB_AFRH, GPIOB_BASE + GPIO_AFRH_OFFSET

.equ APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + APB1ENR_OFFSET

.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ RCC_APB1ENR_CAN, 1 << 25
.equ GPIO_PORTA_ENABLE, 1 << 17
.equ GPIO_PORTB_ENABLE, 1 << 18

.equ GPIOB_MODER_8, 2 << 16         /* PB8 CAN_RX */
.equ GPIOB_MODER_9, 2 << 18         /* PB9 CAN_TX */
.equ GPIOB_AFRH_PB8_AF4, 4 << 0
.equ GPIOB_AFRH_PB9_AF4, 4 << 4

.equ GPIOA_MODER_11, 2 << 22
.equ GPIOA_MODER_12, 2 << 24
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

  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTB_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]

  ldr r1, =GPIOB_MODER
  ldr r2, =(GPIOB_MODER_8 + GPIOB_MODER_9)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_AFRH
  ldr r2, =(GPIOB_AFRH_PB8_AF4 + GPIOB_AFRH_PB9_AF4)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

/*
  ldr r1, =GPIOA_MODER
  ldr r2, =(GPIOA_MODER_11 + GPIOA_MODER_12)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_AFRH
  ldr r2, =(GPIOA_AFRH_PA11_AF4 + GPIOA_AFRH_PA11_AF4)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/

  bx lr
