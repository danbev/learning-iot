## Radio Frequency (RF) notes
Electromagnetic wave between 1 and 3 GHz.

Recall that wavelength is the distance between a peak/trough of a wave,
and frequency is the occurance of these waves per time unit (like seconds for
example). Also that amplitude is the height/distance of a peak/trough.

So the same information can be sent using different frequencies, which also
means that the wave length will be different, but the information is the same.

```
frequency   = cycles /time
wave length = distance/cycle
speed       = frequency * wave length
```

So if we take the 2.4 GHz frequency this communication of electromagnetic waves
that cycle 2.4 billion timese per second. Both the sender and receiver must
know the frequency to be able to interpret the signal. The receiver needs to
know when to read the value of the amplitude of the wave but if the frequencies
are not the same for the sender and receiver the receiver will most probably
read an incorrect value, at least not the value intended by the the sender.

Now, take the 2.4 GHz spectrum, this 2400 MHz and we can divide this into
channels, like one channel might be 2400-2420 MHz. So we have a 20 MHz channel
which describes how wide a signal is. This width is what is referred to when we
talk about band width.

So thinking about wave length and frequency we know that a longer wave length
gives a lower frequency, and a shorter wave length gives a higher frequency.
And remember that the frequency is the number of cycles per time unit. So if
we have two signal waves where one has a frequency of 4Hz and one that has a
frequency of 8 Hz, the distance is the same:
```
Wavelenght 1: 74 meters, 74 * 4 = 296
Wavelenght 2: 37 meters, 37 * 8 = 296
```

When data is sent it is sent using a certian wavelength/frequence but the
amplitude can vary.

### Free Path Loss
Think of a lake that is perfectly still and we toss a rock into it. Waves will
propagate outwards and the will have a certain length and frequency. As the wave
propagates further and further amplitude will decrease more and more and when
the amplitude is 0 the there is not longer any wave. This is called free path
loss as there is not much effecting the wave except distance.
We can think of the size of the rock as the amount of energy/power we put into
a wireless signal.


### Absorbtion
Some materials will cause the amplitude of the signal to decrease which is
called absorbtion. The wavelenght/frequency is the same but some of the
amplitude (power) will have been absorbed.

### Noise
Is an unwanted random signal that gets added to our wanted (random) signal. So,
we have are signal that has a specific wave lenght/frequency. It also has an
amplitude. So the noise signal will also have same wave length/frequency but
with a different amplitude compared to our signal. So the receiver will not
see/read our signal with the intended amplitude but instead the amplitude will
be from the amplitude of the noise signal peak to our signals peak. This is
called the Signal to Noice Ratio (SNR).

### Basic Pules techniques

#### Not-Return-to-Zero (NRZ)
This is when during one clock cycle the pulse does not go down to zero:
```
Amplitude
   ^
   |
   --------+
   |       |
   |       |
   +-------|----> time
   0       T₁
```
So the amplitude is fixed.

#### Return-to-Zero (RZ)
This is when during one clock cycle the pulse does go down to zero:
```
Amplitude
   ^
   |
   ----+
   |   |
   |   |
   +---|---|----> time
   0       T₁
```
So for half of the duration the amplitude will be high, and then go down to
zero for the rest of the duration.

#### Manchester
In this case there is a transistion from high to low, or low to high during
each duration:
```
Amplitude
   ^
   |
   ----+
   |   |
   |   |
   +---|---|----> time
   |   |   |
   |   |   |
   |   +---+
   |       T₁
       1 (high to low represents 1 bit)

   ^
   |   
   |   ----+
   |   |
   |   |
   +---|---|----> time
   |   |   
   |   |   
   +---+
   |       T₁

       0 (low to high represents 0 bit)
```

#### Modified Miller 
In this coding scheme where a 1 bit is always represented by:
```
   ^
   |
   ----+ +--
   |   | |
   |   | |
   +---+-+----> time
   |   
   | 
   |       T₁
       1 (high to low represents 1 bit)
```
But a 0 bit representation depends on the bit that comes before it. If the
preceeding bit is 0 then:
```
   ^
   |
   + +----
   | |
   | |
   +-+-+-+----> time
   |   
   | 
   |       T₁
       0 
```
And if the preceeding bit was 1:
```
   ^
   |
   +----
   |
   |
   +-+-+-+----> time
   |   
   | 
   |       T₁
       0 
```

### Pulse shapings techniques

#### Unipolar
```
 Bit     Level
  1  ---> +a 
  0  ---> 0
```
Notice that the level is between 0 and a.

#### Polar
```
 Bit     Level
  1  ---> +a 
  0  ---> -a
```
Notice that the level is between -a to +a. If we compare this with unipolar we
this would require higher amout of power to send a signal using Polar compared
to unipolar.

#### Bipolar
Is also sometimes referred to as Pseudo Ternary Code or Alternate Marked
Inversion (AMI):
```
 Bit     Level
  1  ---> +a, -a 
  0  ---> 0
```
This might not be clear but for bits of 1s the amplitude is alternating. So the
first 1 could be +3.3 and the second 1 could be -3.3.

Now, this would looks something like this:
```
    Bits    1        1        1 

Amplitude
       ^
       |
    +A |---------+        +---------
       |         |        |
       |         |        |
       +------------------------------> time
       |         |        |
       |         |        |
    -A |         +--------+
       |       
       |
```

#### Transmission efficency
If we compare Unipolar with Polar we find that Polar will require higher amout
of power to send a signal.

### Line Coding
Is the process of converting binary data to a digital signal.
```
 Binary data                       Digital Signal

 0101 0101  ---> Line Coding --->  ^0  1  0  1  0  1   0  1
                                 3 |  +--+  +--+  +--+  +--+
                                   |  |  |  |  |  |  |  |  |
                                   |  |  |  |  |  |  |  |  |
                                   +--|--|--|--|--|--|--|--|--|--|>
                                      
```
The above is just an example and the actual digital signal depends on the
line codeing in use.

There are few important things with regards to line coding:
* Signal Level
Is the number of values (amplitude) that a signal can have. Like it might only
allow 0 and +a, or perhaps -a and +a, or -a, +a and 0.

* Data Level
Is the number of values used to represent data. For example binary only requires
two, 1 and 0.

* Pulse Rate
Is the number of pulses per second. A pulse is the minimum amount of time
required to trasmit a symbol.

* Bit Rate
Is the number of bits per second.

# DC Component
This is when a line coding has an average voltage greater than 0. For example,i
if we represent high as 3V and low as -3V then the average is 0 as the high and
low values will cancel each other out. But if we instead have high as 3V and low
as 0 then we would have a postive average and this is called a non-zero DC
component. This is apparently related to errors in the communication but I'm not
exactly sure how yet.

### Scrambling
Is really just a rearrangement of a sequence of data and is used in wireless
communication to remove long sequences of ones and zeros.

### Radio waves
Are just another form of light (electro magnetic waves) just like light.
They travel at the speed of light, around 300 000 000 meters per second.

Now, electrons in a wire flow with the help of atoms, in the conduction band.
But radio waves/light waves or electro magnetic waves don't have a wire but
Electromagnetic waves differ from mechanical waves in that they do not require
a medium to propagate.  This means that electromagnetic waves can travel not
only through air and solid materials, but also through the vacuum of space.

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
the original signal.
```
If the wavelength is longer, less information is availaible
for processing during the same time period compared to a higher frequency. So
more information can be sent with higher frequencies in the same amount of time.
```

The general line-of-sight propagation mode can be more thought of as allowing
one to communicate with something that one could see in the absence of any
obstacles, that is, something not blocked by the curvature of the Earth or large
geographic features like mountains.

### Diffraction
Like light rays from the sun diffract in the atmosphere and so can other types
of EM waves. This enables them when they hit the peak of a hill diffract
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

### Signal
Any series of data points that change over time can be through of as a signal.


### Modulated Signal
This example is of a computer sending data over a telephone, like when we used
modems in the good old days.
First thing is that a byte will be broken down into separate bits and sent one
after the other. After that there will be partity bits and perhaps sync bits but
that is not important to this section.

The problem is that the telefon line cannot transmit logic levels which might
use 3.3V for High and 0V for low. We need to change these bits into something
that can be trasmitted on the frequence of the telefon wire (300-4000Hz) which
is a periodic wave that oscilates.

There are three properties of a sine wave that we can manipulate:
```
y(t) = A(t)     *        sin(2π f(t)     + ψ(t))
     
       amplitude         frequency         phase
```
So amplitude is the max distance of the trough/crest. And frequency is the
number of cycles per second. Notice that the phase is added so this would be
the higth of the y axis.

Modulation is used to reduce the size of the antenna use to send/receive the
signals. For example:
```
c = λf

c = speed of light,  3*10⁸/ms
λ = wavelength of the signal
f = frequency of the signal

L = λ/4

L = length of antenna
```
So say we have signal that is to be transmitted which has a frequency of 10KHz:
```
          3*10⁸
λ = c/f = ----- = 30000m
          10⁴

L = 30000/4 = 7500 m
```
So having an antennna of 7500m is not very practical. But if we use a higher
frequency like instead of 10KHz we use 10MHz, we would get:
```
          3*10⁸
λ = c/f = ----- = 300m
          10⁶

L = 300/4 = 75m
```
That is still a faily long antenna but if we keep increasing the frequency
this will become lower:
```
          3*10⁸
λ = c/f = ----- = 0.4115226m
          20⁶

L = 0.4115226/4 = 1.171875m
```

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
instead of changing the amplitude we change the frequency.

### Phase Modulation
This this case a change in phase could be used to indicate 1 and no change could
be 0. Visually this would look like break in the curve and it starting over in
the down instead of up or vice verca.

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
Lets say we have a signal with a frequency of 200Hz. And recall that frequency
is the number of waves that pass a fixed place in a given amount of time (in
Hertz this is per second.

![Frequancy image](./img/frequency.png "Frequency image")

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
up to the max amplitude, down to zero, down to the amplitude and back to zero.
This distance is 1500km?  
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

How does frequency and data rate relate to each other. The way I'm thinking
about this at the moment is that we have a carrier wave that is of a certain
frequency, but there is no change in the wave, like no change to the amplitude
phase or anything like that so it does not really transport any information, or
perhaps it transports the same information all the time. But if we can decide
that a change in amplitute means a logical 1 and another change means logical 0
then we can send on bit of information per cycle/period. So if we have a 10Hz
communication channel that would mean 10 bits of information per second?

### Frequency bands
Take the FM band which is the range of frequencies from 88MHz to 108MHz:
```
88MHz         108MHz
 |-------------|------
 

FM broadcast band 88 MHz  (frequency of the electrical current)
88 miljon cycles per second, 88 000 000Hz

220V       -                -           60Hz (60 cycles per second) 
         -   -            -   -
       -      -         -       -
0V    -------------------------------              
                -      -          -
                  -   -             -
                    -
```

### Periodic analog signals
Such a signal can be simple or composite. A simple signal cannot be decomposed
into simpler signals. A composite periodic analog system


If a signal does not change at all its frequency is 0. So if we send three
0 bits then it could be that there is no change to the signal, and that would
give a frequency of 0.

If a signal changes instantaneously its frequency is infinite.

I've read the following statement in multple places:
```
A single frequency sine wave is not useful in data communications, we need to
send a composite signal.
```
Why could a single frequency sine wave not be useful, could we not just alter
the amplitude?  
Actually, once we do that, for example use amplitude modulation of the signal
it is no longer a fundamental wave because it has harmonic components.

Unless the sine wave changes, it can’t carry information, and if it changes, it
isn’t a pure sine wave any more.



### What is bandwidth
So we know that frequency is:
```
     1
f = ---
     T

T = time taken to complete one cycle of an oscillation.
```

Periodic analog signals and non-periodic digital signals


### Electro magnetic waves


Lets say you have two wires with a current running in opposite directions, this
magnetic fields will cancel each other out so there will be now propagation
of EM waves.

### Antennas
Antennas are the interface between the world of electronics and the world of
electromagnetic radiation. 
An antenna can transform an alternating current (AC) into a radio wave and vice
versa.

https://www.youtube.com/watch?v=FWCN_uI5ygY


The below notes were take while watching https://www.youtube.com/watch?v=bwreHReBH2A.

Lets say we have a positive charge (+) and a negative charge (-) and we are
going to move them vertically (but I guess without them being attracted to
each other):
```
     +               -               +
     |   +       -   ↑   -       +   |
E    |   |   +   ↑   |   ↑   -   |   |
     |   ↓   -   |   |   |   +   ↓   |
     ↓   -       +   |   +       -   ↓
     -               +               -

-------------------------------------------------------> time

Electro field = vertial arrow
```
So the electric field is pointing from the positive to the negative. Notice how
the electric field goes from negative to 0 to positive. So the value of the
electricfield starts off negative, then goes up to zero, then changes direction
and becomes positive instead, and then goes back down to zero etc.

If you look at the diagram above and visualize a curve looking something like
this:
```
                     -                
                 -       -            
              -              -        
     ------------------------------------->
         -                       -    
     -                               -
```
```
             Wire with electric current
     +         +-+ 
     |         |||
E    |         |||
     |         |||
     ↓         |↓|
     -         +-+
```
Recall that when we have a current there is also an magnetic field generated.
Remember the right hand rule here, the current is flowing downards so your
right thumb points in that direction, and you other fingers wrap around the wire
and that is direction of the magnetic field. So the magnetic field goes around
the wire in a circle from right to left above, coming out towards us and then
back behing the wire. We can name this magnetic field B.

Now, in the same way we moved the positive and negative charges up and down, we
can change the direction of the current, and we can also stop the current flow:
```
             Wire with electric current
               +-+       +-+
               |||       |↑|
               |||  +-+  |||
               |||  +-+  |||
               |↓|       |||
               +-+       +-+
```
The middle box is supposed to represent zero current. 

```
                     
                - -             - -
              -     -         -     -
     ------------------------------------->
      -     -         -     -        -     -
        - -             - -            - -
    
```
So have the electric field which is doing up and down, and we have the magnetic
field which is coming out towards us and back into the screen. So try to
visualize this as the electric field going up and down and the magnetic field
is on a plane orthogonal to it.

Changing E generates B, and chaging B generates E. This makse the wave and
causes the continuation of this intraction causing this "wave" to propagate.
The speed it propagates is the speed of light, 3 * 10⁸m/s.

```
                                                Metal wire
                                                  ↓  
                                                  |  ↑
                     -                         -  |  |
                 -       -                  -     |  | I
              -              -           -        |  |
     ------------------------------------------>  |  |
         -                       -     -          |  |
     -                               -            |  
```
So the above is just showing when E is positive but it will soon go down to
zero and then to negative:
```
                                                 Metal wire
                                                   ↓  
                                                   |  |
                               -                   |  |
       -                   -       -               |  | I
          -             -              -           |  |
      -------------------------------------------> |  |
             -     -                       -       |  ↓
               -  -                               -  
```
Notice that the current (I) switches direction. 

```
c = 3*10⁸m/s
```
But there is a relation ship between c and the frequence and the wavelenght:
```
c = frequence * wave length
c = f * λ
m   1
- = - * m
s   s
```
Since c is constant if we increase the frequence then the wave length must
decrease. And if the wave length increases the frequence must decrease.

The frequency of E is the same as the frequency of B.
```
E = cB
```

### Amplitude Shift Keying (ASK)
This is where we take a digital message and multiply it with our high frequency
carrier signal, and vary the amplitude of the carrier signal depending on the
digital message values 0 or 1.
For example, it might be the case where the amplitude is 0 for a 0, and the
amplitude 1 one is whatever the amplitude of the carrier signal. So the bits
1010 would be transmitted as a pulse with an amplitude of the carriers signal, 
followed by a pulse of zero amplitude and so on.

### Frequency Shift Keying (FSK)
This is where we take a digital message and multiply it with our high frequency
carrier signal, and vary the frequency of the carrier signal depending on the
digital message values 0 or 1, so a high frequency could represent a 1 and a
low frequency a 0.

### Phase Shift Keying (PSK)
This is where we take a digital message and multiply it with our high frequency
carrier signal, and vary the phase of the carrier signal depending on the
digital message values 0 or 1.


### On-Off Keying (OOK)
In OOK there is no carrier signal during the transmission of logical 0, but
there is a carrier signal for logical one.
So when looking at such a signal it might look like short lines with spaces
between them. For example:

![Inspectrum ASK/OOK image](./img/inspectrum-ask-ook.png "Inspectrum ASK/OOK image")

### Decibel (dB)
This is a unit of measurment but not quite like kg or other units that we are
used to. Instead this is a unit that has been calculated using a logarithmic
function or a logarithmic scale. The name comes from deci as in 10 and B
is for Bell Laboratories.

```
value -> log_function(value) -> dB value
```
So why would we not just simply use the absolut value instead?  
Well take human hearing of sound. The minimum threshold for a human ear to
detect sounds is 0.000002 Pa (Pascal) and the maxinum is 63.2 Pa. This is a very
large range which makes it impractical to work with.

```
Original absolut range                          New "compressed" range
  --- max
   |
   |                                              --- max
   |                                               |
   |               +---------------------+         |
   |        -----> |Logarithmic function | ----->  |
   |               +---------------------+         |
   |                                               |
   |                                              --- min
   |
   |
   |
  --- min

Sound Pressure Level = 20log₁₀[absolute pressure/reference pressure]

reference pressure = threshold of hearing, 0.000002 Pa.

63,2 Pa                       
  --- max
   |                                                         130 dB
   |                                                         --- max
   |                                                          |
   |               +--------------------------------+         |
   |        -----> |20log₁[abs pressure/ref pressure| ----->  |
   |               +--------------------------------+         |
   |                                                          |
   |                                                         --- min
   |                                                         0 dB
   |
   |
  --- min
0.00002 Pa
```
We can take a look at how increases to the actual sound pressure and compare
those values to the soude pressure levels in dB:
```
Sound pressure       Sound pressure level
  x10                +20  dB
  x100               +40  dB
  x1000              +60  dB
  x10000             +80  dB
  x100000            +100 dB
```

```
                    
Input signal power                        Output signal power
                     +--------+
           Pᵢₙ --->  |        | ---> Pₒᵤₜ
                     +--------+
```
If the Pₒᵤₜ > Pᵢₙ then box above is an amplifier and has a `Gain`. 
If the Pₒᵤₜ < Pᵢₙ then box above is an filter and has a `Loss`. 


### Whitening
Radio transmission requires the bits to alternate often so if we have a series
of bit like 1111 1111 1111 1111 that might become an issue.
On the receiver side the clock synchronizer curuit attempting to recover and
track the incoming data clock needs frequent transistions in the signal.

### Linear Feedback Shift Register (LFSR)
TODO:

### Baud Rate
Number of symbols per second.

### Gray Code
Is a ordering of a binary numerical such that two successive values differ
only in one bit. If we take the binary system we have:
```
0  000
     ↓ Only one difference 0->1
1  001
    ↓↓ Two differences
2  010
     ↓ One difference 0->1
3  011
   ↓↓↓ Three differences
4  100
     ↓ One difference
5  101
    ↓↓ Two differences
6  110
     ↓ One difference
7  111
```
Gray code is named after Frank Gray and only allows one bit to change:
```
0  000  0 (0 xor 0) (0 xor 0) = 000
                                  ↓
1  001  0 (0 xor 0) (0 xor 1) = 001
                                 ↓
2  010  0 (0 xor 1) (1 xor 0) = 011
                                  ↓
3  011  0 (0 xor 1) (1 xor 1) = 010
                                ↓
4  100  1 (1 xor 0) (0 xor 0) = 110
                                  ↓
5  101  1 (1 xor 0) (0 xor 1) = 111
                                 ↓
6  110  1 (1 xor 1) (1 xor 0) = 101
                                  ↓
7  111  1 (1 xor 1) (1 xor 1) = 100
```

### Bit Rate Error (BER)

Signal with one bit:
```
               0       1
<--|---|---|---*---|---*---|---|---|------->  Voltage
      -3  -2  -1   0   1   2   3
```
So if the amplitude is -1V then that would be read as 0, and if the amplitude
is +1V that would be 1.

Signal with two bit:
```
      00      01      10      11
<--|---*---|---*---|---*---|---*---|------->  Voltage
      -3  -2  -1   0   1   2   3
```
In this case if the amplitude is -3V then that will be read as 00, and if it
is -1 then it will be read as 01. So we have one signal that represents two
bits. Now, if the signal is disturbed, like a -3V signal increases for than 1
volt this would then read as 00 as it is now read as -1 (or at least in that
range).
```                        1           1            N = noise
Signal Error Rate (SER) =  - P(N>1) +  - P(|N|>1)
                           2           2
```
So that was the error rate for signals but this is not the same for bits.
Notice in our bits we only have a single bit error between reading -3 and -1,
and this is also true when reading 1 and 3 there is only one bit error:
```
       +-------+       +-------+
       |       ↓       |       ↓
      00      01      10      11
<--|---*---|---*---|---*---|---*---|------->  Voltage
      -3  -2  -1   0   1   2   3
```
So what this means is that if we are reading -3V but there is noise that like
before increases the signals voltage (I guess that can happen) then instead of
reading `00` we would read `01`. But notice that only the second bit was
incorrect in this case, the first was not a bit error.
And if we received a -1 which increased by noise we would have two bits of error
as `01` would be read as `10` and both bits have been changed. Now, if the noise
increased by 2 volts instead that would be read as 3V which be `11` and notice
that this would only be one bit error as `01` was read as `11`.

And for -1, `01` and 1, `10` we have two bit errors.

The distribution of noise is a gausian distribution (bell shaped) and the
likelyhood of getting smaller variations are greater than getting the larger.

Now, what if we instead used Gray Code like we introduced earlier in this
document:
```
      00      01      11      10
<--|---*---|---*---|---*---|---*---|------->  Voltage
      -3  -2  -1   0   1   2   3
```
Notice that we no longer have the two bit error between -1 and 1, and actually
all neighbouring values only have a single bit error between them now.

```
            Errors
BER = --------------------
      Total Number of bits
```

### RTL-SDR (RealTek Software Defined Radio)
Is a computer based radio scanner for receiving live radio signals:

![RTL-SDR image](./img/rtl-sdr.jpg "RTL-SDR image")

### ggrx
GQRX is an open source software defined radio receiver (SDR) powered by the GNU
Radio and the Qt graphical toolkit.
I've read that the name comes from GNU Radio (G), Qt (Q), and RX (receive).

Below is an image of this running tuned into a local radio station:

![GQRX image](./img/gqrx.jpg "GQRX image")


### Baseband
Refers to signals before modulation and these have much lower frequencies than
the carrier frequency signal after modulation.
So just to recap, we have a signal before modulation, a carrier signal, and a
signal after modulation.

This could be a stream of bits that is the information that we want to send.

### Passband
Refers to signals after modulation which have frequencies around the carrier
signals frequency.


### Signal Reverse Engineering
The thing we want to figure out are:
* Frequency
* Bandwidth
* Modulation
* Symbol rate
* Packet structure

1) Find the frequency that the device is using. This can be done by looking at
the device and seeing if there is any make/model information and look that up
online. It might be that a datasheet specifies the frequency that the device
uses.

So I've got this garage opener/clicker at home which is not activated, that is
I can't open our garage door with it. But I'm interested in the process of
finding it's frequency so I opened it up and took a look at the circuit board
and found model number which I searched for. That lead me to an FCC
identification number which I then [searched](https://fcc.io/) for and found
that this device has a frequency of `433.92` MHz. Using `gprx` I was able to see
this signal when pressing the button on the device:

First without pressing the button:

![Garage clicker no signal image](./img/garage-no-signal.jpg "Garage clicker image")

And when pressing the button:

![Garage clicker signal image](./img/garage-signal.jpg "Garage clicker signal image")

Looking at this we can see that the frequency is `433.887`MHz.

```console
$ rtl_sdr -f 433887000 -s 2000000 -n 20000000 outfile.cu8
```
While this is running I clicked on the button a number of times to record the
signal. The file format cu8 means Complex 8-bit unsigned integer samples
(RTL-SDR).

Now, we can open `outfile.cu8` in `inspectrum`:
```console
$ inspectrum
```
Also adjust the sample rate to be the same as we specified using the `-s` option
above.

![Garage clicker inspectrum image](./img/inspectrum.png "Garage clicker inspectrum image")

Now, we can scroll to and zoom in on a portion of the sample and stop at the
first click of the button. If we right-click in inspectrum we can add an
amplitude plot and then move it towards the middle of our sample.

![Inspectrum with plot image](./img/inspectrum-with-plot.png "Inspectrum image with sample plot")

![Inspectrum zoomed image](./img/inspectrum-zoomed.png "Inspectrum zoomed image")
Now, I'm trying to understand what I'm seeing in this above image. What I think
we are seeing here is that first there is the carrier signal (there is more of
this to the left, from the beginning of the file). What we see above is the
first press of the button and where we see a change in frequency. Hmm, could
this actually be Amplitude Shift Keying, ON-OFF Keying?  
Notice that there seems to be a gap in the carrier signal which as mentioned
earlier could be an indication of the usage of Amplitude Shift Keying/On-Off
Keying (ASK/OOK):

![Inspectrum ASK/OOK image](./img/inspectrum-ask-ook.png "Inspectrum ASK/OOK image")

I'm really not sure if I'm reading this correctly but this is may current take
on this plot. The first high is a 1 followed by a 0, and this repeats for
12 1,0 pairs. Could this be part of a preamble or start of frame (SOF) perhaps?

We can use cursors in inspectrum so try to mark this suspected preamble:

![Inspectrum Cursors image](./img/inspectrum-cursors.png "Inspectrum cursors image")

We can then use the feature "Extract threshold" and then "Extract symbols" to
generate values:
```console
1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
```
So this does look like a preable, alternating 1 and 0. The above gave us a
symbol rate. We can move the cursor to the next section and then use the `+`
button to increase the size of the cursor but still keeping the symbol rate
(at least I think this is how to do it).

Now, we can to the same with the next signals:

![Inspectrum Data Cursors image](./img/inspectrum-data-cursor.png "Inspectrum data cursors image")

```console
1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 
1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 
```

_work in progress_

### Inspectrum
Installing on Fedora:
```console
$ sudo dnf copr enable domrim/inspectrum
$ sudo dnf install inspectrum
```
