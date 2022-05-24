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

## LoRaWAN                                                                         
Is a Low power Wide Area Network (LPWAN)  

```
Nodes:         Gateways           Network Server  Application servers
*------------->+-------+           +-----+         +-----+
  * *--+------>|       | --------> |     | ------> |     |
       |       +-------+           |     |         +-----+
*------+------>+-------+           |     | ------> +-----+
               |       | --------> |     |         |     |
               +-------+           +-----+         +-----+
      (LoRa)             (TCP/IP, TLS)    (TCP/IP, TLS)
                          
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
