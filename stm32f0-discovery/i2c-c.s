/* I2C Controller */
.thumb
.text

.equ RCC_BASE, 0x40021000

.equ I2C1_BASE, 0x40005400

.equ I2C1_CR1_OFFSET, 0x00
.equ I2C1_CR1, I2C1_BASE + I2C1_CR1_OFFSET

.equ I2C1_CR2_OFFSET, 0x04
.equ I2C1_CR2, I2C1_BASE + I2C1_CR2_OFFSET

.equ I2C1_CR2_START, 1 << 13         /* Set START condition           */
.equ I2C1_CR2_ADD10, 0 << 11         /* Addressing mode, 0 = 7 bits   */
.equ I2C1_CR2_RD_WRN, 0 << 10        /* Transfer direction, 0 = write */
.equ I2C1_CR2_SADD, 0x5 << 7         /* Peripheral address            */

.global start

Vector_Table:    
  .word     0x20002000
  .word     start + 1

start:
  bl i2c_init
  bl i2c_controller_init
  b .

i2c_controller_init:
  /* Set 7 bit addressing mode */
  ldr r1, =I2C1_CR2
  ldr r2, =I2C1_CR2_ADD10
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set write transfer direction */
  ldr r1, =I2C1_CR2
  ldr r2, =I2C1_CR2_RD_WRN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the peripheral target address */
  ldr r1, =I2C1_CR2
  ldr r2, =I2C1_CR2_SADD
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

