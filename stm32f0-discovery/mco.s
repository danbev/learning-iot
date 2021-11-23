.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

.equ RCC_CFGR_OFFSET, 0x04
.equ RCC_CFGR, RCC_BASE + RCC_CFGR_OFFSET

/* General Purpose IO Port A base register */
.equ GPIOA_BASE, 0x48000000

/* Mode Register Offset for Port A (from GPIO_BASE) */
.equ GPIOA_MODER_OFFSET, 0x00
/* Mode Register for GPIO Port A */
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

/* Alternate Function Register High */
.equ GPIOA_AFRH_OFFSET, 0x24
.equ GPIOA_AFRH, GPIOA_BASE + GPIOA_AFRH_OFFSET

/* Alternative function for port A pin 8 (PA8, MCO) */
.equ GPIOA_AF_PA8, 2 << 16
.equ GPIO_PORTA_ENABLE, 1 << 17

/* Which type of alternative function for port A pin 8 (PA8) */
.equ GPIOA_AFSEL_PA8_AF0, 0x0 << 0

.equ MCO_SYSCLK, 4 << 24
.global start

Vector_Table:              /* Vector                       Exception Nr */
  .word     0x20002000     /* Initial Stack Pointer value             - */
ResetHandler:              /* Reset                                   1 */
  .word     start + 1 

start:
  /* Enable Port A clock */
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTA_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2 
  str r0, [r1]

  /* Setup Port A, pin 8 to be an alternativ function */
  ldr r1, =GPIOA_MODER
  ldr r2, =GPIOA_AF_PA8
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Specify the alternativ function for Port A, pin 8 is AF1 */
  ldr r1, =GPIOA_AFRH
  ldr r2, =GPIOA_AFSEL_PA8_AF0
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r0, =RCC_CFGR
  ldr r1, =MCO_SYSCLK
  ldr r2, [r0]
  orr r2, r2, r1
  str r2, [r0]
  
  b .
