### Embedded Rust notes
The assembly language programs that exist in
[stm32f0-discovery](./stm32f0-discovery) can be written in the same way in Rust
which [rust-low-level](../rust-low-level) is an example of. In that case we are
updating memory mapped registers directly and have to define all the memory
memory addresses an the values for these registers in the program.

And in Rust we did something similar
[rust-low-level.rs](../rust-low-level/src/main.rs). The main point is that doing
this over and over again is error prone and the code is not very nice or safe.

Most microcontroller manufacturers provide
[System View Description](system-view-description-(SVD) files that can be used
to create [Peripheral Access Crates](peripheral-access-crates-(PAC). In short
the SVD files describe a specific microcontroller in xml format. These can be
run through programs to generate headers, or in Rust's case crates using
`sv2rust`. 

So, from writing programs like [rust-low-level](../rust-low-level/src/main.rs),
we can now write programs like this [rust-pac](../rust-pac/src/main.rs). 

When we use a PAC we have some nice interfaces/types to periperals but we still
need to know that to turn on an LED we have to enable the port that it is
connected to. There are no checks or anything like that to make sure we don't
forget to do this. The PAC are very nice in that thay give hide away details
like registers and provide functions. To address these issues there we can
write a Hardware Abstraction Layers (HALs) around the PAC which deals with
these concerns. 

This allows "safer" code in the sense that certain dependencies can be enforeced
through functions and structures (like making sure a PORT is enabled, or that
one cannot configure an incorrect mode, or invalid speed, also it makes sure
that PINs/TIMERS etc cannot be used by other parts of the application). By
using a HAL it should be possible to not have to refer to the target
microcontrollers datasheet.

No we might want to write a driver for some hardware, like a senor for example.
Drivers in embedded rust are any crates that interact with an external
peripheral perhaps using a HAL. So we can use the HAL we created.

Now the HAL we created used above is specific to a certain microcontroller.
There are alot of common functionality among microcontrollers, like GPIO, Timer,
SPI. I2C, USART, etc. But thier APIs will differ.

So lets say we developed a driver that uses a sensor. This driver uses a
specific HAL which is specific to that microcontroller. This driver won't be
compatible with other HALs even though most microcontrollers would support the
same functionality, but using a different API. One option is to write another
driver for that microcontrollers HAL but that is duplicating the effort. A
solution to this is `embedded-hal`.

`embedded-hal` is a project that provides Traits for common periperals that are
shared amongst microcontrollers like GPIO, Timers, SPI, USART, I2C, etc.
Then embedded-hal's can be written for specific microcontrollers
embedded-hal's. And these can then be used by drivers so that the same driver
will be able to be used with any embedded-hal that is available.

We can now write programs like this [rust-hal](../rust-hal/src/main.rs).

For a list of embedded-hals see:
https://github.com/rust-embedded/awesome-embedded-rust#hal-implementation-crates

### Micro-architecture Crates
The next step up from this is using a crate for a specific micro-architecture
like cortex-m which provides functionality specific to the processor of an
microprocessor. The crate [cortex-m](https://crates.io/crates/cortex-m) is an
example of such a crate.

#### cortex-m-rt crate
This crate takes care of some of the lower-level things like setting up the
entry point, the vector table (and perhaps other things), that we did manually

### System View Description (SVD)
This is a defined format for describing the system of an ARM Cortex-M micro-
processor. As far as I understand it contains most if not all the info found
in the reference manual, like the register addresses, and the bit values of all
the fields. This is produced by the silicon vendors which publish these to a
web-based [device database](https://www.arm.com/why-arm/technologies/cmsis).

These files can be used to generate device header files and there is a rust
crate named [svd2rust](https://docs.rs/svd2rust/latest/svd2rust/) which can
generate a peripheral API in the `Rust` language crates.

### Peripheral Access Crates (PAC)
Peripheral Access Crates provide access to micro-controller specific
peripherals. These are created by taking the applying patches to the SVD files
and then running `svd2rust`. The patches are to correct some errors and make
the output a little easier to work with. The output of this is called the
PAC.

For example:  https://github.com/stm32-rs/stm32-rs


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


### stm32-pac
While I've still not gone through how the generation of code from device/board
definitions work I think the output can be found in project that uses a
specific device/board. For example:
```
target/thumbv6m-none-eabi/debug/build/stm32-metapac-90e38e1398aeeae0/out/src/chips/stm32f070rb/pac.rs
```
