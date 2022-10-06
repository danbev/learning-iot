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
of what non-volatile memory can be used for). With these set up there is no
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

`Out Of Bound (OOB)` in this mode additional data is transferred outside of BLE,
like Near Field Communication (NFC).

Security Keys:
* Encryption Information (Long Term Key (LTK)) and Master Information (EDIV, Rand)

### Near-Field Communication (NFC)
Other wireless devices emit radio signals but NFC communicate with an EM field
(not a wave that is) between two coils. So these two coils need to be very
close to each other for this to work.
There can be passive tags that don't have any power source of their own and
instead get their power from the reader over the EM field.

### Low-Power, Short-Range, Low-Data, Mesh technologies
Mesh means `many-to-many` so with these technologies we can send a message to a
destination device without being directly connected to that device:
```
 A ---> B --> C
```
In this case A wants to send a message to device C but is only sending to B
which migth be closer. A might be too far away to even be able to send to C.
There can be many hops here and they can be spread out over fairly long distance
and still have low power consuption for the devices.

Examples: BlueTooth Low-Energy, ZigBee, Z-Wave, and 6LoWPAN.

### Directed
Direct advertisements accept connections from any `known` peer.

### Undirected
Undirected advertisements accept connections from any peer.

### Protocol Data Unit
These have a specific format in the BLE specification:
```
[<Where is it used>_]<When is it used>_<What does it do>_[Version_]<How is it used>
```
Notice that the `Where is it used` and `Version ` are optional. The fields are
described below:
Where is it used:
```
Is optional and the default is NONE:
[<NONE|AUX>_]
NONE = nothing which is the default and means the primary channel
AUX  = is used on the secondary physical channel
```

When is it used:
```
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
```

What does it do:
```
NONE
DIRECT = directly connectable
NONCONN = Non-connectable and non-scannable undirected
SCAN = Scannable undirected.
```

Version:
```
None = original version of the PDU
EXT = extended version of the PDU

How is it used:
IND = An indication that does not require a reply
REQ = A request that requires a response
RSP = A response to a request.
```
I found that initially when reading documentation and seeing something like
`ADV_IND` we can understand that this is an advertisment PDU and that it is used
as an indication that does not require a reply.

The packet format for all PDU have the same header and the payload varies
depending on the type specified:
```
 +-----------+------------------+
 | Header    | Payload          |
 +-----------+------------------+
     |
     ↓
 +-------+-----+-------+-------+-------+--------+
 | Type  | RFU | ChSel | TxAdd | RxAdd | Length |
 +-------+-----+-------+-------+-------+--------+

Type:
     0000 ADV_IND                   Primary Advertising Channel
     0001 ADV_DIRECT_IND            Primary Advertising Channel
     0010 ADV_NONCONN_IND           Primary Advertising Channel
     0011 SCAN_REQ                  Primary Advertising Channel
     0011 AUX_SCAN_REQ              Secondary Advertising Channel
     0100 SCAN_RSP                  Primary Advertising Channel
     0101 CONNECT_IND               Primary Advertising Channel
     0101 AUX_CONNECT_REQ           Secondary Advertising Channel
     0110 ADV_SCAN_IND              Primary Advertising Channel
     0111 ADV_EXT_IND               Primary Advertising Channel
     0111 ADV_ADV_IND               Secondary Advertising Channel
RFU = Reserved for Future Use

```

### Advertisement
As mentioned earler in this document BLE uses 40 different RF channels
and of these 40, 3 are called primary advertising channels. These are channels
37, 38, and 39 and are closen to be furthest away from the WiFi channels.
These channels are used for `advertisements`, `scan requests`, `scan responses`
, and `connection requests`.

Advertising channels for PDU types:
```
ADV_IND            Primary Channel
ADV_DIRECT_IND     Primary Channel       
ADV_NOCONN_IND	   Primary Channel
ADV_EXT_IND        Primary Channel
ADV_SCAN_IND       Primary Channel
SCAN_REQ           Primary Channel
SCAN_RSP           Primary Channel
CONNECT_IND        Primary Channel

AUX_SCAN_REQ       Secondary Channel
AUX_SCAN_RSP       Secondary Channel
AUX_ADV_IND        Secondary Channel
AUX_CONNECT_REQ    Secondary Channel
AUX_CONNECT_RSP    Secondary Channel
```

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

A connection is initiated by a central by sending a `CONNECT_IND` indication
to a peripheral:
```
Frame 345: 67 bytes on wire (536 bits), 67 bytes captured (536 bits)
PPI version 0, 24 bytes
Bluetooth
    [Source: 6d:a0:03:9e:dd:21 (6d:a0:03:9e:dd:21)]
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
    Initiator Address: 6d:a0:03:9e:dd:21 (6d:a0:03:9e:dd:21)
    Advertising Address: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)
    Link Layer Data
        Access Address: 0x50657b29
        CRC Init: 0x34ac04
        Window Size: 3 (3.75 msec)
        Window Offset: 8 (10 msec)
        Interval: 24 (30 msec)
        Latency: 0
        Timeout: 104 (1040 msec)
        Channel Map: ff07c0ff1f
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
            .... 0... = RF Channel 13 (2428 MHz - Data - 11): False
            ...0 .... = RF Channel 14 (2430 MHz - Data - 12): False
            ..0. .... = RF Channel 15 (2432 MHz - Data - 13): False
            .0.. .... = RF Channel 16 (2434 MHz - Data - 14): False
            0... .... = RF Channel 17 (2436 MHz - Data - 15): False
            .... ...0 = RF Channel 18 (2438 MHz - Data - 16): False
            .... ..0. = RF Channel 19 (2440 MHz - Data - 17): False
            .... .0.. = RF Channel 20 (2442 MHz - Data - 18): False
            .... 0... = RF Channel 21 (2444 MHz - Data - 19): False
            ...0 .... = RF Channel 22 (2446 MHz - Data - 20): False
            ..0. .... = RF Channel 23 (2448 MHz - Data - 21): False
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
        ...0 0111 = Hop: 7
        001. .... = Sleep Clock Accuracy: 151 ppm to 250 ppm (1)
    CRC: 0xf7d17a
        [Expert Info (Warning/Checksum): Incorrect CRC]
            [Incorrect CRC]
            [Severity level: Warning]
            [Group: Checksum]
```
The payload of CONNECT_IND and AUX_CONNECT_REQ look like this:
```
 +-----------------------------------------+---------------------+
 | Initiator Address | Advertising Address |  Link Layer Data    |
 +-----------------------------------------+---------------------+
```
Notice that `TxAdd` is `1` which means that the initiators device address in
`Initiator Address` is a random value and not the devices real address. Likewise
`RxAdd` is also `1` which means that the advertising devices address is also
random (the `Advertising Address` field).
The initiator in this case is my phone which is running nrfConnect and the
advertising device is the nrf52-dk running the
`examples/ble_central_and_peripheral/experimental/ble_app_multirole_lesc`
example.

So following that we have  the Link Layer Data.
* Access Address
This is the Asynchronous Connection-Less (ACL) connections address which in
this case is `0x50657b29`.

* Channel Map
The channels that have a value of true take part in the channel hopping.

One thing to note is that a CONNECT_IND is done on one of the primary
advertising channels, that is 37, 38, or 39. After this a connection will be
performed on one of the secondary advertising channels, that is any of the
channels except the primary channels. So even if we are using ubertooth to
sniff/listen to one of the primary advertising channels, one ubertooth device
can only listen to one channel with the default being channel 37, we might not
see the CONNECT_IND as there is a 1/3 chanse of capturing it. We can try
multiple times and hope to get lucky or invest in three ubertooth devices and
listen to all 3 primary channels.


Next the Security Manager, notice that the protocol is now `SMP` (Security
Manager Protocol` in Wireshark. is the Pairing Request. I was actually looking
for something named PAIRING_REQ or similar after reading different articles but
it looks like the protocol will be SMP like mentioned with a packet looking
like this format:
```
 +-----------+------------------+------------+---------+
 | Code=0x01 | I/O Capabilities |  OOB Flag  | AuthReq |
 +-----------+------------------+------------+---------+
   8 bits       8 bites             8 bits     8 bits

OOB =Out Of Bounds flag

I/O Capabilities:
 0x00   DisplayOnly
 0x01   DisplayYesNo
 0x02   KeyboardOnly
 0x03   NoInputNoOutput
 0x04   KeyboardDisplay
 0x05   RFU (Reserved for Future Use)
 ...
 0xFF   RFU

OOB Flag:
 0x00   OOB Auth data not present
 0x01   OOB Auth data from remote device is present
 0x02   RFU (Reserved for Future Use)
 ...
 0xFF   RFU

AuthReq (bit field): 
 +--------------+--------+-----+----------+-----+-----+
 | Bonding Flag | MITM   | SC  | Keypress | CT2 | RFU |
 +--------------+--------+-----+----------+-----+-----+
    2 bits        1 bit   1 bit   1 bit    1 bit  2 bits

Bonding flag:
  00  No Bonding
  01  Bonding
  10  RFU
  11  RFU
 
MITM:

SC (Secure Connections):

CT2:
 1 Support for h7 function
```

Security Manager Pairing Request packet:
```
Frame 178: 39 bytes on wire (312 bits), 39 bytes captured (312 bits)
PPI version 0, 24 bytes
Bluetooth
Bluetooth Low Energy Link Layer
    Access Address: 0x5065722d
    [Master Address: 67:10:3d:cb:b3:5a (67:10:3d:cb:b3:5a)]
    [Slave Address: ef:47:d2:57:6a:f6 (ef:47:d2:57:6a:f6)]
    Data Header: 0x0606
        .... ..10 = LLID: Start of an L2CAP message or a complete L2CAP message with no fragmentation (0x2)
        .... .1.. = Next Expected Sequence Number: 1
        .... 0... = Sequence Number: 0
        ...0 .... = More Data: False
        000. .... = RFU: 0
        Length: 6
    [L2CAP Index: 0]
    CRC: 0x37d967
Bluetooth L2CAP Protocol
    Length: 2
    CID: Security Manager Protocol (0x0006)
Bluetooth Security Manager Protocol
    Opcode: Security Request (0x0b)
    AuthReq: 0x0d, Secure Connection Flag, MITM Flag, Bonding Flags: Bonding
        000. .... = Reserved: 0x0
        ...0 .... = Keypress Flag: False
        .... 1... = Secure Connection Flag: True
        .... .1.. = MITM Flag: True
        .... ..01 = Bonding Flags: Bonding (0x1)
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

This peripheral has a service that it is advertising named `Nordic LED and
Button Service`. In the attribute table we can find an attribute named
`Blinky LED State` which is `Read and Write`. If we press on the up arrow we
can send a new value. For example write a Bool value of true will turn on
LED3.

### Elements
I an addressable entity within a node. Every node has at the very least one
element which is called the primary element, and the rest are called secondary
elements. There are static and do not change for as long as the node is part
of the network. I think it can change if the device gets unprovisioned and
then reprovisioned.

### BLE Mesh
Is a network allowing BLE Many-to-many communication. So it is based on BLE and
uses something called managed flooding where messages/packets will get relayed
by nodes in the network. This is managed in that there are ways to control how
long the message can live, and remember/cache packets to avoid bouncing. 

Devices in the mesh have difference roles. A `Node` is just a normal BLE device
which broadcasts messages. The mesh also needs `Releay Nodes` which is what it
sounds like, a node that can receive a packet and then relay it in the network.
The relay node needs to scan for packets continously and therefor requires a
high amount of power so these nodes are mostly connected to a power source and
not powered by batteries. There is also a cache of messages that are stored so
that the same message is not relayed over and over again. 

`Low Power Node (LPN)` is a battery driven node that can switch off, and only
check for packets once in a while. To not risk missing messages these nodes
are associated with a `Friend Node` which will is a node that can store messages
for a LPN.

For a mobile phone to communicate with the BLE Mesh it needs to create a
point-to-point connection with a node called a `Proxy Node` (implements the
Proxy Node Role).

The Link Layer and Physical Layer are the same for BLE Mesh as they are for
BLE but the host layer is completely different.
```
  +--------------------------------------+
  |           Application                |
  +--------------------------------------+
  +--------------------------------------+
  |           Mesh Models                |
  +--------------------------------------+
  +--------------------------------------+
  | Access       |                       |
  |--------------|     Provisioning      |
  | Transport    |                       | 
  |--------------|                       |
  | Network      |                       |
  |--------------+-----------------------|
  |            Bearer                    |
  +--------------------------------------+
  +--------------------------------------+
  |           Link Layer                 |
  +--------------------------------------+
  +--------------------------------------+
  |           Physical Layer              |
  +--------------------------------------+
```


When a device/node wants to be included in the mesh it needs to first be
`provisioned`. This device wanting to join is called the provisionee and it will
contact a device that has the `Provisioning Role`.
The provisionee needs to obtain/receive the following items:
* Unicast Address
* Network key
* IV index
* IV update flag
* Key Refresh flag

#### Unicast Address
Is assigned during provisioning and uniquely identify a single element of and
node. We send a message to an element of a node. This was actually not clear to
be in the begining that it it actually elements and not nodes that we are
addressing.

#### Group Address
Is used to identify a group of one or more elements. There are groups that are
defined by the Bluetooth SIG for things like All-proxies, All-friends, and All-nodes.
But other groups can be defined during by configuring application.

#### Virtual Address
Is an address that is assigned to one or more elements, and it can span multiple
nodes.


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


## Security
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
in plain text.

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

###


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

### LE Legacy Pairing
This is used in 4.0 and 4.1 devices and uses a custom key exchange protocol.
Here the devices exchange a TK and use it to create an STK to encrypt the
connection.
```
 Central      PAIRING_REQ                  Peripheral
          <------------------------------
```


### BR/EDR Secure Connection Pairing

### LE Secure Connection Pairing


### Secure And Fast Encryption Routine (SAFER)
Is a family of block ciphers and was a candidate for AES. It has a block size
of 128 and it is used for autentication (MIC/MAC) and key generation, but not
encryption in BlueTooth classic.

### E0
Is a stream cipher used for encryption in BlueTooth classic.

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
be possible for someone to change the content of the message in transit.

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


### btmon
Instead of trying to sniff packets on the air between two devices we can instead
listen/sniff them on a lap top.

```console
$ sudo btmon -w btmon.log
Bluetooth monitor ver 5.62
= Note: Linux version 5.13.14-200.fc34.x86_64 (x86_64)                                                                                                0.153003
= Note: Bluetooth subsystem version 2.22                                                                                                              0.153005
= New Index: 84:FD:D1:5C:FE:7B (Primary,USB,hci0)                                                                                              [hci0] 0.153005
= Open Index: 84:FD:D1:5C:FE:7B                                                                                                                [hci0] 0.153005
= Index Info: 84:FD:D1:5C:FE:7B (Intel Corp.)                                                                                                  [hci0] 0.153006
@ MGMT Open: bluetoothd (privileged) version 1.20                                                                                            {0x0001} 0.153006
```

### Models
The concept of models are there to enable less data having to be specified into
the protocol data packets. By using specific models the devices know how to
handle messages.

### blueZ
This is the official Linux Bluetooth Protocol Stack. It is like mentioned above
also split into two blocks, one is the Host and the other the Controller.
blueZ implements the Host layer part which recall contains the GAP, GATT, EATT,
SMP, and L2CAP. The Host and the Controller communicate using the Host
Controller Interface which can be done using UART, USB, Secure Digital (SD), or
3-wire UART.

If the Linux computer is going to host 

A linux computer is going to host GAP/GATT applications then a daemon is
required named `bluetoothd`. And if the linux computer is going to host an
BLE mesh node then a daemon named `bluetooth-meshd` needs to be running.
So its one or the other, a single linux computer cannot host both at the same
time it seems. The daemon serializes and handles all the HCI communication.

Now, applications on linux do not communicate directly with these daemons but
instead usd `dbus` which is an IPC system on linux. So an application does not
have to include any blueZ header files but is decoupled from it by using the
IPC/messaging and the application instead used dbus apis.
```
 +--------------------------------------------+
 |  +------+               +------+           |
 |  | app1 |               | app2 |           |
 |  +------+               +------+           |
 |     | remote metod call     ↑ signal       |
 |     ↓                       |              |
 |  +---------------------------------+       |
 |  |              D-Bus (daemon)     |       |
 |  +---------------------------------+       |
 |                   ↑                        |
 |                   ↓                        |
 |  +---------------------------------+       |
 |  |              D-Bus (daemon)     |       |
 |  |    bluetoothd | bluetooth-meshd |       |
 |  +---------------------------------+       |
 |                                            |
 +--------------------------------------------+
                     ↑ HCI
                     ↓
 +--------------------------------------------+
 |        Bluetooth Controller                |
 +--------------------------------------------+
 
```

The blueZ api is contains in a number of text files which can be found here:
https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc

### D-Bus
TODO: extract this to a separate document if it gets too long.
The central concept/component in dbus is the message bus and there are two types
, the `system` and the `session` bus.
There is a single instance of the system bus but there is one session bus per
logged in session on linux.

An applications connects to the dbus will then be allocated a unique connection
name which starts with a `:`. Communication is done by sending dbus messages.

Dbus is object oriented in there are objects which implment interfaces. These
interfaces have dot-separated names like 'se.something.Test`. If one application
creates an Object it can export it do dbus making it available for other
applications to call by sending a special message to the bus. Each Object also
has a unique identifier that looks like a path and is how dbus routes messages
to the correct application. So the Object `se.something.Test` migth be in the
`/se/something' application.
An object can also send out a message without the message being a response to
a method call. These are called signals which are events that applications can
register interest in of receiving.
An object can also have properties which can be get/set.

We can monitor the system bus using:
```console
$ sudo dbus-monitor --system
```
And we can monitor the session bus using:
```console
$ sudo dbus-monitor --session
```
For a standalone (not related to bluetooth) example of DBus see
[learning-c/dbus](https://github.com/danbev/learning-c/tree/master/dbus).

### Node
Is a device that has joined a mesh network, which means the device has been
provisioned. If a device has not joined it is simply called an unprovisioned
node.

### Relay Node
A device that supports the relay feature so it can retransmit broadcasted
message. This increases the reach of the network and allows the message to
travel further than is possible by a single node (the sender).

### Proxy Node
Does translation between proxy protocol PDUs and mesh PDUs and enables non-mesh
BLE devices to communicate with the mesh network using GATT.

### Low Power Node (LPN) and Friend Nodes
Are devices that run on batteries and need to preserves as much power as
possible only using its radio at a minimum. Now my first thought was that this
might be to limit the time the device sends out data, but it turns out that it
is often related to receiving updates of a setting for example. If the device
can be have a setting changed it would need to listen/receive these messages. If
it has to listen at certain constantly to not risk missing a message with an
update. This is where a Friend Node, always-on device, comes into play which
caches messages that are destined for the LPN device. The LPN device can then
wakeup and poll for messages from the Friend without risking missing any
messages.

### Mesh Arch
In contast to BLE where devices connect directly to each other, in BLE-mesh
devices use advertisements and scanning states to relay messages to each other.

#### Layers:
From bottom to to layers.

##### Bluetooth Low Energy Layer
Same as BLE and needs a BLE stack. Mesh used advertisments and scanning states
and the connected state when Proxy Nodes are used.

##### Bearer Layer
Defines how different PDUs are handled. There is an Advertsing Bearer which
handles adv and scanning states.
There is also a GATT Bearer

##### Lower Transport Layer
This layer takes care of re-assembling packets from the bearer layer, and also
splitting of large packets coming from the Upper Transport layer into multiple
Lower Transport PDUs.

##### Upper Transport Layer
Is responsible for handling Encryption, Decryption, Authentication, and
Transport Control messages like heartbeats for example. The keys used here
are the network keys.
A subnet is a group of nodes that can communicate with each other if they share
a network key.

##### Access Layer
Handles application data format, encryption and decryption, and data
verification. The keys used in this layer are application keys.

##### Foundation Models Layer
Handles network configuration and management models.

##### Models Layer
TODO: look closer at what this actually is

#### Provisioning
This process is about adding a unprovisioned device to the mesh network. The
unprovisioned device gets added to the network by a node (an already provisioned
device) capable of adding it to the network. This node, the provisioner, is
usually a PC, a phone, or a tablet.

There are 5 steps involved in provision:
##### 1) Beaconing
The unprovisioned device sends out a message saying that it is available to be
provisioned. This is done a new type of advertisement PDU called `mesh beacon`

##### 2) Invitation
When a provisioner discovers the mesh beacon it will send an `invitation` to the
unprovisioned device which is also a new PDU called `provisioning invite` PDU.

When the unprovisioned device receives the `provisioning invite` it will in turn
send a `provision capabilities` PDU in response which include:
* The number of elements that it has
* The security algorightms it supports
* Input/Ouput capabilites
  - Can the device display output to the user
  - Can the device receive an input from the user (like button or something)
* Ability to use Out-of-Band (OOB) technology

##### 3) Public Key Exchange
When ECDH is used public keys are exchange between the provisioner and the
unprovisioned device.

##### 4) Authentication
This step is about authenticating the unprovisioned device. How this done
depends on the capabilities of the device.

In `output OOB` the unprovisioned device might be able to display a random
number to the user, or blink an LED, output a beep. The user then takes that
number and inputs it to the provisioner device or confirms that it seen the
the number of blinks, heard the number of beeps etc.

In `input OOB` is when the provisioner generates a random number which is then
entered/inputted into the unprovisioned device. 

In `static OOB` k
5.4.2.4 in Mesh Profile v1.0


Next, the unprovisioned device will sends its public key to the provisioner and
it will also send it's public key.

The next step is authentication... 
__wip__

### Messages
All communication in BLE mesh is done by sending messages which operate on
states.

A message is defined as having; opcode, associated parameters, and behaviour.

A message has an opcode which can be a single octet, a single byte, or it can
be two bytes (used for standard messages), or three bytes for vendor specific
messages. So those are just the number of bytes uses for the opcode, the fewer
bytes used for the opcode means that there is more room for other things.

It is the Transport Layer that determines the total message size, which the
opcode is part of. If the max message size if overriden then the transport layer
will use Segmentation and Reassembly (SAR) to split the message into multiple
packets before sending and receiving side will have to reassemble the packets
which is a performance cost and something that is good to avoid with low powered
devices.

11 bytes are provided by the transport layer for non-segmented messages, so if
we have a 1 byte opcode that leaves 10 bytes for the additional message, and
for a 2 byte opcode it leaves 9 bytes, and for a 3 byte opcode it leaves 8
bytes.

### Addresses
There are `unicast addresses`, `virtual addresses`, `group addresses`, and a
special values that represents an unassigned address (not used in messages
though).

A `unicast` address is allocated to an element by the provisioner. These can
appear in the source or destination address fields of a message. Messages sent
to a unicast address are only processed by one element.
Example:
```
 00000000 00000001
```

A `group` address represents elements from one or more nodes. There are two
types, dynamically assigned which are 0xC000-0xFEFF, and fixed addresses which
are assigned by the SIG and divided into 5 segments
```
0xFFFF - All Nodes
0xFFFC - All Proxies Nodes
0xFFFD - All Friend Nodes
0xFFFE - All Relay Nodes
```
Example:
```
 11 000000 00000000
```
There are 16384 group addresses per mesh network. This seems like a large
number but remember that each device can have more than one element and this
the group addess might get used up. Virtual addresses are used to extend this
number (at least that is my current understanding).

A `virtual` address is a multicast address and can be used to address multiple
elements on one or more nodes.
Each virtual address represents a `Label UUID` .
```rust
pub struct VirtualAddress(u16);
```

Example:
```
     13              0
     [ hash value    ] 
 10  00 0000 0000 0000
  ↑
10 indicate this is a virtual address
```
The hash value is derived from a Label UUID which is 128-bits. So if I have two
devices that both use the same Label UUID they would get the virtual address.

An `unassinged` address can look like this:
```
 00000000 00000000
```

### Label UUID
Is a 128-bit value.
```rust
pub struct LabelUuid {
    uuid: [u8; 16],
    address: VirtualAddress,
} 
```

### Keys
There are three types of keys, device key (DevKey), application key (AppKey),
and network key (NetKey).

The DevKey allows for secure communication between a Configuration Client and a
single node. It is simlar to an application key as it also transfers data from
the upper transport layer securely but this key is only know by the device and
the Configuration Client and no other devices. The Configuration Client allows
for new application and network keys to be distributed which can be required to
avoid transcan attacks (where a discared device is used to retrieve the network
and/or application keys). So the devices that are still using those network keys
and application keys I guess can be updated using the Configuration Client in
that case and it does not matter if someone gets access to the old keys. Hmm,
would it be possible to still retrieve the keys to decrypt old messages?

An application key is used for secure communication of application data sent
between nodes. An appkey can only be used with a single network key. These are
per model and each model can have a number of appkeys bound to it.

The network key provides security of the lower layer for network messages. It
allows nodes to be able to relay the packets without having access to the
application data. Each appkey is associated with a single netkey which is called
a key binding.

So a single node will have a one devkey, one or more appkeys, and one or more
network keys I think.


### Configuration Client
Is responsible for generating and distributing network and application keys and
makes sure that devices that need to communicate with each other share the
correct keys for both the network (Upper Transport Layer?) and access layers.
It can also remove a node from the network, turning it back into an
unprovisioned device. It uses the device key to communicate with the nodes (one
for each node).

### BLE Mesh example
First we need to start the BLE Mesh Daemon, and before that we need to stop
bluetoothd daemon which was mentioned earlier in this document:
```console
$ make stop-bluetoothd
$ make start-bluetoothd-meshd
$ sudo /usr/libexec/bluetooth/bluetooth-meshd --config . --storage ./lib --debug
D-Bus ready
Loading node configuration from ./lib
mesh/mesh-mgmt.c:mesh_mgmt_list() send read index_list
mesh/mesh.c:mesh_init() io 0x5576ed9c8080
mesh/mesh-mgmt.c:read_index_list_cb() Number of controllers: 1
mesh/mesh-mgmt.c:read_info_cb() hci 0 status 0x00
mesh/mesh-mgmt.c:read_info_cb() settings: supp 0003feff curr 00000080
mesh/mesh-io-generic.c:hci_init() Started mesh on hci 0
mesh_ready_callback
Added Network Interface on /org/bluez/mesh
Hci dev 0000 removed
```
Notice that we passed a config parameter of `.` which will pick up the
configuration file `config_db.json`. This file describes the mesh network which
is called a Mesh Object.
We will be `mesh-cfgclient` which will communicate with this daemon.

Next, we can start a ble mesh example:
```console
$ cd ~/work/eclipse-hackaton/firmware
$ cargo r --release
```
(HOST) INFO  flashing program (35 pages / 140.00 KiB)
(HOST) INFO  success!
────────────────────────────────────────────────────────────────────────────────
0.119506 INFO  btmesh: starting up
└─ btmesh_driver::{impl#1}::run_driver::{async_fn#0} @ /home/danielbevenius/.cargo/git/checkouts/btmesh-e14acedbce757b27/cd4be51/btmesh-driver/src/fmt.rs:138
0.344207 INFO   =====================================================================
		=  ProvisionedConfiguration                                         =
		---------------------------------------------------------------------
└─ btmesh_driver::storage::provisioned::{impl#2}::display @ /home/danielbevenius/.cargo/git/checkouts/btmesh-e14acedbce757b27/cd4be51/btmesh-driver/src/fmt.rs:138
0.344238 INFO  seq: 3100
└─ btmesh_driver::storage::provisioned::{impl#2}::display @ /home/danielbevenius/.cargo/git/checkouts/btmesh-e14acedbce757b27/cd4be51/btmesh-driver/src/fmt.rs:138
0.344329 INFO  primary unicast address: 00ab
└─ btmesh_driver::stack::provisioned::network::{impl#0}::display @ /home/danielbevenius/.cargo/git/checkouts/btmesh-e14acedbce757b27/cd4be51/btmesh-driver/src/fmt.rs:138
0.344360 INFO  number of elements: 3
```

Next, start use `mesh-cfgclient`:
```console
$ mesh-cfgclient --config config/config_db.json
Mesh configuration loaded from config/config_db.json
Proxy added: org.bluez.mesh.Node1 (/org/bluez/mesh/nodeb67cef0dd1b2451fa54f8d34edba371b)
Proxy added: org.bluez.mesh.Management1 (/org/bluez/mesh/nodeb67cef0dd1b2451fa54f8d34edba371b)
Attached with path /org/bluez/mesh/nodeb67cef0dd1b2451fa54f8d34edba371b
```
From here we can list unprovisioned devices:
```console
[mesh-cfgclient]# list-unprovisioned 
Unprovisioned devices:
```
There are none so far as we need to scan for them first:
```console
[mesh-cfgclient]# discover-unprovisioned on
Unprovisioned scan started
```
After that we can then list the unprovisioned nodes:
```console
Scan result:
	rssi = -49
	UUID = 466349B95B3D4F50A39A04B15B0FA2F7
	OOB = A040
```
We can see that the `UUID` matches our device output and in this case is
`466349B95B3D4F50A39A04B15B0FA2F7`. We can use this UUID to provision this
unprovisioned device so that it becomes a node using:
```console
[mesh-cfgclient]# provision 466349B95B3D4F50A39A04B15B0FA2F7
Provisioning started
Assign addresses for 3 elements
Provisioning done:
Mesh node:
	UUID = FE8817CB1D0D4250B35DE88939277C3A
	primary = 00aa


	elements (3):
		element 0:
			SIG model: 0000 "Configuration Server"
			SIG model: 1001 "Generic OnOff Client"
			SIG model: 1003 "Generic Level Client"
			SIG model: 100d "Generic Battery Client"
			SIG model: 1102 "Sensor Client"
		element 1:
			SIG model: 1000 "Generic OnOff Server"
		element 2:
			SIG model: 1000 "Generic OnOff Server"

```
The provisioner has assigned a primary unicast address which is `00aa` in our
case.

Switch to the `config` menu:
```console
[mesh-cfgclient]# menu config
```
And then we set the target unicast UUID that will be used for commands:
```console
[mesh-cfgclient]# target 00aa
Configuring node 00aa
[config: Target = 00aa]#
```

#### firmware/src/main.rs walkthrough

If we look at the device code:
```rust
use btmesh_nrf_softdevice::{BluetoothMeshDriverConfig, Driver};


        // An instance of the Bluetooth Mesh stack                                           
        let mut driver = Driver::new(                                                        
            "drogue",                                                                        
            unsafe { &__storage as *const u8 as u32 },                                       
            Some(unsafe { &__storage_extra as *const u8 as u32 }),                           
            100,                                                                             
            BluetoothMeshDriverConfig {                                                      
                uuid: None,                                                                  
                persist_interval: Some(Duration::from_secs(10)),                             
            },                                                                               
        );
        ...
        let _ = driver.run(&mut device).await;
```
Now `Driver` in this case is of type `NrfSoftdeviceAdvertisingOnlyDriver`
because we are note specifying the `gatt` feature:
```rust
#[cfg(feature = "gatt")]
  pub use driver::NrfSoftdeviceAdvertisingAndGattDriver as Driver;

  #[cfg(not(feature = "gatt"))]
  pub use driver::NrfSoftdeviceAdvertisingOnlyDriver as Driver;
```
In this case the `gatt` feature is not enabled so `Driver` will be of type
`driver::NrfSoftdeviceAdvertisingOnlyDriver` which we can find in 
`btmesh-nrf-softdevice/src/driver.rs`.
```rust
pub struct NrfSoftdeviceAdvertisingOnlyDriver(
      NrfSoftdeviceDriver<AdvertisingOnlyNetworkInterfaces<SoftdeviceAdvertisingBearer>>,
);
```
And in the same source file we find:
```rust
pub struct NrfSoftdeviceDriver<N: NetworkInterfaces> {
    sd: &'static Softdevice,
    driver: BaseDriver<N, SoftdeviceRng, FlashBackingStore<Flash>>,
}
```
And BaseDriver is imported like this from btmesh_driver:
```rust
use btmesh_driver::{BluetoothMeshDriver, Driver as BaseDriver, BluetoothMeshDriverConfig, DriverError};
```

```rust
pub struct Driver<N: NetworkInterfaces, R: RngCore + CryptoRng, B: BackingStore> {
    network: Option<N>,
    rng: Option<R>,
    storage: Storage<B>,
    persist_interval: Option<Duration>,
```

Then `driver.run` will call the following function:
```rust
    fn run<'r, D: BluetoothMeshDevice>(&'r mut self, device: &'r mut D) -> Self::RunFuture<'_, D> {
        async move {                                                            
            InnerDriver::new(                                                   
                network: unwrap!(self.network.take()),                          
                rng: unwrap!(self.rng.take()),                                  
                &self.storage,                                                  
                self.persist_interval,                                          
            ) InnerDriver<N, R, B>                                              
            .run(device) impl Future<Output = Result<…>>                        
            .await                                                              
        }                                                                       
    } 
```


### Composition Data
Contains info about a node, like the elements it includes and the models it
supports. This contains a company id, vendor productd id, ventor product version
a field named CRPL (Count Replay Protection List?).

#### CRPL (Count Replay Protection List?)
Is a 16 bit-value which is the minium number of replay protection list entries
that a the device has. This can be found in section 4.2.1 Composition Data of
the Mesh Profile specification:
```
CRPL  Contains a 16-bit value representing the minimum number of replay
      protection list entries in a device
```
I've 
```rust
#[derive(Clone, Debug)]
#[cfg_attr(feature = "defmt", derive(defmt::Format))]
pub struct Composition<X: Default = ()> {
    pub(crate) cid: CompanyIdentifier,
    pub(crate) pid: ProductIdentifier,
    pub(crate) vid: VersionIdentifier,
    pub(crate) crpl: u16, // Count Reply Protection List
    pub(crate) features: Features,
    pub(crate) elements: Vec<ElementDescriptor<X>, 4>,
}
```


### BLE Mesh Replay protection
If someone intercepts a message from a device to the network they could respond
that message as it was encrypted with valid appkey/netkeys. This is called a
replay attack and to protect against such attacks each element will increment
the sequence number for each new message that is sends out. So each node that
receives a message needs to store the latest sequence number is has seens from
a node, and check it to avoid/drop messages that have already been seen.

### Mesh Configuration Database format
[mesh-configuration-database-profile-1-0](https://www.bluetooth.com/specifications/specs/mesh-configuration-database-profile-1-0)
