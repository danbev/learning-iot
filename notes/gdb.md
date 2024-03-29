### GDB commands related to embedded devices
The document contains gdb command useful when debugging embedded programs.

Commands like resetting and flashing a device can be done from gdb using
the `monitor` command to send commands to openocd. One way to work with this is
to have gdb connected to openocd and place gdb in the background (CTRL+Z) to
recompile, and the use `fg` to bring gdb to the forground again. Then reset
halt and flash the device. 

```console
$ arm-none-eabi-gdb spi.elf
(gdb) target remote localhost:3333
```

Halt the program:
```console
(gdb) monitor reset halt
```

Run the program:
```console
(gdb) monitor reset run
```

Flash the device:
```console
(gdb) monitor flash write_image erase spi.elf.hex
```

```console
(gdb) monitor flash list
{name stm32f1x base 134217728 size 131072 bus_width 0 chip_width 0}

(gdb) monitor flash banks
#0 : stm32f0x.flash (stm32f1x) at 0x08000000, size 0x00020000, buswidth 0, chipwidth 0
```

Get the current state for the device:
```console
(gdb) monitor stm32f0x.cpu curstate
halted
```

#### Load/reload a program
This is useful when debugging and you want to restart the debugging session.
```console
(gdb) load 
Loading section .text, size 0x1d8 lma 0x8000000
Start address 0x08000008, load size 472
Transfer rate: 1 KB/sec, 472 bytes/write.
```

### Enable inaccessible memory
If memory is outside of the memory map this command is useful to be able to
read/write this memory (this can happen if one want to inspect the registers
related to SysTick for example):
```console
(gdb) set mem inaccessible-by-default off
```
