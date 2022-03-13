### Field Programmable Gate Array 
Are application specific integrated circuits (ASIC) that can be programmed and
reprogrammed.

One reason for using one instead of a general purpose microcontroller (MCU) is
when one wants to be able to perform tasks in parallell (more than one thing at
a time).

A FPGA does not have an MCU built in, but one could create an MCU using an FPGA. 
A more common case is to have an FPGA offload an MCU and have the FPGA do
computational heavy work and let the MCU handle I/0 stuff.

An FPGA contains logical blocks which can be configured and connected by
existing wires/lines in/out from these blocks. Nothing physical changes on the
boards themselves. The configuration is stored in RAM.
Logic gates like AND, OR, XOR, NOT are used to build can be used to describe
any digital circuit. And these gates can be built using transistors, for example
and AND gate can be build with transistors like we [done](../README.md#and-gate) previously


### Application Specific Integrated Circuit (ASIC)
Is a custom built chip designed which is not reprogrammable. FPGAs can be be
used in the initial process to write and test a design before manufacturing a
APIC.

### Configurable Logic Block (CLB)
Is a fundamental piece of an FPGA and is what gives an FPGA its ability to take
on different hardware configurations. An FPGA can be viewed as many(thousands)
of these CLBs close togther and these can be programmed.
A single CLB is made up of discrete logic components like flip-flops, and/or
look up tables (LUTs).

### Verilog
Is a Hardware Description Language (HDL) used to describe a digital system.

### Register Transfer Level (RTL)
Implies that Verilog code describes how data is transformed as it flows from
register to register.

### Synthesesis
Is the process of taking an abstract specification of desired curcuit behaviour
which could be in the form of a RTL and turn that into a design implementation
in the form of logic gates. This is done using a tool.

### Place and Route
This is a stage in the design of FPGAs and is composed of two steps, namely
a place step and a route step.
The place steps is about figuring out where electrical components, ciruitry, and
logic elements are to be placed. Routing is then about hooking up these
components.


### Yosys
[Yosys](https://yosyshq.net/) is a framework for Verilog RTL syntheseis and
can handle Verilog-2005.
```console
$ sudo dnf install -y yosys

$ yosys -V
Yosys 0.14+51 (git sha1 UNKNOWN, gcc 11.2.1 -O2 -fexceptions -fstack-protector-strong -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -fPIC -Os)
```

Example of synthesis:
```console
$ yosys -p "read_verilog first.v; synth_ice40 -blif first.blif"
```

### nextpnr
[nextpnr](https://github.com/YosysHQ/nextpnr) is a tool for Place And Route.
```console
$ git clone https://github.com/YosysHQ/nextpnr nextpnr
$ cd nextpnr
$ sudo dnf install -y boost-devel boost-python3-devel eigen3-devel
$ make -j4
```

Example of Place And Route:
```console
$ nextpnr-ice40
```

### xilinx
[xilinx](https://www.xilinx.com/) is a company that is now owned by AMD.

### icestorm
[https://clifford.at/icestorm](https://clifford.at/icestorm).

```console
$ sudo dnf install -y libftdi-devel
$ git clone https://github.com/YosysHQ/icestorm.git icestorm
$ cd icestorm
$ make -j4
$ sudo make install
```

### Multiplexer
Can be built using multiple AND and one OR gate and it selects a single output
depending on the selected value:
```
     +----\
a    |     \
-----|      \
b    |       |
-----|       |
c    |       |------ g
-----|       |
d    |       |
-----|      /
     |     /
     +----/
        |
s       |
--------+

     +---+
a ---|AND|-------------+
   +-|   |             |    +------+  
   | +---+             +----| OR   |
   | +---+                  |      |
b -|-|AND|------------------|      |
   +-|   |                  |      |
   | +---+                  |      |
   | +---+                  |      |
c -|-|AND|------------------|      |
   +-|   |                  |      |
   | +---+             +----|      |
   | +---+             |    +------+
d -|-|AND|-------------+
   +-|   |
   | +---+
   |
s -+
```
Multiplexers are used for routing signals in FPGAs.

### Lookup tables (LUT)
These allow for performing arbitary logic. They can implement boolean
algebra equations for the number of inputs that the LUT. So for example if
we have a LUT with two inputs it will be able to perform any combination of the
following operations:
```
A * B                     * = AND
A + B                     + = OR
A + B_bar                 - = NOT (should be a bar over the B)
```
The following LUT takes two inputs, and hence can handle any boolean algebra
equation with two terms:
```
           +----+
In[0] -----|LUT2|
           |    |--- out
In[1] -----|    |
           +----+

+-------------------+
|in[0] | in[1] | out|
|-------------------|
|  0   |   0   | 0  |
|  1   |   0   | 0  |
|  0   |   1   | 0  |
|  1   |   1   | 1  |
+-------------------+
```
So for the inputs 00 we map that to 0, 10 to 0, 01 to 0, and 11 to 1.

This is actually implemented using a multiplexer, but instead of exposing the
inputs to the mutiplexer they are values that are programmable and they contain
the ouput of expected operation, in this case AND:
```

             +---+    +---+
   0      ---|AND|----|AND|----+
           +-|   |  +-|   |    |    +------+
           | +---+  | +---+    +----| OR   |
           | +---+  | +---+         |      |
   0      -|-|AND|--|-|AND|---------|      |
           +-|   |  +-|   |         |      |
           | +---+  | +---+         |      |
           | +---+  | +---+         |      |
   0      -|-|AND|--|-|AND|---------|      |
           +-|   |  +-|   |         |      |
           | +---+  | +---+    +----|      |
           | +---+  | +---+    |    +------+
   1      -|-|AND|--|-|AND|----+
           +-|   |  +-|   |
           | +---+  | +---+
           |        |
    s[0]  -+        |
    s[1]  ----------+
```