## Embedded Crypto notes


### Oberon
[Oberon Microsystems](https://www.ocrypto.cha) provide a crypto library, named
ocrypto, for IoT applications, that is embedded systems with
resource-constrained 32-bit microcontrollers.

See this [page](https://www.ocrypto.ch/functions/) for the functions that
ocrypto supports.


### nrf-oberon
The nrf_oberon library contains a collection of cryptographic algorithms created
by Oberon Microsystems, licensed to Nordic Semiconductor ASA for redistribution


### mbed-tls
[mbed-tls](https://github.com/ARMmbed/mbedtls) is a library that contains crypto
primitives, like X.509 certificate manipulation and support for TLS. For
embedded (bare-metal without and operating system) I'm thinking that what is
used from this library could be the...


### Infineon Optiga Trust X backend.
TODO: 

### nrf_crypto
```
 +------------------------------------------------------+
 |            nrf_crypto frontend                       |
 |------------------------------------------------------|
 | CC310 backend | mbed TLS backend | micro-ecc backend |
 |------------------------------------------------------|
 | nrf_ccCC310   | mbed TSL source  | micro-ecc library |
 | runtime lib   | distribution     |                   |
 +------------------------------------------------------+

```

### CC310
ARM CC310 cryptographic subsystem that is available in nRF52840 devices.
Is this CryptoCell?
