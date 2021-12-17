/*
Serial Peripheral Interface (SPI) Peripheral.
*/
.thumb
.text

.equ SPI2_BASE, 0x40003800
.equ RCC_BASE, 0x40021000
.equ GPIOA_BASE, 0x48000000
.equ GPIOB_BASE, 0x48000400
.equ GPIOC_BASE, 0x48000800

.equ SPI_CR1_OFFSET, 0x00
.equ SPI_SR_OFFSET, 0x08
.equ SPI_DR_OFFSET, 0x0C
.equ SPI_CR2_OFFSET, 0x04

.equ SPI2_CR1, SPI2_BASE + SPI_CR1_OFFSET
.equ SPI2_SR, SPI2_BASE + SPI_SR_OFFSET
.equ SPI2_DR, SPI2_BASE + SPI_DR_OFFSET
.equ SPI2_CR2, SPI2_BASE + SPI_CR2_OFFSET

.equ GPIO_MODER_OFFSET, 0x00
.equ GPIO_OTYPER_OFFSET, 0x04
.equ GPIO_OSPEEDR_OFFSET, 0x08
.equ GPIO_ODR_OFFSET, 0x14
.equ GPIO_BSRR_OFFSET, 0x18
.equ GPIO_PUPDR_OFFSET, 0x0C
.equ GPIO_AFRL_OFFSET, 0x20
.equ GPIO_AFRH_OFFSET, 0x24
.equ GPIO_IDR_OFFSET, 0x10

.equ GPIOB_MODER, GPIOB_BASE + GPIO_MODER_OFFSET
.equ GPIOB_OSPEEDR, GPIOB_BASE + GPIO_OSPEEDR_OFFSET
.equ GPIOB_ODR, GPIOB_BASE + GPIO_ODR_OFFSET
.equ GPIOB_AFRL, GPIOB_BASE + GPIO_AFRL_OFFSET
.equ GPIOB_AFRH, GPIOB_BASE + GPIO_AFRH_OFFSET
.equ GPIOB_OTYPER, GPIOB_BASE + GPIO_OTYPER_OFFSET
.equ GPIOB_PUPDR, GPIOB_BASE + GPIO_PUPDR_OFFSET
.equ GPIOB_BSRR, GPIOB_BASE + GPIO_BSRR_OFFSET
.equ GPIOB_IDR, GPIOB_BASE + GPIO_IDR_OFFSET

.equ GPIOC_MODER, GPIOC_BASE + GPIO_MODER_OFFSET
.equ GPIOC_OSPEEDR, GPIOC_BASE + GPIO_OSPEEDR_OFFSET
.equ GPIOC_ODR, GPIOC_BASE + GPIO_ODR_OFFSET
.equ GPIOC_AFRL, GPIOC_BASE + GPIO_AFRL_OFFSET
.equ GPIOC_OTYPER, GPIOC_BASE + GPIO_OTYPER_OFFSET
.equ GPIOC_PUPDR, GPIOC_BASE + GPIO_PUPDR_OFFSET
.equ GPIOC_BSRR, GPIOC_BASE + GPIO_BSRR_OFFSET


/* Peripheral Select (NSS) */
.equ NSS_MODER, 1 << 18
.equ NSS_OTYPER, 1 << 9
.equ NSS_PUPDR, 0x00 << 18
.equ NSS_AFRH, 5 << 4

/* Clock Select (SCK) */
.equ SCK_MODER, 2 << 20
.equ SCK_OTYPER, 1 << 10
.equ SCK_OSPEEDR, 0 << 20
.equ SCK_PUPDR, 0x00 << 20
.equ SCK_AFRH, 5 << 8

/* Controller Input Peripheral Output (CIPO) */
.equ CIPO_MODER, 2 << 4
.equ CIPO_OTYPER, 0 << 2
.equ CIPO_OSPEEDR, 0 << 4
.equ CIPO_PUPDR, 0x00 << 4
.equ CIPO_AFRL, 1 << 8

/* Controller Output Peripheral Input (COPI) */
.equ COPI_MODER, 2 << 6
.equ COPI_OTYPER, 1 << 3
.equ COPI_OSPEEDR, 0 << 6
.equ COPI_PUPDR, 0x00 << 6
.equ COPI_AFRL, 1 << 12

.equ SPI_CR1_PERIPHERAL, 0 << 2
.equ SPI_SR_RXE, 1 << 0
.equ SPI_CR_SPE, 1 << 6

.equ GPIO_IDR_NSS_LOW, 0 << 9

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  bl spi_init
  bl spi_peripheral_init
  bl uart_init
  bl led_init

main_loop:
  bl delay

wait_nss:
  ldr r1, =GPIOB_IDR
  ldr r2, =GPIO_IDR_NSS_LOW
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_nss

  bl turn_led_on

wait_rxe_flag:
  ldr r1, =SPI2_SR
  ldr r2, =SPI_SR_RXE
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_rxe_flag

  /* Read the data register */
  ldr r1, =SPI2_DR
  ldr r0, [r1]
  bl uart_write_char

  bl delay
  bl turn_led_off
  
  b main_loop


spi_peripheral_init:
  /* NSS/Peripheral select */
  ldr r1, =GPIOB_MODER
  ldr r2, =NSS_MODER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_OTYPER
  ldr r2, =NSS_OTYPER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_PUPDR
  ldr r2, =NSS_PUPDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_AFRH
  ldr r2, =NSS_AFRH
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* SCK (Select Clock) */
  ldr r1, =GPIOB_MODER
  ldr r2, =SCK_MODER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_OTYPER
  ldr r2, =SCK_OTYPER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_OSPEEDR
  ldr r2, =SCK_OSPEEDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_PUPDR
  ldr r2, =SCK_PUPDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_AFRH
  ldr r2, =SCK_AFRH
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Controller Output Peripheral Input (COPI) */
  ldr r1, =GPIOC_MODER
  ldr r2, =COPI_MODER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOC_OTYPER
  ldr r2, =COPI_OTYPER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOC_OSPEEDR
  ldr r2, =COPI_OSPEEDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOC_PUPDR
  ldr r2, =COPI_PUPDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOC_AFRL
  ldr r2, =COPI_AFRL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Controller Input Peripheral Output (CIPO) */
  ldr r1, =GPIOC_MODER
  ldr r2, =CIPO_MODER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOC_OTYPER
  ldr r2, =CIPO_OTYPER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOC_OSPEEDR
  ldr r2, =CIPO_OSPEEDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOC_PUPDR
  ldr r2, =CIPO_PUPDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOC_AFRL
  ldr r2, =CIPO_AFRL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set SPI as a peripheral */
  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR1_PERIPHERAL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR_SPE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
