.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000
/* Univeral Serial Asynchronous Receiver Transmitter Base address */
.equ USART_BASE, 0x40013800
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

.equ GPIOA_OTYPER_OFFSET, 0x04
.equ GPIOA_OTYPER, GPIOA_BASE + GPIOA_OTYPER_OFFSET

.equ GPIOA_PUPDR_OFFSET, 0x08
.equ GPIOA_PUPDR, GPIOA_BASE + GPIOA_PUPDR_OFFSET

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ USART_CR1_OFFSET, 0x00
.equ USART_CR1, USART_BASE + USART_CR1_OFFSET

.equ USART_CR2_OFFSET, 0x04
.equ USART_CR2, USART_BASE + USART_CR2_OFFSET

.equ USART_CR3_OFFSET, 0x08
.equ USART_CR3, USART_BASE + USART_CR3_OFFSET

.equ USART_BRR_OFFSET, 0x0C
.equ USART_BRR, USART_BASE + USART_BRR_OFFSET

.equ USART_DTR_OFFSET, 0x28
.equ USART_DTR, USART_BASE + USART_DTR_OFFSET

.equ USART_ISR_OFFSET, 0x1C
.equ USART_ISR, USART_BASE + USART_ISR_OFFSET

.equ USART_EN, 1 << 17
.equ USART1_EN, 1 << 14
.equ GPIO_PORTA_ENABLE, 1 << 17
.equ GPIOA_AF1, 2 << 18
.equ AFSEL2_AF1, 1 << 4

#.equ BRR_CNF, 0x034    /* 0x1A1 0x683  */  
#.equ BRR_CNF, 0x341   /* x0EA6 0x1A1 0x683  */
.equ BRR_CNF, 0x0341  /* x0EA6 0x1A1 0x683  */
#.equ BRR_CNF, 0x683
.equ CR1_CNF, 1 << 3   /* 0000 0000 1000 = TE (Transmitter Enable) */
.equ CR2_CNF, 0x0000   /* bits 13-12 are stop bits 00=1 stop bit */
.equ CR3_CNF, 0x0000   /* No flow control */
.equ USART_CR1_EN, 1 << 0
.equ TX_BUF_FLAG, 1 << 7

.equ OTYPER, 1 << 9
.equ PUPDR, 2 << 18

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
  /* Clock enable GPIOA */
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTA_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]

  /* Enable USART1 */
  ldr r1, =RCC_APB2ENR
  ldr r2, =USART1_EN
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]

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


  /* Enable Alternative function mode for GPIO PA2 */
  ldr r1, =GPIOA_MODER
  ldr r2, =GPIOA_AF1
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_AFRH
  ldr r2, =AFSEL2_AF1
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the baud rate */
  ldr r1, =USART_BRR
  ldr r2, =BRR_CNF /* Can only be written when USART is disabled UE=0 */
  str r2, [r1]

  /* Clock enable USART */
/*
  ldr r1, =RCC_APB1ENR
  ldr r2, =USART_EN
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]
*/

  /* Configure USART Control Register 1 to enable TE (Transmitter Enable) */
  ldr r1, =USART_CR1
  ldr r2, =CR1_CNF
  ldr r0, [r1]
  orr r0, r0, r2
  ldr r3, =USART_CR1_EN
  orr r0, r0, r3
  str r0, [r1]

  /* Enable UART in Control Register 1 */
/*
  ldr r1, =USART_CR1
  ldr r2, =USART_CR1_EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/

  /* Configure USART Control Register 2 to specify the stop bits */
/*
  ldr r1, =USART_CR2
  ldr r2, =CR2_CNF
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/

  /* Configure USART Control Register 3, to specify no flow control */
/*
  ldr r1, =USART_CR3
  ldr r2, =CR3_CNF
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/
/*
  ldr r1, =GPIOA_OTYPER
  ldr r2, =OTYPER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_PUPDR
  ldr r2, =PUPDR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/
  push {lr}
  bl delay
  bl turn_led_on
  bl delay
  bl turn_led_off
  pop {pc}

/* The character to send is expected to be placed in r0 */
uart_write_char:
output_loop:
  push {lr}
  bl delay
  bl turn_led_off
  bl delay
  ldr r1, =USART_ISR
  ldr r2, [r1]
  ldr r3, =TX_BUF_FLAG
  and r2, r3
  cmp r2, #0x00
  beq output_loop
  uxtb r1, r0 
  ldr r2, =USART_DTR
  str r1, [r2]
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

.equ DELAY_LENGTH, 0x000fffff
delay:
  ldr r0,=DELAY_LENGTH
dloop:
  sub r0, r0, #1
  bne dloop      /* branch while the Z (zero) flag is not equal to zero */
  bx  lr
