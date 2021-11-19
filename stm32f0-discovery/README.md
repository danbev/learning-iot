### Assembly stm32 examples
So the goal of this example is to turn on a LED on the bord. The board I'm using
is stm32f0-discovery:

[Product documentation](https://www.st.com/en/evaluation-tools/32f072bdiscovery.html#documentation)  
[User Manual](https://www.st.com/resource/en/user_manual/um1690-discovery-kit-for-stm32f0-series-microcontrollers-with-stm32f072rb-stmicroelectronics.pdf)

This board is based on a STM32F072RBT6 so we will need its 
[reference manual](https://www.st.com/resource/en/reference_manual/rm0091-stm32f0x1stm32f0x2stm32f0x8-advanced-armbased-32bit-mcus-stmicroelectronics.pdf) as well.

### Examples
1. [Blinking LED](./led.s)
1. [Blinking LED using BSRR](./led_bsrr.s)
1. [User button](./led_button.s)
1. [UART Transmit](./uart.s)

### LED background info

There are four LEDs on this board which we can turn on and we can choose one.
There are details about these LEDs on page 14 of the above user manual:
```
                           LED3
                      LED4      LED5
                           LED6

* User LD3: This red user LED is connected to the I/O PC6
* User LD4: This orange user LED is connected to the I/O PC8
* User LD5: This green user LED is connected to the I/O PC9
* User LD6: This blue user LED is connected to the I/O PC7
```
So we can see that we need to access PORT C and then a PIN on that port.
So we can see that all these PINs are connected to PORT C.

The steps we need to go through to write to one of these pins are the following:
* Enable I/O PORT C clock
* Set the Mode (the direction which is output in our case) (GPIOx_MODER)
* Set the bit to be written (GPIOC_ODR)

#### AHB peripheral clock enable
This register is at an offset from RCC (think of this as if rcc is a struct and
we are accessing a member like rcc->ahbenr but instead we are using addition
explicitly where the first term is the RCC_BASE and the second term is 0x14)

```
6.4.6 AHB peripheral clock enable register (RCC_AHBENR)
Address offset: 0x14
...
Bit 19 IOPCEN: I/O port C clock enable
Set and cleared by software.
  0: I/O port C clock disabled
  1: I/O port C clock enabled
```
Notice that bit 19 is the bit for controlling PORT C clock enabling, and if we
write a 1 into that position we are enabling it. 

So we also need to find the address of the Reset and Clock Control register
(RCC) which can be found in the Memory Map section:
```
0x4002 1000 - 0x4002 13FF 1 KB RCC
...
```
So our RCC_AHB1 would be 0x4002100 + 0x14. In the [led.s](./led.s) example we
use symbolic names for these values.

So we need to find the address of PORT C. To do this we look in the reference
manual on page 38 there is a table with a Memory Map (same table as we used 
previously):
```
...
0x4800 0800 - 0x4800 0BFF 1KB GPIOC
...
```
Next we need to set the Mode to output
```
8.4.1 GPIO port mode register (GPIOx_MODER) (x =A..F)
Address offset:0x00

Bits 2y+1:2y MODERy[1:0]: Port x configuration bits (y = 0..15)
These bits are written by software to configure the I/O mode.
  00: Input mode (reset state)
  01: General purpose output mode
  10: Alternate function mode
  11: Analog mode
```
This register is at an offset of `0x00`from `CPIOC`. Using this address we can
then set the output mode `01` of the pin we are interested in. Notice that there
are two bits per PIN and the register is 32 bits, that leaves 15 pins. And we
noted above that the pins of the LEDs are 6, 7, 8, and pin 9. So if we want to
set PIN 6 to output mode we have to write a 1 in bit position 12.

With the mode set we now need to write the data using Output Data Register
(ODR):
```
8.4.6 GPIO port output data register (GPIOx_ODR) (x = A..F)
Address offset: 0x14

Bits 31:16 Reserved, must be kept at reset value.
Bits 15:0 ODRy: Port output data bit (y = 0..15)
  These bits can be read and written by software
```
Again this is a register offset from the GPIOC base register and we set the pin
that we are interested in writing, one of pin 6, 7, 8, or pin 9. Just note that
if you want to change the led or enable more we also have to set the Mode for
those or nothing will happen.

An example of a led blinking with a delay can be found in [led.s](./led.s).

### Building
```console
$ make led.elf
```

### Flashing
```console
$ make openocd
```
From a new terminal (as the first terminal will be running the openocd server)
and it is good to keep that visible so you can see the commands being executed)

```console
$ telnet localhost 4444
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Open On-Chip Debugger
> reset halt
> flash write_image erase main.hex
> reset run
> CTRL+]
telnet> quit
```

![Blue Led example](./blue-led.jpg "Example of blue led blinking")


### Debugging
If you don't have `arm-none-eabi-gdb` installed please follow the
[instructions](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)
to install it and setup the correct PATH.

openocd need to be running:
```console
$ make openocd
openocd -f board/stm32f0discovery.cfg
Open On-Chip Debugger 0.11.0
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
Info : The selected transport took over low-level target control. The results might differ compared to plain JTAG/SWD
srst_only separate srst_nogate srst_open_drain connect_deassert_srst

Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Info : clock speed 1000 kHz
Info : STLINK V2J36S0 (API v2) VID:PID 0483:3748
Info : Target voltage: 2.931101
Info : stm32f0x.cpu: hardware has 4 breakpoints, 2 watchpoints
Info : starting gdb server for stm32f0x.cpu on 3333
Info : Listening on port 3333 for gdb connections
```
And then in a new terminal run gdb:
```console
$ arm-none-eabi-gdb
GNU gdb (GNU Arm Embedded Toolchain 10.3-2021.10) 10.2.90.20210621-git
(gdb) target extended-remote 127.0.0.1:3333
(gdb) monitor reset halt
(gdb) symbol-file main.elf
(gdb) b start
```

### UART Example
First thing we need to do is to take a look at the block diagram and see how
UART is connected to the system. On this board we have `USART1`, `USART2`, and
`USART6`. I think they all work in the same way and I'm going to use `USART1`
for this example. It is connected to Advanced Peripheral Bus 2 (APB2) so we have
to enable USART1 via the APB2 register.
```
6.4.8 APB peripheral clock enable register 2 (RCC_APB2ENR)
Address: 0x18

Bit 14 USART1EN: USART1 clock enable
Set and cleared by software.
  0: USART1clock disabled
  1: USART1clock enabled
```
So we will need to set bit `14` (`USART1_EN`) to 1 to enable the `USART1` clock.
The clock needs to be activated or the peripheral may not be readable by
software and the returned value will always be `0x0`.

Now, the device I/O pins are connected through a multiplexer which allows a
single alternate function (AF) to be connected to one pin at a time. So each pin
can have have 16 alternate function inputs (remember that these are the inputs
to the multiplexer and it outputs a single value). If we look in the data sheet
we can find that `Table 14` contains information about `USART1` which is an
alternative function, and the pins that it uses:
```
USART1_TX    PA9 AF1
```
The output is configured using `GPIOx_AFRH` (Alternate Function Register High)
for pins 8-15:
```
8.4.9 GPIO alternate function high register (GPIOx_AFRH) (x = A..F)
Address offset: 0x24
```
This is a 32 bit register which is divided into 4 bit sections.
```
Bits 31:0 AFSELy[3:0]: Alternate function selection for port x pin y (y = 8..15)
These bits are written by software to configure alternate function I/Os
AFSELy selection:
  0000: AF0
  0001: AF1
  0010: AF2
  0011: AF3
  0100: AF4
  0101: AF5
  0110: AF6
  0111: AF7
```
So I think we need to configure AFSEL9 and specify which alternate 
function this pin should have which in this case is 0001 for AF1.

So we will have to enable Port A and also GPIOA_AFRH

So we will need to configure GPIOA_MODER to be in alternate function mode:
```
8.4.1 GPIO port mode register (GPIOx_MODER) (x =A..F)
Address offset:0x00

Bits 2y+1:2y MODERy[1:0]: Port x configuration bits (y = 0..15)
These bits are written by software to configure the I/O mode.
  00: Input mode (reset state)
  01: General purpose output mode
  10: Alternate function mode
  11: Analog mode 
```
So for the Port in question,  PA9 we would need to set the bit for this to `10`,
alternative function mode. 

We can look at the memory map to get the base address of USART1:
```
.equ USART1_BASE, 0x40013800
```

We also have to configure USART using the control register.
```27.8.1 Control register 1 (USART_CR1)
Address offset: 0x00

Bit 3 TE: Transmitter enable
This bit enables the transmitter. It is set and cleared by software.
  0: Transmitter is disabled
  1: Transmitter is enabled

Bit 0 UE: USART enable
When this bit is cleared, the USART prescalers and outputs are stopped
immediately, and current operations are discarded. The configuration of the
USART is kept, but all the status flags, in the USART_ISR are set to their
default values. This bit is set and cleared by software.
  0: USART prescaler and outputs disabled, low-power mode
  1: USART enabled
```
Setting `UE` will enable the UART module.

```
27.8.4 Baud rate register (USART_BRR)
This register can only be written when the USART is disabled (UE=0). It may be
automatically updated by hardware in auto baud rate detection mode.
Address offset: 0x0C

Bits 31:16 Reserved, must be kept at reset value.
Bits 15:4 BRR[15:4]
BRR[15:4] = USARTDIV[15:4]
Bits 3:0 BRR[3:0]
When OVER8 = 0, BRR[3:0] = USARTDIV[3:0].
When OVER8 = 1:
BRR[2:0] = USARTDIV[3:0] shifted 1 bit to the right.
BRR[3] must be kept cleared
```

For sending data it needs to be placed in this register:
```
27.8.11 Transmit data register (USART_TDR)
Address offset: 0x28
```

```
27.8.8 Interrupt and status register (USART_ISR)
Address offset: 0x1C

Bit 7 TXE: Transmit data register empty
This bit is set by hardware when the content of the USART_TDR register has been
transferred into the shift register. It is cleared by a write to the USART_TDR register.
The TXE flag can also be cleared by writing 1 to the TXFRQ in the USART_RQR register, in
order to discard the data (only in Smartcard T=0 mode, in case of transmission failure).
An interrupt is generated if the TXEIE bit =1 in the USART_CR1 register.
0: data is not transferred to the shift register
1: data is transferred to the shift register)
Note: This bit is used during single buffer transmission
```

#### Testing this example
1) compile:
```console
$ make uart.elf
```

2) Flash the binary to the board.
```console
$ make openocd
$ telnet localhost 4444
> reset halt
> flash write_image erase uart.elf.hex
```
3) Connect with minicom:
Connect PA9 to a USB to Serial Adapter and then connect the USB to the
computer:
```console
$ minicom -D /dev/ttyUSB0 -b 115200 -8 
```
4) Run the executable
```console
> reset run
```

This should now output a number of `A`s in the minicom terminal window:
```console
Welcome to minicom 2.7.1

OPTIONS: I18n
Compiled on Jan 26 2021, 00:00:00.
Port /dev/ttyUSB0, 05:25:03

Press CTRL-A Z for help on special keys

AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
```
