## Fault injection notes
This document contains note related to hardware fault injection specifically
to microcontrollers.

The goal of fault injection is to be able get the CPU to skip instructions, or
incorrectly evaluate instructions, or corrupt reads from memory devices. So it
is about creating small hardware corruptions to workaround security mechanisms.

### Voltage fault-injection
This is done by dropping the supply voltage for a very brief amount of time
and timing this with a very specific operation.

### Clock fault-injection
This  is done by alternating clock timing to violate setup and hold time
requirements of the hardware.

### Electromagnetic fault-injection (EMFI)
This is done by generating a localized short duration high-intensity 
electomagnetic pulse that induces current in the internal chip circuit.

### Optical fault-injection
This is done by using infrared laser and most often requires that the chip be
decapsulated to expost the silicon die.

### Side channel
Think about putting your ear to a railway track, when no train is in sight, and
you might be able to hear a train approaching kilometers away.

There can be various types of this like infrared light on a number pad and then
after someone has used the pad to enter information it could expose what they
entered.

Or listening to a keyboard while someone is typing, apparently the keys pressed
give away unique sounds and doing frequency analysis it is figure out what they
typed. Also there is ultrasound emitted from computers and it is possible to
caputure and analysis this sounds. This was apparenetly done to extract and 
RSA keys.

This has also shown possible to "listen" to old printers to capture what is
being printed.

Also things that we don't have to think about when writing code that is expected
to run on a server somewhere like checking a a password. If strcmp is used it
will compare characters one by one and return as soon as there is a mismatch. So
if the first character is incorrect it will return directly from that call. But
if the first character is correct but to the second it will take slightly
longe. And if we are able to monitor this time we can learn the first character
and then proceed to learn the complete password.

### Fault Injection
The target for these kind of attacks are not just crypto keys and things like
that but also to circumvent access checks, permission checkts etc.

Types of physical level faults injections:
* Timing (Clock glitches)
* Power (Voltage glitches)
* ElectroMagnetic (EM) pulses 
* Heating
* Light (laser)

Exposing the device to these types of physical stress can result in circuit-
level like the logic gates, memory cells, and flip-flops. This will propagate
and cause failure/effects in the micro-archetecture level of the processor it
self and how it executes the machine instructions and accesses memory to be
used by those instructions.

If we want to inject a timing fault (clock glitch) then we would want to cause
a change in the normal clock of the microcontroller. For example if the normal
clock cycle is 80ns then causing a shorter clock cycle of say 40ns might cause
an instruction to not execute correctly. To be able to actually "zoom" in and
have this fault injected at the point that we want we need to be able to do this
multiple times at different points in time. So we need some type of software to
control configure the timeing, and hardware to cause the fault at that time. And
we also need a way to receive results from the target so that we can adjust our
configuration settings.

```

 +---------+           +----------------+
 |  PC     |---------> | Fault Injector |
 |         |---------> |                |
 |         |---------> |                |
 |         |           +----------------+
 |         |                ↑       | Fault
 |         |      Trigger   |       |
 |         |                |       ↓
 |         |           +----|-------|---+
 |         |           | Target device  |
 |         |--Reset---→-                |
 |         |←--I/O------                |
 +---------+           +----------------+
```

Be aware that monitoring may affect the system, like using an oscilloscope may
absorb a voltage glitch so it is better to disconnect these before running the
fault injection.

### Boot
Most modern devices boot from firemware images stored in flash memory and these
are usually signed, and the signature is often stored along side in flash
memory. During boot the signature is verified using the public key of the
device manufacturer. But the decision whether to boot or not to boot often
boils down to a boolean statement, for example:
```c
  int verified = verify_boot_image(image);
  if (!verified)
     fault();
  else
     boot();
```
If we can cause a fault so that the condition is skipped then that would allow
us to run a modified boot image.


### Differential Fault Analysis (DFA)
TODO: 

### Clock fault injection
This section is going to start with some background information on hardware
as this helped me understand how clock faults work.

First we are going to look at a simple Set/Reset latch, or SR Latch which is
like a 1 bit memory. It can be put into two different output states depending
on an input pulse. This circuit remembers its state until it is changes by
another input pulse. This is also called a by-stable latch.

#### NOR Gate SR-Latch:
```   
        +---+                                 NOR
R ------|NOR|-----+-------- Q                 0 0 = 1
      +-|   |     |                           1 0 = 0
      | +---+     |                           0 1 = 0
    +-------------+                           1 1 = 0
    | |
    | +-----------+
    |   +---+     |         _
    +---|NOR|-----+-------- Q
S ------|   |
        +---+

Initialy the R and S will be zero and this latch is storing 1:
  0     +---+             1
R ------|NOR|-----+-------- Q
      +-|   |     |
      | +---+     |
    +-------------+
    | |
    | +-----------+
    |   +---+     |       0 _
    +---|NOR|-----+-------- Q
S ------|   |
  0     +---+

Now we can apply a pulse to R:
  1     +---+             0
R ------|NOR|-----+-------- Q
     1+-|   |     |
      | +---+     |
    +-------------+
    | |
    | +-----------+
    | 0 +---+     |       1 _
    +---|NOR|-----+-------- Q
S ------|   |
  0     +---+

The pulse is then remove and R becomes zero again:
  0     +---+             0
R ------|NOR|-----+-------- Q
     1+-|   |     |
      | +---+     |
    +-------------+
    | |
    | +-----------+
    | 0 +---+     |       1 _
    +---|NOR|-----+-------- Q
S ------|   |
  0     +---+

To store a 1 again a pulse must be applied to S:
  0     +---+             1
R ------|NOR|-----+-------- Q
     0+-|   |     |
      | +---+     |
    +-------------+
    | |
    | +-----------+
    | 1 +---+     |       0 _
    +---|NOR|-----+-------- Q
S ------|   |
  1     +---+

Then the pulse will be removed from S:
  0     +---+             1
R ------|NOR|-----+-------- Q
     0+-|   |     |
      | +---+     |
    +-------------+
    | |
    | +-----------+
    | 1 +---+     |       0 _
    +---|NOR|-----+-------- Q
S ------|   |
  0     +---+
```
This is referred to an active high SR-Latch as the normal state of S and R is
zero (low).

#### NAND Gate SR-Latch:
We can also have SR-Latches that are built using NAND gates which are active
low:
```
  1     +----+             0                  NAND
S ------|NAND|-----+-------- Q                0 0 = 1
      +-|    |     |                          1 0 = 1
      | +----+     |                          0 1 = 1
    +--------------+                          1 1 = 0
    | |
    | +------------+
    |   +----+     |       1 _
    +---|NAND|-----+-------- Q
R ------|    |
  1     +----+

To set, we have to set S low:

  0     +----+             1
S ------|NAND|-----+-------- Q
      +-|    |     |
     1| +----+     |
    +--------------+
    | |
    | +------------+
    |  1+----+     |       0 _
    +---|NAND|-----+-------- Q
R ------|    |
  1     +----+

After that S is returned to it's normal high state 1.

To set q to 0 (reset):

  1     +----+             0
S ------|NAND|-----+-------- Q
      +-|    |     |
     1| +----+     |
    +--------------+
    | |
    | +------------+
    |  0+----+     |       1 _
    +---|NAND|-----+-------- Q
R ------|    |
  0     +----+

```
So we can build SR-Latches using NOR or NAND gates and both can do the same job
but in slightly different ways, like NOR is active high and NAND is active low.
Both of these can be used by themselves but they are also used as building
blocks of more sofisticated cirtuits.

Now, there is an issue with the above devices and that is that it is possible
to set S and R at the same time. More on this later.

#### Gated SR-Latch
In a gated SR-Latch we have an additional input named `E` for enables. This type
of latch can only have its state changed when it is enabled:
```
    +-----+
 ---|S   Q|---
 ---|E   _|
 ---|R   Q|---
    +-----+
```

In the SR-Latches we have seen above it is not the duration of the input pulses
that matter but only if they are high or low.
The enable input can be connected to two AND gates which have there other input
as R and S. So only the ciruit is enabled will the state be changed:
```
    +---+               +---+
R --|AND|---------------|NOR|-----+-------- Q
  +-|   |             +-|   |     |
  | +---+             | +---+     |
  |                 +-------------+
E +                 | |
  |                 | +-----------+
  |                 |   +---+     |         _
  | +---+           +---|NOR|-----+-------- Q
  --|AND|---------------|   |
S --|   |               +---+
    +---+
```
But notice that we still have the issue where E=1 and R=1, and S=1.

We can also have a gated SR-Latch using NAND gates, where instead of AND gates
connected to the enable wire we have NAND gates as these are active low:
```
    +----+               +----+
S --|NAND|---------------|NAND|-----+-------- Q
  +-|    |             +-|    |     |
  | +----+             | +----+     |
  |                 +---------------+
E +                 |  |
  |                 |  +------------+
  |                 |    +----+     |         _
  | +----+          +----|NAND|-----+-------- Q
  +-|NAND|---------------|    |
R --|    |               +----+
    +----+
```

#### Gated D-Latch
Is a one bit memory device (D for Data). And this is very similar to an SR-Latch
which we will see. The symbol of a Gated D-Latch is:
```
    +-----+
 ---|D   Q|---
 ---|E   _|
    |    Q|---
    +-----+
```
Notice that this is similar to the SR-Latch but it only has a two inputs instead
of three.
Now, we mentioned previously that the gated RS-Latches have an issue where it is
possible to enable the circuit and and the same time set both S and R to high
or low depending on the type of gates used. But this does not really make sense
to be able to both set and reset at the same time.

```
  1 +----+               +----+            1
S --|NAND|---------------|NAND|-----+------- Q
  +-|    |             +-|    |     |
  | +----+             | +----+     |
  |                 +---------------+
E +1                |  |
  |                 |  +-----------+
  |                 |    +----+    |       1 _
  | +----+          +----|NAND|----+-------- Q
  +-|NAND|---------------|    |
R --|    |               +----+
  1 +----+
```
This would cause a race condition between in the SR-Latch where if both S and
R fall to zero at the same time
into 
```
  0 +----+               +----+            1
S --|NAND|---------------|NAND|-----+------- Q
  +-|    |             +-|    |     |
  | +----+             | +----+     |
  |                 +---------------+
E +1                |  |
  |                 |  +-----------+
  |                 |    +----+    |       1 _
  | +----+          +----|NAND|----+-------- Q
  +-|NAND|---------------|    |
R --|    |               +----+
  0 +----+
```
This could cause Q to be either 1 or 0 but we can't predict which one.
A solution to this is to add a NOT gate like this:
```
        +----+               +----+            
S --+---|NAND|---------------|NAND|-----+------- Q
  +-|---|    |             +-|    |     |
  | |   +----+             | +----+     |
  |+---+                   +---------------+
E +|NOT|                   |  |
  |+---+                   |  +-----------+
  | |                      |    +----+    |         _
  | |   +----+             +----|NAND|----+-------- Q
  +-|---|NAND|------------------|    |
R   +---|    |                  +----+
        +----+
```
Notice that R is not longer used as an input so we can rename S to D and we
have our gated D-Latch. This can also be built like the following which avoids
the extra NOT gate (which is cheaper to manufacture):
```
        +----+               +----+            
D ------|NAND|---+-----------|NAND|-----+------- Q
   +----|    |   |         +-|    |     |
   |    +----+   |         | +----+     |
   | +-----------+         +---------------+
   | |                     |  |
   | |                     |  +-----------+
   | |                     |    +----+    |         _
   | |  +----+             +----|NAND|----+-------- Q
   | +--|NAND|------------------|    |
E -+----|    |                  +----+
        +----+
```

#### Clocked D-Latch
This is a D-Latch where the enable input is replaced with a clock:
```
        |
    +--------+
 ---|D PRE  Q|---
 ---|C      _|
    |  CLR  Q|---
    +--------+
        |
```

Now with our D-Latch above we had an enable input in addition to the data input
line:
```
    +--------+
 ---|D      Q|---
 ---|E      _|
    |       Q|---
    +--------+
```
And then enabled the Q could be updated, and otherwise Q was latched to the
current value and would not change.

```
                   +-----+
     --------------|D   Q|---------------
           +-------|E    |
           |       +-----+
           |       +-----+
     ------|-------|D   Q|---------------
           +-------|E    |
           |       +-----+
           |       +-----+
     ------|-------|D   Q|---------------
           +-------|E    |
           |       +-----+
           |       +-----+
     ------|-------|D   Q|---------------
           +-------|E    |
           |       +-----+
E ---------+
```
So all these D-Latches are enabled using the same pulse, enableing the data to
be set/reset. Then when E goes low those values will be latched and could be
read by some other component. This signal that E provides can be provided by
a clock which enables E with a regular interval: 
```
      _____    _____    _____    _____    _____    _____    _____
E ____|   |____|   |____|   |____|   |____|   |____|   |____|
```
So to set a value the E will be high for one whole period above which depends
on the clocks frequency. If the frequency is to low (there cycles are longer in
this case) the D input lines are open for longer periods of time. Increasing
the frequency might seem like a solution but the system might contains a mixture
of fast and slow components which have to be taken into consideration.

A solution to this is to only allow the E to be set when the clock signal
changes from low to high (the raising edge).
```
      _____    _____    _____    _____    _____    _____    _____
E ____↑   |____↑   |____↑   |____↑   |____↑   |____↑   |____↑
```
The goal is to have a D-Latch that only responds to changes in E at the raising
edge and not for the entire clock cycle.

We can construct the following cicuit:
```
                 +-----+
input --+--------| AND |
        | +---+  |     |------- output
        +-|NOT|--|     |
          +---+  +-----+
```
So example input and output would be:
```
input: 1, NOT1: 0, 1 & 0 = 0
input: 0, NOT0: 0, 1 & 0 = 0
```
This looks pretty useless, the output will always be zero. But, a real physical
NOT gate does not invert its input immediately. When the input transisions from
low to high there is a very brief moment when the output of the NOT gate is 1
and the input is 1:

```
First we have the low input state:

               0 +-----+
  0   --+--------| AND |
        | +---+  |     |------- 0
        +-|NOT|--|     |
        0 +---+ 1+-----+

Then we transition to the high input state
               1 +-----+
  1   --+--------| AND |
        | +---+  |     |------- 1
        +-|NOT|--|     |
          +---+ 1+-----+

When the NOT gate catches up the output is we expected:
               1 +-----+
  1   --+--------| AND |
        | +---+  |     |------- 0
        +-|NOT|--|     |
          +---+ 0+-----+
```
The same is true when transistioning from high to low but since the input to
the AND gate in this case will be 0 & 0 this does not affect the output.

With this we can detect when the input changes from low to high.
```

                                          +----+               +----+            
                                  D ------|NAND|---+-----------|NAND|-----+------- Q
                                     +----|    |   |         +-|    |     |
                                     |    +----+   |         | +----+     |
                                     | +-----------+         +---------------+
                                     | |                     |  |
                                     | |                     |  +-----------+
                                     | |                     |    +----+    |         _
                  +-----+            | |  +----+             +----|NAND|----+-------- Q
   C   --+--------| AND |            | +--|NAND|------------------|    |
         | +---+  |     |------------+----|    |                  +----+
         +-|NOT|--|     |                 +----+
          +---+   +-----+
```
This changes the device from a level triggered device to an edge triggered
device.
```
      _____    _____    _____    _____    _____    _____    _____
E ____|   |____|   |____|   |____|   |____|   |____|   |____|
      
C ____|________|________|________|________|________|________|____
```
So when this raising edge is detected that will cause the enablement of the
d-latch so the value in D can then be set/reset. This is then latched until the
next raising edge. There can be issues with this setup as the duration of the
pulse my not be wide enough to open the latch and let data in. This can be
worked around by adding two more NOT gates in succession to each other which
increases the delay.


It is also possible to build a falling edge trigger by inverting the input 
signal:
```
      +---+            +-----+
  1 --|NOT|---+--------| AND |
      +---+   | +---+  |     |------- 0
              +-|NOT|--|     |
               0+---+ 1+-----+
```

