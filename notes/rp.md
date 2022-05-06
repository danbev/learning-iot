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
$ git clone https://github.com/raspberrypi/openocd.git --recursive --branch rp2040 --depth=1
$ cd openocd
$ ./bootstrap
$ ./configure --enable-ftdi --enable-sysfsgpio --enable-bcm2835gpio
$ make -j8
```
The openocd binary is then located in src/openocd.

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

### Bootloader
PI Pico has a first stage bootloader in ROM, and cannot be changed, which is the
first thing that is run upon startup. How this works is described in the
datasheet. 
If we press the `BOOTSEL` button on during startup, it will enter USB Mass
Storage Mode for code upload and if not pressed the boot sequence will start
executing the program in flash memory.

Now, the Pico SDK will place piece of code in the start of the flash memory
instead of our program. This is called a second stage bootloader which will then
do some stuff, and later call our program. So if we look in linkerscripts of
examples in the SDK we will find this program which is called (in a section)
`boot2`. The size of boot2 is 256 kb which configures the flash chip using
commands specific to the external flash chip on the board in question. See the
RP2040 uses an external flash chip to store program code and different flash
chips (from different manufactures) have different protocols for configuring
their chips. This is what the purpose of boot2 is.

```console
$ lsblk

$ cp blink.uf2 /run/media/danielbevenius/RPI-RP2 
```
