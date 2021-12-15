/*
PA4  NSS (chip/peripheral select)
PA5  Clock select
PA6  CIPO
PA7  COPI
*/
.thumb
.text

.equ SPI1_BASE, 0x40013000
.equ GPIOA_BASE, 0x48000000

.equ SPI1_CR1_OFFSET, 0x00
.equ SPI1_CR1, SPI1_BASE + SPI1_CR1_OFFSET

.equ SPI1_SR_OFFSET, 0x08
.equ SPI1_SR, SPI1_BASE + SPI1_SR_OFFSET

.equ SPI1_DR_OFFSET, 0x0C
.equ SPI1_DR, SPI1_BASE + SPI1_DR_OFFSET

.equ SPI1_CR2_OFFSET, 0x04
.equ SPI1_CR2, SPI1_BASE + SPI1_CR2_OFFSET

.equ GPIOA_OTYPER_OFFSET, 0x04
.equ GPIOA_OTYPER, GPIOA_BASE + GPIOA_OTYPER_OFFSET

.equ GPIOA_MODER_OFFSET, 0x00
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

.equ GPIOA_PUPDR_OFFSET, 0x0C
.equ GPIOA_PUPDR, GPIOA_BASE + GPIOA_PUPDR_OFFSET

.equ GPIOA_OSPEEDR_OFFSET, 0x08
.equ GPIOA_OSPEEDR, GPIOA_BASE + GPIOA_OSPEEDR_OFFSET

.equ GPIOA_AFRL_OFFSET, 0x20
.equ GPIOA_AFRL, GPIOA_BASE + GPIOA_AFRL_OFFSET

/* PA4 Peripheral Select (NSS) */
.equ GPIOA_MODER_PA4, 2 << 8
.equ GPIOA_OTYPER_PA4, 0 << 4
.equ GPIOA_PUPDR_PA4, 0x01 << 8
.equ GPIOA_AFRL_PA4, 0x00 << 16

/* PA5 Clock Select (SCK) */
.equ GPIOA_MODER_PA5, 2 << 10
.equ GPIOA_OTYPER_PA5, 0 << 5
.equ GPIOA_OSPEEDR_PA5, 0 << 10
.equ GPIOA_PUPDR_PA5, 0x01 << 10
.equ GPIOA_AFRL_PA5, 0x00 << 20

/* PA6 Controller Input Peripheral Output (CIPO) */
.equ GPIOA_MODER_PA6, 2 << 12
.equ GPIOA_OTYPER_PA6, 0 << 6
.equ GPIOA_OSPEEDR_PA6, 0 << 12
.equ GPIOA_PUPDR_PA6, 0x01 << 12
.equ GPIOA_AFRL_PA6, 0x00 << 24

/* PA7 Controller Output Peripheral Input (COPI) */
.equ GPIOA_MODER_PA7, 2 << 14      /* Alternate function mode             */
.equ GPIOA_OTYPER_PA7, 0 << 7
.equ GPIOA_OSPEEDR_PA7, 0 << 14
.equ GPIOA_PUPDR_PA7, 0x01 << 14
.equ GPIOA_AFRL_PA7, 0x00 << 28

.equ SPI_CR1_PERIPHERAL, 0 << 2
.equ SPI_SR_RXE, 1 << 0
.equ SPI_CR_SPE, 1 << 6

.equ SPI_CR1_SSM, 0 << 9
.equ SPI_CR2_SSOE, 0 << 2
.equ GPIOA_IDR_PA4_LOW, 0 << 4
.equ GPIOA_IDR_PA4_HIGH, 1 << 4
.equ GPIOA_ODR_PA4_LOW, 0 << 4
.equ GPIOA_ODR_PA4_HIGH, 1 << 4

.equ GPIOA_IDR_OFFSET, 0x10
.equ GPIOA_IDR, GPIOA_BASE + GPIOA_IDR_OFFSET

.equ GPIOA_ODR_OFFSET, 0x14
.equ GPIOA_ODR, GPIOA_BASE + GPIOA_ODR_OFFSET

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
  bl turn_led_on
  ldr r1, =SPI1_SR

wait_nss:
  ldr r1, =GPIOA_ODR
  ldr r2, =GPIOA_ODR_PA4_HIGH
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  beq wait_nss

wait_rxe_flag:
  ldr r1, =SPI1_SR
  ldr r2, =SPI_SR_RXE
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_rxe_flag

  /* Read the data register */
  ldr r1, =SPI1_DR
  ldr r0, [r1]
  bl uart_write_char

  bl delay
  bl turn_led_off
  
  b main_loop


spi_peripheral_init:
  /* PA4 NSS/Peripheral select */
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

  ldr r1, =GPIOA_AFRL
  ldr r2, =GPIOA_AFRL_PA4
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* PA5 SCK (Select Clock) */
  ldr r1, =GPIOA_MODER
  ldr r2, =GPIOA_MODER_PA5
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_OTYPER
  ldr r2, =GPIOA_OTYPER_PA5
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_OSPEEDR
  ldr r2, =GPIOA_OSPEEDR_PA5
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_PUPDR
  ldr r2, =GPIOA_PUPDR_PA6
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_AFRL
  ldr r2, =GPIOA_AFRL_PA5
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* PA6 Controller Output Peripheral Input (COPI) */
  ldr r1, =GPIOA_MODER
  ldr r2, =GPIOA_MODER_PA6
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_OTYPER
  ldr r2, =GPIOA_OTYPER_PA6
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_OSPEEDR
  ldr r2, =GPIOA_OSPEEDR_PA6
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_PUPDR
  ldr r2, =GPIOA_PUPDR_PA6
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_AFRL
  ldr r2, =GPIOA_AFRL_PA6
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* PA7 Controller Input Peripheral Output (CIPO) */
  ldr r1, =GPIOA_MODER
  ldr r2, =GPIOA_MODER_PA7
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_OTYPER
  ldr r2, =GPIOA_OTYPER_PA7
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_OSPEEDR
  ldr r2, =GPIOA_OSPEEDR_PA7
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_PUPDR
  ldr r2, =GPIOA_PUPDR_PA7
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_AFRL
  ldr r2, =GPIOA_AFRL_PA7
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR1
  ldr r2, =SPI_CR1_SSM
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR2
  ldr r2, =SPI_CR2_SSOE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set SPI as a peripheral */
  ldr r1, =SPI1_CR1
  ldr r2, =SPI_CR1_PERIPHERAL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI1_CR1
  ldr r2, =SPI_CR_SPE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
