.thumb
.text

/* Reset Clock and Counter register base address */
.equ RCC_BASE, 0x40021000

.equ ADC_BASE, 0x40012400

/* Advanced Peripheral clock enable register 2, bus that ADC is connected to */
.equ APB2ENR_OFFSET, 0x18
.equ RCC_APB2ENR, RCC_BASE + APB2ENR_OFFSET

/* Advanced High Performace Bus Enable Register offset (from RCC) */
.equ AHBENR_OFFSET, 0x14
.equ RCC_AHBENR, RCC_BASE + AHBENR_OFFSET

.equ ADC_ISR_OFFSET, 0x00
.equ ADC_ISR, ADC_BASE + ADC_ISR_OFFSET

.equ ADC_CR_OFFSET, 0x08
.equ ADC_CR, ADC_BASE + ADC_CR_OFFSET

.equ ADC_CHSELR_OFFSET, 0x28
.equ ADC_CHSELR, ADC_BASE + ADC_CHSELR_OFFSET

.equ ADC_DR_OFFSET, 0x40
.equ ADC_DR, ADC_BASE + ADC_DR_OFFSET

/* Common configuration Register */
.equ ADC_CCR_OFFSET, 0x308
.equ ADC_CCR, ADC_BASE + ADC_CCR_OFFSET

.equ ADC_CFGR1_OFFSET, 0x0C
.equ ADC_CFGR1, ADC_BASE + ADC_CFGR1_OFFSET

/* Channel Selection Register. Select which channels are to be converted */
.equ ADC_CHSELR_OFFSET, 0x28
.equ ADC_CHSELR, ADC_BASE + ADC_CHSELR_OFFSET

.equ RCC_ADC_ENABLE, 1 << 9
.equ ISR_EOC_FLAG, 1 << 2           /* End of conversion flag   */
.equ ISR_ADRDY_CLEAR, 0 << 0        /* Clear ADC Ready          */
.equ ISR_ADRDY, 1 << 0              /* ADC Ready bit            */
.equ CHSELR_CHSEL, 1 << 0           /* Select the first channel */
.equ CR_EOC, 1 << 2                 /* End of Conversion        */
.equ CR_ADEN, 1 << 0                /* AD enable                */
.equ CR_ADSTART, 1 << 2             /* Start a conversion       */
.equ CCR_TEN, 1 << 23               /* Enable temerature sensor */
.equ CFGR1_CONT, 1 << 13            /* Continuous conversion mode. 0=single  */

.equ GPIOA_BASE, 0x48000000
.equ GPIOA_MODER_OFFSET, 0x00
.equ GPIOA_MODER, GPIOA_BASE + GPIOA_MODER_OFFSET
.equ GPIOA_AFLR_OFFSET, 0x20
.equ GPIOA_AFLR, GPIOA_BASE + GPIOA_AFLR_OFFSET

.equ GPIO_PORTA_ENABLE, 1 << 18
.equ AF_ENABLE_PA2, 2 << 4
.equ AF_ENABLE_PA3, 2 << 6
.equ AF3_ENABLE_PA2, 3 << 8
.equ AF3_ENABLE_PA3, 3 << 12
.equ ADC_CHANNEL_2, 1 << 2
.equ ADC_CHANNEL_3, 1 << 3

.global start

Vector_Table:              /* Vector                       Exception Nr */
  .word     0x20002000     /* Initial Stack Pointer value             - */
ResetHandler:              /* Reset                                   1 */
  .word     start + 1 

start:
  bl gpio_init
  bl adc_init

main_loop:
  /* Start a single ADC conversion. Will start immediatly as EXTEN=00 */
  ldr r1, =ADC_CR
  ldr r2, =CR_ADSTART
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

wait_adc_complete:
  ldr r1, =ADC_ISR
  ldr r2, =ISR_EOC_FLAG
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, #0x00
  beq wait_adc_complete

adc_loop:
  /* Converted signal show now be in ADC Data Registry */
  ldr r1, =ADC_DR
  ldr r0, [r1]
  ldr r2, =#1800
  cmp r2, r0
  bgt led_on
  blt led_off
led_on:
  bl turn_led_on
  b done
led_off:
  bl turn_led_off
  b done
done:
  bl delay
  b adc_loop
  
gpio_init:
  ldr r1, =RCC_AHBENR
  ldr r2, =GPIO_PORTA_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_MODER
  ldr r2, =(AF_ENABLE_PA2 + AF_ENABLE_PA3)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =GPIOA_AFLR
  ldr r2, =(AF3_ENABLE_PA2 + AF3_ENABLE_PA3)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr

adc_init:
  /* Enable ADC on APB2 bus */
  ldr r1, =RCC_APB2ENR
  ldr r2, =RCC_ADC_ENABLE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the conversion mode (single or continuous) */
  ldr r1, =ADC_CFGR1
  ldr r2, =CFGR1_CONT
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Select Channel 1 for conversion */
  ldr r1, =ADC_CHSELR
  ldr r2, =ADC_CHANNEL_3
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Clear the ADRDY bit */
  ldr r1, =ADC_ISR
  ldr r2, =ISR_ADRDY_CLEAR
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Enable ADC */
  ldr r1, =ADC_CR
  ldr r2, =CR_ADEN
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Wait for the ADRDY flag to be set */
wait_adc_ready:
  ldr r1, =ADC_ISR
  ldr r2, =ISR_ADRDY
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, #0x00
  beq wait_adc_ready

  bx lr
