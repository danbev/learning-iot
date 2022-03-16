## FPGA Example
The device I'm using is an
[iCE40HX1K-EVB](https://www.olimex.com/wiki/ICE40HX1K-EVB):

![FPGA Device](./img/ice40hx8k.jpg "FPGA Device")

This FPGA can be powers using a 5V barrel connector or it can be powered using
3.3V pin, but notice that this is only possible if enabled by soldering the
bridge on the bottom side of the board:

![iCE40HX8K-EVD solder bridge](./img/solder-bridge.jpg "iCE40HX8K-EVD solder bridge")

### Building
Synthesis, Place and Route, and build bitstream:
```console
$ make first.bin
```
This will produce first.bin which can then be used to flash the FPGA.

### Connections/Pins
I used the following connections on the Bus Pirate and iCE40HX8K-EVB:
```
                  +------------------------------------+
     Bus Pirate   |            iCE40HX8K-EVB           |
     +---------+  |            +-----------+           |
 +---|GND  3V3 |  |    +-------|SS_B  SCK  |-------+   |
 |   |+5V  ADC |  |  +-|-------|DSO   SDI  |-------|---+
 |   |VPU  AUX |  |  | | +-----|CRST  CDONE|       |
 | +-|CLK  MOSI|--|--+ | |     |TxD   RxD  |       |
 | |+|CS   MISO|--+    | |   +-|GND   3.3V |       |
 | ||+---------+       | |   | +-----------+       |
 | |+------------------+ |   |                     |
 | +---------------------|---|---------------------+
 |                +--------+ |
 +----------------|        |-+
                  |        |
                  +--------+
                  Breadboard
```

![Connections image](./img/connections.jpg "Connections image")

### Configure Bus Pirate
```console
$ minicom -b 115200 -8 -D /dev/buspirate
```
First we have to configure Bus Pirate to use SPI mode:
```console
HiZ>m
(1)> 5
...
Ready
(SPI)>
```
I've just used the defaults apart from selecting 250KHz. The MODE LED should be
on on the Bus Pirate now. Now exit minicom using CTRL+A+Q. 

### Flashing
Pad the binary file:
```
$ make first_pad
```

Flash the device
```console
$ make first_flash_rom
flashrom -p buspirate_spi:dev=/dev/ttyUSB0,spispeed=250k -w first.bin
flashrom v1.2 on Linux 5.13.14-200.fc34.x86_64 (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Using clock_gettime for delay loops (clk_id: 1, resolution: 1ns).
Found Eon flash chip "EN25QH16" (2048 kB, SPI) on buspirate_spi.
Reading old flash chip contents... done.
Erasing and writing flash chip... Erase/write done.
Verifying flash... VERIFIED.
```

_wip_
