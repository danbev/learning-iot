/* Raspberry PI Pico onboard LED example */
.thumb
.text

.global start

.equ USER_BANK0_BASE, 0x40014000
.equ GPIO_25_CTRL_R, USER_BANK0_BASE + 0x0CC // Control register for Pin 25
.equ GPIO_16_CTRL_R, USER_BANK0_BASE + 0x084 // Control register for Pin 21

.equ GPIO_BASE, 0xd0000000                   // SIO base
.equ GPIO_OUT_R, GPIO_BASE + 0x010           // GPIO Output Register
.equ GPIO_OE_R, GPIO_BASE + 0x020            // GPIO Output Enable Set Register

.equ GPIO_FUNC_SIO, 0x05 << 0                // Function Select: SIO=5
.equ GPIO_OE_ENABLE_PIN_25, 1 << 25
.equ GPIO_OUT_PIN_25, 0 << 25

.equ GPIO_16_CTRL_OEOVER, 0x02 << 8
.equ GPIO_OE_ENABLE_PIN_16, 1 << 16
.equ GPIO_OUT_PIN_16, 1 << 16

Vector_Table:
  .word     0x20000000
  .word     start + 1

start:
  // Set Function Select as SIO
  ldr r1, =GPIO_25_CTRL_R
  ldr r2, =GPIO_FUNC_SIO
  str r2, [r1]

  // Enable GPIO Output for PIN
  ldr r1, =GPIO_OE_R
  ldr r2, =GPIO_OE_ENABLE_PIN_25
  str r2, [r1]

  // Set output of PIN to high
  ldr r1, =GPIO_OUT_R
  ldr r2, =GPIO_OUT_PIN_25
  str r2, [r1]

  // Set Function Select as SIO
  ldr r1, =GPIO_16_CTRL_R
  ldr r2, =GPIO_FUNC_SIO
  str r2, [r1]

  // Enable GPIO Output for PIN
  ldr r1, =GPIO_OE_R
  ldr r2, =GPIO_OE_ENABLE_PIN_16
  str r2, [r1]

  // Set output of PIN 21 to high
  ldr r1, =GPIO_OUT_R
  ldr r2, =GPIO_OUT_PIN_16
  str r2, [r1]

  // Disable output to see if this will become floating.
  ldr r1, =GPIO_16_CTRL_R
  ldr r2, =GPIO_16_CTRL_OEOVER
  ldr r0, [r1]                                                                  
  orr r0, r0, r2                                                                
  str r0, [r1]  
  
  b .
