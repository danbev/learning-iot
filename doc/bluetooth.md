## Bluetooth notes


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


### AES/CCM (Counter with CBC-MAC)
Recall that Advanced Encryption Standard (AES) is a symmetric encryption method
so both sides use a shared secret key. This key can be generated in any way and
might have been the result of a Diffie-Hellman key exchange for example.

The CCM block generates an encrypted keystream that is applied to input data
using the XOR operation and generates the four byte MIC field in one operation.

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
Now, only someone with access to the key can decrypt the message. But is might
be possible for someone to have changed the content of the message being sent.
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
more which is where the message authentication code comes in.

### Wireshark BlueTooth packet capturing
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


