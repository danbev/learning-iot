## Inter-integrated circuit (I²C/I2C)
This directory contains assembly language examples related to I2C.

### I2C Controller/Peripheral example
This example for consists of two discovery boards connected to each other,
where [i2c-c.s](./i2c-c.s) is the controller which sends a character
(currently `A`) to [i2c-p.s](../i2c-p.s) which is the peripheral. The peripheral
then uses UART to send that character out which can be displayed using minicom.

#### Building
```console
$ make i2c-c.elf i2c-p.elf
```
#### Flash and Run the peripheral
Connect the USB micro cable to the STM32 ST-LINK port on the board that is
going to be used as the peripheral.

Start openocd:
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
> flash write_image erase i2c-p.elf.hex
> reset run
```

#### Flash and Run the controller
Connect the USB micro cable to the STM32 ST-LINK port on the board that is
going to be used as the controller.

Start openocd:
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
> flash write_image erase i2c-c.elf.hex
> reset run
```

Start `minicom`:
```console
$ minicom --baudrate 115200 --device /dev/ttyUSB0
```

Next press the reset button on the controller board and 'A7' should be displayed
in minicom:

![I2C Example image](../../doc/img/i2c-example.jpg "I2C Example image")
