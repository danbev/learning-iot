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
modes (TDMI = Thumb, Debug Extension, Multiplier, Embedded ICE MacroCell).

In cortex-m there are only two modes, Handler mode and Thread mode.
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
```


#### Current Process State Register (CPSR)
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

### Data flow model
```
             Data
             ↑| |          +-------------------+
             || +--------->|Instruction Decoder|
    +--------+|            +-------------------+
    |         ↓
    |      +-----------+
    |      |Sign Extend|
    |      +-----------+
    |         ↓ Read
  +----------------------------+  Rd
+-| Register File R0-R15       |←------+ 
| +----------------------------+       |
|    |A          |B          |         |
|    |         Rm+----------+|         |
|  Rn+-----------|------+   ||         |
|    |           ↓      ↓   ↓↓         |
|    | +----------+    +-------+       |
|    | |Barrel    |    | MAC   |       |
|    | |Shifter   |    +-------+       |
|    | +----------+        |           |
|    ↓    ↓ N              |           |
|  ----------------        |           |
|  \     ALU      /        |           |
|   \            /         |           |
|    ------------          |           |
|          |               ↓           |
|          +---------------------------+
|          |
|          ↓
|  +------------------+
|  | Address Register |←-------+
|  +------------------+        |
|R15       |    |       +-----------+
+-------+  |    +------>|Incrememter|
        ↓  ↓            +-----------+
        Address

MAC = Multiply Accumulate Unit
ALU = Arithmetic Login Unit
```
Sign extend converts 8 and 16 bit numbers to 32 bit numbers.

#### High Speed External (HSE)
This is a crystal oscillator, resonator, clock generating circuits. Usually
4-25MHx (this might be old figures).

#### Low Speed External (LSE)
Similar to HSE but usually very accurate. 32.768 kHz clock crystals are used to
feed the LSE. The Real Time Clock (RTC) modules uses this clock.

#### High Speed Internal (HSI)
Is an internal 8MHz clock source. RC oscillator.

#### Low Speed Internal (LSI)
Simlar to HSI but no very accurate. RC oscillator with a frequency of 40 kHz.

#### Phase Locked Loop (PLL)
Is the frequency doubling output of PLL.
TODO: explain how this works.

### Clock prescalars
TODO: explain how this works.

### System clock (SYSCLK) selection
The following can be sources for this clock:
* HSI 8 MHz RC oscillator clock
* HSE oscillator clock
* PPL clock
* HSI48 48 MHz RC oscillator clock

After a system reset, the HSI oscillator is selected as system clock. So in that
case it is a 8 MHz clock.

This is an example in [stm32f0-discovery/mco.s](../stm32f0-discovery/mco.s)
which allow an oscilloscope to be connected to PA8 and see the frequency:

![MCO image1](./mco1.jpg "MCO example image 1")
Here we can see that we are running at 8Mhz:
![MCO image2](./mco2.jpg "MCO example image 2")

### Timer vs Clock
If the source of the clock is internal, like RC or PLL that this is called a
timer. If the clock source is externally provided to the CPU this is called
a clock.
Both are used to create delays, count events, and for measuring time between
events.

### General purpose timers
Take a look in the data sheet for the timers available, section 3.14 for the
board I'm working on.
```
General purpose:
TIM2   32-bit Up/down
TIM3   16-bit Up/down
TIM14  16-bit Up
TIM15  16-bit Up
TIM16  16-bit Up
TIM17  16-bit Up
```
So if we choose TIM2 we can look that up in the memory map section of the
reference manual:
```
0x40000000 TIM2  Bus: APB1
```
So that will be the base register for TIM2 and we can see in the data sheet that
this peripheral is connect to APB1

```
RCC_APB1ENR      0x1C

Bit 0 TIM2EN: TIM2 timer clock enable
Set and cleared by software.
  0: TIM2 clock disabled
  1: TIM2 clock enabled
```
Then we can find the registers in chapter 18 which cover TIM2 and TIM3.


#### TIM2 Status Register (TIM2_SR)
Address offset:  0x10
```
Bit 0 UIF: Update interrupt flag
This bit is set by hardware on an update event. It is cleared by software.
  0: No update occurred.
  1: Update interrupt pending. 
```

#### TIM2 Control Register 1 (TIM2_CR)
Address offset: 0x00
```
Bit 4 DIR: Direction
  0: Counter used as upcounter
  1: Counter used as downcounter

Bit 0 CEN: Counter enable
  0: Counter disabled
  1: Counter enabled
```

#### TIM2 Counter Register (TIM2_CNT)
Address offset: 0x24

#### TIM2 Prescalar (TIM2_PSC)
Address offset: 0x28
```
The prescalare is used to divide the clock source. For example, with the default
8MHz clock on my board we would get a 8 000 000 counts per second. That is a
large number of counts and we might not require that. We can therefor divide
the clock with a number to bring the number of counts down. For example, we
could divide the clock to bring the number of counts before the under/overflow
of the counter occurs and we either poll or an interrupt is triggered:
```
8000000/8     = 1000000
8000000/80    = 10000 
8000000/800   = 10000
8000000/8000  = 1000
8000000/80000 = 100
```
This value is that is placed in the prescalare register and can be though of as
the clock source frequence for this timer. This value will then be used with the
auto-reload value.

#### TIM2 Auto-Reload Register (TIM2_ARR)
Address offset: 0x2C
This value is used to calculate the value to be placed in the CNT register when
a counter under/over flows:
```
prescaled_clock_source / auto-reload value
```

### Timer sizes (bits)
Timers are sometimes give in bit sizes. Like the SysTick timer for example which
can have a maximum value of 2²⁴:
```
2²⁴ = 16777216
```
Now, if our clock has a frequency of 8MHz the we have the following:
```
                1
  16777216 * --------- = 2,097sec
             8000000
(max value)  (one cycle) (timer size in second)
```
So what does "timer size in seconds" mean?  
Well it means that if will take 2,097 seconds to count down from 16777216 to
zero. So we can't create a delay greater than 2,097seconds. So if we wanted to
have a delay of 5 seconds just using this setup would not work (one would have
to call the timer multiple times but it would not be possible to have a delay
of 5 seconds with just one count of the timer).


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
interested in enabling GPIO A and this is bit number 0 called GPIOAEN:
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

; ODR_OFFSET 0x14
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

### System Timer (SysTick)
Can be used to schedule something to happen on a regular basis using an internal
clock. So any Cortex-M microcontroller will provide this. This also means that
information about this timer can be found in the
[Cortex-M User Guide](https://developer.arm.com/documentation/dui0553/latest/)
and not in the board manufactures documentation.

This is a 24 bit count-down timer that counts down from value specified in the
SYST_RVR (SysTick Reload Value Register). The value in that register is copied
into the Current Value Register (CVR). It is the value in CVR that is counted
down and once it reaches zero the value from the RVR registr will be copied
again:
```
                +------------------------+
                | Reload Value Register  |
                +------------------------+
                            ↓ (reload value copied when counter is zero)
  _   _   _     +------------------------+
_| |_| |_| |_-->| Current Value Register |
     ↑          +------------------------+
     |
(clock cycles)
Each cycle will decrement the value in the current value register.
```
So the clock source will play an important role here. The internal clock on my
board is 8MHz, that is 8000000 cycles per second. One clock cycle would the be
1/8000000 which is 12.5nsec.
So if we want to have a timer every second we could use 8000000-1 (starts
counting from zero). And half a second would be 4000000-1. So the unit here is
clock cycles that we are dealing with.

When the counter reaches zero it may raise an exception if that has been enabled
, using `TICKINT` in the CSR, and the `COUNTFLAG` bit in CSR will be set to 1.

#### SysTick Control and Status Register (SYST_CSR)
Address: `0xE000E010`  
This 32 bit register is used to enable the SysTick features.
```
Bit 16 Count Flag 1 = timer counted to 0 since last time it was read.
Bit  2 CLKSource 1 = processor clock, 0 external clock.
Bit  1 TICKINT (Tick interrupt/exception) 0 = when 0 is reached then an
       exception/interrupt will not be raised.
Bit  0 Enable 1 = enable
```


In systick.s there SYST_CSR registry is read into R1 and then we try to clear
it
```console
(gdb) l
173	systick_init:
174	  /* Clear the SysTick Control Register */
175	  ldr r1, =SYST_CSR
176	  mov r2, #0
177	  str r2, [r1]

(gdb) p/t $r1
$1 = 11100000000000001110000000010000
(gdb) si
(gdb) si
(gdb) si
$3 = 0
(gdb) p/t $r1
$4 = 11100000000000001110000000010000
```
But this register is never wrtten to.
If I try to access this memory I get:
```console
(gdb) x/t $r1
0xe000e010:	Cannot access memory at address 0xe000e010
```
So this seems to be an issue with GDB and there is a work around for it:
```console
(gdb) set mem inaccessible-by-default off
```
With that setting I'm able to see that the register is cleared:
```console
(gdb) x/t $r1
0xe000e010:	00000000000000000000000000000000
```

#### SysTick Reload Value Register (SYST_RVR)
Address: `0xE000E014`  
This register specifies the start value for the counter and is loaded into the
SYST_CVR register and the counter reaches zero.
```
Bit 0-23 Reload The value to be loaded into the SYST_CVR registry.
```


#### SysTick Current Value Register (SYST_CVR)
Address: `0xE000E018`
Returns the current value of the SysTick counter.
```
Bit 0-23 Current value.
```

#### SysTick Calibration Value Register (SYST_CVR)
Address: `0xE000E01C`


The default frequency of the clock on my board is 8MHz, so it can complete
8000000 (miljon) clock cycles per second.
So each clock cycle takes 1/8000000.

8000000 / 8 / (1000 * ms)); 


### Interrupt Vector
In the first programs I've written I've included the following:
```assembly
Vector_Table:    
  .word     0x20002000
ResetVector:
  .word     start + 1
```
The first entry is for the stack pointer:
```console
(gdb) i r sp
sp             0x20002000          0x20002000
```
So the first entry is stack pointer value to be loaded in to the SP register.
The second entry in the vector table, which is a table of function pointers,
is the ResetVector. Vector seems to mean address in this context. I think this
label can be named anything, for example ResetHandler might be clearer. So in
our case we have only setup two entries in this table of function pointers.

```
Stack Pointer value                    0x0000 0000
Reset                                  0x0000 0004
NMI (Non maskable Interrupt)           0x0000 0008
Hard Fault                             0x0000 000C
SVCall                                 0x0000 002C
PendSV                                 0x0000 0038
SysTick                                0x0000 003C
```

### Access levels
There are two different execution levels called Privileged and Unprivileged
where the latter does not have access to some system registers.
The `control` register bit 0 `nPRIV` will be 0 if in privileged mode and 1 if
in unprivileged mode.

In a Reset handler this will be zero so we are running in privileged mode:
```console
(gdb) p/t $control
$2 = 0
```

### Analog to Digital Converter (ADC)
So this is about converting an analog signal, which remember can be continuos
into a descrete signal.
The ADC samples the analog input whenever one triggers it to start conversion.
It performs a process called quantization so as to decide on the voltage level
and its binary code that gets pushed in the output register.

There are 16 pins available for ADC which are called channels:
```
PA0  ADC_IN0
PA1  ADC_IN1
PA2  ADC_IN2
...
```

So we need to select a channel, and probably enable it.
The type of scanning can be a single scan or a continuous scan.



If we look at the data sheet we can find that there is one 12-bit ADC which is
connected to the APB (Advanced Peripheral Bus).
We can then look at the memory map in the reference manual to find the address:
```
0x40012400  ADC      APB
```
```
RCC_APB2ENR
Bit 9 ADCEN: ADC interface clock enable
Set and cleared by software.
  0: ADC interface disabled
  1: ADC interface clock enabled
```

#### Interrupt and Status Register (ADC_ISR_OFFSET)
Address offset: 0x00
```
Bit 2 EOC: End of conversion flag
This bit is set by hardware at the end of each conversion of a channel when a
new data result is available in the ADC_DR register. It is cleared by software
writing 1 to it or by reading the ADC_DR register.
  0: Channel conversion not complete (or the flag event was already acknowledged
     and cleared by
software)
  1: Channel conversion complete
```

#### Data Register (ADC_DR)
Address offset:  0x40

### Touch Sensing Controller (TSC)
Address: 0x40024000

This works using a feature called charge transfer and two capacitors are used.
One is for the touch sensor itself, Cₓ and one is for a sampling capacitor, Cₛ.
The capacitor Cₓ is charged and the charge accumulated is transferred into
the sampling capacitor Cₛ. This process continues until the charge in Cₛ reached
a predefined limit Vᵢₕ (Input voltage, min high voltage level). This will take
a certain number of clock cycles for a non-touched sensor. When the sensor is
"touched" the charge in Cₓ will be a little higher, and this larger charge will
be transferred into Cₛ. 
```
Threshold: 18

Clock cycles    Cₓ Non-touched Cₛ
1               6              6
2               6              12
3               6              18

Clock cycles    Cₓ Touched     Cₛ
1               9              9
2               9              18
```
The above values are completely made up and are just a way to understant how I
think this works. In this case the theshold is 18 (something, perhaps micro
farads) and without the sensor being touched it would take 3 clock cycles to
reach the threshold. When the sensor it "touched" this capacitiy of Cₓ increases
and it only takes two transferrs to reach the threshold. When this happens it
is detected by TSC.

So if we want to have a touch key using the discovery board that I've got I will
need one GPIO port for the touch key, capacitor Cₓ, and also on GPIO port for
the sampling capacitor Cₛ.

The STM32F072 Discovery board I'm using has a linear touch sensor/touch key.
So this sensor can be used as a 3 position linear sensor or as 4 touch keys.
3 pairs of I/O ports are assigned to the "pad":
```
PA2, PA3 (group 1)
PA6, PA7 (group 2)
PB0, PB1 (group 3)
```
So if I want to use the first section of the "pad" as a touch key I would use
PA2 and PA3 I guess.

The following is from the discovery board data sheet
(3.13 Touch sensing controller):
```
Group              Pin
1     TSC_G1_IO1   PA0
      TSC_G1_IO2   PA1
      TSC_G1_IO3   PA2
      TSC_G1_IO4   PA3

2     TSC_G2_IO1   PA4
      TSC_G2_IO2   PA5
      TSC_G2_IO3   PA6
      TSC_G2_IO4   PA7
...
```
And if we look at the laternative function for PA2 we can see that it is AF3.
```
Pin              Alternat function      GPIOA_AFR
PA0              TSC_G1_IO1             AF3
PA1              TSC_G1_IO2             AF3
PA2              TSC_G1_IO3             AF3
PA3              TSC_G1_IO4             AF3
```
One of the GPIOs is dedicated to the sampling capacitor CS. Only one sampling
capacitor I/O per analog I/O group must be enabled at a time.

Lets start with that enabling Port A pins 2, PA2 as the key touch sensor
, and PA3, as the sampling capacitor. So I think we need to set PA2 and PA3
as the alternative functions as AF3.


Hmm, I think I've mix things up a little here with regards to the analog to
digital converter and the touch sensing controller. I was focusing on the
sensing here and thinking that I'd be able to read the that value and convert
it to a digital signal. But the touch sensor is more about having a sensor
for an action like a button/movement. I'm going to create an example of using
just the TSC and the ADC example will use an external sensor instread.

[tsc.s](../stm32f0-discovery/tsc.s) is implementation for this section.

We also need to enabled TSC by setting TSCEN in RCC_AHBENR:
```
Bit 24 TSCEN: Touch sensing controller clock enable
Set and cleared by software.
  0: TSC clock disabled
  1: TSC clock enabled
```

#### TSC Base address
Address: 0x40024000

#### TSC I/O Analog Switch Control Register (TSC_IOASCR)
Offset: 0x18

```
These bits are set and cleared by software to enable/disable the Gx_IOy analog switch.
  0: Gx_IOy analog switch disabled (opened)
  1: Gx_IOy analog switch enabled (closed)
Note: These bits control the I/O analog switch whatever the I/O control mode is (even if
controlled by standard GPIO registers).
```
TODO: not sure if this need to be set for this example.

#### TSC I/O Sampling Control Register (TSC_IOSRC)
Offset: 0x20

This register is used to set the sampling capacitor.

```
Bits 31:0 Gx_IOy: Gx_IOy sampling mode
These bits are set and cleared by software to configure the Gx_IOy as a sampling capacitor
I/O. Only one I/O per analog I/O group must be defined as sampling capacitor.
  0: Gx_IOy unused
  1: Gx_IOy used as sampling capacitor
```
Like we mentioned above we are going to be using Group 1 and let PA3 be the
sampling capacitator, so we would set bit 2 which is G1_IO3. 

#### TSC I/O Channel Control Register (TSC_IOCCR)
Offset: 0x28

This register is used to enable a GPIO pin as a channel.
```
Bits 31:0 Gx_IOy: Gx_IOy channel mode
These bits are set and cleared by software to configure the Gx_IOy as a channel I/O.
0: Gx_IOy unused
1: Gx_IOy used as channel
```
In our case we are going to use PA2 as the channel so we need to set G1_IO3
which is bit 3.

#### TSC I/O Group Control Status Register (TSC_IOGCSR)
Offset: 0x30

This register is used to enable the TSC IO group:
```
Bits 23:16 GxS: Analog I/O group x status
These bits are set by hardware when the acquisition on the corresponding enabled analog I/O
group x is complete. They are cleared by hardware when a new acquisition is started.
  0: Acquisition on analog I/O group x is ongoing or not started
  1: Acquisition on analog I/O group x is complete

Bits 7:0 GxE: Analog I/O group x enable
These bits are set and cleared by software to enable/disable the acquisition (counter is
counting) on the corresponding analog I/O group x.
  0: Acquisition on analog I/O group x disabled
  1: Acquisition on analog I/O group x enabled
```
In our case we need to enable Group 1 which is G1E (bit 0);

#### TSC Group x counter register (TSC_IOGxCR) 
Where x can be any of the 1-8 groups.
Address Offset: 0x30 + (0x04 * group nr)
This register is a register per group which holds the count of the charge
transfers from Cₓ to the sampling capacitor Cₛ.

```
Bits 13:0 CNT[13:0]: Counter value
These bits represent the number of charge transfer cycles generated on the
analog I/O group x to complete its acquisition (voltage across CS has reached
the threshold).
```
This offset would be 0x34 for group 1.


#### TSC Control Register (TSC_CR)
Offset:  0x00
```
Bit 1 START: Start a new acquisition
This bit is set by software to start a new acquisition. It is cleared by
hardware as soon as the acquisition is complete or by software to cancel the
ongoing acquisition.
  0: Acquisition not started
  1: Start a new acquisition

Bit 0 TSCE: Touch sensing controller enable
This bit is set and cleared by software to enable/disable the touch sensing
controller.
  0: Touch sensing controller disabled
  1: Touch sensing controller enabled
Note: When the touch sensing controller is disabled, TSC registers settings
have no effect
```

#### TSC Interrupt Status Register (ISR)
Offset: 0x0C
```
Bit 0 EOAF: End of acquisition flag
This bit is set by hardware when the acquisition of all enabled group is
complete (all GxS bits of all enabled analog I/O groups are set or when a max
count error is detected). It is cleared by software writing 1 to the bit EOAIC
of the TSC_ICR register.
  0: Acquisition is ongoing or not started
  1: Acquisition is complete
```

#### TSC I/O Channel Control Register (TSC_IOCCR)
Offset: 0x28
```
```

### Interrupts
In Cortex-m there is a hardward component in the processor named Nested Vector
Interrupt Controller (NVIC) that handles interrups, which are called exceptions
in ARM. So peripherals like UART, Timers can generate interrupts. 

The SYSTICK timer can be set to enable interrupts and have an interrupt handler
called when the interrupt event happens. And example of this can be found in
[systickint.s](../stm32f0-discovery/systickint.s).

One thing to note about the vector table is the addition of 1 to the function
pointer addresses:
```assembly
Vector_Table:                        // Vector                     Exception Nr 
  .word     0x20002000               // Initial Stack Pointer value       -
  .word     start + 1                // Reset                             1
  .word     null_handler + 1         // Non Maskable Interrupt            2
```
The +1 is so that the least significant bit be 1 for Thumb
code. If bit[0] is 0 it seems that will clear the Thumb state and will result
in a fault of lockup:

### Serial Peripheral Interface
Can be used with an interrupt or by polling and requires 4 pins for
communication. The wires uses are the same as described in
[Serial Peripheral Interface (SPI)](../README.md#serial-peripheral-interface-(spi)
but the Chip Select is called NSS instead and can have one of following
functions:
* Chip Select (normal peripheral select)
* Synchronize the data frame
* Detect a conflict between masters

The board I'm working on has two SPIs that are capable of communicating at
18Mbit/s.

SPI base addresses:
```
SPI1 base address: 0x40013000, APB bus
SPI2 base address: 0x40003800, APB bus
```

SPI1 uses RCC_APB2ENR to enable its clock:
```
Bit 12 SPI1EN: SPI1 clock enable
Set and cleared by software.
  0: SPI1 clock disabled
  1: SPI1 clock enabled
```
SPI2 uses RCC_APB1ENR to enable its clock:
```
Bit 14 SPI2EN: SPI2 clock enable
Set and cleared by software.
  0: SPI2 clock disabled
  1: SPI2 clock enabled
```

And we need four pins, one for clock, one for COPI, one for CIPO which are
normal GPIO pins, and one for NSS (Peripheral Select). We need to see where
these pins are on our board.  We can lookup this information in the boards data
sheet in Table 14 "pin definitions" page 38:
```
PA4   SPI1_NSS  (Peripheral select)
PA5   SPI1_SCL  (Clock)
PA6   SPI1_MISO (Master Input Slave Output)
PA7   SPI1_MOSI (Master Output Slave Input)
```
And if we look in Table 15 on page 44 we can see what Alternative Function we
need to configure these pins to enable SPI:
```
PA4  SPI1_NSS  AF0
PA5  SPI1_SCL  AF0
PA6  SPI_MISO  AF0
PA7  SPI_MOSI  AF0
```

#### SPI Control Register 1 (SPIx_CR1)
Offset: 0x00
Recall that there are two SPIs on my board and they have different base
addresses which is the reason for the x above.

```
Bit 6 SPE: SPI enable
  0: Peripheral disabled
  1: Peripheral enabled

Bit 2 MSTR: Master selection
  0: Slave configuration
  1: Master configuration

Bit1 CPOL: Clock polarity
  0: CK to 0 when idle
  1: CK to 1 when idle

Bit 0 CPHA: Clock phase
  0: The first clock transition is the first data capture edge
  1: The second clock transition is the first data capture edge
```

#### SPI Control Register 2 (SPIx_CR2)
Offset: 0x04

#### SPI Status Register (SPIx_SR)
Offset: 0x08

```
Bit 1 TXE: Transmit buffer empty
  0: Tx buffer not empty
  1: Tx buffer empty
Bit 0 RXNE: Receive buffer not empty
  0: Rx buffer empty
  1: Rx buffer not empty
```
#### SPI Data Register (SPIxDR)
Offset: 0x08
```
Bits 15:0 DR[15:0]: Data register
Data received or to be transmitted
The data register serves as an interface between the Rx and Tx FIFOs.
```
