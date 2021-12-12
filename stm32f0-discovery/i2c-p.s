/* I2C Peripheral */
.thumb
.text

.equ RCC_BASE, 0x40021000

.equ I2C1_BASE, 0x40005400

.equ I2C1_CR1_OFFSET, 0x00
.equ I2C1_CR1, I2C1_BASE + I2C1_CR1_OFFSET

.equ I2C1_CR2_OFFSET, 0x04
.equ I2C1_CR2, I2C1_BASE + I2C1_CR2_OFFSET

/* Own Address 1 Register */
.equ I2C1_OAR1_OFFSET, 0x08
.equ I2C1_OAR1, I2C1_BASE + I2C1_OAR1_OFFSET

.equ I2C1_ISR_OFFSET, 0x18
.equ I2C1_ISR, I2C1_BASE + I2C1_ISR_OFFSET

/* Receive Data Register */
.equ I2C1_RXDR_OFFSET, 0x24
.equ I2C1_RXDR, I2C1_BASE + I2C1_RXDR_OFFSET

.equ I2C1_ICR_OFFSET, 0x1C
.equ I2C1_ICR, I2C1_BASE + I2C1_ICR_OFFSET

.equ I2C1_OAR1_OA1EN, 1 << 15         /* Enable Own Address1               */
.equ I2C1_OAR1_OA1MODE, 0 << 10       /* 7-bit address                     */
.equ I2C1_OAR1_OA1, 0x19 << 1         /* Peripheral own address            */

.equ I2C1_CR1_PE, 1 << 0              /* Peripheral enable                 */
.equ I2C1_ISR_ADDR, 1 << 3            /* Address matched                   */
.equ I2C1_ISR_RXNE, 1 << 2            /* Receive register not empty        */
.equ I2C1_ICR_ADDRCF, 1 << 3

/*
.equ I2C1_CR1_GCEN, 1 << 19
.equ I2C1_CR1_NOSTRETCH, 0 << 17
.equ I2C1_CR1_SCB, 1 << 16
*/


.global start

Vector_Table:    
  .word     0x20002000
  .word     start + 1

start:
  bl led_init
  bl i2c_init
  bl uart_init
  bl i2c_peripheral_init

main_loop:
  /* Wait for address that matches this peripheral */
  ldr r1, =I2C1_ISR
  ldr r2, =I2C1_ISR_ADDR
wait_for_addr:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_for_addr

  bl turn_led_on

  /* Clear the ADDR flag */
  ldr r1, =I2C1_ICR
  ldr r2, =I2C1_ICR_ADDRCF
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Wait for Receive data register to be filled (not empty) */
  ldr r1, =I2C1_ISR
  ldr r2, =I2C1_ISR_RXNE
wait_for_rxne:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, #0x00
  b wait_for_rxne

  /* Read from Recieve data register */
  ldr r1, =I2C1_ISR_RXNE
  ldr r0, [r1]
  bl uart_write_char

  bl delay
  bl turn_led_off

  b main_loop

i2c_peripheral_init:
  /* Set 7-bit addressing mode */
  ldr r1, =I2C1_OAR1
  ldr r2, =I2C1_OAR1_OA1MODE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set this peripherals address */
  ldr r1, =I2C1_OAR1
  ldr r2, =I2C1_OAR1_OA1
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Enable OA1EN so that this peripherals address will be ACK:ed */
  ldr r1, =I2C1_OAR1
  ldr r2, =I2C1_OAR1_OA1EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Enable Peripheral */
  ldr r1, =I2C1_CR1
  ldr r2, =I2C1_CR1_PE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
