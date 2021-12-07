.thumb

.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

/* General Purpose IO Port A base register */
.equ GPIOA_BASE, 0x48000000

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET
.equ GPIO_PORTA_ENABLE, 1 << 17

/* Input Data Register offset (from GPIOA_BASE) */
.equ GPIOA_IDR_OFFSET, 0x10
/* Input Data Register */
.equ GPIOA_IDR, GPIOA_BASE + GPIOA_IDR_OFFSET
/* The B1 USER button is connected to I/O PA0 */
.equ BTN_PIN, 0x00000001
.equ BTN_ON,  0x00000001
.equ BTN_OFF, 0x00000000

Vector_Table:    
  .word     0x20002000

ResetVector:
  .word     start + 1          // The +1 is so that the least significant bit
                               // be 1 for Thumb code. If bit[0] is 0 it seems
                               // that will clear the Thumb state and will
                               // result in a fault of lockup.
start:
  bl led_init

  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTA_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Notice that we are not enabling GPIOA_MODER because this would simply
     be initializing it to 0x000000000 which it is by default */
         
main_loop:
  bl get_input 
  cmp r0, #BTN_ON
  BEQ turn_led_on
  cmp r0, #BTN_OFF
  BEQ turn_led_off
  b main_loop

get_input:
  ldr r1, =GPIOA_IDR
  ldr r0, [r1]
  ldr r2, =BTN_PIN
  and r0, r0, r2
  bx lr
