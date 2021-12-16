.thumb
.text

//.equ SPI1_BASE, 0x40013000
.equ SPI2_BASE, 0x40003800
.equ RCC_BASE, 0x40021000
//.equ GPIOA_BASE, 0x48000000
.equ GPIOB_BASE, 0x48000400
.equ GPIOC_BASE, 0x48000800

.equ SPI_CR1_OFFSET, 0x00
.equ SPI_SR_OFFSET, 0x08
.equ SPI_DR_OFFSET, 0x0C
.equ SPI_CR2_OFFSET, 0x04

/*
.equ SPI1_CR1, SPI1_BASE + SPI_CR1_OFFSET
.equ SPI1_SR, SPI1_BASE + SPI_SR_OFFSET
.equ SPI1_DR, SPI1_BASE + SPI_DR_OFFSET
.equ SPI1_CR2, SPI1_BASE + SPI_CR2_OFFSET
*/

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

/*
.equ GPIOA_MODER, GPIOA_BASE + GPIO_MODER_OFFSET
.equ GPIOA_OSPEEDR, GPIOA_BASE + GPIO_OSPEEDR_OFFSET
.equ GPIOA_ODR, GPIOA_BASE + GPIO_ODR_OFFSET
.equ GPIOA_AFRL, GPIOA_BASE + GPIO_AFRL_OFFSET
.equ GPIOA_OTYPER, GPIOA_BASE + GPIO_OTYPER_OFFSET
.equ GPIOA_PUPDR, GPIOA_BASE + GPIO_PUPDR_OFFSET
.equ GPIOA_BSRR, GPIOA_BASE + GPIO_BSRR_OFFSET
*/

.equ GPIOB_MODER, GPIOB_BASE + GPIO_MODER_OFFSET
.equ GPIOB_OSPEEDR, GPIOB_BASE + GPIO_OSPEEDR_OFFSET
.equ GPIOB_ODR, GPIOB_BASE + GPIO_ODR_OFFSET
.equ GPIOB_AFRL, GPIOB_BASE + GPIO_AFRL_OFFSET
.equ GPIOB_AFRH, GPIOB_BASE + GPIO_AFRH_OFFSET
.equ GPIOB_OTYPER, GPIOB_BASE + GPIO_OTYPER_OFFSET
.equ GPIOB_PUPDR, GPIOB_BASE + GPIO_PUPDR_OFFSET
.equ GPIOB_BSRR, GPIOB_BASE + GPIO_BSRR_OFFSET

.equ GPIOC_MODER, GPIOC_BASE + GPIO_MODER_OFFSET
.equ GPIOC_OSPEEDR, GPIOC_BASE + GPIO_OSPEEDR_OFFSET
.equ GPIOC_ODR, GPIOC_BASE + GPIO_ODR_OFFSET
.equ GPIOC_AFRL, GPIOC_BASE + GPIO_AFRL_OFFSET
.equ GPIOC_OTYPER, GPIOC_BASE + GPIO_OTYPER_OFFSET
.equ GPIOC_PUPDR, GPIOC_BASE + GPIO_PUPDR_OFFSET
.equ GPIOC_BSRR, GPIOC_BASE + GPIO_BSRR_OFFSET

.equ GPIO_BSRR_NSS_SET, 1 << 9
.equ GPIO_BSRR_NSS_RESET, 1 << 25

.equ SPI_CR1_MASTER, 1 << 2
.equ SPI_SR_BSY_FLAG, 1 << 7
.equ SPI_SR_TXE_EMPTY, 1 << 1
.equ SPI_CR_SPE, 1 << 6

.equ SPI_CR1_SSM, 0 << 9
.equ SPI_CR1_SSI, 1 << 8
.equ SPI_CR2_SSOE, 1 << 2

.equ GPIOA_ODR_PA4_LOW, 0 << 4
.equ GPIOA_ODR_PA4_HIGH, 1 << 4

.equ NSS_MODER, 1 << 18
.equ NSS_OTYPER, 1 << 9
.equ NSS_OSPEEDR, 0 << 18
.equ NSS_PUPDR, 0x01 << 18
.equ NSS_AFRH, 5 << 4

.equ SCL_MODER, 2 << 20
.equ SCL_OTYPER, 0 << 10
.equ SCL_OSPEEDR, 0 << 20
.equ SCL_PUPDR, 0 << 20
.equ SCL_AFRH, 5 << 8

.equ CIPO_MODER, 2 << 4
.equ CIPO_OTYPER, 0 << 2
.equ CIPO_OSPEEDR, 0 << 4
.equ CIPO_PUPDR, 0x00 << 4
.equ CIPO_AFRL, 1 << 8

.equ COPI_MODER, 2 << 6
.equ COPI_OTYPER, 0 << 3
.equ COPI_OSPEEDR, 3 << 6
.equ COPI_PUPDR, 2 << 6
.equ COPI_AFRL, 1 << 12

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  bl spi_init
  bl spi_controller_init
  bl led_init

  ldr r1,=GPIOC_BSRR
  ldr r2,=GPIO_BSRR_NSS_SET
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1,=GPIOC_BSRR
  ldr r2,=GPIO_BSRR_NSS_RESET
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

main_loop:
  ldr r1, =SPI2_SR
  ldr r2, =SPI_SR_TXE_EMPTY
wait_txe_flag:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_txe_flag

  bl turn_led_on

  /* Write to data register */
  ldr r1, =SPI2_DR
  ldr r2, =#0x41
  str r2, [r1]

  /* Read the data register */
  //ldr r1, =SPI_DR
  //ldr r0, [r1]

wait_busy_flag:
  ldr r1, =SPI2_SR
  ldr r2, =SPI_SR_BSY_FLAG
  and r0, r0, r2
  cmp r0, r2
  bne wait_busy_flag

  bl delay
  bl delay
  bl turn_led_off

/*
  ldr r1,=GPIOA_BSRR
  ldr r2,=GPIO_BSRR_4_SET
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/

/*
  ldr r1, =GPIOA_ODR
  ldr r2, =GPIOA_ODR_PA4_HIGH
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/  
  b main_loop

spi_controller_init:
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

  ldr r1, =GPIOB_OSPEEDR
  ldr r2, =NSS_OSPEEDR
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

  /* SCL (Select Clock) */
  ldr r1, =GPIOB_MODER
  ldr r2, =SCL_MODER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_OTYPER
  ldr r2, =SCL_OTYPER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_OSPEEDR
  ldr r2, =SCL_OSPEEDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_PUPDR
  ldr r2, =SCL_PUPDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_AFRH
  ldr r2, =SCL_AFRH
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Controller Input Peripheral Output (CIPO) */
  ldr r1, =GPIOC_MODER
  ldr r2, =COPI_MODER
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

  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR1_SSM
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR1_SSI
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR2
  ldr r2, =SPI_CR2_SSOE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set SPI as the controller */
  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR1_MASTER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR_SPE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
