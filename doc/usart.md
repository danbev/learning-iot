### Universal Synchronous and Asynchronous Receiver-Transmitter (USART)
Is a serial communication protocol which as the name suggests can be used
sync (using clocks) or async(using start/stop bits).
```
     Device 1               Device 2
    +----------+           +----------+
    |        TX|-----------|RX        |
    |        RX|-----------|TX        |
    |       GND|-----+-----|GND       |
    +----------+     |     +----------+
                     |
                   -----
                    ---
                     -
```
The sender and reicever must agree on a data transfer rate, which is called the
baud rate which is number of bits transferred per second.
Simplex mode is when data is transferred in one direction only.
Half-duplex is when data is transferred in both directions but not at the same
time.
Full-duplex is when data can be transferred simultainously in both directions at
the same time.

The wire protocol:
```
  +-----------+-------------+---------------+-------------+
  |1 start bit|5-9 data bits|0-1 parity bits|1-2 stop bits|
  +-----------+-------------+---------------+-------------+
```

### Signaling
Normally, the sender keeps the transmission (Tx) line high, say at 5V and this
is polled/sampled by the reciever (Rx). When this goes low the receiver will
start sampling/reading for data packets.
```
    idle   start
     |      bit
     ↓      ↓
5V  -----+      +------+      +
         |      |      |      |
         |      | d0   |  d1  |
0V       +------+      +------+
         |      |      |      |
```

Both sides need to agree on things like if how many data bits the packet
contains, if there is a parity bit or not (and if it is odd or even), and how
many stop bits are in use (1-2 bits). In addition they also need the receiver
needs know how many bits the sender sent per second. Both sides need to agree
on this rate as well. The receiver needs to know how many bit are being sent
per second so that it can determine how long a 5V pulse is determined to be
a 1 bit, and how long a 0V pulse is considered to be a 0 bit value. This is
configured by the sender and receiver specifying a bits per second for sending
and receiving and is called the baud rate.
```
                                    Baud rate: 9600 (9600 bits/s)
    idle   start
     |      bit
     ↓      ↓
5V  -----+      +------+------+
         |      |      |      |
         |      | d0   |  d1  |
0V       +------+
                 1/9600  1/9600
```
Remember that the receiver reads one value at a time from the wire and in the
above case the first two bits are 1s. If the receiver does not know the time
to sample, or is does not use the same rate as the sender, the read values may
become incorrect. What the receiver does is it knows how long a single bit
should be and samples with that frequency so it will determine that there were
two 1 bits as the wire was held high for 2/9600.

### Baud (Bd)
Is a common unit in symbols per second in electronic communication. The number
of symbol changes, signaling events in the transmission medium. So if we take
our image above where we have

### Oversampling
The receiver constantly samples/reads/polls the data line and it does this more
often than the baud rate. An common setting is to sample 16 times the baud rate.
So our baud rate might be 9600 bits/s then the frequency that the reciever polls
the data line would be 9600x16=153600 times per second. But the data rate being
used is only 9600 bits per second so the receiver is reading/sampling more than
that, so it is "over sampling".

The receiver will sample the data line and look for when the it goes from idle
(high) to low. When this happens the reciever will start a timer:
```
    idle   start
     |      bit
     ↓      ↓
5V  -----+      +------+      +
         |      |      |      |
         |      | d0   |  d1  |
0V       +------+      +------+
         ↑
       start counter (0-15 ticks)
```
When the tick counter reaches 7, the middle of the start bit, it clears the
tick counter and the counter restarts:
```
    idle   start
     |      bit
     ↓      ↓
5V  -----+      +------+      +
         |      |      |      |
         |      | d0   |  d1  |
0V       +------+      +------+
            ↑
         7 ticks
```
This is done to estimate the middle of each bit. So when can then count from
0 to 15 and then we know that is the first data bit (data bit 0) and that value
can be read into a register:
```
    idle   start
     |      bit
     ↓      ↓
5V  -----+      +------+      +
         |      |      |      |
         |      | d0   |  d1  |
0V       +------+      +------+
            ↑       ↑
            +-------+
            0       15
```
This process repeats for the number of bits that make up the data (this is
agreed upon to be 6, 7, or 8 bits). And this will optionally happen for a
parity bit if that is in use.

If the stop bit is configured to be 1 bit then we again count to 16:
```
    
                         stop bit 
                           ↓  
                +------+      +
         |      |      |      |
         |      | d7   |      |
         +------+      +------+
                   ↑       ↑
                   +-------+
                   0       15
```
If the stop bit is configured to be 0.5 bits that we count to 8:
```
    
                         stop bit 
                           ↓  
                +------+      +
         |      |      |      |
         |      | d7   |      |
         +------+      +------+
                   ↑   ↑
                   +---+
                   0   7
```
If the stop bit is configured to be 1.5 bits that we count to 24:
```
    
                         stop bit 
                           ↓  
                +------+      +------+
         |      |      |      |      |
         |      | d7   |      |      |
         +------+      +------+      +
                   ↑              ↑
                   +--------------+
                   0             24
```
If the stop bit is configured to be 2 bits that we count to 32:
```
    
                         stop bit 
                           ↓  
                +------+      +------+
         |      |      |      |      |
         |      | d7   |      |      |
         +------+      +------+      +
                   ↑                 ↑
                   +-----------------+
                   0                 32
```
