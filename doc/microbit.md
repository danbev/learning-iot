### BBC Microbit v2.0
This device contains a 64 MHz Arm Context-M4 with FPU, 512 KB Flash, and
128 KB RAM.


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

