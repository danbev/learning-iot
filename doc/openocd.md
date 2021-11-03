### Open On-Chip Debugger (openocd)
[openocd](https://github.com/openocd-org/openocd) uses Jim-Tcl which is a
stripped down version of Tcl and openocd configuration scripts are Jim-Tcl
scripts. For some notes and examples see
[learning-tcl](https://github.com/danbev/learning-tcl)

Mostly focuses on JTAG and the transport protocol. So we need to have support
for JTAG which is a hardware component on the chip

### Running
Without any command line options openocd will use a default configuration
file named openocd.cfg.

This file can be found in in `/usr/share/openocd/`:
```console
$ ls /usr/share/openocd/
OpenULINK  scripts
```
And in scripts we can find the following directories:
```console
$ ls /usr/share/openocd/scripts/
bitsbytes.tcl  board  chip  cpld  cpu  fpga  interface  mem_helper.tcl  memory.tcl  mmr_helpers.tcl  target  test  tools
```
Now, in my situation I have a STM32F072B-DISCO development board which comes
with a built in ST-LINK. So I might be able to find the board configuration in
the `board` directory and the adapter/interface in the `interface` directory.

```console
$ ls /usr/share/openocd/scripts/board/stm32f0discovery.cfg 
/usr/share/openocd/scripts/board/stm32f0discovery.cfg

$ cat /usr/share/openocd/scripts/board/stm32f0discovery.cfg 
# This is an STM32F0 discovery board with a single STM32F051R8T6 chip.
# http://www.st.com/internet/evalboard/product/253215.jsp

source [find interface/stlink.cfg]

transport select hla_swd

set WORKAREASIZE 0x2000
source [find target/stm32f0x.cfg]

reset_config srst_only
```
The source command will execute the script found by the find command. So lets
take a look at `interface/stlink.cfg`:
```console
$ cat /usr/share/openocd/scripts/interface/stlink.cfg 
#
# STMicroelectronics ST-LINK/V1, ST-LINK/V2, ST-LINK/V2-1, STLINK-V3 in-circuit
# debugger/programmer
#

adapter driver hla
hla_layout stlink
hla_device_desc "ST-LINK"
hla_vid_pid 0x0483 0x3744 0x0483 0x3748 0x0483 0x374b 0x0483 0x374d 0x0483 0x374e 0x0483 0x374f 0x0483 0x3752 0x0483 0x3753

# Optionally specify the serial number of ST-LINK/V2 usb device.  ST-LINK/V2
# devices seem to have serial numbers with unreadable characters.  ST-LINK/V2
# firmware version >= V2.J21.S4 recommended to avoid issues with adapter serial
# number reset issues.
# eg.
#hla_serial "\xaa\xbc\x6e\x06\x50\x75\xff\x55\x17\x42\x19\x3f"
```
So we should be able to simply specify stm32f0discovery.cfg and the interface
config will be included.
```console
$ openocd -d -f board/stm32f0discovery.cf
```

openocd starts as a server waiting for connections. You can use telnet or GDB
to connect and then issue openocd commands. Just note that when in GDB you need
to specify the command `monitor` first followed by the openocd command so that
GDB can differentiate it from other commands.
```
  Host
 +-----------+    Debug Adapter               Board
 | +-------+ |    +----------+              +-----------+
 | |OpenOCD| |---→| ST-Link  |-------------→| CMU       |
 | +-------+ |USB +----------+  JTAG/SWD    +-----------+
 |     ↑     |
 |     ↓     |
 | +-------+ |
 | |ST-Link| |
 | |Driver | |
 | +-------+ |
 +-----------+
```
In my case the ST-Link is on the board itself but this is the general model.
So the debug adapter will take commands and messages send using USB into the
equivalent SWD or JTAG signaling.
For this in-circuit ST-Link only SWD seems to be supported.

### ST-LINK
```make
.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
```

### Test Access Port (TAP)

### Commands


### Listing adapters
An adapter is a hardware device that connects to the computers USB and then

```console
$ openocd -c 'adapter list'
Open On-Chip Debugger 0.11.0
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
The following debug adapters are available:
1: parport
2: dummy
3: ftdi
4: usb_blaster
5: jtag_vpi
6: jtag_dpi
7: ft232r
8: amt_jtagaccel
9: gw16012
10: presto
11: usbprog
12: openjtag
13: jlink
14: vsllink
15: rlink
16: ulink
17: arm-jtag-ew
18: buspirate
19: remote_bitbang
20: hla
21: osbdm
22: opendous
23: sysfsgpio
24: linuxgpiod
25: xlnx_pcie_xvc
26: aice
27: cmsis-dap
28: kitprog
29: xds110
30: st-link
```

### ST-LINK
Just pasting this from the user guide in case I ran into any issues:
```
For info the original ST-LINK enumerates using the mass storage usb class; however, its
implementation is completely broken. The result is this causes issues under Linux. The
simplest solution is to get Linux to ignore the ST-LINK using one of the following methods:
• modprobe -r usb-storage && modprobe usb-storage quirks=483:3744:i
• add "options usb-storage quirks=483:3744:i" to /etc/modprobe.conf
```
