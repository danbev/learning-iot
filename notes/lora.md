## LoRa
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

LoRa is the `physical layer` that enables a long-range communication link and
this is propriatary (was patented in June 2014).
LoRaWAN is a media access control (MAC) layer built on top of LoRa and released
in January 2015.

```
+---------------------------------------+
|           Application                 |
+---------------------------------------+  --+
|           LoRaWAN MAC                 |    |
+---------------------------------------+    | LoRaWAn (Media Access Control Layer)
|           MAC options                 |    |
+---------------------------------------+   -+
| Class A | Class B | Class C           |    |
+---------------------------------------+    |
|           LoRa Modulation             |    |  LoRa (Physical Layer)
+---------------------------------------+    |
|           Regional ISM Band           |    |
+----------------------------------------    | 
|EU686 | EU433 | US 915 | AS430 | ...|  |    |
+----------------------------------------   -+  
```

So we have a lot of different protocols to use in IoT like BLE, ZigBee, LoRa,
SigFox, UNB etc and I'm having trouble understanding where and when one would
use one over the other. It all comes down to the devices and how constrained
they are (like in power consumption).
```
Bandwidth
 ^
 |                   5G   
 |   
 |   
 |  WiFi             3G/4G/LTE 
 |   
 |   
 |   
 |  BLE        ZigBee 
 |   
 |  RFID/NFC   LoRa/SigFox/UNB
 +------------------------------------------------> Range

NFC  = Near Field Communication
RFID = Radio Frequency Identification
```

### Modulation
Uses `compressed high intensity radar pulse (CHIRP)` spread spectrum (CSS)
modulation.

A chirp is a signal of continously changing frequence, either increasing or
decreasing frequencied. This is also called a sweep signal which is a signal
that increases, called upchirp, or decreases, called downchrip, linearly with
time.

```
Upchirp

  Lower Frequency      Higher Frequency

         \__
            \__
               \__
                  \__
                     \__
                        \__
                           \__
```
So this signal starts at a lower frequency and increases to a higher frequency.
If we imaging a sine wave this would start off with longer wavelenghts to become
shorter and shorter.

```
Downchirp

  Lower Frequency      Higher Frequency

                          __/
                       __/
                    __/
                 __/
              __/
           __/
          /
```
In this case the starts at a higher frequency and decreases to a lower frequency.
If we imaging a sine wave this would start off with shorter wavelenghts to
become longer and longer.


Let look at frequency shift keying (FSK) which is something that is somewhat
more familar to me:
```
Waterfall "diagram"

  Lower Frequency                    Higher Frequency

         |
         | Logical 0
         |
                                           |
                                           |      Logical 1
                                           |
         |
         | Logical 0
         |
                                           |
                                           |      Logical 1
                                           |
```
In FSK the frequency will shift or jump depending on the symbol being
represented, in the above case the lower frequency could represent a logical 0
and the higher a logical 1.

In CSS I think this would look like:
```
Waterfall "diagram"

  Lower Frequency         Higher Frequency

         \__
            \__
               \__                     Logical 0
                  \__
                     \__
                        \__
                           \_
                          __/
                       __/
                    __/                Logical 1
                 __/
              __/
           __/
           \__
              \__                     Logical 0
                 \__
                    \__
                       \__
                          \_
                         __/
                      __/
                   __/                Logical 1
                __/
             __/
          __/

```


So if we compare this to frequency modulation where the carrier signal will be
modulates in its frequency depending on the symbol that is being represented. In
this case chirp signals are the carrier.

Lets try to sort out some definitions here:
#### Bandwidth
Bandwidth is the range of fequencies occupied by a RF signal.

#### Chip
Lets say we have a bandwidth of 125kHz which means that we have 125000
oscilations per second. In LoRa one such oscilation is called a chip and the
chip rate (CR) in this case is the same also 125kHz chips/second. This is the
width of spectrum occupied by the chrip. Recall that a chirp will use/span the
entire spectrum.

#### Chirp
Is a signal in which frequency increases or decreases as shown above.
A basic chirp uses the entire bandwidth, the range of frequenies.

```
    0           125kHz
                /
              /
            /
          /
        /
      /
    /
```
This above chirp starts from the lowest frequency and increases to the highest.
Chirps wrap (think modulus) when reaching the lower/highest frequencies, for
example:
```
    0           125kHz
             /
           /
         /
       /
     /        
                /
              / 
```
Notice that the chirp did not start at the lowest frequency this time but
instead a little higher frequency and then wrapped when it reached the max to
got down to the lowest frequency and then increase again to the starting
frequency, still using the entier frequency range.

One chirp is equal one signal. 

#### Spreading factor
The spreading factor relates chips and symbols and is the number of chips used
to represent a symbol. This involved dividing the up the bandwidth into groups
of chips (oscillations) and this specifies one symbol:
```
 2ˢᶠ chips = 1 symbol

 2⁷ = 128 chips = 1 symbol
```
So we can have 0-127 different symbols with a spreading factor or 7:
```
0000000 = symbol 0
0000001 = symbol 1
...

1111111 = symbol 127
```

For example, `0000010` might look like:
```
    0           125kHz
              /
            /
          /
        /
      /        
    /
              / 
```
So lets think about what that means, this will be a signal that starts at a
certain frequency, increased up to the max, and then restarts from the lowest
frequency. And different symbols will start at differrent frequencies.

#### Coding Rate



The fast fourier transformation (FFT) can decompose a signal into its component
frequencies. So think about a signal as a wave. What the FFT does for use is
to split this into individual waves each with different frequencies (matching
the original wave that is). If we split a signal in to the number of possible
symbols (2ˢᶠ)...

The symbol rate is the bandwitdh divided by 2ˢᶠ:
```
              bandwidth 
Symbol rate = ---------
                2ˢᶠ

              1250000 
Symbol rate = --------- = 9765.625 symbols/sec
                128
```
A chirp is a number of chips (oscillations) that together represent a symbol.

A symbol is a chirp

#### Encoding
* Gray indexing which adds error tolerance.
* Data whitening which introduces randomness.
* Interleaving which scrables the bits within the frame.
* Forward Error Correction which adds correcting parity bits.

## LoRaWAN                                                                         
Is a Low Power Wide Area Network (LPWAN), low power, long range, has geolocation
so the network can determine the location of devices. Can have both public and
private deployments. Supports fireware updates over the air (of the LoraWAN
stack I'm guessing). Supports end-to-end security.

* [v1.1 Specification][loraspec]

```
Nodes          Gateways           Network Server     Application servers
*------------->+-------+           +-----+             +-----+
  * *--+------>|       | --------> |     | ----------> |     |
       |       +-------+           |     |             +-----+
*------+------>+-------+           |     | ----------> +-----+
               |       | --------> |     |             |     |
               +-------+           +-----+             +-----+
      (LoRa)            (TCP/IP, TLS)       (TCP/IP, TLS)
      wireless          3G/4G/5G/Ehternet
                          
```
The nodes, which are end devices like sensors sends out messages (uplink) to
all gateways that are listening, are in range. This communication uses wireless
technology (LoRa). The gateways operate at the physcial layer and only checks
the integrity of the incoming message (check the Message Integrity Code (MIC)).

### LoRaWAN Network Servers (LNS)
These servers control the network, which is not static but conditions change,
which they adapt to.

### Activation of devices
A device can be activate in two ways:
* ABP = Activation By Personalization
Device ID's and keys are personalized at manufactoring time. These devices can
simply be powered on and are good to go, there is no need to join activation
messages. 
These devices are tied to a specific network/service, the NetID is a portion
of the device network address.

* OTAA = Over-The-Air Activation
Device ID's and keys can be updated and also renewed which inhances security.

Each end device has root keys that are security stored on the device. The join
server has matching keys.
The ende device sends a JoinRequest to the Gateway:
```
  Device     JoinRequest       Gateway        JoinServer
         ------------------->          ------>
   
      8       8        2
   JoinEUI  DevEUI  DevNounce
```
The JoinServer will authenticate the device and send a JoinAccept message back
to the device.
JoinEUI was previously named AppEUI

### JoinServer
These managed

Protocol stack:
```
+---------------------------------------------------------------+
| Class A  Baseline | Class B baseline     | Class C baseline   | 
+---------------------------------------------------------------+
|           LoRa Modulation
+---------------------------------------------------------------+
|         Reginal ISM band                                      |
+---------------------------------------------------------------+
| EU 868  | EU 433 | US 915 | AS 430 |                          |
+---------------------------------------------------------------+
```

#### Class A (All) 
Each device uplink to the gateway is followed by 2 short downlink recieve
windows. Is used for battry powered devices. This is called `All` because all
class types can act as a class A device.
So after a class A device has broadcasted a message (uplink transmission) the
end node will listen for a response from the gateway. There end node will have
two receive slots T₁ and T₂ seconds where it will listen for reponses from the
gateway. The gateway can only use one of these slots and not both.
```
   +---------+ +-----+ +-----+
   | node tx | | Rx₁ | | Rx₂ |
   +---------+ +-----+ +-----+
```

#### Class B (Beacon)
Like class A but also have a scheduled window for recieving data.
```
              { Same as Class A       }   { Ping Period }
 +--------+   +---------+ +-----+ +-----+   +----+  +----+       +--------+
 | beacon |   | node tx | | RX₁ | | Rx₂ |   | rx |  | rx |       | beacon |
 +--------+   +---------+ +-----+ +-----+   +----+  +----+       +--------+
     ↑                                                              ↑
  From Gateway                                                  From Gateway
```
In this case the end node will receive a time synchronized beacon from the
gateway which enables the gateway to know when the node is listening. The end
device uses this time reference to schedule when ping slots are to be opened.

A gateway will broadcast the beacon every 128 seconds. The device must keep
listening for a beacon for at least one beacon period. 

#### Class C (Continous)
Is also like class A but will continously listen for data so it uses more power
and more suited to devices with a non-battery power source.


## The Things Network (TTN)
Coverage in [Stockholm](https://www.thethingsnetwork.org/community/stockholm)
and it looks like my area is covered so I should be able to use a connection
point/router. Another option if that is not possible is to install a LoRa
gateway which the device can communicate with and then be connected to the the
internet. The gateway will open a local LoRa network cell, and connect via
TCP/IP to the TTN LoRa network backend.

Register an account: https://account.thethingsnetwork.org/.

My username is `danbev`, and the cluster location I'm using is `eu1`.

### Message types
These are used to transport Media Access Control (MAC) layer commands as well
as application data.


#### Uplink message
An `uplink` message is a message that is sent from a device to the network
server via one or more gateways.

Uplink Physical packet:
```
  +----------+-------+----------+------------+-----+
  | Preamble | PHDR  | PHDR_CRC | PHYPayload | CRC |
  +----------+-------+----------+------------+-----+
```

PHDR = Physical Header
```
The PHDR, PHDR_CRC, and the CRC are inserted by the radio transiever.

#### Downlink message
A `downlink` message is sent by the network server to one and only one end
device.

Downlink Physical packet:
```
  +----------+-------+----------+------------+
  | Preamble | PHDR  | PHDR_CRC | PHYPayload |
  +----------+-------+----------+------------+
```
Notice that downlink messages do no contain a CRC which is to keep the messages
as short as possible.

#### PHYPayload
All uplink and downlink message have a physical payload as can be seen above.
This packet contains the following elements:
```
PHYPayLoad:

  +-------+-----------------------------------------+-----+
  | MHDR  | MACPayload/Join-Request/Re-join-Request | MIC |
  +-------+-----------------------------------------+-----+

MHDR = Media Access Control Layer Header (MAC Header).
MIC  = Message Integrity Code (same as Message Authentication Code but that
       clashes with the definition of MAC in LoRa).

A PHYPayLoad can also contains a Join-Accept entry which then does not have a
MIC as the MIC field is encrypted with the payload:
  +-------+-------------+
  | MHDR  | Join-Accept |
  +-------+-------------+
```

#### MHDR
Media Access Control Layer Header.
```
  7       5
  +-------+-----+-------+
  | MType | RFU | Major |
  +-------+-----+-------+

MType is a 3 bit field:
  000 = Join-Request
  001 = Join-Accept
  010 = Unconfirmated Data Up (non-acked uplink message)
  011 = Unconfirmated Data Down (non-acked downlink message)
  100 = Confirmated Data Up (acked uplink message)
  101 = Confirmated Data Down (acked downlink message)
  110 = Rejoin-Request
  111 = Proprietary

RFU = Reserved for Future Usage
Major = the LoRaWAN specification that this message is encoded with.
```

#### MACPayload
```
   7..22    0..1   0..N           (bytes)
  +------+-------+------------+
  | FHDR | FPort | FRMPayload |
  +------+-------+------------+

FPort = If this field is 0 this indicates that the FRMPayload contains MAC
        commands that should be handled by the LoRaWAN implementation.
        Values 1..223 are application specific and are available to the app
        layer. 224 reserved for the MAC Layer test protocol.
        
```
If `FPort` is 0 it means that this packet contains MAC commands in the
FRMPayload field. A value greater then 0 indicated that FRMPayload contains
application data.
The MAC payload is then put into a physical layer packet.

### MAC Commands
These are messages exchanged between the network server and the MAC Layer on the
device so these are not messages that an application will ever see. The `FPort`
in the MACPayload specifies if the FRMPayload contains this type a message which
are also called command, I guess command messages.

#### FHDR
Frame Header I guess?

```
   +---------------------------------+
   | DevAddr | FCtrl | FCnt  | FOpts |
   +---------------------------------+

DevAddres = Short device address 4 bytes
FCtrl     = Frame control  1 byte
  FCtrl Downlink messages:
      7     6      5      4          3-0
    +-----+-----+-----+----------+----------+
    | ADR | RFU | ACK | FPending | FOptsLen |
    +-----+-----+-----+----------+----------+

    ADR = Adaptive Data Rate, when enabled (1) the network will be optimized for
          the fastest possible data rate. Since this is an uplink field it will
          allow the network to send commands that control the data rate and tx
          power. 
    RFU = Reserved for Future Usage
    ACK = This will be set for confirmed data messages.
    FPending = Frame pending. Is this is set in a received message it means that
               the network has more data pending and that can be sent and wants
               the device to open another receive window asap. It does this by
               sending another uplink message.

  Fctrl Uplink messages:
      7        6         5      4          3-0    
    +-----+-----------+-----+----------+----------+
    | ADR | ADRACKReq | ACK | ClassB   | FOptsLen |
    +-----+-----------+-----+----------+----------+

    ADR = Adaptive Data Rate
    ADRACKReq = TODO: 
    ACK = This will be set for confirmed data messages.
    ClassB = If set to 1 signals to the Network server that this device has
             switched to class b mode.

FCnt      = Frame conter 0..15 bytes
```

### MAC commands
These are listed in section 5 of the spec and like we mentioned above the
messages are exchanged between the network server and the MAC layer on the
devices but the application layer will never see or be able to access these
messages.

All MAC commands have a command identifier (CID) of size 1 byte.

### Framing
The packets send can either have an explicit header and variable payload or
have an implicit header (which is known to the receiver) and a fixed lentgh
payload. In this case the payload length, forward error correction coding rate
and presence of the payload CRC must be configured on both sides.



### Drogue LoRaWAN workshop
This following is just my notes while following the
[ttn-lorawan-quarkus workshop](https://book.drogue.io/drogue-workshops/ttn-lorawan-quarkus/drogue-cloud.html).
First we create a new application in Drogue Cloud
```console
$ drg create app danbev-ttn-app
```

Next, add the `.spec.ttn` section to the above app that we created:
```console
$ drg create app danbev-ttn-app --spec '{
    "ttn": {
        "api": {
            "apiKey": "xxx", 
            "id": "danbev-ttn-app", 
            "owner": "danbev", 
            "region": "eu1" 
        }
    }
}'
```

Next we create a device and enable The Things Network synchronization.
```console
$ drg create device danbev-ttn-device --app danbev-ttn-app --spec '{
    "ttn": {
        "app_eui": "0000000000000000",
        "dev_eui": "xxx", 
        "app_key": "xxx", 
        "frequency_plan_id": "EU863-870", 
        "lorawan_phy_version": "PHY_V1_0",
        "lorawan_version": "MAC_V1_0"
    }
}'
```
Generate the 16 byte device identifier (dev_eui):
```console
$ openssl rand -hex 16 | tr [a-z] [A-Z]
xxxxxxx
```

Generate the 32 byte app_key (app_key):
```console
$ openssl rand -hex 32 | tr [a-z] [A-Z]
xxxxxxxxxxxxxxxxx
```
For the `frequency_plan_id` one can look at the
[frequenies-by-country](https://www.thethingsnetwork.org/docs/lorawan/frequencies-by-country/) to find the correct one. For Sweden it is the following:
```
Sweden	EU863-870        Svenska frekvensplanen, CEPT Rec. 70-03
        EU433	
```

To be able to run the [lora-discovery](https://github.com/drogue-iot/drogue-device/blob/main/examples/stm32l0/lora-discovery/README.adoc)
example we need to add some configuration properties into `~/.drogue/config.toml:
```toml
dev-eui = "danbev-ttn-app"                                                                    
app-eui = ""                                                                    
app-key = ""
```
The `dev-eui` can be found in the console part of the The Things Network.
https://eu1.cloud.thethings.network/console/applications/danbev-ttn-app

The `app-key` is the application encryption key. This is used to encrypt the
application data being sent from the end device to the application server/
service, and the application data sent from the application server/service. 

The `app-eui` is a 

### Organizationally Unique Identifier (OUI)
Is a 24 bit number that uniquely identifies a vendor, manufacturer, or an
organisation and are assigned by IEEE Standards Association Registration
Authority.
Example:
```
  F4-BD-9E
```

### OUI-36
This type of identifier is created by taking a 24-bit OUI and adding 12 bits
to it, so we have 4,5 octets:
```
  70-B3-D5-7E-D
``

### Extended Unique Identifier (EUI)
Is used to identify devices and software and it includes the manufacturers
OUI and an extension identifier (which is set freely by the manufacturer).
```

     36-bits       28-bits
  70-B3-D5-7E-D - 00-40-62-0
     OUI           Extension
``

### DevEUI
Is a EUI-64 address that unquely identifies an end device.

### AppEUI
This is also a EUI-64 address which uniquely identifies the entity that is able
to process a JoinReq packet/frame. This identifies an application server and is
similar to a port number.

### AppKey
Is an AES 128 bit symmetric key used to generate the Media Integrity Code (MIC)
which is the same as a Message Authenitcation Code but this collides with the
term media access control (as in layer). This is used to ensure the integrity
of messages. The same key is use by the device and the network server.

And end device will have a DevEUI, either on the device itself or generated for
it.
```
   +-----------+                 +----------------+
   | End Device|                 | Network Server |
   +-----------+                 +----------------+
   | DevEUI    |  JoinRequest    | AppKey         |
   +-----------+ --------------> +----------------+
   | AppEUI    |
   +-----------+
   | AppKey    |
   +-----------+
```

### IQ Inversion
I/Q is an abbreviation for `in-phase` and `quadrature` and revers to two
sinusoids that have the same frequency and are 90 degrees out of phase.

### Frequency Shift Chirp Modulation (FSCM)
Is the modulation that LoRa uses.

[loraspec]: https://lora-alliance.org/wp-content/uploads/2020/11/lorawantm_specification_-v1.1.pdf

ABP = Activation By Personalization
OTAA = Over-The-Air Activation

### SubGHz Radio in STM32WL
Is a ultra low-power radio that operates in the 150-960MHz ISM band.
Uses SPI to communicate with the CPU, and also has a set of interrupts
available.

Even if the device is in sleep mode, or standby, or one of the stop modes the
RF will still be able to receive. So RF is available in all modes.

[datasheat](https://www.st.com/resource/en/reference_manual/rm0453-stm32wl5x-advanced-armbased-32bit-mcus-with-subghz-radio-solution-stmicroelectronics.pdf)

There are 4 modulations available
* LoRa used by LoRaWAN
* (G)FSK (Frequency Shift Keying) used by sigfox, MBus
* (G)MSK (Minimum Shift Keying) (only supports transmission)
* BPSK (Binary Phase Shift Keying) used by sigfox (only supports transmission)

Signals from sub-GHz component:
```
RFO_LP  = RR Output Low-Power
RFO_HP  = RF Output High-Power
RFI_P   = RF Input differential P (what is this?)
RFI_N   = RF Input differential N (what is this?)
OSC_IN  = HSE32 Oscillator Input
OSC_OUT = HSE32 Oscillator Output
VDDPA   = Input supply for PA (Power Amplifier) regulator
VRPA    = Regulated PA (Power Amplifier) supply output
PB0_VDDTCXO = Regulated Temparatur Compensated Crystal Oscillator supply ouput
hse32   = HSE32 clock signal to CPU
HSEON   = HS Enable HSE32 clock for CPU usage
HSEBYPPWR = Enable VDDTCXO regulator control
HSERDY  = HSE ready indication
SUBGHZSPI = Sub-GHz radio SPI interface
BUSY    = Busy signal
Intrrupts = IRQ Interrupts
```

TCXO = Temperature Compensated Crystal Oscillator regulator.

### Binary Phase Shift Keying (BPSK)
Phase shift keying is where the phase of a digial signal is switched (simliar
to analog phase modulation) to represent different symbols. So the carrier
signal will be switch phase when it modulates the carrier signal to represent a
0 or a 1. Like it might shift the phase 180 degrees when to represent 1 for
example. When there are only two symbols this is called binary phase shift
keying.


### Analysing LoRa
```console
$ gqrx
```
Now we need to configure the frequency used. I'm in 

### peer-to-peer
There is a lora_mode option in lorawan-device which in the example in
Drogue IoT is using LoraMode::WAN:
```rust
let config = LoraConfig::new()                                              
        .region(LoraRegion::EU868)                                              
        .lora_mode(LoraMode::WAN)                                               
        .spreading_factor(SpreadingFactor::SF12);
```
But there is also another member of that enum which is named `LoraMode::P2P`
which stands for peer-to-peer. In this case LoraWAN is not using but just LoRa
using raw MAC communication to send commands and messages directly like in a
P2P network.

### The Things Network Gateway
I got an indoor The Things Network Gateway as I was not able to connect to a
public gateway in my area. 

When configuring the gateway I ran into an issue where after connecting to the
device using http://192.168.4.1/ and adding my wifi network the green led on the
gateway would just blink about every second and nothing else would happen.
What I ended up doing is tethering via my phone and then it was able to connect
and a steady green light came on after a while. But I don't want to have this
kind of set up.
