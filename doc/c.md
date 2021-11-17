### Working with C
This document contains notes related to building C language programs for
ARM cortex microcontrollers.

### libopencm3
[libopencm3](https://github.com/libopencm3/libopencm3) is an open source
firmware library for ARM Cortex-M microcontrollers.

#### libopencm3 examples
There are [examples](https://github.com/libopencm3/libopencm3-examples) for 
various microcontrollers which can be useful references. Just clone that repo
and then run:
```console
$ git submodule init
$ git submodule update
$ make
```
To run an example change to the example directory and run the following command:
```console
$ cd libopencm3-examples/examples/stm32/f0/stm32f0-discovery/miniblink
$ openocd -f board/stm32f0discovery.cfg
```
The from another terminal we can use telnet to connect and flash the
microcontroller:
```
$ telnet localhost 4444
> reset halt
> flash write_image erase miniblink.elf
```
This will flash the orange LED on my device.

#### Building libopencm3
I ran into thie following issue when trying to compile:
```console
$ make
make -C libopencm3 TARGETS=stm32/f1
make[1]: Entering directory '/home/danielbevenius/work/iot/learning-iot/stm32f103c8t6/libopencm3'
  BUILD   lib/stm32/f1
  CC      adc.c
In file included from ../../../include/libopencm3/cm3/common.h:63,
                 from ../../../include/libopencm3/stm32/adc.h:20,
                 from adc.c:94:
/usr/lib/gcc/arm-none-eabi/10.2.0/include/stdint.h:9:16: fatal error: stdint.h: No such file or directory
    9 | # include_next <stdint.h>
      |                ^~~~~~~~~~
compilation terminated.
make[2]: *** [../../Makefile.include:41: adc.o] Error 1
Failure building: lib/stm32/f1: code: 2
make[1]: *** [Makefile:79: lib] Error 1
make[1]: Leaving directory '/home/danielbevenius/work/iot/learning-iot/stm32f103c8t6/libopencm3'
make: *** [Makefile:38: libopencm3/lib/libopencm3_stm32f1.a] Error 2
```
This issue can be worked around by installing the following library:
```console
$ sudo dnf install -v arm-none-eabi-newlib
```
