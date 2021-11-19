.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000
/* Univeral Serial Asynchronous Receiver Transmitter Base address */
.equ USART1_BASE, 0x40013800
/* General Purpose IO Port A base register */
.equ GPIOA_BASE, 0x48000000

/* Advanced Peripheral Bus 1 Enable Register Offset (from RCC_BASE) */
.equ RCC_APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + RCC_APB1ENR_OFFSET

.equ RCC_APB2ENR_OFFSET, 0x18
.equ RCC_APB2ENR, RCC_BASE + RCC_APB2ENR_OFFSET

/* Mode Register Offset for Port A (from GPIO_BASE) */
.equ GPIOA_MODER_OFFSET, 0x00
/* Mode Register for GPIO Port A */
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

/* Alternate Function Register High */
.equ GPIOA_AFRH_OFFSET, 0x24
.equ GPIOA_AFRH, GPIOA_BASE + GPIOA_AFRH_OFFSET

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

/* USART Control Register 1 CR1 */
.equ USART_CR1_OFFSET, 0x00
.equ USART_CR1, USART1_BASE + USART_CR1_OFFSET

/* USART Baud Rate Register */
.equ USART_BRR_OFFSET, 0x0C
.equ USART_BRR, USART1_BASE + USART_BRR_OFFSET

/* USART Data Transmit Register */
.equ USART_TDR_OFFSET, 0x28
.equ USART_TDR, USART1_BASE + USART_TDR_OFFSET

/* USART Data Transmit Register */
.equ USART_RDR_OFFSET, 0x24
.equ USART_RDR, USART1_BASE + USART_RDR_OFFSET

/* USART Interrupt and Status Register */
.equ USART_ISR_OFFSET, 0x1C
.equ USART_ISR, USART1_BASE + USART_ISR_OFFSET

.equ RCC_USART1_ENABLE, 1 << 14
.equ GPIO_PORTA_ENABLE, 1 << 17

/* Alternative function for port A pin 9 (PA9, TX) */
.equ GPIOA_AF_PA9, 2 << 18
/* Alternative function for port A pin 10 (PA10, RX) */
.equ GPIOA_AF_PA10, 2 << 20

/* Which type of alternative function for port A pin 9 (PA9) */
.equ GPIOA_AFSEL_PA9_AF1, 1 << 4 /* GPIOA_ARFH Pin 9 */

/* Which type of alternative function for port A pin 10 (PA10) */
.equ GPIOA_AFSEL_PA10_AF1, 1 << 8 /* GPIOA_ARFH Pin 9 */

/* Baud Rate Register value */
.equ USART_BRR_VALUE, 0x45

/* Control Register 1, Transmitter Enable (TE) */
.equ USART_CR1_TE_ENABLE, 1 << 3
/* Control Register 1, Receiver Enable (RE) */
.equ USART_CR1_RE_ENABLE, 1 << 2

/* Control Register 1, USART Enable (UE)  */
.equ USART_CR1_UE_ENABLE, 1 << 0

/* Interrupt and Status Register Transmit (TX) data registry Empty */
.equ USART_ISR_TXE, 1 << 6

/* Interrupt and Status Register RXNE (Read data register no empty) */
.equ USART_ISR_RXNE, 1 << 5

.global start

Vector_Table:    
  .word     0x20002000

ResetVector:
  .word     start + 1

start:
  bl uart_init
main_loop:
  b uart_read_char

uart_init:
  /* Enable Port A clock */
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTA_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]


  /* Enable USART1 clock */
  ldr r1, =RCC_APB2ENR
  ldr r2, =RCC_USART1_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]

  /* Enable Port C clock */
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTC_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Setup Port A, pin 9 to be an alternativ function */
  ldr r1, =GPIOA_MODER
  ldr r2, =GPIOA_AF_PA9
  ldr r3, =GPIOA_AF_PA10
  ldr r0, [r1]
  orr r0, r0, r2
  orr r0, r0, r3
  str r0, [r1]

  /* Specify that the alternativ function for Port A, pin 9 is AF1 */
  ldr r1, =GPIOA_AFRH
  ldr r2, =GPIOA_AFSEL_PA9_AF1
  ldr r3, =GPIOA_AFSEL_PA10_AF1
  ldr r0, [r1]
  orr r0, r0, r2
  orr r0, r0, r3
  str r0, [r1]

  ldr r1, =GPIOC_MODER
  ldr r2, =GPIOC_MODER_MASK
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the baud rate */
  ldr r1, =USART_BRR
  mov r2, #USART_BRR_VALUE /* Can only be written when USART is disabled UE=0 */
  str r2, [r1]

  /* Configure USART Control Register 1 to enable TE (Transmitter Enable) */
  ldr r1, =USART_CR1
  ldr r2, =USART_CR1_TE_ENABLE
  ldr r3, =USART_CR1_RE_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  orr r0, r0, r3
  str r0, [r1]

  /* Enable UART in Control Register 1 */
  ldr r1, =USART_CR1
  ldr r2, =USART_CR1_UE_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  push {lr}
  bl delay
  pop {pc}

uart_read_char:
rx_output_loop:
  bl delay
  ldr r1, =USART_ISR
  ldr r2, [r1]
  ldr r3, =USART_ISR_RXNE
  and r2, r2, r3
  cmp r2, #0x0
  beq rx_output_loop
  bl turn_led_on
  bl delay
  ldr r2, =USART_RDR
  ldr r3, [r2]
  ldr r4, =#0xFF
  and r3, r3, r4
  mov r0, r3
  bl uart_write_char
  bl delay
  bl turn_led_off
  b uart_read_char

uart_write_char:
  mov r6, r0
tx_output_loop:
  push {lr}
  ldr r1, =USART_ISR
  ldr r2, [r1]
  ldr r3, =USART_ISR_TXE
  and r2, r2, r3
  cmp r2, #0x00
  beq tx_output_loop
  uxtb r3, r6 
  ldr r2, =USART_TDR
  str r3, [r2]
  pop {pc}

.equ GPIO_PORTC_ENABLE, 1 << 19
.equ GPIOC_MODER_MASK, 1 << 14
.equ GPIOC_MODER_OFFSET, 0x00
.equ GPIOC_MODER, GPIOC_BASE + GPIOC_MODER_OFFSET
.equ GPIOC_BASE, 0x48000800
.equ GPIOC_BSRR_OFFSET, 0x18
.equ GPIOC_BSRR, GPIOC_BASE + GPIOC_BSRR_OFFSET
.equ BSRR_9_SET, 1 << 7
.equ BSRR_9_RESET, 1 << 23

turn_led_on:
  ldr r1,=GPIOC_BSRR
  ldr r2,=BSRR_9_SET
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
  bx lr

turn_led_off:
  ldr r1,=GPIOC_BSRR
  ldr r2,=BSRR_9_RESET
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
  bx lr

.equ DELAY_LENGTH, 100000
delay:
  ldr r0,=DELAY_LENGTH
dloop:
  sub r0, r0, #1
  bne dloop      /* branch while the Z (zero) flag is not equal to zero */
  bx  lr
