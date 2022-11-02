## EclipseCon Hackathon Microbit probe-run issue
I got an error when running the following command in the
[firmware](https://github.com/Eclipse-IoT/eclipsecon-2022-hackathon/tree/main/firmware)
directory:
```console
$ cargo run --release
...
(HOST) INFO  flashing program (35 pages / 140.00 KiB)
(HOST) INFO  success!
Error: An error with the usage of the probe occured

Caused by:
    Operation timed out
```

Lets enable some logging for `probe-run`:

```console
$ probe-run -v --chip nrf52833_xxAA target/thumbv7em-none-eabihf/release/eclipsecon-device
...
(HOST) DEBUG Programmed page of size 4096 bytes in 117 ms
└─ probe_run @ /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/probe-run-0.3.3/src/main.rs:112
(HOST) DEBUG Programmed page of size 4096 bytes in 118 ms
└─ probe_run @ /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/probe-run-0.3.3/src/main.rs:112
(HOST) INFO  success!
└─ probe_run @ /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/probe-run-0.3.3/src/main.rs:129
(HOST) DEBUG 55352 bytes of stack available (0x200127C4 ..= 0x2001FFFC), using 1024 byte canary
└─ probe_run::canary @ /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/probe-run-0.3.3/src/canary.rs:84
(HOST) TRACE setting up canary took 0.011s (95.01 KiB/s)
└─ probe_run::canary @ /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/probe-run-0.3.3/src/canary.rs:103
(HOST) DEBUG starting device
└─ probe_run @ /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/probe-run-0.3.3/src/main.rs:187
Error: An error with the usage of the probe occured

Caused by:
    Operation timed out
```

Now, I'm able to flash this using an example from Drogue Device. I tried the
jukebox example which run without any issue.

I've also tried the [microbit blinky](./microbit-blinky.hex) app which also
deploys without issue (using the mounted USB drive).

Lets see if we can connect using openocd:
```console
$ openocd -f interface/cmsis-dap.cfg -f target/nrf51.cfg
Open On-Chip Debugger 0.11.0-g610f137 (2022-05-06-14:16)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
Info : auto-selecting first available session transport "swd". To override use 'transport select <transport>'.
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Info : Using CMSIS-DAPv2 interface with VID:PID=0x0d28:0x0204, serial=9904360258824e45005680040000004b000000009796990b
Info : CMSIS-DAP: SWD  Supported
Info : CMSIS-DAP: FW Version = 0255
Info : CMSIS-DAP: Serial# = 9904360258824e45005680040000004b000000009796990b
Info : CMSIS-DAP: Interface Initialised (SWD)
Info : SWCLK/TCK = 1 SWDIO/TMS = 1 TDI = 0 TDO = 0 nTRST = 0 nRESET = 1
Info : CMSIS-DAP: Interface ready
Info : clock speed 1000 kHz
Info : SWD DPIDR 0x2ba01477
Info : nrf51.cpu: hardware has 6 breakpoints, 4 watchpoints
Info : starting gdb server for nrf51.cpu on 3333
Info : Listening on port 3333 for gdb connections
```
And lets now connect using gdb:
```console
$ arm-none-eabi-gdb target/thumbv7em-none-eabihf/release/eclipsecon-device

(gdb) target remote localhost:3333
Remote debugging using localhost:3333
Dwarf Error: Cannot find DIE at 0x17b3b referenced from DIE at 0x5ba51 [in module /home/danielbevenius/work/iot/eclipsecon-2022-hackathon/firmware/target/thumbv7em-none-eabihf/release/eclipsecon-device]
```
This seems to be related to Link Time Optimization (LTO) and does not happend if
LTO is disabled. Disabling LTO and debug allows me to attach using gdb but
there is still a failure when trying to run the application:
```console
(gdb) monitor reset halt
target halted due to debug-request, current mode: Thread 
xPSR: 0x01000000 pc: 0x00000a80 msp: 0x20000400
(gdb) monitor reset run
nrf51.cpu -- clearing lockup after double fault
target halted due to debug-request, current mode: Handler HardFault
xPSR: 0x21000003 pc: 0x0003775a msp: 0x2001ffe0
```

I'm an idiot, the device needs to be flashed with the nrf softdevice.

Download the [softdevice](https://www.nordicsemi.com/Products/Development-software/S140/Download).

Flash the softdevice using gdb:
```console(gdb) monitor reset halt
target halted due to debug-request, current mode: Thread 
xPSR: 0x01000000 pc: 0xfffffffe msp: 0xfffffffc
(gdb) monitor flash write_image erase s140_nrf52_7.2.0_softdevice.hex
Padding image section 0 at 0x00000b00 with 1280 bytes
Adding extra erase range, 0x00026634 .. 0x00026fff
auto erase enabled
wrote 157236 bytes from file s140_nrf52_7.2.0_softdevice.hex in 7.881345s (19.483 KiB/s)
```
And now we should be able to run the eclipsecon-device:
```console
Running `probe-run --chip nrf52833_xxAA target/thumbv7em-none-eabihf/release/eclipsecon-device`
(HOST) WARN  insufficient DWARF info; compile your program with `debug = 2` to enable location info
(HOST) INFO  flashing program (42 pages / 168.00 KiB)
(HOST) INFO  success!
────────────────────────────────────────────────────────────────────────────────
0.119628 INFO  btmesh: starting up
0.120300 INFO  ========================================================================
0.120330 INFO  =  Unprovisioned                                                       =
0.120330 INFO  ------------------------------------------------------------------------
0.120361 INFO  uuid: 96E438B02ED04673A2FA0D0665522774
0.120452 INFO  ========================================================================
────────────────────────────────────────────────────────────────────────────────

Flash the softdevice using probe-rs-cli:
```console
$ probe-rs-cli erase --chip nRF52833_xxAA                                         
$ probe-rs-cli download s140_nrf52_7.3.0_softdevice.hex --format Hex --chip nRF52833_xxAA
```
