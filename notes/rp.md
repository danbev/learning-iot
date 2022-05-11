## Raspberry

### RP2040
This is a 32 bit `dual` ARM Cortex M0+ microcontroller and is the first
microcontroller designed by the Raspberry PI Foundation in 2021.
Raspberry sells this chip to other manufacturers, including Adafruit, Arduino,
Seeed Studio, SparkFun, and Pimoroni.

It is very low cost, like $1 (can this be true?) and can be programmed in
Assembly, Rust, C/C++ and MicroPython.

Datasheet: https://datasheets.raspberrypi.com/rp2040/rp2040-datasheet.pdf

RP in the name RP2040 comes from Raspberry PI, 2 is the number of cores, 0 the
type of the cores which in this case is M0+.

* Dual Cortex M0+ processor cores, up to 133 MHz
* 264 kB of embedded SRAM in 6 banks
* 30 multifunction GPIO
* 2xUART
* 2xSPI
* 2xI2C
* Programmable I/O (PIO)

### Addresses Map
Can be found in section 2.2 of the RP2040 datasheet.

APB Peripherals:
```
APB_PERIPHERALS  0x40000000
IO_BANK0_BASE    0x40014000   (GPIO_BASE)
```

### GPIO
There are to banks of 18 General Purpose Input/Ouput pins named `QSPI bank`
(Quad SPI) and `User Bank`. 

```
QSPI: QSPI_SS, QSPI_SCLK, QSPI_SD0, QSPI_SD1, SQSPI_SD2, SQPI_SD3
User Bank: GPIO0-GPIO29
```
The GPIO pins can have different functions like SPI, UART, SPI, I2C, PIO, SIO
etc.  The function of a pin is configured to getting the Function Select value
`FSEL`.
```
 +-----+   +---+
 |SPI  |---| m |
 +-----+   | u |     +-------+   output data      +----------------+
 +-----+   | x |-----|???    |------------------->|   IO PAD       |
 |PIO  |---| e |     +-------+                    |                |
 +-----+   | r |                                  |                |
 +-----+   |   |     +-------+   output enable    |                |
 |UART |---|   |-----|???    |------------------->|                |
 +-----+   |   |     +-------+                    |                |
 +-----+   |   |                                  |                |
 |I2C  |---|   |     +-------+           input    |                |
 +-----+   |   |-----|???    |<-------------------|                |
 +-----+   |   |     +-------+                    +----------------+
 |PWM  |---|   |
 +-----+   +---+
```

The IO Pad are the interface to the external circuitry. 
```
                            +----------------------------+
      Slew rate        -----|                            |
      Output Enable    -----|                            |
      Output Data      -----|                            |
      Drive Strength   -----|                            |
                            |                            |
      Input Enable     -----|                            |
      Input Data       -----|                            |
      Schmitt Trigger  -----|                            |
                            |                            |
      Pull up/ Down    -----|                            |
                            +----------------------------+
```
Notice that `Output Enable`, `Output Data`, and `Data Input` are connected to
the function controlling the pad (using FSEL).

Since there are two cores on the PI Pico there are register that perform atomic
operations. For example there is GPIO_OUT (SIO):
```
GPIO_OUT     0x010  RW  Sets the pin 0..29 to high (1) or low (0)
GPIO_OE      0x020  RW  Set output enable for pins 0..29, (1=output, 0=input)

Atomic registers:
GPIO_OUT_SET 0x014  RW  Set atomically the pin 0..29 to high (1) or low (0)
GPIO_OE_SET  0x024  RW  Set atmomically output enable for pins 0..29, (1=output, 0=input)
```

To output to a pin we will need to set the function, enable the pin as output
and write to the pins output register. Now the function select to use for to
the output pin, for example to turn on an LED which has become my first program
when encountering new hardware, we should choose Singe Cycle IO (SIO) which is
F5 in 2.19.2 Function Select table.
The following note can be found in 2.3.1.2 GPIO Control:
```
To drive a pin with the SIO’s GPIO registers, the GPIO multiplexer for this pin
must first be configured to select the SIO GPIO function.
```

Since this microcontroller has two cores it is possible for both of them to
modify a register at the same time. For this reason there are registers that
perform atomic set/clear operations.

### Single Cycle IO Block
Here the processor can drive the GPIO pins.

https://datasheets.raspberrypi.com/rp2040/rp2040-datasheet.pdf#tab-registerlist_sio

Registers in 2.3.1.7. List of Registers:
```
SIO_BASE: 0xd0000000
GPIO_IN: 0x004
GPIO_OUT: 0x010
GPIO_OE: 0x020             GPIO Output Enable
```


### Programmable I/O (PIO)
Two of these PIO block are included on the PI Pico board.

Each of these contains 4 state machines:
```
  +--------------------+
  |       PIO          |
  |  +--------------+  |
  |+-| State Machine|  |
  || +--------------+  |
  || +--------------+  |
  |+-| State Machine|  |
  || +--------------+  |
  || +--------------+  |
  |+-| State Machine|  |
  || +--------------+  |
  || +--------------+  |
  |+-| State Machine|  |
  || +--------------+  |
  ||                   |
  || +---------------+ |
  |+-| Instruction   | |
  |  | Memory 32 inst| |
  |  +---------------+ |
  +--------------------+
```
Programming is done in a custom assembly language which only has 9 instructions:
* in
* out
* push
* pull
* mov
* irq
* wait
* jmp
* set

I looks like this can also be programmed using Rust with
[pio-rs](https://github.com/rp-rs/pio-rs).

### Openocd
```console
$ git clone https://github.com/raspberrypi/openocd.git --branch rp2040 --depth=1 --no-single-branch
$ cd openocd
$ ./bootstrap
$ ./configure --enable-picoprobe --enable-sysfsgpio --enable-bcm2835gpio
$ make -j8
```
The openocd binary is then located in src/openocd.
```console
$ ./src/openocd --version
Open On-Chip Debugger 0.11.0-g610f137 (2022-05-06-14:51)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
```

Update udev rules:
```console
$ sudo cp ./contrib/60-openocd.rules /etc/udev/rules.d
```
Remember that for this to take effect you'll need to disconnect the probe if
it is currently hooked in.

![Piceprobe example](./img/picoprobe.jpg "Picoprobe image")

Using minicom:
```console
$ sudo minicom -D /dev/ttyACM0 -b 115200
```

###  rp-hal
[rp-hal](https://github.com/rp-rs/rp-hal) contains high level drivers for
RP2040 and also has board support (Supported Board Packages) for PI Pico, and
Adafruit Feather RP2040 that use the HAL but have preconfigured values for the
specific components of the board in question.

[rp2040-hal](https://github.com/rp-rs/rp-hal/tree/main/rp2040-hal) is the
hardware abstration layer for RP2040.


### USB Flashing Format (UF2)
Is a file format developed by Microsoft and can be used for flashing
microcontrollers over Mass Storage Devices (flashdrive). RP2040 contains a
bootloader that appears as a Mass Storage Device over USB which can accept UF2
format files. A UF2 file copied to the drive is downloaded and written to Flash
or RAM.

Rust produces ELF format binaries which can be converted into
[UF2](https://github.com/microsoft/uf2) using
[elf2uf2](https://github.com/JoNil/elf2uf2-rs).
```console
$ cargo install elf2uf2-rs --locked
```

### Memory
RP2040 has 16kB ROM `on-chip` at address 0x00000000 and this memory contents
(Read Only Memory remember) is fixed at manufacturing time and contains the
initial startup routine, flash boot sequence, flash programming routines, USB
mass storage support (UF2 format).

There is also 264kB `on-chip` SRAM which is divided into:
* 4 16k x 32-bit banks (64kB each, 256kB total)
* 2 1k  x 32-bits banks (4kB each, 8kB total)

SRAM is mapped to system addresses starting at 0x20000000.

There are also another 2 RAM blocks that are used for XIP caching of size
16kB starting at 0x15000000.
And 4kB for USB DPRAM at 0x50100000.

Flash is external to the chip (not on-chip) and accessed using Quad SPI (QSPI)
interface using the Execute in Place (XIP) hardware. This allows an external
flash memory hardware to be addresses/accessed by the system as though it was
internal memory. From the RP2040 datasheet:
```
Bus reads to a 16MB memory window starting at 0x10000000 are translated into a
serial flash transfer, and the result is returned to the master that initiated
the read. This process is transparent to the master, so a processor can execute
code from the external flash without first copying the code to internal memory,
 hence "execute in place"
```
Like mentioned above there is a internal cache of 16kB fr XIP caching.

### Boot
The bootrom is 16kB in size and is built into the chip and takes care of a
number of things like initializing the boot sequence for processor 0 and
processor 1 will be placed in power wait mode. It will then setup USB Mass
Storage, and set routines for programming and manipulating external flash.

Source can be found in [pico-bootrom](https://github.com/raspberrypi/pico-bootrom)

Now, with the first program I wrote which is a very basic assembly example that
turns on the onboard LED. My first attempt to just have a linker-script handle
the layout like I've done from `stm32` and `nrf` devices this did not work in
the case of PI Pico and it instead booted into USB Mass Storage mode when taking
the device out of reset. The following section will take a closer look at the
boot sequence to understand why this happening.

Simplified bootsequence:
```
    ...
      ↓ 
   +--------+  no     +------------------------------------------+
   |BootSel |---------| Conf. init Synopsys SSI for standard mode|
   +--------+         | QSPI pins                                |
      |               +------------------------------------------+
      |                     ↓
      |               +---------------+
      |               | Load and copy |
      |      +------->| 256kB to SDRAM|
      |      |        | from Flash    |
      |   no |        +---------------+
      |      |              ↓          
      |   +------+    +-----------------+
      |   | <0.5s|<-- | Verify checksum |
      |   +------+    +-----------------+
      |   yes|              ↓
      |<-----+        +-------------------+
      |               | Start executing at|
      |               | at start of the   |
      |               | copies 256kb in   |
      |               | SDRAM             |
      |               +-------------------+
 +------------------+
 | Enter USB device |
 | mode bootcode    |
 +------------------+
```

If we press the `BOOTSEL` button on during startup, it will enter USB Mass
Storage Mode for code upload and if not pressed the boot sequence will start
executing the program in flash memory.

If BOOTSEL was not pressed then there will be a step that configures SSI and
connects to I/O pads, and initializes it for Standard SPI mode which I think is
so that it can communicate with any type of Flash device that is in use. 

Next in the boot sequence 256 bytes will be read from Flash using the standard
SPI interface (at least that is how I understand it) and copies those bytes
into SDRAM. I've read that the reason form copying this is that the intention
of this code it to configure the external Flash device which need to be
disabled while doing that. These 256 bytes contain 252 bytes of code and 4 bytes
of checksum. This checksum will be verified, and if it passes execution will
start by jumping to the first bytes in the 256 bytes copied in SDRAM.

Now, if the checksum check fails, it will be retried 128 times each check
taking about 4ms which in total takes about 0.5sec. After this it will boot into
USB device mode (sounds familiar? This is what I ran into with my first program).

The second stage bootloader which is normally in a section named `.boot2` and
configures the flash chip using commands specific to the external flash chip on
the board in question. RP2040 uses an external flash chip to store program code
and different flash chips (from different manufactures) have different protocols
for configuring their chips. This is what the purpose of boot2 is. 

So to know which second stage boot loader program we need to use depends on
what kind of flash we have on our board. Lets take a look at the 
[data sheet](https://octopart.com/datasheet/w25q16jvsniq-winbond-75609620) for
 Pico:
```
External Quad-SPI Flash with eXecute In Place (XIP) and 16kByte on-chip cache.
...
Pico provides minimal (yet flexible) external circuitry to support the RP2040
chip: flash (Winbond W25Q16JV)
```
[Datasheet](https://octopart.com/datasheet/w25q16jvsniq-winbond-75609620) for
Winbond W25Q16J.
If we take a look in [boot_stage2](https://github.com/raspberrypi/pico-sdk/tree/master/src/rp2_common/boot_stage2)
we can see that there are few assembly files which have `w25q` in them, for
example [boot2_w25q080.S](https://github.com/raspberrypi/pico-sdk/blob/master/src/rp2_common/boot_stage2/boot2_w25q080.S)
and if we look in side we can see that this does in fact support W25Q16JV:
```assembly
// Device:      Winbond W25Q080
//              Also supports W25Q16JV (which has some different SR instructions)
```
Looking futher down in the comments we find that this program/functions will
configure the W25Q16JV device to run in QSPI execute in place (XIP) mode.


So the rhe reason for my first program not working  is that bootsequence will,
after a few other things which I've not fully understood yet, will read 256
bytes from flash and store them in SDRAM. This is expected to be the second
stage bootloader as discussed above.

After loading this it will verify that the checksum is correct for these 256
bytes and if that passes it will enter the second stage of the booting, which
will start after those 256 bytes. But this is a problem for us because we want
our program to run but it will not pass this boot stage (the checksum check).
The solution is provided by a python script named `pad_checksum` which can take
our binary and padded it and adds the checksum:
```console
$ hexdump -C led.bin 
00000000  00 00 00 20 01 00 00 00  04 49 05 4a 0a 60 05 49  |... .....I.J.`.I|
00000010  05 4a 0a 60 05 49 06 4a  0a 60 fe e7 cc 40 01 40  |.J.`.I.J.`...@.@|
00000020  05 00 00 00 20 00 00 d0  00 00 00 02 10 00 00 d0  |.... ...........|
00000030  00 00 00 00                                       |....|
00000034
```

```assembly
.section .boot2, "ax"

.byte 0x00, 0x00, 0x00, 0x20, 0x01, 0x00, 0x00, 0x00, 0x04, 0x49, 0x05, 0x4a, 0x0a, 0x60, 0x05, 0x49
.byte 0x05, 0x4a, 0x0a, 0x60, 0x05, 0x49, 0x06, 0x4a, 0x0a, 0x60, 0xfe, 0xe7, 0xcc, 0x40, 0x01, 0x40
.byte 0x05, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0xd0, 0x00, 0x00, 0x00, 0x02, 0x10, 0x00, 0x00, 0xd0
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4f, 0x31, 0x6b, 0xe0
```
And this assembly file can then be assembled and linked and will then work. An
example can be found in [led.s](../rp/led).

### Hook up
In my case I've got two Pico's and I'm going to use one a programmer and the
other as the target where application will be run.

```console
$ git clone https://github.com/raspberrypi/picoprobe.git
$ cd picoprobe
$ mkdir build
$ Cmake -G "Unix Makefiles" ..
$ make
```
Now press the BOOTSEL button and while pressing it connect the debugger probe
into the host using the USB cable.
Now we are going to copy the generate picoprobe.uf2 to the mounted mass storage
device named `RPI-RP2`. We can find its path by using:
```console
$ lsblk
NAME                            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                               8:0    1     0B  0 disk 
sdb                               8:16   1     0B  0 disk 
sdc                               8:32   1     0B  0 disk 
sdd                               8:48   1   128M  0 disk 
└─sdd1                            8:49   1   128M  0 part /run/media/danielbevenius/RPI-RP2
```
```console
$ cp picoprobe.uf2 /run/media/danielbevenius/RPI-RP2/
```
The onboard LED should now be turned on.

```console
$ lsblk

$ cp blink.uf2 /run/media/danielbevenius/RPI-RP2 
```

### Synchronous Serial Interface (SSI)
This is a controller on the QSPI pins and is used to communicate with external
Flash devices. SSI is part of the Execute in Place block (XIP block).

This is covered in section 4.10 of the Peripheral section of the datasheet. It
contains the following:
```
The SSI controller is based on a configuration of the Synopsys DW_apb_ssi IP
```
DW stands for Design Ware, and apb stand for advanced peripheral bus. IP stands
for Intelectual Property (IP as in FPGA IP) which is a block of logic or data
used in making FPGAs or application specific integrated circuits. There are
three categories of IPs, hard cores, firm cores, and soft cores.  

The APB port connects the IP instance to the rest of the SoC while the bus is 
connectd to the register interface and DMA.

On RP2040 DW_abp_ssi is a component of the flash execute-in-place subsystem
and provides communication with an external SPI, dual SPI or QSPI flash device.

### Clocks


### Resus
Short for resuscitation is a curcuit that enables which will switch the clk_sys
back to a known good clock source if software for some reason has stopped the
clock (which would normally cause an unrecoverable lock-up).
The on-chip resus component restarts the system clock from a known good clock if
it is accidentally stopped. This allows the software debugger to access
registers and debug the problem.

### Single Cycle IO (SIO)
```
  +--------+                         +--------+
  | Core 0 |                         | Core 1 |
  +--------+                         +--------+
      ↑                                   ↑
    IOPort                              IOPort
      ↓                                   ↓

-----------   Single-cycle I/0 -----------------------------------------

 +---+                                         +---+
 | B |←----- CPUID 0         CPUID 1 ---------→| B |
 | u |                                         | u |
 | s |----------→ FIFO to Core 1 -------------→| u |
 |   |←---------- FIFO to Core 1 ←-------------|   |
 | I |                                         | I |
 | n |←-------→ Hardware Spinlock (32) ←------→| n |
 | t |                                         | t |
 | e |←-----→ Integer Divider                  | e |
 | r |                 Integer Divider -------→| r |
 | f |←-----→ Interpolator 0                   | f |
 | a |                 Interpolator 0  -------→| a |
 | c |←-----→ Interpolator 1                   | c |
 | e |                 Interpolator 1  -------→| e |
 +---+                                         +---+
   ↑
 +--------------------------------------------------+
 |  GPIO Registers, shared and atomic (set/clear/xor|
 +--------------------------------------------------+
                       ↑
-----------   Single-cycle I/0 -----------------------------------------
                       ↓
                    GPIO Muxing
```
Address range: 0xd0000000 to 0xd000017c.  

THE CPUID registers are the first and this value will be 0 if read from
Core 0, and 1 if read from Core 1
```console
(gdb) x/t 0xd0000000
0xd0000000:	00000000000000000000000000000000
```
So this gives us a why to know which core we are one.

There are two banks:
* Bank 0:  GPIO_0 - CPIO_29 
* QSPI: GPIO_HI_0, GPIO_HI_SCLK, GPIO_HI_SSn, GPIO_HI_SD0, GPIO_HI_SD1, GPIO_HI_SD2, GPIO_HI_SD3

These GPIO registers are shared between both cores so both can access them at
the same time.
There are registers like GPIO_OUT which is used to set the output level.

SIO appears as memory mapped hardware withing the IOPort space. The FIFO allow
for message passing between the two cores and the spinlocks enable
synchronization.


### Turn on LED from GDB
First set function select SIO (5) for pin 25 (the PI Pico onboard LED):
```console
(gdb) set *(0x400140CC as *mut i32) = 5
(gdb) x/t 0x400140CC
0x400140cc:	00000000000000000000000000000101
```
Next, set enable output:
```console
(gdb) set *(0xd0000020 as *mut i32) = 1 << 25
(gdb) x/t $0xd0000020 
0xd0000020:	00000010000000000000000000000000
```
And finally turn on the LED:
```console
(gdb) set *(0xd0000010 as *mut i32) = 1 << 25
(gdb) x/t 0xd0000010
0xd0000010:	00000010000000000000000000000000
```
Notice that I needed to use a Rust cast in this case for the memory location
and the dereferencing it.
