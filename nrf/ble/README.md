## Bluetooth Low Energy (BLE) Examples
This directory contains examples of using BLE.


### BLE Peripheral
This example is a copy of the ble_peripheral_blinky example from the nrs SDK
and modified to build from this directory. The requirement is that the
environment variable `SDK_ROOT ` be set to point to the SDK.

This example also uses an external LED which can be turned on and off using
nrf-connect.

```
#### Building
First the BLE protocol stack (SoftDevice s132) needs to be flashed to the device:
```console
$ make flash_device
```

Then we need to flash the periperal:
```console
$ make flash_ble_p
```

We can use `JlinkRTTViewer` to see the logs from ble_p.c:
```console
$ JLinkRTTViewer
```
Which should looks something like this:
```console
00> <info> app: BLE_Peripheral example started.
00> 
00> <info> app: Number of peers: 0
00> 
00> <info> app_timer: RTC: initialized.
00> 
00> <info> app: buttons_init
00> 
00> <error> app: Function return code: NRF_SUCCESS
00> 
00> <debug> nrf_ble_lesc: Initialized nrf_crypto.
00> 
00> <debug> nrf_ble_lesc: Initialized nrf_ble_lesc.
00> 
00> <debug> nrf_ble_lesc: Generating ECC key pair
00> 
00> <info> app: here....
00> 
00> <error> app: Function return code: NRF_SUCCESS
00> 
00> <info> app: ADDR: EF:47:D2:57:6A:F6
00> 
00> 
00> <info> app: advertising_start erase_bonds: false
```
Notice that LE Secuce Connections (LESE/lesc) and an ECC key pair has been
generated.

We can inspect the advertisements that are being broadcasted using the BLE
sniffer Ubertooth one:
```
$ ubertooth-btle -f -tef:47:d2:57:6a:f6 -c /tmp/pipe
```
And in WireShark we can see inspect the packets:
```
$ ubertooth-btle -f -tef:47:d2:57:6a:f6 -c /tmp/pipe

Frame 3: 70 bytes on wire (560 bits), 70 bytes captured (560 bits) on interface /tmp/pipe, id 0
PPI version 0, 24 bytes
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
        16-bit Service Class UUIDs
            Length: 3
            Type: 16-bit Service Class UUIDs (0x03)
            UUID 16: Device Information (0x180a)
        Device Name (shortened): BLE_Peripheral_Exa
            Length: 19
            Type: Device Name (shortened) (0x08)
            Device Name: BLE_Peripheral_Exa
    CRC: 0x66f22b
```

So we have device that is sending out broadcast adverisments in the form of
`ADV_IND` which are advertisment indications, that is they don't require
a response as opposed to a Protocol Data Unit (PDU) type with a `_REQ` suffix. 

Then we can open nrf-connect on a mobil phone and we should see a peripheral 
that is sending out advertisments with the name `BLE_Peripheral_Example` which
we should be able to connect to using nrf-connect.
_wip_


Next we need to flash the central, [ble_c.c](./ble_c.c):
```console
$ make flash_ble_c
```
One thing to note is that at this point we have two devices connected to the
computer using USB. In the Makefile, see `DEVICE2_SERIAL_NR ` we specify the
serial number of the second device. The serial number can be copied taken from
the output of  `dmesg`. The serial number of the device I'm using as the central
is '682659901'.

Using the same serial number we can also see the logs using JLinkRTTViewer
which will ask which device to connect to. The output should be something
similar to the below for ble_c:
```console
00> <info> app_timer: RTC: initialized.
00>
00> <debug> ble_scan: Adding filter on BLE_Peripheral_Example name
00>
00> <info> app: BLE Central example started.
00>
00> <info> app: ADDR: E1:9E:91:ED:7:E2
00>
```



### Ubertooth One issue
I've had huge problems trying to capture packets with ubertooth one and it
seems that it can only listen to one of the three advertisment channels at one
time. So it might be that the CONNECT_REQ packet is getting sent one of the
other advertising channels (37, 38, or 39). By default ubertooth-btle listens
to channel 37.
