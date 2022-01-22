## Bluetooth Low Energy (BLE) Examples
This directory contains examples of using BLE.


### BLE Peripheral
This example is a copy of the ble_peripheral_blinky example from the nrs SDK
and modified to build from this directory. The requirement is that the
environment variable `SDK_ROOT ` be set to point to the SDK.

This example also uses an external LED which can be turned on and off using
nrf-connect.


#### Building
First the BLE protocol stack (SoftDevice s132) needs to be flashed to the device:
```console
$ make flash_device
```

Then we need to flash the application:
```console
$ make flash
```

Then we can open nrf-connect on a mobil phone and we should see a peripheral 
that is sending out advertisments with the name `BLE_Peripheral_Example` which
we should be able to connect to using nrf-connect.

Example of the advertisment send by the peripheral:
![Advertisment](./img/ble_p_adv.jpg "BLE Peripheral Example advertisment")

Example of the client tab in nrf-connect:
![Client tab](./img/ble_p_client.jpg "BLE Peripheral Example Client tab")


Example writing to the attribute:
![Attribute tab](./img/ble_p_attribute.jpg "BLE Peripheral Example Attribute tab")

The result of writing to the attribute (led turns on)
![Led on](./img/ble_p_led_on.jpg "BLE Peripheral Example Write attribute")
