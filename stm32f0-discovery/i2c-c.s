/* I2C Controller */
.thumb
.text

.equ RCC_BASE, 0x40021000

.equ I2C1_BASE, 0x40005400

.equ I2C1_CR1_OFFSET, 0x00
.equ I2C1_CR1, I2C1_BASE + I2C1_CR1_OFFSET

.equ I2C1_CR2_OFFSET, 0x04
.equ I2C1_CR2, I2C1_BASE + I2C1_CR2_OFFSET

.equ I2C1_ISR_OFFSET, 0x18
.equ I2C1_ISR, I2C1_BASE + I2C1_ISR_OFFSET

/* Timing Register */
.equ I2C1_TIMINGR_OFFSET, 0x28
.equ I2C1_TIMINGR, I2C1_BASE + I2C1_TIMINGR_OFFSET

/* Transmit Data Register */
.equ I2C1_TXDR_OFFSET, 0x28
.equ I2C1_TXDR, I2C1_BASE + I2C1_TXDR_OFFSET

.equ I2C1_CR2_START, 1 << 13         /* Set START condition           */
.equ I2C1_CR2_ADD10, 0 << 11         /* Addressing mode, 0 = 7 bits   */
.equ I2C1_CR2_RD_WRN, 0 << 10        /* Transfer direction, 0 = write */
.equ I2C1_CR2_SADD, 0x19 << 1        /* Peripheral address            */
.equ I2C1_CR2_AUTOEND, 1 << 25       /* Send STOP after NBYTES        */
.equ I2C1_CR2_NBYTES, 3 << 16        /* Number of bytes to transmit   */

.equ I2C1_TIMINGR_SCLH, 0xF << 8     /* SCL High period, standard mode 100kHz */
.equ I2C1_TIMINGR_SCLL, 0x13 << 0    /* SCL Low period, standard mode 100kHz  */

.equ I2C1_PE, 1 << 0
.equ I2C1_ISR_TXIS, 1 << 1 
.equ I2C1_ISR_TXE, 1 << 0 
.equ I2C1_ISR_TC, 1 << 6
.equ I2C1_ISR_NACKF, 1 << 4

.global start

Vector_Table:    
  .word     0x20002000
  .word     start + 1

start:
  bl i2c_init
  bl i2c_controller_init
  ldr r1, =I2C1_ISR
  bl led_init
  bl i2c_write
  b .

i2c_write:
  bl turn_led_on
  /* Set the number of bytes to write */
  ldr r1, =I2C1_CR2
  ldr r2, =I2C1_CR2_NBYTES
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Send STOP condition automatically when NBYTES have been sent */
  ldr r1, =I2C1_CR2
  ldr r2, =I2C1_CR2_AUTOEND
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the peripheral target address */
  ldr r1, =I2C1_CR2
  ldr r2, =I2C1_CR2_SADD
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Start condition */
  ldr r1, =I2C1_CR2
  ldr r2, =I2C1_CR2_START
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Wait for transmit data register empty flag to be set */
wait_for_peripheral:
  ldr r1, =I2C1_ISR
  ldr r2, =I2C1_ISR_NACKF
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  beq nack_received

  ldr r1, =I2C1_ISR
  ldr r2, =I2C1_ISR_TXIS
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, #0x00
  beq wait_for_peripheral

  /* Write 'A' to the transmit data directory */
  ldr r1, =I2C1_TXDR
  mov r2, #'A'
  str r2, [r1]

  /* Wait for transfer complete */
  ldr r1, =I2C1_ISR
  ldr r2, =I2C1_ISR_TC
wait_transfer_complete:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, #0x00
  beq wait_transfer_complete

  bl delay
  bl turn_led_off

  bx lr

nack_received:
  bl turn_led_off
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

  /* SCL High period */

/*
  ldr r1, =I2C1_TIMINGR
  ldr r2, =I2C1_TIMINGR_SCLH
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/

  /* SCL Low period */
/*
  ldr r1, =I2C1_TIMINGR
  ldr r2, =I2C1_TIMINGR_SCLL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
*/

  /* Enable Peripheral */
  ldr r1, =I2C1_CR1
  ldr r2, =I2C1_PE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr 
