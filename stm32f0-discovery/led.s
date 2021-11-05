.thumb

.text

@ General Purpose IO Port C base register
.equ GPIOC_BASE, 0x48000800
@ Reset and Clock Control register base address
.equ RCC_BASE, 0x40021000

@ Advanced High Performance Bus Enable Register (RCC_AHBENR)
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET
@ Mask to enable I/O PORT C clock
.equ GPIO_PORTC_ENABLE, 1 << 19

@ MODER Register
.equ GPIOC_MODER_OFFSET, 0x00
.equ GPIOC_MODER, GPIOC_BASE + GPIOC_MODER_OFFSET
@ Output Data Register
.equ GPIOC_ODR_OFFSET, 0x14
.equ GPIOC_ODR, GPIOC_BASE + GPIOC_ODR_OFFSET

.equ RED, 6
.equ BLUE, 7
.equ ORANGE, 8
.equ GREEN, 9
/* Enable writing for MODER9 (Mode Register) which is the green LED.*/
.equ GPIOC_MODER_MASK_GREEN, 1 << (GREEN * 2)
.equ LED_MASK_GREEN, 1 << GREEN

/* Enable writing for MODER8 (Mode Register) which is the orange LED. */
/*
.equ GPIOC_MODER_MASK, 1 << (ORANGE * 2)
.equ LED_MASK, 1 << ORANGE
*/

/* Enable writing for MODER7 (Mode Register) which is the blue LED. */
.equ GPIOC_MODER_MASK_BLUE, 1 << (BLUE * 2)
.equ LED_MASK_BLUE, 1 << BLUE

.equ GPIOC_MODER_MASK, GPIOC_MODER_MASK_BLUE + GPIOC_MODER_MASK_GREEN
.equ LED_MASK, LED_MASK_BLUE + LED_MASK_GREEN

/* Enable writing for MODER6 (Mode Register)  which is the red LED. */
/*
.equ GPIOC_MODER_MASK, 1 << (RED * 2)
.equ LED_MASK, 1 << RED
*/

.equ DELAY_LENGTH, 0x000fffff

/* Set up interrupt vector table: 
 entry 0: initial stack pointer
 entry 1: reset address
*/
Vector_Table:    
  .word     0x20002000

ResetVector:
  .word     start + 1

start:
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTC_ENABLE
  bl  set_bits

  ldr r1, =GPIOC_MODER
  ldr r2, =GPIOC_MODER_MASK
  bl  set_bits
         
main_loop:
  ldr r1,=GPIOC_ODR
  ldr r2,=LED_MASK
  bl  set_bits

  bl  delay
 
  ldr r1,=GPIOC_ODR
  ldr r2,=LED_MASK
  bl  clear_bits

  bl  delay
 
  b   main_loop
         
delay:
  ldr r0,=DELAY_LENGTH
dloop:
  sub r0, r0, #1
  bne dloop      /* branch while the Z (zero) flag is not equal to zero */
  bx  lr
 
set_bits: 
  ldr r0, [r1]   /* deref r1 and store in r0. */
  orr r0, r0, r2 /* OR that with r2 saving back to r0. */
  str r0, [r1]   /* store r0 into r1, updating that r1 points to. */
  bx  lr         /* branch to the address in lr. x changes the processor state*/
                 /* to ARM or Thumb depending on the bit[0] of lr. If bit[0] is**/
                 /* 0 then processor changes to ARM state, and if it is 1 will*/
                 /* change (or remain) in Thumb state. */

clear_bits: 
  ldr r0, [r1]
  bic r0, r0, r2
  str r0, [r1]
  bx  lr
         
