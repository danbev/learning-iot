.thumb
.syntax unified
             
.text

// General Purpose IO Port C base register
.equ GPIOC_BASE, 0x48000800
// Reset and Clock Control register base address
.equ RCC_BASE, 0x40021000

// Advanced High Performance Bus Enable Register (RCC_AHBENR)
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET
// Mask to enable I/O PORT C clock
.equ GPIO_PORTC_ENABLE, 1 << 19

// MODER Register
.equ GPIOC_MODER_OFFSET, 0x00
.equ GPIOC_MODER, GPIOC_BASE + GPIOC_MODER_OFFSET
// Output Data Register
.equ GPIOC_ODR_OFFSET, 0x14
.equ GPIOC_ODR, GPIOC_BASE + GPIOC_ODR_OFFSET

.equ RED, 6
.equ BLUE, 7
.equ ORANGE, 8
.equ GREEN, 9
// Enable writing for MODER9 (Mode Register) which is the green LED.
//.equ GPIOC_MODER_MASK, 1 << (GREEN * 2)
//.equ LED_MASK, 1 << GREEN

// Enable writing for MODER8 (Mode Register) which is the orange LED.
//.equ GPIOC_MODER_MASK, 1 << (ORANGE * 2)
//.equ LED_MASK, 1 << ORANGE

// Enable writing for MODER7 (Mode Register) which is the blue LED.
.equ GPIOC_MODER_MASK, 1 << (BLUE * 2)
.equ LED_MASK, 1 << BLUE

// Enable writing for MODER6 (Mode Register)  which is the red LED.
//.equ GPIOC_MODER_MASK, 1 << (RED * 2)
//.equ LED_MASK, 1 << RED

.equ DELAY_LENGTH, 0x000fffff

// Set up interrupt vector table: 
// entry 0: initial stack pointer
// entry 1: reset address
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

  ldr r0,=DELAY_LENGTH     
  bl delay
 
  ldr r1,=GPIOC_ODR
  ldr r2,=LED_MASK
  bl  clear_bits

  ldr r0,=DELAY_LENGTH
  bl delay
 
  b   main_loop
         
delay:
  subs r0, r0, #1
  bne delay
  bx lr
 
set_bits: 
  ldr r0, [r1]
  orrs r0, r0, r2
  str r0, [r1]
  bx LR

clear_bits: 
  ldr r0, [r1]
  bics r0, r0, r2
  str r0, [r1]
  bx LR
         
