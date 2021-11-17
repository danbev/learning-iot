### USART2 Issue
The problem I'm having after changing to UART1 is that I can see that FTDI
serial adapter's RX led is blinking when the board is transmitting. But the
only thing that is getting transmited looks like the start bit and nothing else.

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
So if `HSI` is used and there are no prescalars that would mean we have a clock
with a frequency of 8 MHz

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
register: 
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

After spending an embarrasing amount of time trying to get USART to work I
need to find out if there was something else wrong (like an issue with cables,
pins, serial board etc). So I tried using `libopencm3` (open cortex-m I think
it stands for). Trying the example that ships with libopencm3 I was able to
verify that USART does work which was good news. I've been looking at that
as a reference and using the same port and pins which I know work. But after
going through this over and over I still get the same behavior.

I checked the baud rate in `libopencm3/lib/stm32/common/usart_common_all.c`
which contains the function usart_set_baudrate which is of interest to me as
I've been struggling getting usart to work in assembly and I suspect that the
baud rate is wrong.
```c
void usart_set_baudrate(uint32_t usart, uint32_t baud)
{
        ...
	USART_BRR(usart) = (clock + baud / 2) / baud;
}
```
In this case I can check the value of the clock and the passed in baud:
```console
(gdb) info locals
clock = 8000000

(gdb) info args 
baud = 115200
```
So that should give us:
```console
(gdb) p/x (clock + baud / 2) / baud
$3 = 0x45
```
That might not be enough though. I also noticed that in usart.c there is a
delay
```c
		for (i = 0; i < 100000; i++) {	/* Wait a bit. */
			__asm__("NOP");
		}
```
With that baud rate it still does not work. So I started to look at what
happens before the main function is called.
__work in progress__
