### USART2 Issue
The problem I'm having is that I can see that data is not read out of the
data register. When stepping through the code in the debugger I can see that
the second time `uart_write_char` is called the old data is still in the USART2
Transmit Data Registry (TDR). I'm assuming here that the data would be removed
when it is copied to the shift register of the USART. Hmm, that might be an
incorrect assumption, like think about a mov instruction, that will only copy
the data and not remove it from the source register. I've checked this and the
reference manual states that:
```
Clearing the TXE bit is always performed by a write to the transmit data
register. The TXE bit is set by hardware and it indicates:
• The data has been moved from the USART_TDR register to the shift register and
the data transmission has started.
• The USART_TDR register is empty.
• The next data can be written in the USART_TDR register without overwriting the
previous data.
```
So it looks like the TDR should be cleared if UART was working propertly.

There is no indications either on the serial adapter of any transmission, the rx
light is not blinking (I verfied that I could do a loop back using it by
shorting rx/tx and can see them working).

### Trouble shooting
Lets take a closer look at the RCC_CR (Clock Control) register:
```console
uart_init () at uart.s:89
89	  ldr r1, =RCC_CR
(gdb) si
(gdb) x/wt $r1
0x40021000:	00000000000000000101001010000011
```
So this is showing the default settings.
```
Bit 0 (1) is saying that HSI clock is enabled.
Bit 1 (1) is saying that the HSI oscillator is stable.
Bit 2 (0) is reserved.
Bit 3-7 (10000) is for HSI clock trimming and used in combination with (HSICAL,
the next 8 bits). These 4 bits provide a user programmable trimming value to
adjust to variations in temparature and voltage. The default value is 16
(10000b) and when this value is added to the value in HSICAL it should trim the
HSI to 8 MHz. 
Bit 8-15 (1010010) HSI clock callibration (HSICAL).
```
The rest of the bits are zero so the HSE clock is not enabled.

Next, lets take a look at `RCC_RC2`:
```console
(gdb) x/wt $r1
0x40021034:	10001000000000000111010010000000
```
As far as I can tell the values in this register are mainly for HSI14, and we
know that HSI is enabled by default (From bit 0 in RCC_CR).

Next, lets inspect `RCC_CFGR` register
```console
gdb) x/wt $r1
0x40021004:	00000000000000000000000000000000
```
So nothing in this register is being set by default. A few of the interesting
bits related to HSI are:
```
Bit 0-1 (00) System clock switch (SW) 00 = HSI selected as system clock.
Bit 2-3 (00) System clock switch status (SWS) 00 = HSI oscillator used as
system clock.
Bit 4-7 (0000) HCKL prescalar. 0000 means no division factor of AHB clock.
Bit 8-10 (000) PCKL prescalar. 000 means no division factor of APB clock.
Bit 13 (0) reserved.
Bit 14 (0) ADC prescalar. Is obselete according to the manual.
Bit 15-16 (00) PLL input clock source. 00 = HSI/2 selected as PLL. PREDIV forced
to divide by 2 on STM32F07x.
Bit 17 (0) HSE divider for PLL input clock.
Bit 18-21 (0000) PLL multiplication factor (PLLMUL). 0000 = PLL input clock x 2
Bit 22 (0) reserved
Bit 23 (0) reserved
Bit 24-27 (0000) Microcontroller clock output (MCO). 000 MCO ouput disabled.
Bit 28-30 (000) Microcontroller clock ouput prescalar (MCOPRE). 000 = MCO is
divided by 1.
Bit 31 (0) PLL clock not divided (PLLNODIV). 0 = PLL is not divided by 2 for
MCO.
```
Next we have `RCC_CFGR3`:
```console
(gdb) x/wt $r1
0x40021030:	00000000000000000000000000000000
```
Since I'm using USART2 the only relevant value I think is bit 16-17:
```
Bit 16-17 (00) USART2 clock source selection (USART2SW). 00 = PCKL selected as
USART2 clock source (default).
```

`FCKL` is the clock signal provided to the CPU core.  
`HCKL` is the clock signal provided to the high-speed bus (AHB).  
`PCKL` is the clock signal provided to the low-speed bus (APB).

Lets take a look at the USART2_CR1 register and find the value of `OVER8` which
is bit 15:
```console
(gdb) x/wt $r1
0x40004400:	00000000000000000000000000000000
```
Bit 15 (0) Oversampling Mode (OVER8). 0 = Oversampling by 16.

This value is important when cacluating the Baud rate. 

So the system clock is 8 MHz, and in this case I think `PCKL` is that same value
, and we know that Oversampling is 16. So if we want to have a baud rate of
9600:
```
         8000000
  9600 = --------
         USARTDIV

             80000
  USARTDIV = ----- = 833d, 0x341
              96
```
And we have a symbol for this in uart.s:
```assembly
.equ BRR_CNF, 0x341
```
But if you look at the code I'm just writing this directly into the `USART_BRR`
register. But if we look at the code for writing the value I'm just writing it
directly:
```console
(gdb) x/wt $r1
0x4000440c:	00000000000000000000000000000000
(gdb) i r $r2
r2             0x341               833
(gdb) p/t $r0
$1 = 1101000001
(gdb) x/wt $r1
0x4000440c:	00000000000000000000001101000001
```
Actually the manual says When OVER8 = 0, BRR[3:0] = USARTDIV[3:0] so this should
be correct in this case.

With these current settings I can see that after writing to the DTR USART2_IRS
is then cleared with only one bit set:
```console
(gdb) x/wt $r1
0x4000441c:	00000000001000000000000000000000
```
The is bit 21 that is set. This is Transmit enable acknowledge flag (TEACK)
which is set by hardware when Transmit Enable.
TEACK can be configured in USART_CR1:
```
Bit 7 TXEIE: interrupt enable
This bit is set and cleared by software.
  0: Interrupt is inhibited
  1: A USART interrupt is generated whenever TXE=1 in the USART_ISR register

Bit 6 TCIE: Transmission complete interrupt enable
This bit is set and cleared by software.
  0: Interrupt is inhibited
  1: A USART interrupt is generated whenever TC=1 in the USART_ISR register

Bit 4 IDLEIE: IDLE interrupt enable
This bit is set and cleared by software.
  0: Interrupt is inhibited
  1: A USART interrupt is generated whenever IDLE=1 in the USART_ISR register
```


00000000001000000000000011000000


### PORT/Alternative Function
From the data sheet I can read the following:
```
Table 15. Alternate functions selected through GPIOA_AFR registers for port A 

                 AF1
PA2             USART2_TX
```
I'm setting AF1 using:
```assembly
.equ AFSEL2_AF1, 1 << 8                      // checked

  /* Set GPIO Port A Pin 2 to 0001 (AF1) */ 
  ldr r1, =GPIOA_AFRL
  ldr r2, =AFSEL2_AF1
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
```

![Oscilloscope image of PA2](./uart-oscilloscope.jpg "Oscilloscope image of PA2")

I actually had the USB connected incorrectly in that picture but I changed it
to USB User with the same result.
So I'm thinking it could still be the pin that is incorrectly setup but I've
checked this multiple times now. I'm leaning towards it being and issue with
the UART configuration.

### Incorrect UART configuration
TODO:



```console
$ minicom -D /dev/ttyUSB0 -b 9600 -8 -H
Welcome to minicom 2.7.1

OPTIONS: I18n 
Compiled on Jan 26 2021, 00:00:00.
Port /dev/ttyUSB0, 19:56:24

Press CTRL-A Z for help on special keys

00 00 00 00 00 00 00 00 00 00 00 00
```
When using an oscilloscope I'm only seeing the start bit and nothing else, it
is like it is sent but nothing else after it.
