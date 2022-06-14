## embedded-hal
This project contains Traits that are common to embedded devices.                  
                                                                                   
The motivation for this can be thought of as if we look at what we did when        
writing the assembly language programs for various devices, we had to specify   
the registers used in each program (or include them from a common include file).
We had to look these registers up in the datasheet for the microcontroller in   
question.

To turn on an LED we need to perform some specific tasks for the microcontroller
like enabling the PORT that the LED is connected to, set the mode, the output
type, the speed and finally set/unset the PIN of the LED to turn it on. An
example can be found in [led-ext.s](../stm32f0-discovery/led/led-ext.s).

And in Rust we did something similar [main.rs](../rust-low-level/src/main.rs). 
The main point is that doing this over and over again is error prone and the
code is not very nice or safe.

[API reference](https://docs.rs/embedded-hal/latest/embedded_hal/)


Take [embedded_hal::digital::v2::InputPut](https://docs.rs/embedded-hal/latest/embedded_hal/digital/v2/trait.InputPin.html)
which is a Trait:
```rust
pub trait InputPin {
    type Error;
    fn is_high(&self) -> Result<bool, Self::Error>;
    fn is_low(&self) -> Result<bool, Self::Error>;
}
```

We can see a concrete implementation of this in
[stm32f0xx-hal](https://github.com/stm32-rs/stm32f0xx-hal/blob/9f21c49001ebc841bac21759b11aaa632858057f/src/gpio.rs#L119):
```rust
impl InputPin for Pin<Output<OpenDrain>> {
    type Error = Infallible;

    #[inline(always)]
    fn is_high(&self) -> Result<bool, Self::Error> {
        self.is_low().map(|v| !v)
    }

    #[inline(always)]
    fn is_low(&self) -> Result<bool, Self::Error> {
        Ok(unsafe { (*self.port).is_low(self.i) })
    }
}
```
A driver can write code using the interfaces/traits in embedded_hal and then
someone wanting to use the driver can import any embedded-hal implemenation
and still use the driver. Users of Drivers can the use/import a specific hal
using:
```rust
use stm32f0xx_hal as hal;
```
If they want to switch to a different type of microcontroller they will only
have to update the dependency in Cargo.toml and then replace `stm32f0xx_hal`
with the name of that create instead.
