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

_wip_
