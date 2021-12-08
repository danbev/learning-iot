.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

.equ I2C1_BASE, 0x40005400
.equ GPIOA_BASE, 0x48000000

.equ APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + APB1ENR_OFFSET

.equ GPIOA_MODER_OFFSET, 0x00
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET

.equ GPIOA_AFRL_OFFSET, 0x20
.equ GPIOA_AFRL, GPIOA_BASE + GPIOA_AFRL_OFFSET

.equ GPIOA_OTYPER_OFFSET, 0x04
.equ GPIOA_OTYPER, GPIOA_BASE + GPIOA_OTYPER_OFFSET

.equ GPIOA_PUPDR_OFFSET, 0x0C
.equ GPIOA_PUPDR, GPIOA_BASE + GPIOA_PUPDR_OFFSET

.equ I2C1_CR1_OFFSET, 0x00
.equ I2C1_CR1, I2C1_BASE + I2C1_CR1_OFFSET

.equ I2C1_CR2_OFFSET, 0x04
.equ I2C1_CR2, I2C1_BASE + I2C1_CR2_OFFSET

.equ I2C1_ISR_OFFSET, 0x18
.equ I2C1_ISR, I2C1_BASE + I2C1_ISR_OFFSET

/* Timing Register */
.equ I2C1_TIMINGR_OFFSET, 0x28
.equ I2C1_TIMINGR, I2C1_BASE + I2C1_TIMINGR_OFFSET

/* Clock configuration register 3 (RCC_CFGR3) */
.equ RCC_CFGR3_OFFSET, 0x30
.equ RCC_CFGR3, RCC_BASE + RCC_CFGR3_OFFSET

.equ RCC_APB1_I2C1EN, 1 << 21
.equ GPIOA_ALT_PA6, 2 << 12              /* SCL PA6                           */
.equ GPIOA_ALT_PA7, 2 << 14              /* SDA PA7                           */
.equ GPIOA_AF1_PA6, 1 << 24              /* SCL PA6                           */
.equ GPIOA_AF1_PA7, 1 << 28              /* SDA PA7                           */
.equ GPIOA_OTYPER_PA6, 1 << 6            /* Open-drain PA6                    */
.equ GPIOA_OTYPER_PA7, 1 << 7            /* Open-drain PA7                    */
.equ GPIOA_PUPDR_PA6, 0x00 << 12         /* Non pull-up/pull-down PA6         */
.equ GPIOA_PUPDR_PA7, 0x00 << 14         /* Non pull-up/pull-down PA7         */
.equ RCC_CFGR3_I2C1SW, 1 << 4            /* Clock source, 0=HSI, 1=SYSCLK     */

.equ I2C1_TIMINGR_PRESC, 1 << 28         /* Prescalar value                   */
.equ I2C1_TIMINGR_SCLDEL, 0x4 << 20      /* SCL delay                         */
.equ I2C1_TIMINGR_SDADEL, 0x2 << 16      /* SDA delay                         */

.equ I2C1_CR1_ANFOFF, 0 << 12            /* Enable/Disable Analog noise filter*/
.equ I2C1_CR1_NOSTRETCH, 1 << 17         /* Disable clock stretching          */

.global i2c_init

i2c_init:
  /* Clock enable I2C1 */
  ldr r1, =RCC_APB1ENR
  ldr r2, =RCC_APB1_I2C1EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_MODER
  ldr r2, =(GPIOA_ALT_PA6 + GPIOA_ALT_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_AFRL
  ldr r2, =(GPIOA_AF1_PA6 + GPIOA_AF1_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set output type to open-drain */
  ldr r1, =GPIOA_OTYPER
  ldr r2, =(GPIOA_OTYPER_PA6 + GPIOA_OTYPER_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set no pull-up/pull-down */
  ldr r1, =GPIOA_PUPDR
  ldr r2, =(GPIOA_PUPDR_PA6 + GPIOA_PUPDR_PA7)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Clear PE Peripheral */
  ldr r1, =I2C1_CR1
  ldr r2, =(0 << 0)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Enable/Disable Noise filter */
  ldr r1, =I2C1_CR1
  ldr r2, =I2C1_CR1_ANFOFF
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set clock source for I2C1 */
  ldr r1, =RCC_CFGR3
  ldr r2, =RCC_CFGR3_I2C1SW
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set Prescalar value */
  ldr r1, =I2C1_TIMINGR
  ldr r2, =I2C1_TIMINGR_PRESC
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set SCL delay */
  ldr r1, =I2C1_TIMINGR
  ldr r2, =I2C1_TIMINGR_SCLDEL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set SDA delay */
  ldr r1, =I2C1_TIMINGR
  ldr r2, =I2C1_TIMINGR_SDADEL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set NOSTRETCH */
  ldr r1, =I2C1_CR1
  ldr r2, =I2C1_CR1_NOSTRETCH
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
