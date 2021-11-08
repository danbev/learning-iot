.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000
/* Univeral Serial Asynchronous Receiver Transmitter Base address */
.equ USART2_BASE, 0x40004400
/* General Purpose IO Port A base register */
.equ GPIOA_BASE, 0x48000000
/* Advanced Peripheral Bus 1 Enable Register Offset (from RCC_BASE) */
.equ RCC_APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + RCC_APB1ENR_OFFSET
.equ USART2_EN, 1 << 17
/* Mode Register Offset for Port A (from GPIO_BASE) */
.equ GPIOA_MODER_OFFSET, 0x00
/* Mode Register for GPIO Port A */
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

/* Alternate Function Register Low */
.equ GPIOA_AFRL_OFFSET, 0x20
.equ GPIOA_AFRL, GPIOA_BASE + GPIOA_AFRL_OFFSET

.equ AFSEL0_AF1, 1 << 1   /* PA0 USART2_CTS */
.equ AFSEL1_AF1, 1 << 4   /* PA1 USART2_RTS */
.equ AFSEL2_AF1, 1 << 8   /* PA2 USART2_TX  */
.equ AFSEL3_AF1, 1 << 12  /* PA3 USART2_RX */
.equ AFSEL4_AF1, 1 << 16  /* PA3 USART2_CK */

.equ CR1_OFFSET, 0x00
.equ CR1, USART2_BASE + CR1_OFFSET
.equ CR2_OFFSET, 0x04
.equ CR2, USART2_BASE + CR2_OFFSET
.equ CR3_OFFSET, 0x08
.equ CR3, USART2_BASE + CR3_OFFSET
.equ BRR_OFFSET, 0x0C
.equ BRR, USART2_BASE + BRR_OFFSET
.equ DATAR_OFFSET, 0x28
.equ DATAR, USART2_BASE + DATAR_OFFSET
.equ ISR_OFFSET, 0x1C
.equ ISR, USART2_BASE + ISR_OFFSET

.global _start

_start:
  b _start
