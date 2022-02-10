## Bluetooth notes

### BlueTooth (Basic Rate/Enhanced Data Rate (BR/EDR) (classic)
Short range, low power, low datarate. Point-to-point.
Was created in the late 80, early 90's by Ericson Mobile where the goal was to
create a wireless headset + serial link. This was a IEEE standard 802.15.1 but
is now managed by the BlueTooth Special Interest Group (SIG) which has
members like Ericsson, Intel, Nokia, Toshiba, IBM, MicroSoft, Lenova, Apple.

The name `BlueTooth` I heard comes from a Danish king named Harald Blåtand
Gormsen who united the tribes of Denmark into a single kingdom, and the logo
is rune skrift of his initials H and B.

One master/controler and up to 7 active slaves/peripherals in what is referred
to as a piconet. But a piconet can have up to 255 parked slaves.

Baseband modes in the connected state:
* active
  The slave is actively listening for transmissions. Consumes most power.

* sniff
  The slave becomes active periodically which allows a method reduced power
  consumption

* hold
  The slave stops listening entierly for a specific time interval. Also reduces
  power consuption.

* park
  The slave maintains sync with the master but is no longer considered active.
  There can only be 7 active slaves in a piconet and this is a way to enable
  slaves outside of the currently active 7 to participate. There still needs to
  be a sync using a beaconing scheme. Also reduces power consumption.

Baseband mode in the un-connected state:
* standby


Transport protocol group
```
   Audio applications         Data applications
      ↓                         ↓            ↓
  +--------------------------------------------------------------------------+
  |   |                         |            |                               |
  |   |                  +-------------+ +---------------+                   |
  |   |                  |     L2CAP   |→|  control      |                   |
  |   |                  +-------------+ +---------------+                   |
  |   |                         |            |            +-------------+    |
  |   |                         |            |            |link manager |    |
  |   |                         |            |            +-------------+    |
  |   ↓                         ↓            ↓                               |
  | +-------------------------------------------------------------------+    |
  | |                          baseband                                 |    |
  | +-------------------------------------------------------------------+    |
  |                             ↓                                            |
  | +-------------------------------------------------------------------+    |
  | |                          radio                                    |    |
  | +-------------------------------------------------------------------+    |
  |                                                                          |
  +--------------------------------------------------------------------------+

```
Audio applications require being treated with high priority which bypasses the
intermediate transport layers and goes directly to the baseband layer.

#### Logical Link Control and Adapation protocol (L2CAP)
Trafic from data applications are routed through this layer which takes care
of things like frequency hops, the message wire format, segmentation of larger
packets and reassembling them on the receiving side.

Transmits packets within the 2.4Ghz band. The master is the party that controls
the Frequency Hopping Spread Spectrum (FHSS) and specifies the frequency
based upon the masters bluetooth device address, and the timing based upon
the masters clock.

L2CAP can use the control layer to control layer which can interact with the
link manager to perform actions.

#### Link Manager
These negotiate the properites of the connection using the Link Manager
Protocol (LMP). They take care of device pairing and they also support power
control by negotiating the low activity baseband modes (see above for the
modes). The concept of master/slave does not propagate higher up than this
layer.

Uses the Industrial Scientific, and Medical (ISM) radio band.
```
2.4 GHz ISM -> 2,400.0 - 2,483.5
Lower Guard Band (LGB): 2.0
Upper Guard Band:(UGB) 3.5

Channels:
0   =  2,400.0 + 2.0    = 2,402.0
1   =  2,402.0 + 1      = 2,403.0
2   =  2,402.0 + 2      = 2,404.0
...
78  =  2,402.0 + 78     = 2,480.0
79  =  2,480.0 + 3.5    = 2,483.5
```
So this gives 79 1MHz channels which are the channels used for FHSS which hops
at 1600/second (which should give 625 micro seconds per hop).

For devices to be able to communicate they all have to transmit and receive
using the same frequency (at the same time and with frequency hoping in mind).

Uses Time Division Multiplexing (TDM) where the master has time slots where it
communicates with slaves. It is after each such time slot that the frequency
hopping takes place.

Connection States:
```
           +-----------------------------+
           |                             ↓
      +----------+   +----------+   +---------+
      | standby  |--→| inquery  |--→| page    |---------+
      +----------+   +----------+   +---------+         |
                                                        |
                                                        ↓
                                                 +------------+
                                                 |  connected |
                                                 +------------+
```
Inquery state is where a device learns about the identity of other devices.
These other devices must be in a inquiry-scan state so that they can respond
to the inquery.

The page state is where a device explicitly invites another device to join the
piconet whose master is inviting the device. The other device must be in a
page-scan state listening and able to respond to.

If the device is already know the inquery stage can be skipped.

#### BlueTooth Device Address (BD_ADDR)
This is a 48-bit address electronically "engraved" on each device and is
globally unique among bluetooth devices.
```
    Lower Address Part  Upper Address Part  Non-Significant Address Part
         (LAP)               (UAP)            (NAP) 
            ↓                   ↓               ↓
  +----------------------+------------+----------------+
  |                      |            |                |
  +----------------------+------------+----------------+
          24 bits            8 bits         16
```
The UAP and NAP are provided/assigned by a number authority and represent the
organization unique identfier (OUI).


The data format between the master and the slave (after the connection step
has been performed) looks like this:
```
  +-------------+------------+--------------------------+
  | access code |   header   |       payload            |
  +-------------+------------+--------------------------+
    72 bits        54 bits           0-2744 bits
```
This is the amount of data that can be sent in a single time slot.

Access code portion:
```
  +---------+------------------------+--------+
  |preamble |   synchronization      |trailer |
  +---------+------------------------+--------+
    4 bits          64 bits              4 bits

```
The synchronization bits are derived from the masters id.

Header portion:
```
  +--------+---------+---+----+----+-------------------+
  |am-addr |  type   |flo|arqn|seqn| header error check|
  +--------+---------+---+----+----+-------------------+
      3         4      1   1    1            8

am-addr = Active Member Address. 1 master plus 7 slaves so 3 bits to specify
          which member this packet is to/from.
type    = 12 types of data packets, and 4 control types.
arqn    = Ack bit?
seqn    = Sequence bit.
```

### BlueTooth Low Energy (BLE)
Broadcast. One to many.
Is also marketed as BlueTooth Smart and is part of the 4.1 Bluetooth
specification. BLE is completely focused on low power and was originally
designed by Nokia as Wibree and their focus was on designing a radio standard
with the lowest possible power consumption, low cost, low bandwidth, low power
low complexity. It was designed to be an extensible framework for data exhange.

The on-the-air wire protocol the upper protocol layers, and the application
layers are different for BLE which makes it incompatible with Bluetooth classic.

The bluetooth specification 4.0 and above specifcy two wireless technologies:
* Bluetooth Basic Rate/Enhanced Data Rate (BR/EDR) or classic Bluetooth.
* Bluetooth Low Energy (BLE)

There are also two configurations where one is named single mode which is a
device that implements BLE. Such a device can communicate with other single mode
devices and dual-mode devices but not with devices that only support BR/EDR.

The we have dual-mode which implements both BR/EDR and BLE which can communicate
with any Bluetooth device.

#### Boadcasting
There are two was of communication, broadcasting or connections.
With broadcasting data is sent out to any scanning device in listening range.
This is one way communication and the sender is called the broadcaster and
the listeners are called observers. The message that the broadcaster sends are
called `advertising` packets and the observer repeatadly scans the preset
frequenies to receive any of these advertising packets.
Broadcasting is the only way to send data to multiple devices at once.
The advertising packet contains a 31 bit payload but it is possible to have an
optional `Scan Response` to allow for 62 bytes.

#### Connections
Are a periodic permanent exchange of packets between two devices. Like in
Bluetooth classic we have two roles, Central (master), and Peripheral (slave).
A Central device will scan for `connectable advertising` packets on preset
frequencies and one a connection is established the Central manages timing and
initiates the periodic data exchange.

The Perhipheral sends connectable advertising packets periodically and accepts
incoping packets.

```
                        conn adv    +--------------+
   +-----------+      <-------------| Peripheral 1 |
   | Central   |                    +--------------+
   +-----------+        conn adv    +--------------+
                      <-------------| Peripheral 2 |
 scans frequencies                  +--------------+


                 connection request +--------------+
   +-----------+------------------->| Peripheral 1 |
   | Central   |                    +--------------+
   +-----------+

```
In Bluetooth classic before version 4.1 there was a limit that a peripheral
could only be connected to one central but this is not the case anymore.

With connections there is greater control of the fields or properties through
the usage of additional protocol layers like Generic Attribute Profile (GATT)

#### Physical Layer
Uses the Industrial Scientific, and Medical (ISM) radio band.
```
2.4 GHz ISM -> 2,400.0 - 2,483.5
Lower Guard Band (LGB): 2.0
Upper Guard Band:(UGB) 3.5

Channels:
```
    =  2,402.0 <--+
0   =  2,404.0    |
1   =  2,406.0    |
2   =  2,408.0    |
...               |
    =  2,426.0 <-----+
...               |  |
36  =  2,478.0    |  |
37  =  -----------+  |
38  =  --------------+
39  =  2,480.0

```
Channel 37, 38, and 39 are used for advertising to set up connections and send
broadcast data.
```
channel = (curr_channel + hop) mod 37
```
The value of `hop` is communicated when the connection is established so it is
different for each new connection.
The modulation used is Gaussian Frequency Shift Keying (GFSK).

#### GAP
The topmost control layer and specifies how devices perform things like device
discovery, connections, security establishment.

#### Attribute Protocol (ATT)
Is simple client/server protocol for interacting with attributes of a device.
An attribute handle which is an Universal Unique Identifer (UUID) is used to
identify an attribute, for example for reading or writing a value. So a client
would issue a read request and specify the UUID for that particular attribute
and it would get back attribute value. A client can get a list of attributes
that a server has.
TODO: add example of using ATT.

#### Security Manager (SM)
Is both a protocol and a number of security algorithms.

Pairing is the process where a temp encryption key is generated so that an
encrypted secure link can be switched to. This key is not stored and not reused.

Bonding is a sequence of pairing followed by the generation and exchange of
permanent keys which are stored in non-volotile memory (so this is an example
of what non-volatile memory can be used for). With these setup there is not
need to go through this bonding process again.

Encryption Re-establishment uses the keys from a previous bonding to establish
a secure connection using those keys (does not have to go through the bonding
again).

```
  Central                            Peripheral
+----------------------------------------------------------+
|                   Bonding                                |
| +------------------------------------------------------+ |
| |                 Pairing                              | |
| |                                                      | |
| |           Feature exchange                           | |
| |          <------------------------>                  | |
| |  STK gen                             STK gen         | |
| |             encrypted with STK                       | |
| |          <------------------------>                  | |
| |                                                      | |
| +------------------------------------------------------+ |
| +------------------------------------------------------+ |
| |            Key Distribution                          | |
| +------------------------------------------------------+ |
|                                                          |
+----------------------------------------------------------+
```
So with the feature exchange that information is/could be sent in clear text
allowing an attacher to intercept the message and find out the data used in the
key generation. This type of pairing algorithm is called `Just Works`.

`Passkey Display` can also be used where one of the peers randomally generates
a 6-digit passkey and the other side is asked to enter it.

`Out Of Bound (OOB)` this way additional data is transferred outside of BLE,
like Near Field Communication (NFC).

Security Keys:
* Encryption Information (Long Term Key (LTK)) and Master Information (EDIV, Rand)

### WiFi Direct
Is  a peer-to-peer connection and and does not need a wifi access point. It uses
the same frequency and similar bandwidth and speed as normal WiFi.

### Near-Field Communication (NFC)
Other wireless devices emit radio signals but NFC communicate with an EM field
(not a wave that is) between two coils. So these two coils need to be very
close to each other for this to work.
There can be passive tags don't have any power source of their own and instead
get their power from the reader over the EM field.

### Low-Power, Short-Range, Low-Data, Mesh technologies
Mesh means many-to-many so with these technologies we can send a message to a
destination device without being directly connected to that device:
```
 A ---> B --> C
```
In this case A want to send a message to device C but is only sending to B which
migth be closer. A might be too far away to even be able to send to C. There
can be many hops here and they can be spread out over fairly long distance and
still have low power consuption for the devices.

Examples: BlueTooth Low-Energy, ZigBee, Z-Wave, and 6LoWPAN.

### Directed
Direct advertisements accept connections from any `known` peer.

### Undirected
Undirected advertisements accept connections from any peer.

### Protocol Data Unit
These have a specific format in the BLE specification:
```
[<Where is it used>_]<When is it used>_<What does it do>_[Version_]<How is it used>

Where is it used:
Is optional and the default is NONE:
[<NONE|AUX>_]
NONE = nothing which is the default and means the primary channelr
AUX  = is used on the secondary physical channel

When is it used:
ADV = Normal Advertising
SYNC = Periodic Advertising
SCAN = Scanning
CONNECT = Connecting
CHAIN = Fragmented data
LL = Control PDU on the data logical transport?
BIG =  TODO: Isochronous
DATA = Reliable data
CIS = TODO:
BIS = TODO:

What does it do:
NONE
DIRECT = directly connectable
NONCONN = Non-connectable and non-scannable undirected
SCAN = Scannable undirected.

Version:
None = original version of the PDU
EXT = extended version of the PDU

How is it used:
IND = An indication that does not require a reply
REQ = A request that requires a response
RSP = A response to a request.
```
I found that initially when reading documentation and seeing something like
ADV_IND we can understand that this is an advertisment PDU and that it is used
as an indication that does not require a reply.

### Advertisement
As mentioned earler in this document there BLE uses 40 different RF channels
and of these 40, 3 are called primary advertising channels. These are channels
37, 38, and 39 and are closen to be furthest away from the WiFi channels.
These channels are used for `advertisements`, `scan requests`, `scan responses`
, and `connection requests`.

Advertisements are broadcasted by a peripheral to anyone that is listening. 
```
Frame 1: 70 bytes on wire (560 bits), 70 bytes captured (560 bits) on interface /tmp/pipe, id 0
PPI version 0, 24 bytes
    Version: 0
    Flags: 0x00
    Header length: 24
    DLT: 251
    Reserved: 36750c0000620900fa63050023152200
Bluetooth
    [Source: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)]
    [Destination: Broadcast (ff:ff:ff:ff:ff:ff)]
Bluetooth Low Energy Link Layer
    Access Address: 0x8e89bed6
    Packet Header: 0x2560 (PDU Type: ADV_IND, ChSel: #2, TxAdd: Random)
        .... 0000 = PDU Type: 0x0 ADV_IND
        ...0 .... = Reserved: 0
        ..1. .... = Channel Selection Algorithm: #2
        .1.. .... = Tx Address: Random
        0... .... = Reserved: 0
        Length: 37
    Advertising Address: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)
    Advertising Data
        Appearance: Unknown
            Length: 3
            Type: Appearance (0x19)
            Appearance: Unknown (0x0000)
        Flags
            Length: 2
            Type: Flags (0x01)
            000. .... = Reserved: 0x0
            ...0 .... = Simultaneous LE and BR/EDR to Same Device Capable (Host): false (0x0)
            .... 0... = Simultaneous LE and BR/EDR to Same Device Capable (Controller): false (0x0)
            .... .1.. = BR/EDR Not Supported: true (0x1)
            .... ..1. = LE General Discoverable Mode: true (0x1)
            .... ...0 = LE Limited Discoverable Mode: false (0x0)
        Device Name: BLE_Peripheral_Example
            Length: 23
            Type: Device Name (0x09)
            Device Name: BLE_Peripheral_Example
    CRC: 0xe60779
```


Scan requests are sent by a controller to a specific peripheral:
```
Frame 3: 45 bytes on wire (360 bits), 45 bytes captured (360 bits) on interface /tmp/pipe, id 0
PPI version 0, 24 bytes
Bluetooth
    [Source: 6a:4c:3f:c2:d2:18 (6a:4c:3f:c2:d2:18)]
    [Destination: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)]
Bluetooth Low Energy Link Layer
    Access Address: 0x8e89bed6
    Packet Header: 0x0cc3 (PDU Type: SCAN_REQ, TxAdd: Random, RxAdd: Random)
        .... 0011 = PDU Type: 0x3 SCAN_REQ
        ...0 .... = Reserved: 0
        ..0. .... = Reserved: 0
        .1.. .... = Tx Address: Random
        1... .... = Rx Address: Random
        Length: 12
    Scanning Address: 6a:4c:3f:c2:d2:18 (6a:4c:3f:c2:d2:18)
    Advertising Address: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)
    CRC: 0xf1a5d5
```
Notice that the `Destination` is specified.

And a scan response would look like this:
```
Frame 4: 57 bytes on wire (456 bits), 57 bytes captured (456 bits) on interface /tmp/pipe, id 0
PPI version 0, 24 bytes
Bluetooth
    [Source: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)]
    [Destination: Broadcast (ff:ff:ff:ff:ff:ff)]
Bluetooth Low Energy Link Layer
    Access Address: 0x8e89bed6
    Packet Header: 0x1844 (PDU Type: SCAN_RSP, TxAdd: Random)
        .... 0100 = PDU Type: 0x4 SCAN_RSP
        ...0 .... = Reserved: 0
        ..0. .... = Reserved: 0
        .1.. .... = Tx Address: Random
        0... .... = Reserved: 0
        Length: 24
    Advertising Address: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)
    Scan Response Data: 110723d1bcea5f782315deef121223150000
        Advertising Data
            128-bit Service Class UUIDs
                Length: 17
                Type: 128-bit Service Class UUIDs (0x07)
                Custom UUID: 00001523-1212-efde-1523-785feabcd123 (Unknown)
    CRC: 0xfa8da7
```
I was a little surprised to see that this is broadcasted instead of being sent
to the party that issued the scan request.

A connection is initiated by a central by sending a `CONNECT_IND` request
to a peripheral:
```
Frame 532: 67 bytes on wire (536 bits), 67 bytes captured (536 bits) on interface /tmp/pipe, id 0
PPI version 0, 24 bytes
Bluetooth
    [Source: 5a:3e:6b:71:17:cc (5a:3e:6b:71:17:cc)]
    [Destination: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)]
Bluetooth Low Energy Link Layer
    Access Address: 0x8e89bed6
    Packet Header: 0x22c5 (PDU Type: CONNECT_IND, TxAdd: Random, RxAdd: Random)
        .... 0101 = PDU Type: 0x5 CONNECT_IND
        ...0 .... = Reserved: 0
        ..0. .... = Reserved: 0
        .1.. .... = Tx Address: Random
        1... .... = Rx Address: Random
        Length: 34
    Initiator Address: 5a:3e:6b:71:17:cc (5a:3e:6b:71:17:cc)
    Advertising Address: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)
    Link Layer Data
        Access Address: 0xaf9aa3a6
        CRC Init: 0x3bc312
        Window Size: 3 (3.75 msec)
        Window Offset: 13 (16.25 msec)
        Interval: 24 (30 msec)
        Latency: 0
        Timeout: 72 (720 msec)
        Channel Map: ffffffff1f
            .... ...1 = RF Channel 1 (2404 MHz - Data - 0): True
            .... ..1. = RF Channel 2 (2406 MHz - Data - 1): True
            .... .1.. = RF Channel 3 (2408 MHz - Data - 2): True
            .... 1... = RF Channel 4 (2410 MHz - Data - 3): True
            ...1 .... = RF Channel 5 (2412 MHz - Data - 4): True
            ..1. .... = RF Channel 6 (2414 MHz - Data - 5): True
            .1.. .... = RF Channel 7 (2416 MHz - Data - 6): True
            1... .... = RF Channel 8 (2418 MHz - Data - 7): True
            .... ...1 = RF Channel 9 (2420 MHz - Data - 8): True
            .... ..1. = RF Channel 10 (2422 MHz - Data - 9): True
            .... .1.. = RF Channel 11 (2424 MHz - Data - 10): True
            .... 1... = RF Channel 13 (2428 MHz - Data - 11): True
            ...1 .... = RF Channel 14 (2430 MHz - Data - 12): True
            ..1. .... = RF Channel 15 (2432 MHz - Data - 13): True
            .1.. .... = RF Channel 16 (2434 MHz - Data - 14): True
            1... .... = RF Channel 17 (2436 MHz - Data - 15): True
            .... ...1 = RF Channel 18 (2438 MHz - Data - 16): True
            .... ..1. = RF Channel 19 (2440 MHz - Data - 17): True
            .... .1.. = RF Channel 20 (2442 MHz - Data - 18): True
            .... 1... = RF Channel 21 (2444 MHz - Data - 19): True
            ...1 .... = RF Channel 22 (2446 MHz - Data - 20): True
            ..1. .... = RF Channel 23 (2448 MHz - Data - 21): True
            .1.. .... = RF Channel 24 (2450 MHz - Data - 22): True
            1... .... = RF Channel 25 (2452 MHz - Data - 23): True
            .... ...1 = RF Channel 26 (2454 MHz - Data - 24): True
            .... ..1. = RF Channel 27 (2456 MHz - Data - 25): True
            .... .1.. = RF Channel 28 (2458 MHz - Data - 26): True
            .... 1... = RF Channel 29 (2460 MHz - Data - 27): True
            ...1 .... = RF Channel 30 (2462 MHz - Data - 28): True
            ..1. .... = RF Channel 31 (2464 MHz - Data - 29): True
            .1.. .... = RF Channel 32 (2466 MHz - Data - 30): True
            1... .... = RF Channel 33 (2468 MHz - Data - 31): True
            .... ...1 = RF Channel 34 (2470 MHz - Data - 32): True
            .... ..1. = RF Channel 35 (2472 MHz - Data - 33): True
            .... .1.. = RF Channel 36 (2474 MHz - Data - 34): True
            .... 1... = RF Channel 37 (2476 MHz - Data - 35): True
            ...1 .... = RF Channel 38 (2478 MHz - Data - 36): True
            ..0. .... = Reserved: False
            .0.. .... = Reserved: False
            0... .... = Reserved: False
        ...0 1000 = Hop: 8
        001. .... = Sleep Clock Accuracy: 151 ppm to 250 ppm (1)
    CRC: 0xaa41c4
```

This will be followed by a PHY Link Layer feature request:
```
Frame 539: 42 bytes on wire (336 bits), 42 bytes captured (336 bits) on interface /tmp/pipe, id 0
PPI version 0, 24 bytes
Bluetooth
Bluetooth Low Energy Link Layer
    Access Address: 0xaf9aa3a6
    [Master Address: 5a:3e:6b:71:17:cc (5a:3e:6b:71:17:cc)]
    [Slave Address: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)]
    Data Header: 0x090f
        .... ..11 = LLID: Control PDU (0x3)
        .... .1.. = Next Expected Sequence Number: 1
        .... 1... = Sequence Number: 1
        ...0 .... = More Data: False
        000. .... = RFU: 0
        Length: 9
    Control Opcode: LL_FEATURE_REQ (0x08)
    Feature Set: 0x00000000000179ff
        .... ...1 = LE Encryption: True
        .... ..1. = Connection Parameters Request Procedure: True
        .... .1.. = Extended Reject Indication: True
        .... 1... = Slave Initiated Features Exchange: True
        ...1 .... = LE Ping: True
        ..1. .... = LE Data Packet Length Extension: True
        .1.. .... = LL Privacy: True
        1... .... = Extended Scanner Filter Policies: True
        .... ...1 = LE 2M PHY: True
        .... ..0. = Stable Modulation Index - Transmitter: False
        .... .0.. = Stable Modulation Index - Receiver: False
        .... 1... = LE Coded PHY: True
        ...1 .... = LE Extended Advertising: True
        ..1. .... = LE Periodic Advertising: True
        .1.. .... = Channel Selection Algorithm #2: True
        0... .... = LE Power Class 1: False
        .... ...1 = Minimum Number of Used Channels Procedure: True
        0000 000. = Reserved: 0
        Reserved: 0000000000
    CRC: 0x248aae
        [Expert Info (Note/Checksum): CRC unchecked, not all data available]
```

#### BLE Blinky Example
Up until this point I've just been reading and I'm finding this a little
abstract so I wanted to take a look at an example to help my understanding and
that I can follow. For this I needed to install JLink and
nrf-command-line-tools.

Run the nrf BLE Blinky example:
```console
$ cd nRF5_SDK_17.1.0_ddde560/examples/ble_peripheral/ble_app_blinky/pca10040/s132/armgcc
$ make flash_softdevice
$ make flash
```
Now we can use `nrf-connect` which is a mobil app and I'm using it on my iphone
and the name of the adverisment is `Nordic_Blinky`. So this is a peripheral
which is sending out advertisements which is indicated by LED1 coming on.
When we press the `Connect` button we will be paired and bonded with central
which is the nrf-connect app if I'm understanding things correctly.

This peripheras has a service that it is advertising named `Nordic LED and
Button Service`. In the attribute table we can find an attribute named
`Blinky LED State` which is `Read and Write`. If we press on the up arrow we
can send a new value. For example write a Bool value of true will turn on
LED3.

### BLE Mesh
Is a network allowing BLE Many-to-many communication.
TODO: 


### Connectionless Packet Switching
Each packet contains the complete routing infomation in its header section, like
source address, destination addresss, sequence number.

### Connection-Oriented Packet Switching
In contrast to connectionless packet switching the packets are assembled and
numbered and then sent over a predefined route sequentially. The packets do
not require the address information that is required in connection-less
packet switching.

### Asynchronous Connection Less (ACL)
So we know what connection-less packets are from the above section about it.
This type is used for general data frames.
There are two frame types:
* DM# (Data Medium Rate?) which contains Forward Error Correction (FEC)
* DH# (Data High Rate) which does not provide FEC.

The `#` indicates a number of 625 micro seconds each each frame type will take.

### Synchronous Connection Oriented (SCO)
This is used for Audio frames. 


### Secure And Fast Encryption Routine (SAFER)
Is a family of block ciphers and was a candidate for AES. It has a block size
of 128 and it is used for autentication (MIC/MAC) and key generation, but not
encryption in BlueTooth classic.

### E0
Is a stream cipher used for encryption in BlueTooth classic.



### Security
One thing to keep in mind when reading documentation related to BlueTooth
classic and BlueTooth Low Energy. For versions 4.2 and beyond there is a type
of connection called Secure Connections or LE Security which uses ECHF. Prior
type of secure connection before this is called Legacy connection. 

```

  +-----------------+ +-----------+                ⌉
  |    GAP          | | GATT      |                |
  +-----------------+ +-----------+                |
  +-----------------+ +-----------+                | BLE Stack
  | Security Manager| |ATT        |                |
  +-----------------+ +-----------+                |
  +--------------------------------------------+   |
  |     L2CAP                                  |   |
  +--------------------------------------------+   |
  +--------------------------------------------+   |
  |     HCI                                    |   |
  +--------------------------------------------+   |
  +--------------+ +-----------+                   |
  | Link Layer   | | DTM       |                   |
  +--------------+ +-----------+                   ⌋
                                                     
  +--------------------------------------------+ 
  |     Radio Physical Layer (PHY              |
  +--------------------------------------------+
```
The Security Manager (SM) is responsible for managing pairing and bonding.
The Link Layer takes care of the encryption/decryption and uses AES-CCM.
The GATT server defines which characteristics are exposed and how they are
accessible (read/write), and also defines the services security requirements 
TODO: document how this actually work.

A connection starts out without any security so the initial packets are sent
in plain text. But the information in these packets are.

After a secure link has been established then every data packet sent will be
protected by AES-CCM. 

Lets look at an example to visualize what a connection process might look like

```
Central            Advertisement broadcast            Peripheral
GATT Client      <-------------------------           GATT Server

                   Connection Request                 Service
                  ------------------------>              Characteristic 1
                   GATT Service and Characteristics      Characteristic 2
	            discovery
                  <----------------------->
                   Pairing (optionally with MITM protection)
                  <----------------------->
                   Establishment of Secure link
                  <----------------------->
                   Secure channel
                  <----------------------->

```

BR/EDR Legacy Pairing uses E21 or E22 based on SAFER+.
Secure Simple Pairing uses SHA-256, HMAC-SHA-256 and P-192 elliptic curve.
LE Legacy Pairing used AES-CCM


## Security

### Temporary Key (TK)
This is a key used during pairing and its value depends on the pairing method
in use.

### Short Term Key (STK)
This key is used for encryption when two devices pair for the first time and
is generated using 3 pieces of information, the TK, the Srand value which comes
from the peripheral/slave, and the Mran which comes from the central/master.


### Long Term Key (LTK)
This key is distributed once the inital pairing procedure has encrypted the
connection.

### Identity Resolving Key (IRK)
A peer devices identity can be used to track the user of the device and this is
a measure to avoid such tracking. This works by changing this device address
so tracking is not possible but to resolve a random device address to a real
address this key is used.
TODO: explain how this works.

### Connection Signature Resolving Key (CSRK)
Used for signature verification to authenticate the sender of a message.

### AES/CCM (Counter with CBC-MAC)
Recall that Advanced Encryption Standard (AES) is a symmetric encryption method
so both sides use a shared secret key. This key can be generated in any way and
might have been the result of a Diffie-Hellman key exchange for example.

The CCM block generates an encrypted keystream that is applied to input data
using the XOR operation, and  also generates the four byte Message Integrity
Check (MIC), which is what a MAC is called in the Bluetooth specification to
avoid confusion with the term Media Access Controller, field in one
operation.

In the following case Bob and Alice have a shared key so this is symmetric
encryption:

```
  Bob                                                        Alice
  msg: hello  e ------> 1E73EB42C5467E8D8A71BB9856   ----> d msg: hello
              ^                                            ^ 
              |                                            |
              +------------ bajja -------------------------+
                           (AES key)
    
```
Now, only someone with access to the key can decrypt the message. But it might
be possible for someone to changed the content of the message in transit.

For example, if instead of hello above we had a message that was "Pay out 300"
```
Message: "Pay out 300"
Ciphertext: 2677FE0EC5E84431D04D6A8B6271C674A4A14B
```
The ciphertext could be intercepted and modified, and if it could be updated
to:
```
Message: "Pay out 900"
Ciphertext: 2677FE0EC5E84431DA4D6A740E690908CC58E4
```
And this would look perfectly alright to the receiver. So we need something
more which is where the message authentication code/message integrity check
comes into play.

### Wireshark BlueTooth (Ubertooth One) packet capturing
```
$ mkfifo /tmp/pipe
```
Open Wireshark and click on the settings "Capture Options" (looks a little like
a steering wheel of an old ship). Then click "Manage intefaces" and the choose
Pipe and add a pipe named `/tmp/pipe`. Then close and then make sure to select
this option and then click capture.

Next start `ubertooth`:
```console
$ ubertooth-btle -f -c /tmp/pipe 
```
This should now start capturing packets in wireshark and also there will be
output in the console.


