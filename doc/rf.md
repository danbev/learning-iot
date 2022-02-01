## Radio Frequency (RF) notes
Electromagnetic wave between 1 and 3 GHz.

Recall that wavelength is the distance between a peak/trough of a wave,
and frequency is the occurance of these waves per time unit (like seconds for
example). Also that amplitude is the hight/distance of a peak/trough.

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

```

### Pulse shapings techniques

#### Unipolar
```
 Bit     Level
  1  ---> +a 
  0  ---> 0
```

#### Polar
```
 Bit     Level
  1  ---> +a 
  0  ---> -a
```

#### Bipolar
Is also sometimes referred to as Pseudo Ternary Code.
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
Radio transmission requires the bits to alternate often (why is that?) so
if we have a series of bit like 1111 1111 1111 1111 that might become an issue.
On the receiver side the clock synchronizer curuit attempting to recover and
track the incoming data clock needs frequent transistions in the signal.
