## Fault injection notes
This document contains note related to hardware fault injection specifically
to microcontrolers.

The goal of fault injection is to be able get the CPU to skip instructions, or
incorrectly evaluate instructions, or corrupt reads from memory devices.

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
