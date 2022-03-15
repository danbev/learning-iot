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

### Hardware Description Language (HDL)
Provide a way of describing the behaviour without having to specify any
implementation. Note what we describing hardware in this case and this enable
us to verify the design before any hardware is constructed.
After this abstract design has been verified, we can use a tool to process
this design into a technology-specific gate-level implementation which is called
synthesis. The output of synthesis is a netlist specific to a semiconductor
technology.

### Verilog
Is a Hardware Description Language (HDL) used to describe a digital system.
Uses a `.v` file extension.

```
always @(event) begin
  [statement]
end
```
The @ and content the parenthesis means that this block will be triggered at
the condition specified in the parenthesis.

Blocks can be named:
```
always begin: Something
...
end : Something

```

Variables of type net:
* wire : connects instances
* tri : alias/same as wire
* wand : wired AND
* triand : alias/same as wand
* tri0 : nets that pull up when not driven
* tri1 : nets that pull down when not driven

### SystemVerilog
Is a superset of Verilog.

Uses a `.sv` file extension.

### Combinational logic
Does not require a clock to operate, for example an AND gate.

### Sequential logic
Does require a clock to operate, for example a D Flip-flop.

### Sensitivity list
```
       Sensitivity list
            ↓         
         |<---->|
always @ (A or B) begin
  and_gate = A & B;
end
```
Is a list of all the signals which will cause the always block to execute.
The same can also be accomplished without using combinational logic and instead
using `assign`:
```
assign and_gate = A & B;
```

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
     |       |
     |       |
     |       |------ g
     |       |
b    |       |
-----|      /
     |     /
     +----/
        |
s       |
--------+

            +---+
a ----------|AND|-------------+
     +---+  |   |             |
   +-|NOT|--|   |             |    +------+  
   | +---+  +---+             +----| OR   |
   |        +---+                  |      |---- Q
b -|--------|AND|------------------|      |
   +--------|   |                  |      |
   |        +---+                  +------+
   |                        
s -+
```
So in the above we have 2 inputs, a, b and we can select one of those using
0, or 1. The truth table for this looks like this:
```
+---------------+
| s | a | b | q |
|---------------|
| 0 | 0 | 0 | 0 |
|---------------|
| 0 | 0 | 1 | 0 |
|---------------|
| 0 | 1 | 0 | 1 |
|---------------|
| 0 | 1 | 1 | 1 |
|---------------|
| 1 | 0 | 0 | 0 |
|---------------|
| 1 | 0 | 1 | 1 |
|---------------|
| 1 | 1 | 0 | 0 |
|---------------|
| 1 | 1 | 1 | 1 |
+---------------+
```
Notice that when we set s=0, regardless of what value we specify for b, the
value of a is set as the output q. So the first two rows can be merged to one
as it does not matter that b=1 in that case. And the same goes for when we set
s=1:
```
+---------------+             X = ignored, or does not matter.
| s | a | b | q |
|---------------|
| 0 | 0 | X | 0 |
|---------------|
| 0 | 1 | X | 1 |
|---------------|
| 1 | X | 0 | 0 |
|---------------|
| 1 | X | 1 | 1 |
|---------------|
```

### Lookup tables (LUT)
These allow for performing arbitary logic. They can implement boolean
algebra equations for the number of inputs that the LUT. 

So a LUT2 could look like this:
```
                +---------------+
                | 0 | 0 | 0 | 1 |     (SRAM)
                +---------------+
                 |    |   |   |
(terms)          |    |   |   |
 a ----------- -------------------
               \ 00   01  10  11 /    (2-1 Multiplexer)
 b -----------  -----------------
                         |
                         q
```
The inputs a and b are used to 2² 1-byte digital memory that stores the truth
table. Now, the inputs `a` and `b` would be the same for both `a & b` and for
a ^ b`. If we want to instead implement the OR (`^`), we (well actually the
designer tool will do this for us) only have to update the 1-bit digital
memory to reflect the different truth table:
```
                +---------------+
                | 0 | 1 | 1 | 1 |     (SRAM)
                +---------------+
                 |    |   |   |
(terms)          |    |   |   |
 a ----------- -------------------
               \ 00   01  10  11 /    (2-1 Multiplexer)
 b -----------  -----------------
                         |
                         q
```

### Flip-Flop
Besides LUTs flip-flops are also a main part that makes up an FPGA. I went
through how these work in [Gated D-Latch](./fault-injection.md#gated_d-latch).

### Clocks
An FPGA will typically have several clock signals to allow different areas
accross the FPGA to operate at different speeds.
