/* Raspberry PI Pico external LED example */
.thumb
.text

.global start

.equ USER_BANK0_BASE, 0x40014000
.equ GPIO_25_CTRL_R, USER_BANK0_BASE + 0x0CC // Control register for Pin 25

.equ GPIO_BASE, 0xd0000000                   // SIO base
.equ GPIO_OE_R, GPIO_BASE + 0x020           // GPIO Output Enable Set Register
.equ GPIO_OUT_R, GPIO_BASE + 0x010          // GPIO Output Register

//.equ GPIO_OUT_SET_R, GPIO_BASE + 0x014    // GPIO Output Register atomic set

.equ PIN, 25                                // Pin 25 if the LED on the Pico
//.equ GPIO_OE_SET_R, GPIO_BASE + 0x024     // GPIO Output Enable Set Register
//.equ GPIO_CTRL_R, GPIO_BASE + 0x018

.equ GPIO_FUNC_SIO, 0x05 << 0                // Function Select: SIO=5
.equ GPIO_OE_ENABLE_PIN, 1 << PIN
.equ GPIO_OUT_PIN, 1 << PIN                 

Vector_Table:
  .word     0x20000000
  .word     start + 1

start:
  // Enable GPIO Output for PIN
  ldr r1, =GPIO_OE_R
  ldr r2, =GPIO_OE_ENABLE_PIN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  // Set Function Select as SIO
  ldr r1, =GPIO_25_CTRL_R
  ldr r2, =GPIO_FUNC_SIO
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  // Set output of PIN to high
  ldr r1, =GPIO_OUT_R
  ldr r2, =GPIO_OUT_PIN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  b .
