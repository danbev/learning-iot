### Open On-Chip Debugger (openocd)
[openocd](https://github.com/openocd-org/openocd) uses Jim-Tcl which is a
stripped down version of Tcl and openocd configuration scripts are Jim-Tcl
scripts. For some notes and examples see
[learning-tcl](https://github.com/danbev/learning-tcl)

### Running
Without any command line options openocd will use a default configuration
file named openocd.cfg.

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
