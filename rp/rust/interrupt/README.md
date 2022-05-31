## semihosting example
This is just an example of getting semihosting to work with Pico PI using a
separate Pico PI running Picoprobe.

Start openocd:
```console
$ ./openocd.sh
```

Build/Run and start gdb:
```console
$ cargo r
(gdb) monitor flash write_image erase target/thumbv6m-none-eabi/debug/interrupt
(gdb) load
(gdb) handle SIGTRAP nostop
(gdb) c
```
There should now be output in the openocd console similar to this:
```console
target halted due to debug-request, current mode: Thread 
xPSR: 0x01000000 pc: 0x0000012a msp: 0x20041f00
semihosting example
target halted due to debug-request, current mode: Thread 
xPSR: 0x01000000 pc: 0x0000012a msp: 0x20041f00
semihosting example
```
