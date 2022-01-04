.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

/* Advanced Peripheral clock enable register 1, bus that TIM2 is connected to */
.equ APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + APB1ENR_OFFSET

/* Timer 2 base address */
.equ TIM2_BASE, 0x40000000

/* Control register 1 */
.equ TIM2_CR1_OFFSET, 0x00
.equ TIM2_CR1, TIM2_BASE + TIM2_CR1_OFFSET

/* Status register */
.equ TIM2_SR_OFFSET, 0x10
.equ TIM2_SR, TIM2_BASE + TIM2_SR_OFFSET

/* Count register */
.equ TIM2_CNT_OFFSET, 0x24
.equ TIM2_CNT, TIM2_BASE + TIM2_CNT_OFFSET

/* Prescalar register */
.equ TIM2_PSC_OFFSET, 0x28
.equ TIM2_PSC, TIM2_BASE + TIM2_PSC_OFFSET

/* Auto-Reload register */
.equ TIM2_ARR_OFFSET, 0x2C
.equ TIM2_ARR, TIM2_BASE + TIM2_ARR_OFFSET

.equ TIM2_ENABLE, 1 << 0  /* Enable TIM2 in APB1ENR */
.equ TIM2_CR1_CEN, 1 << 0 /* Counter Enable bit */

/* 
  clock_source / prescalar = auto-reload value
  8000000      / 800       = 10000

  scaled_clk_source / auto-reload value = xHz
  10000             / 10000             = 1Hz

  8000000      / 80        = 100000
  100000       / 10000     = 10Hz
*/

/* Count starts a zero which is the reason for -1 */
.equ PSC_VALUE, 800 - 1
.equ ARR_VALUE, 10000 - 1
.equ CNT_CLEAR, 0x0
.equ SR_UIF, 1 << 0  /* Update Interrupt Flag (UIF) */

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.global start

Vector_Table:              /* Vector                       Exception Nr */
  .word     0x20002000     /* Initial Stack Pointer value             - */
ResetHandler:              /* Reset                                   1 */
  .word     start + 1 

start:
  bl led_init
  bl tim2_init

main_loop:
  bl wait
  bl turn_led_on
  bl wait
  bl turn_led_off
  b main_loop

wait:
  ldr r1, =TIM2_SR
  ldr r2, =SR_UIF /* Update Interrupt Flag (UIF) */
wait_uif:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, #0x00
  beq wait_uif

  /* Clear the Update Interrrupt Flag (UIF) */
  ldr r0, [r1]
  mov r2, #1
  bic r0, r0, r2
  str r0, [r1]

  bx lr


tim2_init:
  /* Enable TIM2 on APB1 bus */
  ldr r1, =RCC_APB1ENR
  ldr r2, =TIM2_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set prescalar value */
  ldr r1, =TIM2_PSC
  ldr r2, =PSC_VALUE
  str r2, [r1]

  /* Set the auto-reload value */
  ldr r1, =TIM2_ARR
  ldr r2, =ARR_VALUE
  str r2, [r1]

  /* Set the count register */
  ldr r1, =TIM2_CNT
  ldr r2, =CNT_CLEAR
  str r2, [r1]

  /* Set the control register counter enable */
  ldr r1, =TIM2_CR1
  ldr r2, =TIM2_CR1_CEN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
