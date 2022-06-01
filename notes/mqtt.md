## MQ Telemetry Transport (MQTT)
This is a message based protocol for Machine to Machine (M2M) and originally
this was developed by at least one person from IBM and the MQ is from IBM's
MQ Series (Message Queue) product. Uses a p publish subscribe model which
decouples the publisher from the subscriber.

In 2014 MQTT 3.1.1 became an official OASIS Standard.
* [v3.1.1 specification][v3]
* [v5.0 specification][v5]

MQTT messages are small and can be as small as 2 bytes compared to HTTP requests
which are larger due to HTTP headers. Also with a a broker it is possible to
send the same message to multiple devices.

Runs on TCP but there is a UDP version named MQTT-SN.

Message payloads can be encrypted using TLS and auth like OAUTH.

MQTT uses two ports which by default are:
* 1883 for MQTT
* 8883 for secure MQTT

### Packet format
Control packet:
```
   +------------------------------------+
   | Fixed length header                |
   +------------------------------------+
   | Variable length header             |
   +------------------------------------+
   | Payload (optional)                 |
   +------------------------------------+
```
The fixed header is 2 bytes long, so 16 bits only:
```
    7  6  5  4  3  2  1  0
   +-----------------------+
   |  |  |  |  |  |  |  |  |
   +-----------------------+
   |-----------|-----------|
     Type        Flags specific to Type

Types:
0000   Reserved
0001   CONNECT
0010   CONNACK
0011   PUBLISH
0100   PUBACK
0101   PUBREC (Publish recieved)
0110   PUBREL (Publish release)
0111   PUBCOMP (Publish complete)
1000   SUBSCRIBE
1001   SUBACK
1010   UNSUBSCIBE
1011   UNSUBACK
1100   PINGREQ
1101   PINGRESP
1110   DISCONNECT
1111   Reserved

    15 14 13 12 11 10 9  8
   +-----------------------+
   |  |  |  |  |  |  |  |  |
   +-----------------------+
   |-----------------------|
     Length of Variable length header and payload
```

### Communication protcol
MQTT uses TCP/IP so the first thing that needs to happen is that an TCP/IP
connection must be established. After that the first packet sent from the client
to the server must be a CONNECT packet.

#### CONNECT
The variable header for these packets contains a Protocol Name, Protocol Level,
Connect flags and a Keep Alive.

The protocol name is `MQTT`, the protocol level is `0100`. The connection flags
are a little more interesting:
```
Flags:
     7           6           5            4          3             2            1
  +---------+----------+-------------+----------+-----------+---------------+----------+
  |Username | Password | Will Retain | Will QoS | Will Flag | Clean Session | Reserved |
  +---------+----------+-------------+----------+-----------+---------------+----------+
```


### Last Will and Testament (LWT)
This is used for when clients disconnect non-gracefully, that is the don't send
a DISCONNECT packet but might have just powered down or for some other reason
the connetion to the client is broken. 
A client can specify a last will message when it connects to the broker, and
this is one of the flags in the CONNECT packets connection flags.
If the client disconnects ungracefully the broker will send that last will
message, which is a normal MQTT message, to all the subscribers for that last
will topic.




### Quality of Service (QoS)
Each connection to the broker can specify an int value between 0-2:
```
0 = at most once (fire and forget, so no ack).
1 = at least once. The message is sent multiple times until an ack is recieved.
    I needs to be stored on the broker for subscribers that are offline.
2 = exactly once. Sender and receiver use a two level handshake to ensure
    only one copy of the message is received.


### Eclipse Mosquitto
A very lightweight MQTT broker useful for embedded deployments.
```console
$ sudo dnf install mosquitto
```

Start mosquitto:
```console
$ mosquitto
1649850732: mosquitto version 2.0.14 starting
1649850732: Using default config.
1649850732: Starting in local only mode. Connections will only be possible from clients running on this machine.
1649850732: Create a configuration file which defines a listener to allow remote access.
1649850732: For more details see https://mosquitto.org/documentation/authentication-methods/
1649850732: Opening ipv4 listen socket on port 1883.
1649850732: Opening ipv6 listen socket on port 1883.
1649850732: mosquitto version 2.0.14 running
```

Subscribe to a topic:
```console
$ mosquitto_sub -t test_topic
```
Publish to the topic:
```console
$ mosquitto_pub -t test_topic -m "bajja"
```
This will show the message in the `mosquitto_sub' console.

### Eclipse Amien
Is a clusterable MQTT broker more suited for Enterprise deployment.

[v3]: http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718008
[v5]: https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html
