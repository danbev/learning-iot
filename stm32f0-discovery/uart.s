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
.equ RCC_APB1ENR_OFFSET, 0x1c
.equ RCC_APB1ENR, RCC_BASE + RCC_APB1ENR_OFFSET
.equ USART2_EN, 1 << 17
/* Mode Register Offset for Port A (from GPIO_BASE) */
.equ GPIOA_MODER_OFFSET, 0x00
/* Mode Register for GPIO Port A */
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

/* Alternate Function Register Low */
.equ GPIOA_AFRL_OFFSET, 0x20
.equ GPIOA_AFRL, GPIOA_BASE + GPIOA_AFRL_OFFSET

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ AFSEL2_AF1, 1 << 8
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

.equ GPIOA_ALT_SLT, 2 << 4 /* Port A Pin 3 enable alternate function mode */

.equ BRR_CNF, 0x683    /* 0x1A1 0x683  */  
.equ CR1_CNF, 1 << 3   /* 0000 0000 1000 = TE (Transmitter Enable) */
.equ CR2_CNF, 0x0000   /* bits 13-12 are stop bits 00=1 stop bit */
.equ CR3_CNF, 0x0000   /* No flow control */
.equ USART2_CR1_EN, 1 << 0
.equ USART2_CR1_DISABLE, 0x0000
.equ TX_BUF_FLAG, 1 << 6

.global start

Vector_Table:    
  .word     0x20002000

ResetVector:
  .word     start + 1

start:
  bl uart_init
main_loop:
  mov r0, #0x41 // #'A' /* hex: 0x41 */
  bl uart_write_char
  b main_loop

uart_init:

  /* USART2 Clock Enable pin 17 of RCC_APB1ENR */
  ldr r1, =RCC_APB1ENR
  ldr r2, =USART2_EN
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]

  /* Clock enable GPIOA */
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTA_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]

  /* Set GPIO Port A Pin 2 to 0001 (AF1) */ 
  ldr r1, =GPIOA_AFRL
  ldr r2, =AFSEL2_AF1
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Enable Alternative function mode for GPIO PA2 */
  ldr r1, =GPIOA_MODER
  ldr r2, =GPIOA_ALT_SLT
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the baud rate */
  ldr r1, =USART2_BRR
  ldr r2, =BRR_CNF /* Can only be written when USART is disabled UE=0 */
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Configure USART2 Control Register 1 to enable TE (Transmitter Enable) */
  ldr r1, =USART2_CR1
  mov r2, #CR1_CNF
  str r2, [r1]

  /* Configure USART2 Control Register 2 to specify the stop bits */
  ldr r1, =USART2_CR2
  mov r2, #CR2_CNF
  str r2, [r1]

  /* Configure USART2 Control Register 3, to specify no flow control */
  ldr r1, =USART2_CR3
  ldr r2, =CR3_CNF
  str r2, [r1]

  /* Enable UART in Control Register 1 */
  ldr r1, =USART2_CR1
  ldr r2, =USART2_CR1_EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr

/* The character to send is expected to be placed in r0 */
uart_write_char:
  ldr r1, =USART2_ISR
output_loop:
  ldr r2, [r1]
  ldr r3, =TX_BUF_FLAG
  and r2, r3
  cmp r2, #0x00
  beq output_loop
  uxtb r1, r0   /* zero extend byte */
  ldr r2, =USART2_DATAR
  str r1, [r2]
  push {lr}
  bl turn_led_on
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

  ldr r1,=GPIOC_BSRR
  ldr r2,=BSRR_9_SET
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
  bx lr
