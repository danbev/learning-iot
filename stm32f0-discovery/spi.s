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

.equ SPI2_CR1_OFFSET, 0x00
.equ SPI2_CR1, SPI2_BASE + SPI2_CR1_OFFSET

.equ SPI2_CR2_OFFSET, 0x04
.equ SPI2_CR2, SPI2_BASE + SPI2_CR2_OFFSET

.equ SPI2_SR_OFFSET, 0x08
.equ SPI2_SR, SPI2_BASE + SPI2_SR_OFFSET

.equ SPI2_DR_OFFSET, 0x0C
.equ SPI2_DR, SPI2_BASE + SPI2_DR_OFFSET

.equ GPIOA_BASE, 0x48000000
.equ GPIOB_BASE, 0x48000400
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

.equ GPIOB_MODER_OFFSET, 0x00
.equ GPIOB_MODER, GPIOB_BASE + GPIOB_MODER_OFFSET

/* Alternate Function Register Low */
.equ GPIOA_AFRL_OFFSET, 0x20
.equ GPIOA_AFRL, GPIOA_BASE + GPIOA_AFRL_OFFSET

.equ GPIOB_AFRH_OFFSET, 0x24
.equ GPIOB_AFRH, GPIOB_BASE + GPIOB_AFRH_OFFSET

.equ GPIOA_OSPEED_OFFSET, 0x08
.equ GPIOA_OSPEED, GPIOA_BASE + GPIOA_OSPEED_OFFSET

.equ GPIOC_MODER_OFFSET, 0x00
.equ GPIOC_MODER, GPIOC_BASE + GPIOC_MODER_OFFSET

.equ GPIOC_BSRR_OFFSET, 0x18
.equ GPIOC_BSRR, GPIOC_BASE + GPIOC_BSRR_OFFSET

.equ GPIOC_ODR_OFFSET, 0x14
.equ GPIOC_ODR, GPIOC_BASE + GPIOC_ODR_OFFSET

.equ GPIOB_MODER_OFFSET, 0x00
.equ GPIOB_MODER, GPIOB_BASE + GPIOB_MODER_OFFSET

.equ GPIO_PORTC_ENABLE, 1 << 19
.equ GPIO_PORTA_ENABLE, 1 << 17
.equ GPIO_PORTB_ENABLE, 1 << 18
.equ GPIOC_MODER_MASK, 1 << 14
.equ GPIOC_ODR_PC7, 1 << 7
.equ BSRR_9_SET, 1 << 7
.equ BSRR_9_RESET, 1 << 23
.equ RCC_APB2_SPIEN, 1 << 12
.equ RCC_APB1_SPI2EN, 1 << 14

.equ GPIOA_ALT_PA4, 1 << 8         /* NSS (chip/peripheral select) */
.equ GPIOA_ALT_PA5, 2 << 10        /* Clock select                 */
.equ GPIOA_ALT_PA6, 2 << 12        /* CIPO                         */
.equ GPIOA_ALT_PA7, 2 << 14        /* COPI                         */

.equ GPIOA_AF0_PA5, 0x00 << 20
.equ GPIOA_AF0_PA6, 0x00 << 24
.equ GPIOA_AF0_PA7, 0x00 << 28

.equ GPIOA_SPEED_PA4, 3 << 8
.equ GPIOA_SPEED_PA5, 3 << 10
.equ GPIOA_SPEED_PA6, 3 << 12
.equ GPIOA_SPEED_PA7, 3 << 14

.equ GPIOB_ALT_PB12, 1 << 24        /* NSS (chip/peripheral select) */
.equ GPIOB_ALT_PB13, 2 << 26        /* Clock select                 */
.equ GPIOB_ALT_PB14, 2 << 28        /* CIPO                         */
.equ GPIOB_ALT_PB15, 2 << 30        /* COPI                         */
.equ GPIOB_AF0_PB12, 0x00 << 16
.equ GPIOB_AF0_PB13, 0x00 << 20
.equ GPIOB_AF0_PB14, 0x00 << 24
.equ GPIOB_AF0_PB15, 0x00 << 28


.equ SPI_CR1_MASTER, 1 << 2
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

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  bl gpio_init
  bl spi1_init
  //bl spi2_init

main_loop:
  bl delay
  ldr r1, =SPI1_SR
  ldr r2, =SPI_SR_TXE_EMPTY
wait_txe_flag:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_txe_flag

  bl turn_led_on

  /* Write to data register */
  ldr r1, =SPI1_DR
  mov r2, #0x41
  uxtb r3, r2 
  strb r2, [r1]

wait_busy_flag:
  ldr r1, =SPI1_SR
  ldr r2, =SPI_SR_BSY_FLAG
  and r0, r0, r2
  cmp r0, r2
  bne wait_busy_flag

/*
  ldr r1, =SPI1_DR
  ldrb r0, [r1]
  ldr r2, =SPI1_SR
  ldr r0, [r2]
*/

  bl delay
  bl turn_led_off
  
  b main_loop

spi1_init:
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

/*
  ldr r1, =GPIOA_OSPEED
  ldr r2, =(GPIOA_SPEED_PA4 + GPIOA_SPEED_PA5 + GPIOA_SPEED_PA6 + GPIOA_SPEED_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/

  /* Set SPI as the controller */
  ldr r1, =SPI1_CR1
  ldr r2, =SPI_CR1_MASTER
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

spi2_init:
  /* Enable SPI2 clock */
  ldr r1, =RCC_APB1ENR
  ldr r2, =RCC_APB1_SPI2EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTB_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_MODER
  ldr r2, =(GPIOB_ALT_PB12 + GPIOB_ALT_PB13 + GPIOB_ALT_PB14 + GPIOB_ALT_PB15)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_AFRH
  ldr r2, =(GPIOB_AF0_PB13 + GPIOB_AF0_PB14 + GPIOB_AF0_PB15)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR1_BR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =SPI_CR1_LSBFIRST
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =(SPI_CR1_SSM + SPI_CR1_SSI)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR1
  ldr r2, =(SPI_CR1_CPOL +  SPI_CR1_CPHA)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =SPI2_CR2
  ldr r2, =SPI_SSOE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

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
