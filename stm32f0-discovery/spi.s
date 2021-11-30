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

.equ SPI1_CR_OFFSET, 0x00
.equ SPI1_CR, SPI1_BASE + SPI1_CR_OFFSET

.equ SPI1_SR_OFFSET, 0x08
.equ SPI1_SR, SPI1_BASE + SPI1_SR_OFFSET

.equ SPI1_DR_OFFSET, 0x0C
.equ SPI1_DR, SPI1_BASE + SPI1_DR_OFFSET

.equ GPIOC_BASE, 0x48000800
.equ GPIOA_BASE, 0x48000000

/* Advanced Peripheral Bus 2 clock Enable Register */
.equ APB2ENR_OFFSET, 0x18
.equ RCC_APB2ENR, RCC_BASE + APB2ENR_OFFSET

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ GPIOA_MODER_OFFSET, 0x00
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

/* Alternate Function Register Low */
.equ GPIOA_AFRL_OFFSET, 0x24
.equ GPIOA_AFRL, GPIOA_BASE + GPIOA_AFRL_OFFSET

.equ GPIOC_MODER_OFFSET, 0x00
.equ GPIOC_MODER, GPIOC_BASE + GPIOC_MODER_OFFSET

.equ GPIOC_BSRR_OFFSET, 0x18
.equ GPIOC_BSRR, GPIOC_BASE + GPIOC_BSRR_OFFSET

.equ GPIOC_ODR_OFFSET, 0x14
.equ GPIOC_ODR, GPIOC_BASE + GPIOC_ODR_OFFSET

.equ GPIO_PORTC_ENABLE, 1 << 19
.equ GPIO_PORTA_ENABLE, 1 << 17
.equ GPIOC_MODER_MASK, 1 << 14
.equ GPIOC_ODR_PC7, 1 << 7
.equ BSRR_9_SET, 1 << 7
.equ BSRR_9_RESET, 1 << 23
.equ RCC_APB2_SPIEN, 1 << 12

.equ GPIOA_ALT_PA4, 1 << 8         /* NSS (chip/peripheral select) */
.equ GPIOA_ALT_PA5, 1 << 10        /* Clock select                 */
.equ GPIOA_ALT_PA6, 1 << 12        /* CIPO                         */
.equ GPIOA_ALT_PA7, 1 << 14        /* COPI                         */

.equ GPIOA_AF0_PA4, 0x00 << 16
.equ GPIOA_AF0_PA5, 0x00 << 20
.equ GPIOA_AF0_PA6, 0x00 << 24
.equ GPIOA_AF0_PA7, 0x00 << 28

.equ SPI1_MASTER, 1 << 2
.equ SPI1_SPE, 1 << 6
.equ SPI1_SR_BSY_FLAG, 1 << 7 
.equ SPI1_SR_TXE_EMPTY, 1 << 7 

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  bl gpio_init
  bl spi_init

main_loop:
  bl delay
  ldr r1, =SPI1_SR
  ldr r2, =SPI1_SR_BSY_FLAG
wait_busy_flag:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, #0x00
  bne wait_busy_flag

  bl turn_led_on

  /* Write to data register */
  ldr r1, =SPI1_DR
  mov r2, #0x41
  str r2, [r1]

  bl delay
  bl turn_led_off
  
  b main_loop

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
  ldr r2, =(GPIOA_AF0_PA4 + GPIOA_AF0_PA5 + GPIOA_AF0_PA6 + GPIOA_AF0_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set SPI as the controller */
  ldr r1, =SPI1_CR
  ldr r2, =(SPI1_MASTER)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Enable the SPI 1 Peripheral */
/*
  ldr r1, =SPI1_CR
  ldr r2, =(SPI1_SPE)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/

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

.include "blue-led.s"

.equ DELAY_LENGTH, 100000
delay:
  ldr r0,=DELAY_LENGTH
dloop:
  sub r0, r0, #1
  bne dloop      /* branch while the Z (zero) flag is not equal to zero */
  bx  lr
