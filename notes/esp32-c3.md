## ESP32-C3-MINI-1
This is based on a RISC-V single core processor (up to 160MHz), and has 15 GPIO
pins, 4 MB of on chip flash from Espressif Systems.

![ESP32-C3-MINI-1 image](./notes/img/esp32-c3-mini1.jpg "Image of ESP32-C3-MINI-1")

### Datasheet for ESP32-C3-MINI-1
https://www.espressif.com/sites/default/files/documentation/esp32-c3-mini-1_datasheet_en.pdf

### Technical Reference Manual ESP32-C3
https://www.espressif.com/sites/default/files/documentation/esp32-c3_technical_reference_manual_en.pdf#page33

### openocd
We need to build the fork of OpenOCD:
```console
$ git clone git@github.com:espressif/openocd-esp32.git
$ ./bootstrap.sh
$ ./configure
$ make
```
The `openocd` executable can then be found in `./src/openocd`:
```console
$ ./src/openocd -v
Open On-Chip Debugger  v0.11.0-esp32-20220706-47-g9d742a71 (2022-08-08-15:14)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
```

```console
$ ./src/openocd -s tcl -f board/esp32c3-builtin.cfg
Open On-Chip Debugger  v0.11.0-esp32-20220706-47-g9d742a71 (2022-08-08-15:14)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
Info : only one transport option; autoselect 'jtag'
Info : esp_usb_jtag: VID set to 0x303a and PID to 0x1001
Info : esp_usb_jtag: capabilities descriptor set to 0x2000
Warn : Transport "jtag" was already selected
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Error: esp_usb_jtag: could not find or open device!

Error: Unsupported xlen: -1
Error: Unknown target arch!
```
