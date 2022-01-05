### Embedded Rust notes
The assembly language programs that exist in
[stm32f0-discovery](./stm32f0-discovery) can be written in the same way in Rust
which [rust-low-level](../rust-low-level) is an example of. In that case we are
updating memory mapped registers directly and have to define all the memory
memory addresses an the values for these registers in the program.

### Micro-architecture Crates
The next step up from this is using a crate for a specific micro-architecture
like cortex-m which provides functionality specific to the processor of an
microprocessor. The crate [cortex-m](https://crates.io/crates/cortex-m) is an
example of such a crate.

#### cortex-m-rt crate
This crate takes care of some of the lower-level things like setting up the
entry point, the vector table (and perhaps other things), that we did manually
in the [rust-low-level](../rust-low-level) example.

### Peripheral Access Crates(PAC)
Peripheral Access Crates provide access to micro-controller specific
peripherals.

For 
https://github.com/stm32-rs/stm32-rs


### System View Description (SVD)
This is a defined format for describing the system of an ARM Cortex-M micro-
processor. As far as I understand it contains most if not all the info found
in the reference manual, like the register addresses, and the bit values of all
the fields. This is produced by the silicon vendors which publish these to a
web-based [device database](https://www.arm.com/why-arm/technologies/cmsis).

These files can be used to generate device header files and there is a rust
crate named [svd2rust](https://docs.rs/svd2rust/latest/svd2rust/) which can
generate a peripheral API in the Rust language.


