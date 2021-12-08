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

.equ I2C1_OAR1_OA1, 0x08 << 7         /* Peripheral interface address      */
.equ I2C1_OAR1_OA1EN, 1 << 15         /* Enable Own Address1               */
.equ I2C1_OAR1_OA1MODE, 0 << 10       /* 7-bit address                     */
.equ I2C1_CR2_ADD10, 0 << 11          /* Addressing mode, 0 = 7 bits       */
.equ I2C1_PE, 1 << 0                  /* Peripheral enable                 */
.equ I2C1_ISR_ADDR, 1 << 3            /* Address matched                   */
.equ I2C1_ISR_RXNE, 1 << 2            /* Address matched                   */
.equ I2C1_CR1_GCEN, 1 << 19           /* Address matched                   */

.global start

Vector_Table:    
  .word     0x20002000
  .word     start + 1

start:
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
  cmp r0, #0x00
  b wait_for_addr

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
  b main_loop

i2c_peripheral_init:
  /* Set 7 bit addressing mode */
  ldr r1, =I2C1_CR2
  ldr r2, =I2C1_CR2_ADD10
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =I2C1_OAR1
  ldr r2, =I2C1_OAR1_OA1EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Enable OA1EN */
  ldr r1, =I2C1_OAR1
  ldr r2, =I2C1_OAR1_OA1EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =I2C1_OAR1
  ldr r2, =I2C1_OAR1_OA1MODE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the interface address of the peripheral */
  ldr r1, =I2C1_OAR1
  ldr r2, =I2C1_OAR1_OA1
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =I2C1_CR1
  ldr r2, =I2C1_CR1_GCEN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Enable Peripheral */
  ldr r1, =I2C1_CR1
  ldr r2, =I2C1_PE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
