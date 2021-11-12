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

### Capacitors
Is a component that is capable of storing electric charge, like a battery but it
works in an different way and cannot hold the charge for the same amount of time
as a battery. Also where a battery stores charge using chemicals, a capacitator
stores enery in an electric field. The capacitor can be charged quickly and also
release the energy quickly (much faster than a battery).

One can think of the setup where we have a water pipe that has a valve which can
be used to turn off and on the flow of water. If we add a tank to this pipe, the
valve coming before the tank, we can allow the tank to fill, and even if we
close the valve water will still flow out of the tank for a while (until the
tank is empty. If we open the valve before the tank is empty we can make sure
that we have a steady flow of water.

A capacitor has a container and inside it we have anode foil and a cathode foil
with a separator between them. These are rolled up (like a RullTårta) with two
terminals connected to

```
 +----------->------------->--+
 |     +-----------+          |  +---------------+
 ^     | Capacitor |          +->| Battery       |
 |     |*  *  *    |             |               |
 +----<+-----------|             |               |
 +---->+-----------|          +-<|               |
 ^     | **        |          |  +---------------+
 |     +-----------+          |
 +-----------<-------------<--+

* = electrons
``` 
Notice that there is a non-conductive layer in the capacitor preventing
the flow of electrons. Hooking up a battery will eventually lead to the
capacitor having the same voltage as the battery, the electrons in the lower
compartment in the diagram above and no more current will flow. So we have 
a build of of electrons on one side:
```
 +----------->------------->--+
 |     +-----------+          |  +---------------+
 ^     | Capacitor |          +->| Battery       |
 |     |           | (+)         |               |
 +----<+-----------|             |               |
 +---->+-----------|          +-<|               |
 ^     |***********| (-)      |  +---------------+
 |     +-----------+          |
 +-----------<-------------<--+

* = electrons
```
We have a difference in potential between the + and negative which is a
potential voltage. The positively charged particles (electron holes) attract the
negatively charge electrons and it is the electric field that keeps the
electrons in place.

Now if we connect an LED (and it should have a resistor in this but skipping
that for now) electrons will have a way to flow:
```
           +--+----------------------------+
           |  ↓     +-----------+          |
           ^  |     | Capacitor |          \
           |  |     | *     *   | (+)      
+---+-->---+  +---->+-----------|          |
|LED|         +----<+-----------|          | 
+---+--<---+  ↓     |***********| (-)      | 
           |  |     +-----------+          |
           +<-+----------------------------+

* = electrons
```
And they will flow until they fill up the positive side of the capacitor. When
the build up is equalized then no electrons will flow as the voltage is zero.
When we connect the battery again electrons will start to build up in the
negative side of the capacitor and holes will be created in the positive side
as electrons flow out (attracted to the positive terminal of the battery):
```
           +--+------>------------->-------+
           |  ^     +-----------+          |  +----------+
           ^  |     | Capacitor |          +->| Battery  |
           |  |     |***********| (+)         |          |
+---+-->---+  +---->+-----------|             |          |
|LED|         +---->+-----------|          +-<|          |
+---+--<---+  ^     |*          | (-)      |  +----------+
           |  |     +-----------+          |
           +<-+----------------------<-----+

* = electrons
```
This will again charge the capacitator. So the power supply can be interrupted
without effecting the LED (in this example).

### Inductors
Is a component that stores energy in it's magnetic field. Recall that a
capacitor also stores energy but it stores electrons so there differ.

```
       ⌒⌒ ⌒ ⌒ ⌒ ⌒  
-------/\/\/\/\/\-------------
       ⌒ ⌒ ⌒ ⌒ ⌒ ⌒ 

⌒  = magnetic field
/\ = inductor
```
Think of a water pump which pumps water through a pipe. The pipe branches like
this:
```
                      +------------+
                +-----| Water Wheel|---->---+
                ^     +------------+        |
+------+        |                           |
| Pump |--->----+                           ↓
+------+        |                           |
   |            ↓    +--------------+       |
   ^            +----| Reducer      |--->---+
   |                 +--------------+       |
   |                                        ↓
   +-------<---------------<----------------+

Reducer = resistance in an electrical circuit (like an LED)
Wheel   = inductor
```
The water wheel takes a certain amount of pressure to start moving so initially
water will start flowing and it will take the path of the water wheel, but then
as it take alot of pressure to flow that way, water will start to flow through
the reducer path as it ccan flow straight throw this back to the pump to close
the loop (think circuit here). But when the wheel starts to move faster there
will be a point when that path provides no resistance and water will flow only
through that path and not through the reducer path. Now, if we turn off the pump
the water wheel will continue to turn for a while and water can still flow
through and continue to flow in a loop through the reducer until the wheel slows
down (remember that the reducer could be a LED in an electric circuit so it
would continue to shine for this period of time):
```
                      +------------+
                +-----| Water Wheel|---->---+
                ^     +------------+        |
+------+        |                           |
| Pump |---/    |                           ↓
+------+        ^                           |
   |            |    +--------------+       |
   |            +-<--| Reducer      |---<---+
   |                 +--------------+       |
   |                                        |
   +----------------------------------------+

Reducer = resistance in an electrical circuit (like an LED)
Wheel   = inductor
```
So, similar to how we could disconnect the battery of a capacitor and current
would continue to flow, the same is true in the case of an inductor.
```
           +--+------>------------->-------+
           |         \                     |  +----------+
           ^         /                     +->| Battery  |
           |         \                        |          |
+---+-->---+         /                        |          |
|LED|                \                     +-<|          |
+---+--<---+         /                     |  +----------+
           |         \                     |
           +--<----------------------<-----+
```
Initially electrons are going to flow through the circuit (the outer loop) and
turn on the LED as that it is the path of least resistance. But once the
inductors resistance reduces it will be come the path of least resistance and
the electrons will prefer that path (inner loop) meaning that the LED will turn
off.
Now, if we disconnect the battery in some way (using a switch perhaps) the
electrons will no flow in a loop through the inductor to the LED and back until
the inductor disapates the energy (like the water wheel slowing down and
eventually stopping);
```
           +--<------<---------------------+
           |         \                     |  +----------+
           ↓         /                     +--| Battery  |
           |         \                        |          |
+---+--<---+         /                        |          |
|LED|                \                     +--|          |
+---+-->---+         /                     |  +----------+
           |         \                     |
           +-->------↑-------------  \-----+
```
Now the magnatic field that is generated by the inductor will collapse into
electic energy when the current stops flowing. It will reach its max magnatic
field and once the current stops flowing start to collapse which will release
electrons (I think) into the wire which allows current continue to flow.


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
capitor is now charge its electrons will flow in the other direction (compare
to the two above states that is). If we again think or our imaginary graph we
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
continue for every as there are things that cause the amplitude to decrease, and
that I mean is that electrons (the current) are lost to heat, resistance in
wires that will cause the maxium current to become less for each period/cycle.
This means that our amplitude will decrease over time and eventually become
zero. But if we have some way of preventing this from happening we would have
an oscillator.

