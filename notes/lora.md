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
The spreading factor relates chips and symbols and is the number of bits encoded
per symbol. This involved dividing the up the bandwidth in into groups of
chips (oscillations) and this specifies one symbol:
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


The modulation and demodulation is relatively simple and a device can do both.

## LoRaWAN                                                                         
Is a Low power Wide Area Network (LPWAN), low power, long range, has geolocation
so the network can determine the location of devices. Can have both public and
private deployments. Supports fireware updates over the air (of the LoraWAN
stack I'm guessing). Supports end-to-end security.

* [v1.1 Specification][loraspec]

```
Nodes:         Gateways           Network Server     Application servers
*------------->+-------+           +-----+             +-----+
  * *--+------>|       | --------> |     | ----------> |     |
       |       +-------+           |     |             +-----+
*------+------>+-------+           |     | ----------> +-----+
               |       | --------> |     |             |     |
               +-------+           +-----+             +-----+
      (LoRa)            (TCP/IP, TLS)       (TCP/IP, TLS)
      wireless          3G/4G/5G/Ehternet
                          
```

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

An `uplink` message is a message that is sent from a device to the network
server via one or more gateways.

A `downlink` message is sent by the network server to one and only one end
device.

* Join-Request
* Join-Accept
* Rejoin-Request
* Proprietary
* Unconfirmated Data Up (non-acked uplink message)
* Unconfirmated Data Down (non-acked downlink message)
* Confirmated Data Up (acked uplink message)
* Confirmated Data Down (acked downlink message)


MAC payload:
```
   |--------   FHDR   ---------------| 
   22                               7
   +--------------------------------------------------------+
   | DevAddr | FCtrl | FCnt  | FOpts | FPort | FRMPayload
   +--------------------------------------------------------+

FPort and FRMPayload are optional
```
If `FPort` is 0 it means that this packet contains MAC commands in the
FRMPayload field. A value greater then 0 indicated that FRMPayload contains
application data.

The MAC payload is then put into a physical layer packet.

This following is just my notes while following the
[ttn-lorawan-quarkus workshop](https://book.drogue.io/drogue-workshops/ttn-lorawan-quarkus/drogue-cloud.html).
First we create a new application in Drogue Cloud
```console
$ drg create app danbev-ttn-app
```
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
Generate the 16 byte device identifier:
```console
$ openssl rand -hex 16 | tr [a-z] [A-Z]
xxxxxxx
```

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


### Frequency Shift Chirp Modulation (FSCM)
Is the modulation that LoRa uses.

[loraspec]: https://lora-alliance.org/wp-content/uploads/2020/11/lorawantm_specification_-v1.1.pdf

