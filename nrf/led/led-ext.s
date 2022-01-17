/* nRF external LED example */
.thumb
.text

.global start

.equ GPIO_BASE, 0x50000000
.equ GPIO_OUT_OFFSET, 0x504
.equ GPIO_OUTSET_OFFSET, 0x508
.equ GPIO_DIRSET_OFFSET, 0x518
.equ GPIO_CNF_OFFSET, 0x700
/* Pin 0 on the microbit board is connected to pin P0.02 on the nrf52833 mcu */
.equ PIN, 2
.equ PIN_x, (PIN * 0x4)

.equ GPIO_OUT_R, GPIO_BASE + GPIO_OUT_OFFSET
.equ GPIO_OUTSET_R, GPIO_BASE + GPIO_OUTSET_OFFSET
.equ GPIO_CNFx_R, GPIO_BASE + GPIO_CNF_OFFSET + PIN_x
.equ GPIO_DIRSET_R, GPIO_BASE + GPIO_DIRSET_OFFSET

.equ GPIO_CNFx_DIR, 1 << 0
.equ GPIO_CNFx_INPUT, 1 << 1
.equ GPIO_CNFx_PULL, 0 << 2
.equ GPIO_CNFx_DRIVE, 0 << 8
.equ GPIO_CNFx_SENSE, 0 << 16

.equ GPIO_DIRSET_x, 1 << PIN
.equ GPIO_OUTSET_x, 1 << PIN

.equ GPIO_OUT_ON, 0x1

Vector_Table:
  .word     0x20002000               // Initial Stack Pointer value       -
  .word     start + 1

start:
  ldr r1, =GPIO_CNFx_R
  ldr r2, =GPIO_CNFx_DIR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIO_CNFx_R
  ldr r2, =GPIO_CNFx_DRIVE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIO_CNFx_R
  ldr r2, =GPIO_CNFx_PULL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIO_CNFx_R
  ldr r2, =GPIO_CNFx_SENSE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIO_DIRSET_R
  ldr r2, =GPIO_DIRSET_x
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIO_OUTSET_R
  ldr r2, =GPIO_OUTSET_x
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  b .
