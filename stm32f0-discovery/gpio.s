.thumb
.syntax unified
             
.text

// General Purpose IO Port C base register
.equ GPIOC_BASE, 0x48000800
// Reset and Clock Control register base address
.equ RCC_BASE, 0x40021000

// Advanced High Performance Bus Enable Register
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

//.equ GPIOCMODER, 0x48000800
// Mode Register
.equ GPIOC_MODER_OFFSET, 0x00
.equ GPIOC_MODER, GPIOC_BASE + GPIOC_MODER_OFFSET
// Output Data Register
.equ GPIOC_ODR_OFFSET, 0x14
.equ GPIOC_ODR, GPIOC_BASE + GPIOC_ODR_OFFSET

.equ RCC_AHBENR_MASK, 0x00080000
.equ GPIOC_MODER_MASK, 0x00010000
// currently the orange led, the value being 0x00000100 which is 256 decimal,
// and 10000000 binary, which is bit 8 which is being set which corresponds to
// PC8.
.equ LED_MASK, 1 << 8
.equ DELAY_LENGTH, 0x000fffff

// Set up interrupt vector table: 
// entry 0: initial stack pointer
// entry 1: reset address
Vector_Table:    
  .word     0x20002000

ResetVector:    .word     start + 1

start:
  ldr r1, =RCC_AHBENR
  ldr r2, =RCC_AHBENR_MASK
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
         
// Delay subroutine.  Pass the length of the delay in R0
delay:
  subs r0, r0, #1
  bne delay
  bx lr
 
// on entry, R1 contains address where target address is stored
// R2 contains address where mask bits are stored
set_bits: 
  ldr r0, [r1]         // read register contents
  orrs r0, r0, r2       // combine with register contents
  str r0, [r1]         // write back contents
  bx LR               // return to caller
// on entry, R1 contains address where target address is stored
// R2 contains address where mask bits are stored
clear_bits: 
  ldr r0, [r1]         // read register contents
  bics r0, r0, r2       // combine with register contents
  str r0, [r1]         // write back contents
  bx LR               // return to caller
         
