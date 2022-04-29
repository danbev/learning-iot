/* Raspberry PI Pico external LED example */
.thumb
.text

.global start

.equ GPIO_BASE, 0x40014000           // Base address of User Bank IO
.equ GPIO_OUT_R, GPIO_BASE + 0x010   // GPIO Output Register

.equ GPIO_OE_R, GPIO_BASE + 0x020    // GPIO Output Enable Register
.equ GPIO0_CTRL_R, GPIO_BASE + 0x004

.equ GPIO_FUNC_SIO, 0x5              // Function Select: SIO
.equ GPIO_OE_ENABLE_PIN0, 1
.equ GPIO_OUT_PIN0, 1 << 0

Vector_Table:
  .word     0x20000000
  .word     start + 1

start:
  // Enable GPIO Output for GPIO0
  ldr r1, =GPIO_OE_R
  ldr r2, =GPIO_OE_ENABLE_PIN0
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  // Set Function Select as SIO
  ldr r1, =GPIO0_CTRL_R
  ldr r2, =GPIO_FUNC_SIO
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  // Set output of PIN 0 to high
  ldr r1, =GPIO_OUT_R
  ldr r2, =GPIO_OUT_PIN0
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  b .
