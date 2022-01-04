### Assembly stm32 examples
This document contains notes the assembly language examples that I've written
to learn and explore various concepts related to microcontrolers, like LEDs,
UART, SPI, I2C, CAN, Timers. The board I'm using is stm32f0-discovery:

### Examples
1. [LED](./led/README.md)
1. [UART](./uart/README.md)
1. [SPI](./spi/README.md)
1. [I2C](./i2c/README.md)
1. [CAN](./can/README.md)
1. [SysTick timer](./systick.s)
1. [SysTick timer using interrupt](./systickint.s)
1. [Timer](./tim2.s)

### Resources/Documentation
[Product documentation](https://www.st.com/en/evaluation-tools/32f072bdiscovery.html#documentation)  
[User Manual](https://www.st.com/resource/en/user_manual/um1690-discovery-kit-for-stm32f0-series-microcontrollers-with-stm32f072rb-stmicroelectronics.pdf)  
[reference manual](https://www.st.com/resource/en/reference_manual/rm0091-stm32f0x1stm32f0x2stm32f0x8-advanced-armbased-32bit-mcus-stmicroelectronics.pdf)

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

