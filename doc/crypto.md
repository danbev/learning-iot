## Embedded Crypto notes


### nrf_crypto
The crypto library in nrf consists of a frontend API and a number of options
for the backend implementation:
```
 +-----------------------------------------------------------------------------------------------------------+
 |                                      nrf_crypto frontend                                                  |
 |------------------------------------------------------|----------------|-----------------------------------|
 | CC310 backend | mbed TLS backend | micro-ecc backend | Cifra backend  | nrf_hw | nrf_sw | oberon | optiga |
 |------------------------------------------------------|----------------|-----------------------------------|
 | nrf_ccCC310   | mbed TSL source  | micro-ecc library |    ???         |        |        |        |        |
 | runtime lib   | distribution     |                   |                |        |        |        |        |
 +------------------------------------------------------+----------------------------------------------------+
```
This needs to be be enabled by setting `NRF_CRYPTO_ENABLED` in
config/sdk_config.h.

#### Frontend
This is an interface to various crypto functions for which the implementation
depends on the selected backend, so it could be that the backend is implemented
in software or in hardware. 

The following headers are included by
`components/libraries/crypto/nrf_crypto.h`:
```c
#include <stdint.h>
#include "nrf_crypto_init.h"
#include "nrf_crypto_types.h"
#include "nrf_crypto_mem.h"
#include "nrf_crypto_ecc.h"
#include "nrf_crypto_hash.h"
#include "nrf_crypto_ecdsa.h"
#include "nrf_crypto_ecdh.h"
#include "nrf_crypto_rng.h"
#include "nrf_crypto_aes.h"
#include "nrf_crypto_aead.h"
#include "nrf_crypto_hmac.h"
#include "nrf_crypto_hkdf.h"
#include "nrf_crypto_eddsa.h"
```
And if we take a look in `components/libraries/crypto/backend` we can find
implementations for these backends:
```console
$ ls components/libraries/crypto/backend/
cc310  cc310_bl  cifra	mbedtls  micro_ecc  nrf_hw  nrf_sw  oberon  optiga
```
#### CC310
ARM CC310 (CryptoCell) cryptographic subsystem that is available in nRF52840
devices.

This can be enabled by setting `NRF_CRYPTO_BACKEND_CC310_BL_ENABLED` in
config/sdk_config.h.


#### mbed TLS backend
This backend uses selected crypto algorithms from
[mbed-tls](https://github.com/ARMmbed/mbedtls) which is a library that contains
crypto primitives, like X.509 certificate manipulation and support for TLS.

This can be enabled by setting `NRF_CRYPTO_BACKEND_MBEDTLS_ENABLED` in
config/sdk_config.h.


#### micro-ecc
This backend used [micro-ecc](https://github.com/kmackay/micro-ecc).

This can be enabled by setting `NRF_CRYPTO_BACKEND_MICRO_ECC_ENABLED` in
config/sdk_config.h.


#### Cifra
[Cifra](https://github.com/ctz/cifra) is a collection of crypto primitives that
is targeted at embedded devices.

This can be enabled by setting `NRF_CRYPTO_BACKEND_CIFRA_ENABLED` in
config/sdk_config.h.


#### nrf_hw
Used NRF hardware as the backend.

This can be enabled by setting `NRF_CRYPTO_BACKEND_NRF_HW_RNG_ENABLED` in
config/sdk_config.h.

#### nrf_sw
This is a legacy software implementation from nrf.

This can be enabled by setting `NRF_CRYPTO_BACKEND_NRF_SW_ENABLED` in
config/sdk_config.h.


#### oberon
[Oberon Microsystems](https://www.ocrypto.cha) provide a crypto library, named
ocrypto, for IoT applications, that is embedded systems with
resource-constrained 32-bit microcontrollers.

See this [page](https://www.ocrypto.ch/functions/) for the functions that
ocrypto supports.

This can be enabled by setting `NRF_CRYPTO_BACKEND_OBERON_ENABLED` in
config/sdk_config.h.

#### optiga
This backend used crypto algorithms from Infineon OPTIGA Trust X. 

The selected Trust X functions supported by the OPTIGA backend are:
* Random number generation using a true random number generator (TRNG).
* EC (Elliptic curve) key generation.
* ECDH (EC Diffie-Hellman) key agreement to compute shared secrets.
* ECDSA signature computation and verification.
* Encoding/decoding functions for key material to use them with the Trust X API.

This can be enabled by setting `NRF_CRYPTO_BACKEND_OPTIGA_ENABLED` in
config/sdk_config.h.

