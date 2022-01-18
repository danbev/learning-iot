/* nRF external GPIOTE (GPIO Task and Events) LED example */
.thumb
.text

.global start

.equ GPIOTE_BASE, 0x40006000
.equ GPIOTE_TASKOUT_OFFSET, 0x000
.equ GPIOTE_CONFIG_OFFSET, 0x510

.equ GPIOTE_CONFIG_R, GPIOTE_BASE + GPIOTE_CONFIG_OFFSET
.equ GPIOTE_TASKOUT, GPIOTE_BASE + GPIOTE_TASKOUT_OFFSET

.equ CONFIG_MODE, 3 << 0       /* Task mode                                  */
.equ CONFIG_PSEL, 2 << 8       /* Select Pin 2 (P0.02) Pin 0 on the microbit */
.equ CONFIG_PORT, 0 << 13      /* Port number 0                              */
.equ CONFIG_POLARITY, 1 << 16  /* Low To High                                */
.equ CONFIG_OUTINIT, 0 << 20   /* Initial value                              */
.equ TASKOUT_VALUE, 1 << 0     /* Set the task to write to the pin           */

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  /* Configure CONFIG[0] */
  ldr r1, =GPIOTE_CONFIG_R
  ldr r2, =CONFIG_MODE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOTE_CONFIG_R
  ldr r2, =CONFIG_PSEL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOTE_CONFIG_R
  ldr r2, =CONFIG_PORT
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOTE_CONFIG_R
  ldr r2, =CONFIG_POLARITY
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOTE_CONFIG_R
  ldr r2, =CONFIG_OUTINIT
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set TASKOUT[0] */
  ldr r1, =GPIOTE_TASKOUT
  ldr r2, =TASKOUT_VALUE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  b .
