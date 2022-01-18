## Nordic Semiconductor 
Is a company from Norway that produces semiconductors.

### nRF51
Uses ARM-Cortex M0 as their core mcu.

### nRF52
Uses ARM-Cortex M4 as their core mcu.

### nRF53
Uses ARM-Cortex M33 as their core mcu.

### nRF91
LTE

### Development
The system-on-chip (SoC) that is on the microbit device is a nRF52833, which
contains the 64MHz Arm Cortex-M4.

So I'm wondering if the same type of assembly programams that I've written for
stm32 would work for this device as well. The registers and all that would be
totally different but the general process migth be possible is what I'm
thinking like the linker-script.ld with some modifications and the Makefiles.

[nRF52833 Product Specification](https://infocenter.nordicsemi.com/pdf/nRF52833_PS_v1.5.pdf)

### I2C
This is called Two-Wire Inteface in nRF so the register names will be TWI1 etc.

### EasyDMA
TODO:

### Memory configuration
If an application does not use a SoftDevice or a Master Boot Record then the
Flash memory should be 0x0.

How do I know if the application uses a SoftDevice?  
For a bare-metal assembly example where I'm not using anything except a linker
script that I've written if there anything reason why I should not use 0x0 as
the origin of the Flash memory?
No, I don't think so.

When using a SoftDevice the linker would need to have access to the SoftDevice
object file during the linking, and the linker script would have to have memory
configuration and section for it.

### SoftDevice
A SoftDevice is a wireless protocol stack that complements an nRF5 Series System
on Chip (SoC).

SoftDevices are a closed source C binary written by Nordic for their
microcontrollers that sits at the bottom of flash and is called first on
startup. The softdevice then calls your application or bootloader or whatever
is sitting directly after it in flash.

So this will affect the linker-script and the origin of flash memory.

### Peripherals
Each peripheral is assigned a block of 0x1000 (4096) bytes of address space. So
that gives 4096 x 8 = 32768, providing 1024, 32 bit registers. 

```
0x40000000 ID = 0   1073741824
0x40001000 ID = 1   1073741824 + 4096    = 1073745920  = 0x40001000
0x40002000 ID = 2   1073741824 + 2*4096  = 1073750016  = 0x40002000
   ...
0x4001F000 ID = 31  1073741824 + 31*4096 = 1073868800  = 0x40001F00
```
Most peripherals have an enable register that is used to enable the peripheral
in question. For example, lets take GPIO P0:
```
ID  Base Address
0   0x50000000
```
The pins available for each port are PIN0 to PIN31 and each pin can be
configured using the PIN_CNF[n].

Peripherals are controlled by the CPU writing config registers and task
registers. When a peripheral wants to signal that something has occurred it will
write to the event register.

### Task registers
Task are registers as are events. Writing to a task register will start some
task (what ever that might mean to some module in the system that is interested
(reads the task register value).

### Event registers
The events register are like status registers
and reading a `1` means that a particular event has occurred. The event can be
cleared by writing `0`.

### General Purpose I/0 Task and Events (GPIOTE)
Is a way of accessing GPIO pins using tasks and events. So a GPIOTE channel
would be associated with a pin and we can enable it so that when a state change
occurs a task will automatically created.

How this works is that we configure a register named CONFIG[n] (where n is
between 0 and 7) and specify which port/pin to connect (the channel?) to.
There are more options that can be configured and there is an example in
[led-external-gpiote.s](../nrf/led/led-external-gpiote.s) which shows the other
options available. After this we can write to this channel (I'm really not sure
if I'm using the right terminology here but hopefully this makes sense just the
same) using the register `TASKS_OUT[n]` or `TASKS_SET[n]`.
