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

One thing to not is that temperature changes can lead to changes in frequency
and is something that might be an issue when deciding which clock source to be
used.

### CMOS Clocks
Are basically crystal oscilators that do not include any method of temperature
compensation

### Quartz Crystals
When a voltage source is applied to a small thin piece of quartz crystal, it
begins to change shape producing a characteristic known as the Piezo-electric
effect (see section below). 

### Oven Controlled Crystal Oscillators (OCXO)
Is a crystal oscillator with a temperature controlled internal mini oven which
allows it to maintain a consistent temperature of the crystal and other key
components (rememeber that otherwise a change in temperature could change the
frequency of the signal). So the goal of the OCXO is to keep the crystal and
the internal components stabil when outside temperatures change.

These are used when when one need to have a signal stabil within a range of
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
