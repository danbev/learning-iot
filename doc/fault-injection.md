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
