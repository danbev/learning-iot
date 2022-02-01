## Radio Frequency (RF) notes
Electromagnetic wave between 1 and 3 GHz.

Recall that wavelength is the distance between a peak/trough of a wave,
and frequency is the occurance of these waves per time unit (like seconds for
example). Also that amplitude is the hight/distance of a peak/trough.

When data is sent it is sent using a certian wavelength/frequence but the
amplitude can vary (if it did not we would only be able to send the same
information as there would not be any variation.

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

### Noise
Is an unwanted random signal that gets added to our wanted (random) signal. This
is called white noise because is contains all the frequenecies (think about
white light which contain all the visual light frequencies).


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
