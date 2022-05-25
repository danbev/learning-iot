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

LoRa is the `physical layer` that enables a long-range communication link.
LoRaWAN is the communication protocol and system architecture for the network.
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
Uses chirp spread spectrum modulation

The modulation and demodulation is relatively simple and a device can do both.

## LoRaWAN                                                                         
Is a Low power Wide Area Network (LPWAN), low power, long range, has geolocation
so the network can determine the location of devices. Can have both public and
private deployments. Supports fireware updates over the air (of the LoraWAN
stack I'm guessing). Supports end-to-end security.

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
