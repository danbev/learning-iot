.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

.equ I2C1_BASE, 0x40005400
.equ GPIOA_BASE, 0x48000000

.equ APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + APB1ENR_OFFSET

.equ GPIOA_MODER_OFFSET, 0x00
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

.equ GPIOA_AFRL_OFFSET, 0x20
.equ GPIOA_AFRL, GPIOA_BASE + GPIOA_AFRL_OFFSET

.equ I2C1_CR1_OFFSET, 0x00
.equ I2C1_CR1, I2C1_BASE + I2C1_CR1_OFFSET

.equ I2C1_CR2_OFFSET, 0x04
.equ I2C1_CR2, I2C1_BASE + I2C1_CR2_OFFSET

.equ RCC_APB1_I2C1EN, 1 << 21
.equ GPIOA_ALT_PA6, 1 << 12
.equ GPIOA_ALT_PA7, 1 << 14
.equ GPIOA_AF1_PA6, 1 << 24
.equ GPIOA_AF1_PA7, 1 << 28
.equ I2C1_PE, 1 << 0

.global i2c_init

i2c_init:
  /* Clock enable I2C1 */
  ldr r1, =RCC_APB1ENR
  ldr r2, =RCC_APB1_I2C1EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_MODER
  ldr r2, =(GPIOA_ALT_PA6 + GPIOA_ALT_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_AFRL
  ldr r2, =(GPIOA_AF1_PA6 + GPIOA_AF1_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =I2C1_CR1
  ldr r2, =I2C1_PE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]