### Controller Area Network (CAN)
This directory contains assembly language examples related to CAN.

#### CAN loopback example
This example can be run without any external transceiver or wires connected
(wires for CAN that is) and use the CAN loopback to send and receive data. The
received data is then sent using UART so that it can be inspected using minicom.

##### Building
```console
$ make can-loopback.elf
```

##### Flash and Run
First start openocd:
```console
$ make openocd
```

Start a telnet session:
```console
$ telnet localhost 4444
```

Flash the program:
```console
> reset halt 
> flash write_image erase can-loopback.elf.hex
```

Start `minicom`:
```console
$ minicom --baudrate 115200 --device /dev/ttyUSB0
```
Next press the reset button and 'A7' should be displayed in minicom. The A is
the data sent to the CAN bus and 7 is the identifier of the CAN frame.
TODO: Add image of running.
