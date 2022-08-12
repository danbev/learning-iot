## esp32-c3 examples
This directory contains examples of using esp32-c3-mini1 and also contains
simple risc-v assembly programs as this is the only real risc-v device I have
access to.

### Assembly examples
```console
$ make hello.elf
```
Start OpenOCD:
```console
$ make openocd
```
Start gdb:
```console
$ xtensa-esp32-elf-gdb hello.elf
```
Flashing:
```console
(gdb) target remote localhost:3333
(gdb) monitor reset halt
(gdb) monitor flash write_image erase hello.elf
```
