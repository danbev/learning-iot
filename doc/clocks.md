### Clocks
So a clock is a source of some sort of signal a specific frequency. This signal
can be generated in different ways. For example:

Internal (to the microcontroller):
* a resistor capcitator circuit
* a phase locked loop (for frequency multiplication)

External (to the microcontroller):
* CMOS Clock
* Crystal
* Ceramic resonator
* Resistor capacitator
* Capacitator only

One thing to note is that temperature changes can lead to changes in frequency
and is something that might be an issue when deciding which clock source to be
used.

### CMOS Clocks
Are basically crystal oscilators that do not include any method of temperature
compensation.

### Quartz Crystals
When a voltage source is applied to a small thin piece of quartz crystal, it
begins to change shape producing a characteristic known as the Piezo-electric
effect (see section below). 

### Oven Controlled Crystal Oscillators (OCXO)
Is a crystal oscillator with a temperature controlled internal mini oven which
allows it to maintain a consistent temperature of the crystal and other key
components (rememeber that otherwise a change in temperature could change the
frequency of the signal). So the goal of the OCXO is to keep the crystal and
the internal components stable when the outside temperatures change.

These are used when one need to have a stable signal within a range of
±1 x 10-8 or better. But they are more expensive and also consume more power.


### Piezoelectricity
Is the electric charge that accumulates in some solid materials like crystals,
and ceramics.The name comes from the Greek word πιέζειν; piezein, which means to
squeeze or press, and ἤλεκτρον ēlektron, which means amber.
So the "original" effect was to place some kind of pressure on a solid material
to get an electric charge, the inverse is also true that exposed to an electric
charge the structure of the solid will be affected. This change in structure
will produce a mechanical vibration (oscillation).
French physicists Jacques and Pierre Curie discovered piezoelectricity in 1880.




### LC Oscillator 
Is a circuit that consists of a capacitator (represented by the C), and an
inductor (represented with L). Notice that both of these components can store
energy so what good can come from using them as the only components in a
circuit?  
Lets take a look at how such a circuit would work:
```
  +----<-----+
  |          |+
 +|          \
 ---         /
 ---         \
 -|          |-
  |          |
  +---->-----+
```
Imaging that the capacitor (on the left side) starts out fully charged, this
means that it has electrons that are attracted to the positive side and will
start flowing. The current will go through the inductor which will create a
magnetic field which will increase to a maxium value (when the current is at the
maxium flow. The incuctor will then have store the maxium amount of enery
possible with the given current.

So lets imaging a curve for the current (I), initially there is no current so
we start at zero, then current increases to a maxium amplitude. Once the maxium
current has been reached it will start to decrease (the electrons will have been
drawn to the positive side. So our imaginary curve will start to slope downwards
. When the current decreases the magnetic field inside of the inductor will
start to collapse freeing electrons. When this happens the polarity of the
inductor will be inversed:
```
  +----<-----+
  |          |-
 +|          \
 ---         /
 ---         \
 -|          |+
  |          |
  +---->-----+
```
I think that makes sense as the electrons will be attracted to positive terminal
of the conductor. The inductor is releasing energy which means that the
capacitor is being charged.
After the capacitor has been charged we have the following situation, it will
discharge:
```
  +---->-----+
  |          |-
 -|          \
 ---         /
 ---         \
 +|          |+
  |          |
  +----<-----+
```
Notice that the polarity of the capacitor has been reversed and since the
capitor is now charged its electrons will flow in the other direction (compared
with the two above states that is). If we again think or our imaginary graph we
are back at zero before the capacitor starts to discharge and we are now going
below zero (think of a sine wave) and when the current is at its maxium the
inductor will have stored its maxium amount of energy and the current will
start to decrease "back up to zero".
```
  +---->-----+
  |          |+
 -|          \
 ---         /
 ---         \
 +|          |-
  |          |
  +----<-----+
```
And since the inductors' magnetic field will start to collapse it will change
polarity once again. This is now a period in our wave, we started from zero
to our max current, then down to zero current, then continued down to the max
"negative" current, and back up again to zero. So this is providing a wave with
all the properties like amplitute, frequency, and phase. But this will not
continue forever as there are things that cause the amplitude to decrease, and
by that I mean that electrons (the current) are lost to heat, resistance in
wires that will cause the maxium current to become less for each period/cycle.
This means that our amplitude will decrease over time and eventually become
zero. But if we have some way of preventing this from happening we would have
an oscillator.

