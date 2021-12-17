/*
Serial Peripheral Interface (SPI) common code for controllers and
peripherals.
*/
.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

.equ SPI2_BASE, 0x40003800

.equ SPI_CR1_OFFSET, 0x00
.equ SPI_CR2_OFFSET, 0x04

.equ SPI2_CR1, SPI2_BASE + SPI_CR1_OFFSET
.equ SPI2_CR2, SPI2_BASE + SPI_CR2_OFFSET

/* Advanced Peripheral Bus 2 clock Enable Register */
.equ APB2ENR_OFFSET, 0x18
.equ RCC_APB2ENR, RCC_BASE + APB2ENR_OFFSET

/* Advanced Peripheral Bus Enable Register offset (from RCC) */
.equ APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + APB1ENR_OFFSET

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ GPIO_PORTA_ENABLE, 1 << 17
.equ GPIO_PORTB_ENABLE, 1 << 18
.equ GPIO_PORTC_ENABLE, 1 << 19
.equ RCC_APB_SPI2EN, 1 << 14

.equ SPI_CR2_DS, 0x07 << 8             /* Data Size: 8-bit data              */
.equ SPI_CR2_FRXTH, 0 << 12            /* FIFO RX Threshold (8-bits)         */
.equ SPI_CR1_LSBFIRST, 0 << 7          /* Frame format                       */
.equ SPI_CR1_BR, 0x1 << 3              /* Baud Rate prescalar                */
.equ SPI_CR1_CPOL, 0 << 1              /* Clock Polarity                     */
.equ SPI_CR1_CPHA, 1 << 0              /* Clock Phase                        */

.global spi_init

spi_init:
  /* Enable SPI2 clock */
  ldr r1, =RCC_APB1ENR
  ldr r2, =RCC_APB_SPI2EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTC_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTB_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR1_BR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =(SPI_CR1_CPOL + SPI_CR1_CPHA)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR1_LSBFIRST
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR2
  ldr r2, =SPI_CR2_DS
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR2
  ldr r2, =SPI_CR2_FRXTH
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
