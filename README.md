### Learning IoT
The sole purpose of this repository is to store notes and code helping me
learn things related to internet of things, but also basic electronics.

### Electrons
An atom is composed of a necleus which consists of a core of tightly bound 
subatomic particles called protons (positive charge) and neutrons (neither 
positive of negative). Rotating around the necleus are electrons. These have orbits
that are referred to rings or shells and an electron has a negative charge.
The number of electrons in orbit equal the number of protons in the necleus and
the atom is electrically balanced.
Electrons can be manipulated, like storing or moving, and be used to produce 
electricity.

### Static electricity
This is where one object has an excess of electrons and the other objects has a 
shortage of electrons. The object with the excess is negatively charge as it now
has more negative electrons that positivly charged protons.
There is an invisible force field called an electric field between two charged
objects. The object with a shortage of electrons attracts the object with the 
excess electrons.
When we have such a situation, where we have two objects with opposite charge
we say there is an electrical potential, or a difference of potential between 
them. This difference is called voltage.
If these two charged objects come to close to one another the electrons jump
the gap between them and create a spark. This is how lightning occurs for example.
The earth is positively charged and the clouds negatively 

### Electricity
This is the flow of electrons. The electrons flowing from one place to another
is called current flow. Voltage, the difference in the charge between to object
is what causes the flow.
Electronics is about controlling the electrons with special components and
circuits.


### Electric charge
This is movement of electrons. 

### Voltage
Voltage is what pushes electrons arounda a circuit. Without Voltage the
electrons will move randomly in any direction.

(Spänning in Swedish) is the difference in charge between two points. This is 
measured in volt (V) and the symbol used is `U` from the German word unterschied
that means difference.
Electrons flow from the netative terminal of a voltage source around the curcuit
as they are attracted by the positive terminal.

### Current
Is the rate at which charge is flowing. Is measured in ampere (A) and the symbol
used is `I` which comes from the French word intensite de courant which means
current strength.
The number of electrons that move past a point in a conductor during a specific
period of time is measured in coulombs (C). One coulomb of charge is equal to
1 Coulomb = 6.242x10^18 electrons

If 1 coulomb moves past a point in 1s, we say that the current is 1 ampere (A)
1 Ampere = 1 coulomb/s


### Resistance
Is a materials tendency to resist the flow of charge (current). Is measured in
ohm using the symbol used is capital omega Ω and resistance uses the symbol R.

### Gound
In a ciruit with one battery we refer to the negative terminal as ground.
And in schematics instread of drawing lines that should be connected to the
negative terminal we simply use the ground symbol. For example:

```
  +----------/\/\/--------+
  |                       |
+ |                       |
-----                     |
 ---                      |
  |                       |
  |                       |
 ---                    ---
  =                      -
  .                      .
```
Which is the same as writing:
```
  +----------/\/\/--------+
  |                       |
+ |                       |
-----                     |
 ---                      |
  |                       |
  |                       |
  +-----------------------+
```


### Ohm's Law
voltage = Resistance * Current
U = R * I
I = U/R
R = U/I


### Power
Is the rate, per unit time, at which electrical energy is transferred by an 
electric circuit. The unit of power is watt which is one joule per second.

### Joule 

### Watt


### General Purpose Input Output (GPIO)

### Normally Open (NO)
Is open (broken) by default so no current flows

### Normally Closed (NC)
The opposite of normally open.

### Batteries
All batteries have a voltage of 1.5 V. 9V batteries are simply 6 such batteries
that are connected in a series.

### Radio waves
Are just another form of light (electro matnetic waves) just like light. 
They travel at the speed of light 300 000 000 meters per second.

Now, electrons in a wire flow with the help of atoms, in the conduction band.
But radio waves/light waves or electro magnetic waves don't have a wire but
Electromagnetic waves differ from mechanical waves in that they do not require
a medium to propagate. 
This means that electromagnetic waves can travel not only through air and solid
materials, but also through the vacuum of space.

### Radio bands
```
Name                             Frequency Range       Wavelength Range

ELF (Extremely Low Frequency)    3–30 Hz               100,000–10,000 km
SLF (Super Low Frequency)        30–300 Hz             10,000–1,000 km
ULF (Ultra Low Frequency)        300–3000 Hz           1,000–100 km
VLF (Very Low Frequency)         3–30 kHz              100–10 km
LF (Low Frequency)               30–300 kHz            10–1 km
MF (Medium Frequency)            300 kHz–3 MHz         1,000–100 m
HF (High Frequency)              3–30 MHz              100–10 m
VHF (Very High Frequency)        30 MHz–300 MHz        10–1 m
UHF (Ultra High Frequency)       300 MHz–3 GHz         1–0.1 m
SHF (Super High Frequency)       3 GHz–30 GHz          10–1 cm
EHF (Extremely High Frequency)   30–300 GHz            10–1 mm
THF (Tremendously High Frequency)0.3 THz–30 THz        1–0.1 mm
```
Radio waves with long wavelengths such as in the bands LF, MF, and HF can
exploit interesting effects of the Earth’s atmosphere to travel extremely long
distances. It is possible to reflect waves in these bands off various layers in
the atmosphere and ionosphere, making intercontinental communications possible. 

Notice that the lower frequency which also means longer wavelengths. When
sending data this data needs to travel over a signal that oscilates over with
a wave length. With the modulation techniques discussed later in this doc we
will see that most of these, if not all, will use the frequency to interpret
the original signal. If the wavelenght is longer less information is availaible
for processing during the same time period compared to a higher frequency. So
more information can be sent with higher frequencies in the same amount of time.

The general line-of-sight propagation mode can be more thought of as allowing
one to communicate with something that one could see in the absence of any
obstacles, that is, something not blocked by the curvature of the Earth or large
geographic features like mountains.

### Diffraction
Like light rays from the sun diffract in the atmosphere so can other types of
EM waves. This enables them to when they hit the peak of a hill diffract
(spread) out into the vallly. This can also happen with walls in ones home
which happens for 2.4GHz and 5GHz radiation which is what our WiFi routes emit.

### Reflection
In general, good conductors (such as metal) reflect most of an electromagnetic
wave’s energy. Other materials like rock reflect some energy, and many
insulators such as plastics reflect little energy. Areas covered in metal are
well shielded from electromagnetic radiation, because the metal will reflect
much of the incoming energy back.

### Absorption
The energy not reflected by a medium will pass into the medium. Some materials
allow electromagnetic radiation to pass through them without attenuation (
gradual loss) better than others. 
Many materials do not allow visible light to pass at all but do pass
lower-frequency radio waves. Radio waves can travel through most nonconductive
materials,

### LoRa
Is short for "long range" and provides low power consumption and long range,
a low data rate, and secure transmission.
Is used in small battery driven sensor devices that connect to a gateway which
may be between 1km to 10km form them. These devices are expected to run on the
same battery for about 2 years.

Has a greater range than celluar networks which have a range from a few 100m to
1km.

In Europe the frequencies for LoRa are 433MHz and 868MHz. Be carful when
configuring this as it could be illegal to use 915MHz which is allowed in other
places in the world.


### Amplitude Modulation
Lets take the example of sending a signal through a coppar wire:
```
        +---+       (wire)       +---+
mic --->|amp|------------------->|amp|---> speaker
        +---+                    +---+
```
So sending this over this wire can be done 

### Modulated Signal
This example is of a computer sending data over a telephone, like when we used
modems in the good old days.
First thing is that a byte will be broken down into separate bits and sent one
after the other. After that the will be partity bits and perhaps sync bits but
that is not important to this section.

The problem is that the telefon line cannot transmit logic levels which might
use 3.3V for High and 0V for low. We need to change these bits into something
that can be trasmitted on the frequence of the telefon wire (300-4000Hz) which
is a periodic wave that oscilates.

### Amplitude Modulation (AM)
We start with an input signal which is what we want to send to the reciever.
The reciever knows the frequency that this signal will be sent. The signal
is then modulated into a carrier signal where the amplitude will proportional
to the original signal. For example where the original signal has a higher
value the amplitude of the carrier signal will be greater, and where the
original signal value is lower the amplitude will be lower. On the receiving
side the demodulator will interpret the amplitudes to transform the carrier
signal into the original senders signal.

Just remember that we start with some signal on a wire and for this to be
transported as a radio wave it has to be modulated into 30Hz-300GHz frequency
without loosing the information that the orignal signal represents.




### Frequency Modulation (FM)
The goal here is similar to AM where we have a signal that we want to send and
instead of changing the amplitude we change the frequency. For exampl 0 might be 
represented by a higher frequency (shorter wave lengths), and a 1 by a lower
frequency (longer frequency).

### Digial signals and frequency
A digital signal is in a specific state as high or low, 1 or 0. This state is
represented by a constant non-changing voltage on the wire. Like 0V or 3.3V.

If instead this voltate varies over time we have a signal.

If the voltage is changing is a regular way, periodically way, over time we have
a frequency.

### Wave length                                                                 
```                                                                             
     c                c = speed of light                                        
λ =  -                f = frequency                                             
     f                                                                          
```
Lets say we have a signal that frequency of 200Hz. And recall that frequency
is the number of waves that pass a fixed place in a given amount of time (in
Hertz this is per second.

![Frequancy image](./frequency.png "Frequency image")

So the more waves that complete the higher the frequency. These waves are
shorter and the lower frequency waves are longer.

So if we have a wave of 200Hz, that means 200 cycle per second can
calculate the wave lenght using the formula above:
```
     3 * 10⁸ m/s
λ =  ----------- = 1.5 * 10⁶ m = 1500 km
        200Hz
```
Now, a wave length is the length of one cycle, as in starting from zero going
up to the amplitude, down to zero, down to the amplitude and back to zero. This
distance is 1500km?  
So would an antennna that is build to receive such a signal then have to be
1500km long to receive the complete wave. This does not work and in reality we
have small devices that have antennas which are much must shorter. What is
needed is to take this low level fequency and transform it into a higher
frequency but still retain the same information, and on the other side we take
this high frequency and transform it back into the lower frequency.


And lets take a higher frequency of 3000Hz:
```
     3 * 10⁸ m/s
λ =  ----------- = 10⁵m = 100 km
        3000Hz
```


There are three properties of a sine wave that we can manipulate:
```
y(t) = A(t)     * sin(2π f(t)     + ψ(t))
     
       amplitude         frequency  phase
```
So amplitude is the max distance of the trough/crest. And frequency is the
number of cycles per second. Notice that the phase is added so this would be
the hight of the y axis.

### LoRaWAN                                                                         
+ Is a Low power Wide Area Network (LPWAN)  
