.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000
/* Univeral Serial Asynchronous Receiver Transmitter Base address */
.equ USART2_BASE, 0x40004400
/* General Purpose IO Port A base register */
.equ GPIOA_BASE, 0x48000000
.equ GPIO_PORTA_ENABLE, 1 << 17
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
.equ USART2_CR1_OFFSET, 0x00
.equ USART2_CR1, USART2_BASE + USART2_CR1_OFFSET
.equ USART2_CR2_OFFSET, 0x04
.equ USART2_CR2, USART2_BASE + USART2_CR2_OFFSET
.equ USART2_CR3_OFFSET, 0x08
.equ USART2_CR3, USART2_BASE + USART2_CR3_OFFSET
.equ USART2_BRR_OFFSET, 0x0C
.equ USART2_BRR, USART2_BASE + USART2_BRR_OFFSET
.equ USART2_DATAR_OFFSET, 0x28
.equ USART2_DATAR, USART2_BASE + USART2_DATAR_OFFSET
.equ USART2_ISR_OFFSET, 0x1C
.equ USART2_ISR, USART2_BASE + USART2_ISR_OFFSET

.equ GPIOA_ALT_SLT, 1 << 7 /* 10 00 0000 0000 */
/* Set AF1 for PA2  */
.equ AF1, 1 << 8      /* 0001 0000 0000 */

.equ BRR_CNF, 0x683    /* 0110 1000 0011. 9600 */
.equ CR1_CNF, 0x0008   /* 0000 0000 1000 = TE (Transmitter Enable)*/
.equ CR2_CNF, 0x0000   /* bits 13-12 are stop bits 00=1 stop bit */
.equ CR3_CNF, 0x0000   /* No flow control */
.equ USART2_CR1_EN, 0x2000 /* 0010 0000 0000 0000 */
.equ TX_BUF_FLAG, 0x0007   /* 0000 0000 0000 0111 Not sure about this value? */

.global _start

_start:
  bl uart_init
  mov r0, #'A' /* hex: 0x41 */
main_loop:
  bl uart_write_char
  b main_loop

uart_init:
  /* Clock enable GPIOA */
  ldr r0, =RCC_APB1ENR
  ldr r1, =GPIO_PORTA_ENABLE
  ldr r2, [r0]
  orr r1, r1, r2 
  str r1, [r0]
  /* Enable USART2 */
  ldr r0, =RCC_APB1ENR
  ldr r1, =USART2_EN
  ldr r2, [r0]
  orr r1, r1, r2 
  str r1, [r0]
  /* Set AF1 for GPIO Port A Pin 3 */ 
  ldr r0, =GPIOA_AFRL
  ldr r1, =AFSEL3_AF1
  ldr r2, [r0]
  orr r1, r1, r2
  str r1, [r0]
  /* Enable Alternative function mode for GPIO PA3 */
  ldr r0, =GPIOA_MODER
  ldr r1, =GPIOA_ALT_SLT
  ldr r2, [r0]
  orr r1, r1, r2
  str r1, [r0]
  /* Set the baud rate */
  ldr r0, =USART2_BRR
  ldr r1, =BRR_CNF
  str r1, [r0]
  /* Configure USART2 Control Register 1 to enable TE (Transmitter Enable) */
  ldr r0, =USART2_CR1
  ldr r1, =CR1_CNF
  str r1, [r0]
  /* Configure USART2 Control Register 2 to specify the stop bits */
  ldr r0, =USART2_CR2
  ldr r1, =CR2_CNF
  str r1, [r0]
  /* Configure USART2 Control Register 3, to specify no flow control */
  ldr r0, =USART2_CR3
  ldr r1, =CR3_CNF
  str r1, [r0]
  /* Enable UART in the Control Register 1*/
  ldr r0, =USART2_CR1
  ldr r1, =USART2_CR1_EN
  ldr r2, [r0]
  orr r1, r1, r2
  str r1, [r0]

  bx lr

/* The character to send is expected to be placed in r0 */
uart_write_char:
  ldr r1, =USART2_ISR
output_loop:
  ldr r2, [r1]
  ldr r3, =TX_BUF_FLAG
  and r2, r2
  cmp r2, #0x00
  beq output_loop
  uxtb r1, r0   /* zero extend byte */
  ldr r2, =USART2_DATAR
  str r1, [r2]
  bx lr
