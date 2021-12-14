/*
This example show how a SPI controller can be configured and will write
to the data register. The controller output pin in PA7 which can be connected
to an oscilloscope to see that data is written.
*/
.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

.equ SPI1_BASE, 0x40013000

.equ SPI1_CR1_OFFSET, 0x00
.equ SPI1_CR1, SPI1_BASE + SPI1_CR1_OFFSET

.equ SPI1_CR2_OFFSET, 0x04
.equ SPI1_CR2, SPI1_BASE + SPI1_CR2_OFFSET

.equ SPI1_SR_OFFSET, 0x08
.equ SPI1_SR, SPI1_BASE + SPI1_SR_OFFSET

.equ SPI2_BASE, 0x40003800

.equ SPI1_DR_OFFSET, 0x0C
.equ SPI1_DR, SPI1_BASE + SPI1_DR_OFFSET

.equ GPIOA_BASE, 0x48000000
.equ GPIOC_BASE, 0x48000800

/* Advanced Peripheral Bus 2 clock Enable Register */
.equ APB2ENR_OFFSET, 0x18
.equ RCC_APB2ENR, RCC_BASE + APB2ENR_OFFSET

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + APB1ENR_OFFSET

.equ GPIOA_MODER_OFFSET, 0x00
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

/* Alternate Function Register Low */
.equ GPIOA_AFRL_OFFSET, 0x20
.equ GPIOA_AFRL, GPIOA_BASE + GPIOA_AFRL_OFFSET

.equ GPIOA_OSPEED_OFFSET, 0x08
.equ GPIOA_OSPEED, GPIOA_BASE + GPIOA_OSPEED_OFFSET

.equ GPIO_PORTA_ENABLE, 1 << 17
.equ GPIOC_ODR_PC7, 1 << 7
.equ RCC_APB2_SPIEN, 1 << 12

.equ GPIOA_ALT_PA4, 1 << 8         /* NSS (chip/peripheral select) */
.equ GPIOA_ALT_PA5, 2 << 10        /* Clock select                 */
.equ GPIOA_ALT_PA6, 2 << 12        /* CIPO                         */
.equ GPIOA_ALT_PA7, 2 << 14        /* COPI                         */

.equ GPIOA_AF0_PA5, 0x00 << 20
.equ GPIOA_AF0_PA6, 0x00 << 24
.equ GPIOA_AF0_PA7, 0x00 << 28

.equ SPI_CR1_SSM, 1 << 9
.equ SPI_CR1_SSI, 1 << 8
.equ SPI_SSOE, 0 << 2
.equ SPI_CR2_DS, 7 << 8
.equ SPI_CR2_FRXTH, 1 << 12
.equ SPI_SR_BSY_FLAG, 1 << 7
.equ SPI_SR_TXE_EMPTY, 1 << 1
.equ SPI_CR1_LSBFIRST, 0 << 7
.equ SPI_CR1_BR, 0 << 3
//.equ SPI_CR1_BIDIOE, 1 << 14
.equ SPI_CR1_CPOL, 1 << 1
.equ SPI_CR1_CPHA, 1 << 0
.equ SPI_CR_SPE, 1 << 6

.global spi_init

spi_init:
  /* Enable SPI1 clock */
  ldr r1, =RCC_APB2ENR
  ldr r2, =RCC_APB2_SPIEN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Enable Port A clock */
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTA_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set alt function mode for PA4, PA5, PA6, and PA7 */
  ldr r1, =GPIOA_MODER
  ldr r2, =(GPIOA_ALT_PA4 + GPIOA_ALT_PA5 + GPIOA_ALT_PA6 + GPIOA_ALT_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set AF0 as the alternative functions for PA4, PA5, PA6, and PA7 */
  ldr r1, =GPIOA_AFRL
  ldr r2, =(GPIOA_AF0_PA5 + GPIOA_AF0_PA6 + GPIOA_AF0_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR1
  ldr r2, =SPI_CR1_BR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR1
  ldr r2, =SPI_CR1_LSBFIRST
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR1
  ldr r2, =(SPI_CR1_SSM + SPI_CR1_SSI)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR1
  ldr r2, =(SPI_CR1_CPOL +  SPI_CR1_CPHA)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR1
  ldr r2, =SPI_CR_SPE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR2
  ldr r2, =SPI_CR2_DS
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR2
  ldr r2, =SPI_CR2_FRXTH
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
