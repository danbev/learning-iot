## Near Field Communication

### Radio Frequency Identification (RFID)
Is a wireless system comprised of two components, a tag and a tag reader.
A reader is a device that has an antenna that emits radio waves and receives
signals back from the tag.

Tags use radio waves to communicate their identity to nearby readers. A tag
can be passive meaning that it is powered by the reader and does not have a
battery (if it has a battery it is called an active tag). 


### Coupling mode
This is the method used to link the RFID tag and the reader to one another. This
is needed so that the reader can recognize and retrieve information from the
tag.
There are two main types of coupling which are inductive and radiactive
coupling.

#### Inductive coupling
Also called magnetic coupling and is generally used by low and high frequency
systems (LF and HF).
```
--------| = Magnetic field

------------------
\\\||||||||||////
\\\||||||||||///       
|--+---------+------------|   +----------+
|--| Reader  |------------|   |   Tag    |
|--+---------+------------|   +----------+
 //|||||||||||\\
///|||||||||||\\\
-----------------
```
The reader creates a magnetic field which when it comes in range of the tag,
that is the reader or the tag need to move closer to each other than shown above
as they are currently out of range. When they are in range the reader will send
electricity through the conductive antenna. This allows the tag to be powered
and allow for data stored on in the tag to be read.
This transfer of power is one things that limits the distance of this
technology. And it is also the reason that that tag does not require and
battery.

LF has a range of up to 1 m. HF has a proximity range of up to 10 cm and a
visinity range of up to 1m.

#### Radiactive coupling
This is usually used for Ultra High Frequency (UHF) and sometimes called
backscatter coupling (kinda like radar).
In this case the reader will radiate electromagnetic waves and any nearby tag
can reflect back the information stored in the tag. Notice that the reader does
not power the tag in this case so it will need to have its own power source.


### Proximity cards
Are also known as Passive 125kHz cards and have a limited range and must be held
close to the reader (but does not have to touch/swipe). The are often used for
hotel room keys.
These operate in the 125 kHz (LF) range.

### Visinity cards
Are known as active cards as they have a battery that powers them and can have
a range of up to two meters. The key for my care has this and if the key is
close to the car the doors can be opened.
These operate in the 13.56 MHz (LF) range.
