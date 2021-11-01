### Cortex-m notes

### General Purpose I/O (GPIO)
These are for things like LED, LCD, KEYPAD, SWITCH etc.
When dealing with GPIO peripheral you have to deal with at least 2 registers,
the data register and the direction register (either input or output).

### Special Purpose I/O
For I²C, S²I, ADC, CAN, PWM, UART, TIMER.

### Ports
In the MCU pins are grouped into ports, like port A, B, C, D, F. When we access
a pin we need to specify the port that the pin belongs to.
For example:
```
PA1 = Pin 1 of Port A
```

### Buses

#### Advanced Peripheral Bus (APB)
Min of 2 clock cycles to access the peripheral
For example, this bus could connect to UART2, SP2/I2S2, SP3/I but you have to
look at the block diagram for the microncontroller that you are working with.

#### Advanced High Performance Bus (AHB)
1 clock cycle to access the peripheral.
For example, this bus could connect to GPIO Ports A, B, C, D, and H but again
you'll have to look at the block diagram for the microcontroller that you are
working with.

### Registers
ARM7TDMI uses banked registers which means that the same register my have
different values depending on the mode of the processor. For ARM7TDMI there
are USER/SYSTEM, Supervisor, Abort, Undefined, Interrupt, and Fast Interrupt
modes. In cortex-m there are only two modes, Handler mode and Thread mode.
So for example in Supervisor mode the registers r13 and r14 will contain values
different from the other modes if the mode is switched into Supervisor mode even
though the registers are accessed with the same register name.

Cortex-m has 17 general puprose registers, 1 status register, and 3 interrupt
mask registers.
```
r13 is the stack pointer register (SP).
r14 is the link register (LR)
r15 is the program counter (PC)
```


Special registers:
```
APSR/EPSR/IPSR
PRIMASK
FAULTMASK
BASEPRI
CONTROL
```
These registers are accessed using two operations,  MRS, and MSR for reading
and writing to these special registiers.

#### APSR/EPSR/IPSR
Application Program State Register, Execution Program State Regiser, and
Interrupt Program State Register.
```
31                                                                  0
+-------------------------------------------------------------------+
|N|Z|C|V|Q| | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
+-------------------------------------------------------------------+
| | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
+-------------------------------------------------------------------+
| | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
+-------------------------------------------------------------------+

N = Negation flag
Z = Zero flag
C = Carry flag
V = Overflog flag
Q = Sticky flag
```

### Vector table
```
Exception Type                  Exception No          Vector address
Top of Stack                    -                     0x0000 0000
Reset                           1                     0x0000 0004
NMI                             2                     0x0000 0008
Hard Fault                      3                     0x0000 000C
Memory management fault         4                     0x0000 0010
Bus fault                       5                     0x0000 0014
Usage fault                     6                     0x0000 0018
Svcall                          11                    0x0000 002C
Debug monitor                   12                    0x0000 0030
PendSV                          14                    0x0000 0038
SysTick                         15                    0x0000 003C
Interrups                       16                    0x0000 0040
...                             ...                   ...


#### Current Process State Register
TODO: move this to an arm7tdmi doc.
```
31                                                      0
+------------------------------------------------------------------+
|N|Z|C|V| | | | | | | | | | | | | | | | | | | |I|F|T|M₄|M₃|M₂|M₁|M₀|
+------------------------------------------------------------------+

N = Negation flag
Z = Zero flag
C = Carry flag
V = Overflog flag

I = Enable/Disable Interrupt
F = Enable/Disable Fast Interrupt
T = Status bit of the system, 1 = Thumb mode, 0 = Not Thumb (32 bit instructions)
M = Mode:
    10000 = User Mode
    10001 = FIQ Mode (Fast Interrupt Mode)
    10010 = IRQ Mode
    10011 = Supervisor Mode
    10111 = Abort Mode
    11011 = Undefined Mode
    11111 = System Mode
```


###
```
1) Enable Clock to Peripheral
Open the clock gate?

2) Set the pin to output mode
So we need 2 registers, the data register and the direction register. We need
the addresses of these registers and these can be found in the data sheet of
the specific MCU.

So say we want to use PA5, that is pin 5 of Port A.
We first need to enable clock to PORTA.
Next, we set PA5 to output.
Then, write output to PA5.

So we have to look at the data sheet to see how PORTA is connected, meaning
which bus it is connected to. So this might be throug the AHB1 bus for example.
We also need to know the address of the PORT A and we can also look this up
in the data sheet for the MCU.
As an example looking in https://www.st.com/resource/en/datasheet/stm32f411ce.pdf
and page 54 we find a table with the entry for GPIOA:
```
0x4002 0000 - 0x4002 03FF GPIOA
```
So that is the start address followed by the end address.
So 0x40020000 is the base address of GPIO PORT A:
```assembly
GPIO_BASE 0x40020000
```
Now to enable the clock to the PORT we have to go through the RCC which is the
Reset and Clock Control
```
0x4002 3800 - 0x4002 3BFF RCC
```

```assembly
RCC_BASE 0x40023800
```
The direction register is called the MODE register in stm32 so we have to find
the address of this register. ODR (Output Data Register) is the name of the
output register. To get these addresses we use an offset from the GPIO base
register. We can think of GPIO_BASE as struct in C and it has different member
which we can access, and instead of using names we use offsets.

https://www.st.com/resource/en/reference_manual/dm00119316-stm32f411xc-e-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf
on page 117 we find RCC_AHB1ENR which is the name of this register:
```text
6.3.9 RCC AHB1 peripheral clock enable register (RCC_AHB1ENR)
  Address offset: 0x30
  Reset value: 0x0000 0000
```
So using the RCC address we can get to the AHB1ENR (AHB1 enable?) by taking
RCC_BASE + 0x30.
```assembly
AHB1ENR_OFFSET 0x30
```
This register is 32 bits and is layout is described in the document. We are
interested in enableing GPIO A and this is bit number 0 called GPIOAEN:
```
Bit 0 GPIOAEN: IO port A clock enable
Set and cleared by software.
0: IO port A clock disabled
1: IO port A clock enabled
```
This can be enabled using as left shift:
```
GPIOA_EN 1<<0
```
Next we need the address of the MODE register (MODER), this is the direction
register which should be set to out in this case. This can also be found in
the same document.
```
8.4.1 GPIO port mode register (GPIOx_MODER) (x = A..E and H)
Address offset: 0x00
Reset values:
• 0xA800 0000 for port A
• 0x0000 0280 for port B
• 0x0000 0000 for other ports
```
Notice that GPIOx_MODER where x can be A..E or H. So In our case it will be
CPIOA_MODER.

This register is 32 bits and deviced into 15 two pit pairs. So we have MODER0-
MODER15. Each of these have two bits and can represent the following values:
```
00: Input (reset state)
01: General purpose output mode
10: Alternate function mode (UART, PWM, DAC, etc)
11: Analog mode
```
Recall that we are trying to set PA5, that is pin 5 of Port A. We would therefor
set the bit-pair number five, MODER5 (notice the 5):
So we have to set bit 10 = 1, and bit 11 = 0.
```
MODER5_OUT 1 << 10
MODER_OFFSET  0x00
```
Using this value will set PA5 direction/mode to output.
So that was setting the direction, next we have to set the data register

8.4.6 GPIO port output data register (GPIOx_ODR) (x = A..E and H)
Address offset: 0x14
Reset value: 0x0000 0000

Bits 31:16 Reserved, must be kept at reset value.
Bits 15:0 ODRy: Port output data (y = 0..15)
These bits can be read and written by software.

We are interested in ODR5 (pin number 5).
```assembly
; GPIOA_BASE 0x40020000
; RCC_BASE 0x40023800   (Reset and Clock Control register base)

; AHB1ENR_OFFSET 0x30   (Advanded Higher Performace Bus 1, Enable Register Offset)
;                       Offset from RCC_BASE
; GPIOA_EN 1<<0         (GPIO Port A Enable)

; MODER_OFFSET  0x00    (Mode/direction register offset, its the first member
;                        of the "struct")
; MODER5_OUT 1 << 10    (set the output bit)

; ODF_OFFSET 0x14
; LED_ON 1 << 5

RCC_BASE           equ 0x40023800
AHB1ENR_OFFSET     equ 0x30
RCC_AHB1ENR        equ RCC_BASE + AHB1ENR_OFFSET

GPIOA_BASE         equ 0x40020000
CPIOA_MODER_OFFSET equ 0x00
CPIOA_MODER        equ GPIOA_BASE + CPIOA_MODER_OFFSET 

CPIOA_ODR_OFFSET   equ 0x14
CPIOA_ODR          equ CPIOA_BASE + CPIOA_ODR_OFFSET

GPIOA_EN           equ 1<<0
MODER5_OUT         equ 1 << 10
LED_ON             equ 1 << 5

.text


```
Notice that `RCC_BASE + AHB1ENR_OFFSET` is really like writing something like
`rcc_base->ahb1enr_offset` in C just that the compiler knows the size of the
members of a struct and can do this calculation for us.

3) Write to the pin
