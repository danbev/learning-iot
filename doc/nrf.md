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


### SoftDevice
A SoftDevice is a wireless protocol stack that complements an nRF5 Series System
on Chip (SoC).

SoftDevices are a closed source C binary written by Nordic for their
microcontrollers that sits at the bottom of flash and is called first on
startup. The softdevice then calls your application or bootloader or whatever
is sitting directly after it in flash.
