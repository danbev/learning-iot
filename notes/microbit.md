### BBC Microbit v2.0
This device contains a 64 MHz Arm Cortex-M4 with FPU, 512 KB Flash, and
128 KB RAM.

The system-on-chip (SoC) that is on this device is from Nordic Semiconductors
and is nRF52833, which contains the 64MHz Arm Cortex-M4, a BLE

This [page](https://tech.microbit.org/hardware/#overview) contains a nice
overview of the microbit.

When connected to a computer it identifies as a USB storage device.
```console
[781499.725294] usb 1-1: new full-speed USB device number 104 using xhci_hcd
[781499.854283] usb 1-1: New USB device found, idVendor=0d28, idProduct=0204, bcdDevice=10.00
[781499.854295] usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[781499.854300] usb 1-1: Product: "BBC micro:bit CMSIS-DAP"
[781499.854304] usb 1-1: Manufacturer: ARM
[781499.854307] usb 1-1: SerialNumber: 9904360258824e45005680040000004b000000009796990b
[781499.865063] usb-storage 1-1:1.0: USB Mass Storage device detected
[781499.865645] scsi host3: usb-storage 1-1:1.0
[781499.867705] hid-generic 0003:0D28:0204.001D: hiddev97,hidraw7: USB HID v1.00 Device [ARM "BBC micro:bit CMSIS-DAP"] on usb-0000:00:14.0-1/input3
[781499.891601] cdc_acm 1-1:1.1: ttyACM0: USB ACM device
[781499.891651] usbcore: registered new interface driver cdc_acm
[781499.891653] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[781500.927456] scsi 3:0:0:0: Direct-Access     MBED     VFS              0.1  PQ: 0 ANSI: 2
[781500.928355] sd 3:0:0:0: Attached scsi generic sg3 type 0
[781500.928820] sd 3:0:0:0: [sdd] 131200 512-byte logical blocks: (67.2 MB/64.1 MiB)
[781500.929057] sd 3:0:0:0: [sdd] Write Protect is off
[781500.929064] sd 3:0:0:0: [sdd] Mode Sense: 03 00 00 00
[781500.929291] sd 3:0:0:0: [sdd] No Caching mode page found
[781500.929299] sd 3:0:0:0: [sdd] Assuming drive cache: write through
[781500.947699]  sdd:
[781500.959097] sd 3:0:0:0: [sdd] Attached SCSI removable disk
```
To flash a program to the device one can simply copy a .hex file to the device:
To find the mounted drive:
```console
$ lsblk
NAME                            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sdd                               8:48   1  64.1M  0 disk /run/media/danielbevenius/MICROBIT
zram0                           252:0    0     8G  0 disk [SWAP]
nvme0n1                         259:0    0 476.9G  0 disk 
├─nvme0n1p1                     259:1    0   600M  0 part /boot/efi
├─nvme0n1p2                     259:2    0     1G  0 part /boot
└─nvme0n1p3                     259:3    0 475.4G  0 part 
  ├─fedora_localhost--live-root 253:0    0    70G  0 lvm  /
  ├─fedora_localhost--live-swap 253:1    0  15.7G  0 lvm  [SWAP]
  └─fedora_localhost--live-home 253:2    0 389.7G  0 lvm  /home
```
Then we can copy the using:
```console
$ cp src/microbit-Flashing-Heart.hex /run/media/danielbevenius/MICROBIT
```

```console
$ cat /run/media/danielbevenius/MICROBIT/DETAILS.TXT 
# DAPLink Firmware - see https://mbed.com/daplink
Unique ID: 9904360258824e45005680040000004b000000009796990b
HIC ID: 9796990b
Auto Reset: 1
Automation allowed: 0
Overflow detection: 0
Incompatible image detection: 1
Page erasing: 0
Daplink Mode: Interface
Interface Version: 0255
Bootloader Version: 0255
Git SHA: 1436bdcc67029fdfc0ff03b73e12045bb6a9f272
Local Mods: 0
USB Interfaces: MSD, CDC, HID, WebUSB
Bootloader CRC: 0x828c6069
Interface CRC: 0x5b5cc0f5
Remount count: 0
URL: https://microbit.org/device/?id=9904&v=0255
```

```console
$ sudo openocd -f interface/cmsis-dap.cfg -f target/nrf51.cfg
Open On-Chip Debugger 0.11.0
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

### Creating an application for the micorbit
The following command was used to create [microrust-start](../microrust-start):
```console
$ cargo new microrust-start
$ cd microrust
$ rustup target add thumbv6m-none-eabi
```
To build this project the following command can be used:
```console
$ cargo build --target thumbv6m-none-eabi
```

Notice that [main.rs](../microrust-start/src/main.rs) has been updated to include
the attribute `no_std` and `no_main`, and depencenies to `panic-halt` and
`microbit` have been added. Also the default main function has been replaced.

The `microbit` depencency depens on `cortex-m-rt` which requires a memory.x
file that is specific to the microcontroller being targeted. This file contains
the memory layout for the specific microcontroller.

```console
error: language item required, but not found: `eh_personality`
```
Possibly cause is forgetting to specify a `--target`. For example just doing
`cargo build` instead of `cargo build --target thumbv6m-none-eabi`.

```console
$ file target/thumbv6m-none-eabi/debug/microrust-start
target/thumbv6m-none-eabi/debug/microrust-start: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, with debug_info, not stripped
```
