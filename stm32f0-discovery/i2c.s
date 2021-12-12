.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

.equ I2C1_BASE, 0x40005400
.equ GPIOB_BASE, 0x48000400

.equ APB1ENR_OFFSET, 0x1C
.equ RCC_APB1ENR, RCC_BASE + APB1ENR_OFFSET

.equ RCC_AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + RCC_AHBENR_OFFSET

.equ GPIOB_MODER_OFFSET, 0x00
.equ GPIOB_MODER, GPIOB_BASE + GPIOB_MODER_OFFSET

.equ GPIOB_AFRL_OFFSET, 0x20
.equ GPIOB_AFRL, GPIOB_BASE + GPIOB_AFRL_OFFSET

.equ GPIOB_AFRH_OFFSET, 0x24
.equ GPIOB_AFRH, GPIOB_BASE + GPIOB_AFRH_OFFSET

.equ GPIOB_OTYPER_OFFSET, 0x04
.equ GPIOB_OTYPER, GPIOB_BASE + GPIOB_OTYPER_OFFSET

.equ GPIOB_OSPEEDR_OFFSET, 0x08
.equ GPIOB_OSPEEDR, GPIOB_BASE + GPIOB_OSPEEDR_OFFSET

.equ GPIOB_PUPDR_OFFSET, 0x0C
.equ GPIOB_PUPDR, GPIOB_BASE + GPIOB_PUPDR_OFFSET

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
.equ RCC_AHBENR_IOPBEN, 1 << 18
.equ GPIOB_ALT_PB8, 2 << 16              /* SCL PB8                           */
.equ GPIOB_ALT_PB9, 2 << 18              /* SDA PB9                           */
.equ GPIOB_AF1_PB8, 1 << 0               /* SCL PB8                           */
.equ GPIOB_AF1_PB9, 1 << 4               /* SDA PB9                           */
.equ GPIOB_OTYPER_PB8, 1 << 8            /* Open-drain PB8                    */
.equ GPIOB_OTYPER_PB9, 1 << 9            /* Open-drain PB9                    */
.equ GPIOB_OSPEEDR_PB8, 1 << 16          /* Speed for PB8                     */
.equ GPIOB_OSPEEDR_PB9, 1 << 18          /* Speed for PB9                     */
.equ GPIOB_PUPDR_PB8, 0 << 16            /* pull-up PB8                       */
.equ GPIOB_PUPDR_PB9, 0 << 18            /* pull-up PB9                       */
.equ RCC_CFGR3_I2C1SW, 0 << 4            /* Clock source, 0=HSI, 1=SYSCLK     */

.equ I2C1_TIMINGR_PRESC, 1 << 28         /* Prescalar, standard mode 100kHz   */
.equ I2C1_TIMINGR_SDADEL, 0x2 << 16      /* SDA delay, standard mode 10/100   */
.equ I2C1_TIMINGR_SCLDEL, 0x4 << 20      /* SCL delay, standard mode 10/100   */

.equ I2C1_CR1_ANFOFF, 0 << 12            /* Enable/Disable Analog noise filter*/

.global i2c_init

i2c_init:
  /* Clock enable I2C1 */
  ldr r1, =RCC_APB1ENR
  ldr r2, =RCC_APB1_I2C1EN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Clock enable Port B */
  ldr r1, =RCC_AHBENR
  ldr r2, =RCC_AHBENR_IOPBEN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_MODER
  ldr r2, =(GPIOB_ALT_PB8 + GPIOB_ALT_PB9)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOB_AFRH
  ldr r2, =(GPIOB_AF1_PB8 + GPIOB_AF1_PB9)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set output type */
  ldr r1, =GPIOB_OTYPER
  ldr r2, =(GPIOB_OTYPER_PB8 + GPIOB_OTYPER_PB9)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set pin speed */
  ldr r1, =GPIOB_OSPEEDR
  ldr r2, =(GPIOB_OSPEEDR_PB8 + GPIOB_OSPEEDR_PB9)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set no pull-up/pull-down */
  ldr r1, =GPIOB_PUPDR
  ldr r2, =(GPIOB_PUPDR_PB8 + GPIOB_PUPDR_PB9)
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

  bx lr
