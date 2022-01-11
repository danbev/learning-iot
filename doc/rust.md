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


### critical_section
This is a struct that is part of the
[critical_section](https://docs.rs/critical-section/latest/critical_section)
crate. A critical section means that no interrupts should be enabled that might
preempt the code that is covered by the critical section.

There is as a function to `aquire` a critical section (which is a kind of token)
```rust
pub unsafe fn acquire() -> u8
```

There is also a function named `with` which will take a closure and before
executing that closure will aquire a critical_section token, and also release
it afterwards.
```rust
pub fn with<R>(f: impl FnOnce(CriticalSection) -> R) -> R {
    unsafe {
        let token = acquire();
        let r = f(CriticalSection::new());
        release(token);
        r
    }
}
```
The implementation of cortex-m looks like this:
```rust
#[no_mangle]
        unsafe fn _critical_section_acquire() -> u8 {
            let primask = cortex_m::register::primask::read();
            cortex_m::interrupt::disable();
            primask.is_active() as _
        }

        #[no_mangle]
        unsafe fn _critical_section_release(token: u8) {
            if token != 0 {
                cortex_m::interrupt::enable()
            }

```
The above will call the following funtions in `cortext-m`:
```rust
#[inline]                                                                       
pub fn disable() {                                                              
    call_asm!(__cpsid());                                                       
} 

#[inline]                                                                       
pub unsafe fn enable() {                                                        
    call_asm!(__cpsie());                                                       
}
```
`CPS` is the instruction to Change Processor State (CPS), and `id` is
interrupt disable, and `ie` is interrupt enable.

