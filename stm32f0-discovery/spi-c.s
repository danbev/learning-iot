/*
PA4  NSS (chip/peripheral select)
PA5  Clock select
PA6  CIPO
PA7  COPI
*/
.thumb
.text

.equ SPI1_BASE, 0x40013000

.equ SPI1_CR1_OFFSET, 0x00
.equ SPI1_CR1, SPI1_BASE + SPI1_CR1_OFFSET

.equ SPI1_SR_OFFSET, 0x08
.equ SPI1_SR, SPI1_BASE + SPI1_SR_OFFSET

.equ SPI1_DR_OFFSET, 0x0C
.equ SPI1_DR, SPI1_BASE + SPI1_DR_OFFSET

.equ SPI_CR1_MASTER, 1 << 2
.equ SPI_SR_BSY_FLAG, 1 << 7
.equ SPI_SR_TXE_EMPTY, 1 << 1

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  bl spi_init
  bl spi_controller_init

main_loop:
  bl delay
  ldr r1, =SPI1_SR
  ldr r2, =SPI_SR_TXE_EMPTY
wait_txe_flag:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_txe_flag

  bl turn_led_on

  /* Write to data register */
  ldr r1, =SPI1_DR
  mov r2, #0x41
  uxtb r3, r2 
  strb r2, [r1]

wait_busy_flag:
  ldr r1, =SPI1_SR
  ldr r2, =SPI_SR_BSY_FLAG
  and r0, r0, r2
  cmp r0, r2
  bne wait_busy_flag

/*
  ldr r1, =SPI1_DR
  ldrb r0, [r1]
  ldr r2, =SPI1_SR
  ldr r0, [r2]
*/

  bl delay
  bl turn_led_off
  
  b main_loop

spi_controller_init:
  /* Set SPI as the controller */
  ldr r1, =SPI1_CR1
  ldr r2, =SPI_CR1_MASTER
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
  bx lr
