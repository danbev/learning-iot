### Oscilloscope notes
This document contains notes releated to understanding and using an
oscilloscope. I've got a Hantek DSO5102P which has two channels.

While I've been able to use the oscilloscope for UART and just checking the
output clock frequency I ran into problems when working with I2C.

### Time grid (horizontal)
So we have a grid of unit for time which is not showing up on my scope by
default (actually it was but as dots and the intensity was not very large) and
thi can be adjusted by pressing the `DISPLAY` button and then going to the
second meny (by pressing F5) and then I changed the `Grid` to be `Real line` and
increased the intensity.

So the squares in horizonal direction are in time units. If we have setting of
40.0 micro seconds that means that one square is 40.0µs and lets say that it the
wave is high for 12 squares, that will become 480µs. Now, if we change the
horizontal setting to be 80µs instead that will make each square 80µs instead
and we will only have 6 squares for the same 480µs. 

We can use the horizontal nob to position the wave on the grids to make
measuring easier. Like if we have a time unit of 200µs and a period of our wave
takes 5 squares that would be one 1000µs, or 0.001sec or 1ms.

### Voltage grid (vertial)
This grid shows the voltage and it is per square, what I mean is that if the
display says 2.00V that means that each square in the grid (vertical direction)
represents 2.00V. So if we have a signal of 2.40V that would be almost two and
a half squares.

### Trigger
What a trigger does is tell the oscilloscope when to start aquiring data and
display the wave of the data. By pressing the `TRIG MENU` button we can access
the setting to specify the type, which can be at the edge, and we can also
specify that we want to trigger on raising or falling edge (this is done further
down in the Slope section).

In the case of I2C SCL should be high and then pulled low, so I think it makes
sense to trigger on the falling edge.
Now the signal I'm seeing (not sure if this is correct at the moment) is not
a square wave. We can use a trigger to get a stable view of the wave (instead
of one that is moving around all over the place). This trigger should be at
the middle of the wave.

### Volts/Div
This nob is available for both channels and what this allows us to do is to
zoom in on the 

