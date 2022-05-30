## Embassy
Embassy (EMBedded ASYnc) is an async executor of tasks and also a Hardware
Access Layer (HAL). The HAL provides an API to access peripherals like USART,
I2C, SPI, CAN etc.

The async part is useful when you consider that many embedded controllers only
have a single core, but it might still be desirable to execute tasks
concurrently (intermixed) and not synchronously (one after the other).

Tasks are woken by interrupts, there is no busy-loop polling while waiting.




### embassy::main
This macro can be used in an embassy application and expands to something like:
```console
$ cargo rustc --profile=check -- -Zunpretty=expanded
```

### Compiling crates in Embassy
One has to specify the target when building as there are conditional compilation
guards in the code that might not be enables. For example, just doing cargo
build in some of the creates generates the following warning:
```console
error[E0432]: unresolved import `embassy::interrupt`
 --> src/peripheral.rs:6:14
  |
6 | use embassy::interrupt::{Interrupt, InterruptExt};
  |              ^^^^^^^^^ could not find `interrupt` in `embassy`

```
Specifying a target will enable it to compile:
```console
$ cargo build --target thumbv7em-none-eabi --features nrf52833,gpiote,time-driver-rtc1,unstable-traits
```
One can look in `ci.sh` or `ci_stable.sh` for example invokations including
features sets that work.


### Walkthrough

So the above will generate the following in the source code:
```rust
async fn main(_spawner: Spawner, p: Peripherals) {
    let mut led = Output::new(p.PIN_25, Level::Low);
    ...
}
```
And Output::new looks like this:
```rust
    pub fn new(pin: impl Unborrow<Target = T> + 'd, initial_output: Level) -> Self {
       let mut pin = unsafe { pin.unborrow() };                           
```
Lets first see what p.PIN_25 is and for this we have to look in
embassy-rp/src/lib.rs:
```rust
embassy_hal_common::peripherals! {
    PIN_0,
    ...
    PIN_25,
    ...
}
```
The `peripheral!` macro can be found in embassy-hal-common/src/macros.rs which
we can expand using the following command (need to cargo install expand):
```console
$ cargo expand --target thumbv6m-none-eabi > lib.rs-expanded 
```
If we look in the lib.rs-expanded file we will find the expanded macro for:
```rust
pub mod peripherals {                                                           
    ...
    pub struct PIN_25 {
        _private: (),
    }

    impl embassy::util::Steal for PIN_25 {
        #[inline]
        unsafe fn steal() -> Self {
            Self { _private: () }
        }
    }

    unsafe impl embassy::util::Unborrow for PIN_25 {
        type Target = PIN_25;
        #[inline]
        unsafe fn unborrow(self) -> PIN_25 {
            self
        }
    }
}

pub struct Peripherals {
    ...
    pub PIN_25: peripherals::PIN_25,
    ...
}
```
So Peripherals is a struct with a public member for each pin, and the type
of this member is peripheral::Pin_25.
Now, there is also an implementation for Peripherals:
```rust
impl Peripherals {                                                              
    pub(crate) fn take() -> Self {                                              
        static mut _EMBASSY_DEVICE_PERIPHERALS: bool = false;                   
        critical_section::with(|_| unsafe {                                     
            if _EMBASSY_DEVICE_PERIPHERALS {                                    
                {                                                               
                    ::core::panicking::panic("init called more than once!");    
                }                                                               
            }                                                                   
            _EMBASSY_DEVICE_PERIPHERALS = true;                                 
            <Self as embassy::util::Steal>::steal()                             
        })                                                                      
    }                                                                           
}      
```
Notice that this will check that take is only called once and after that
will call the steal() function:
```rust
impl embassy::util::Steal for Peripherals {                                     
    #[inline]                                                                   
    unsafe fn steal() -> Self {                                                 
        Self {  
            PIN_0: <peripherals::PIN_0 as embassy::util::Steal>::steal(),
            ...
            PIN_25: <peripherals::PIN_25 as embassy::util::Steal>::steal(),
            ...
         }
```
This is what returns a Peripherals instance. 

If we look closer at these PIN structs they only have a member named `_private`
which is of the unit type '()'. There are implementations for this struct
which are included by the usage of mod gpio in lib.rs:
```rust
macro_rules! impl_pin {
    ($name:ident, $bank:expr, $pin_num:expr) => {
        impl Pin for peripherals::$name {}
        impl sealed::Pin for peripherals::$name {
            fn pin_bank(&self) -> u8 {
                ($bank as u8) * 32 + $pin_num
            }
        }
    };
}
impl_pin!(PIN_0, Bank::Bank0, 0);
...
impl_pin!(PIN_25, Bank::Bank0, 25);
```
Which will expand into:
```rust
    impl Pin for peripherals::PIN_25 {}                                         

    impl sealed::Pin for peripherals::PIN_25 {                                  
        fn pin_bank(&self) -> u8 {                                              
            (Bank::Bank0 as u8) * 32 + 25                                       
        }                                                                       
    }                                     

/// A GPIO bank with up to 32 pins.
#[derive(Debug, Eq, PartialEq)]
pub enum Bank {
    Bank0 = 0,
    Qspi = 1,
```
Bank::Bank0 is 0 so this value will just be 25 but it the same code can also
work for Quad SPI which is the reason for the multiplication by 32.
```rust
    pub trait Pin: Sized {
        fn pin_bank(&self) -> u8;
    
        #[inline]
        fn pin(&self) -> u8 {
            self.pin_bank() & 0x1f
        }
```
We saw that `pin_bank` returns 25 in our case, and here that function is called
and then the topmost 3 bits, or 8, are masked out as there are 2⁵=32 pins:
```
Dec 25   00011001
Hex 1F   00011111 &
       -------------
         00011001
```
This is all good but how is this connected to the actual physical register
addresses. For that we have to look to the other functions in the trait (Pin):
```rust
        fn bank(&self) -> Bank {
            if self.pin_bank() & 0x20 == 0 {
                Bank::Bank0
            } else {
                Bank::Qspi
            }
        }

        fn io(&self) -> pac::io::Gpio {
            let block = match self.bank() {
                Bank::Bank0 => crate::pac::IO_BANK0,
                Bank::Qspi => crate::pac::IO_QSPI,
            };
            block.gpio(self.pin() as _)
        }
```
So we know that `pin_bank()` returns 25 and here we are masking to see if this
pin is part of the Quad SPI bank:
```
Dec 25   00011001
Hex 20   00100000 &
       -------------
         00000000
```
Next, lets look at the `io` function which will call `bank()` and this will
return Bank::Bank0 in our case so `block` will be `crate::pac::IO_BANK0` which
can be found in rp2040-pac2/src/lib.rs:
```rust
pub const IO_BANK0: io::Io = io::Io(0x4001_4000 as u32 as _);
```
`io::Io` can be found in rp2040-pac2/src/io.rs:
```rust
pub struct Io(pub *mut u8);
```
And next we have the `block.gpio(self.pin() as Io)`:
```rust
unsafe impl Sync for Io {}
impl Io {
    pub fn gpio(self, n: usize) -> Gpio {
        assert!(n < 30usize);
        unsafe { Gpio(self.0.add(0usize + n * 8usize)) }
    }
```
And this is using the address 0x40014000 + (25 * 8) which is
0x40014000 + (200) which is 0x400014000 + C8 = 400140C8, and if we look in
the datasheet we can find:
```
0x400140C8  GPIO25_STATUS
0x400140CC  GPIO25_CTRL
```
And `Gpio` then contains functions to access the status and cltr registers:
```rust
pub struct Gpio(pub *mut u8);

impl Gpio {
    #[doc = "GPIO status"]
    pub fn status(self) -> crate::common::Reg<regs::GpioStatus, crate::common::RW> {
        unsafe { crate::common::Reg::from_ptr(self.0.add(0usize)) }
    }

    #[doc = "GPIO control including function select and overrides."]
    pub fn ctrl(self) -> crate::common::Reg<regs::GpioCtrl, crate::common::RW> {
        unsafe { crate::common::Reg::from_ptr(self.0.add(4usize)) }
    }
}
```
Here we can see that to get access to the status register for pin 25 the value
of Gpio is returned and for ctrl it is that valeu + 4usize to get the next
register. `add` calculates an offset from the 
[pointer](https://web.mit.edu/rust-lang_v1.25/arch/amd64_ubuntu1404/share/doc/rust/html/std/primitive.pointer.html).

Notice that these functions return a `Reg` (register) which is a struct that
has a single member field which is a pointer to the register:
```rust
pub struct Reg<T: Copy, A: Access> {
    ptr: *mut u8,
    phantom: PhantomData<*mut (T, A)>,
}
```
And has implementations of Read and Write to be able to read to the register
that it points to.

impl<T: Copy, A: Read> Reg<T, A> {
    pub unsafe fn read(&self) -> T {
        (self.ptr as *mut T).read_volatile()
    }
}

impl<T: Copy, A: Write> Reg<T, A> {
    pub unsafe fn write_value(&self, val: T) {
        (self.ptr as *mut T).write_volatile(val)
    }
}

impl<T: Default + Copy, A: Write> Reg<T, A> {
    pub unsafe fn write<R>(&self, f: impl FnOnce(&mut T) -> R) -> R {
        let mut val = Default::default();
        let res = f(&mut val);
        self.write_value(val);
        res
    }
}
```
We can see that `read()` will return the contents of the register.


```rust
pub const PADS_BANK0: pads::Pads = pads::Pads(0x4001_c000 as u32 as _); 
```

And `sealed::Pin` is a trait with only pin_bank for which there is not a
default implementation.
```rust
pub(crate) mod sealed {
    use super::*;

    pub trait Pin: Sized {
        fn pin_bank(&self) -> u8;

```

What is embassy::util::Steal?  
This is a trait which can be found in  embassy/src/util/steal.rs:
```rust
pub trait Steal {
    unsafe fn steal() -> Self;
}
```
So an implementation would return Self and give up ownership of it.


The `peripherals` that is passed to our main function above is created in the
`init` function in embassy-rp/src/lib.rs:
```rust
pub fn init(_config: config::Config) -> Peripherals {
    // Do this first, so that it panics if user is calling `init` a second time
    // before doing anything important.
    let peripherals = Peripherals::take();

    unsafe {
        clocks::init();
        timer::init();
    }

    peripherals
}
```
When is this function called?
```console
(gdb) br embassy_rp::init 
(gdb) load
(gdb) c
(gdb) bt
#0  embassy_rp::init (_config=...) at /home/danielbevenius/work/drougue/embassy/embassy-rp/src/lib.rs:104
#1  0x10000afe in blinky::__cortex_m_rt_main () at src/bin/blinky.rs:14
#2  0x10000aec in blinky::__cortex_m_rt_main_trampoline () at src/bin/blinky.rs:14
```
Now, that will point to the attribute `#[embassy::main]` but if we expand this
we can see the call to init:
```console
$ cargo expand --target thumbv6m-none-eabi --bin blinky > blinky-expanded
```
```rust
fn __cortex_m_rt_main() -> ! {
    let p = ::embassy_rp::init(Default::default());
    let mut executor = ::embassy::executor::Executor::new();
    let executor = unsafe { __make_static(&mut executor) };
    executor.run(|spawner| {
        spawner.must_spawn(__embassy_main(spawner, p));
    })
}
```

```console
$ cargo expand --target thumbv6m-none-eabi > lib.rs-expanded 
```
If we look in the lib.rs-expanded file we will find the expanded macro for:
```
pub mod peripherals {

```


Unborrow is a Trait declared in embassy/src/util/unborrow.rs:
```rust
pub unsafe trait Unborrow {
    /// Unborrow result type
    type Target;

    /// Unborrow a value.
    ///
    /// Safety: This returns a copy of a singleton that's normally not
    /// copiable. The returned copy must ONLY be used while the lifetime of `self` is
    /// valid, as if it were accessed through `self` every time.
    unsafe fn unborrow(self) -> Self::Target;
}
```


```rust
                    pin.pad_ctrl().write(|w| {
                        w.set_pde(true);
                    });

        fn pad_ctrl(&self) -> Reg<pac::pads::regs::GpioCtrl, RW> {
            let block = match self.bank() {
                Bank::Bank0 => crate::pac::PADS_BANK0,
                Bank::Qspi => crate::pac::PADS_QSPI,
            };
            block.gpio(self.pin() as _)
        }
        fn sio_out(&self) -> pac::sio::Gpio {
```
Notice here that pad_ctrl returns a Reg. To write directly to this we need
to create a new GpioCtrl, and set the values on this instance before passing
it into the write_value function: 
```
impl<pac::pads::regs::GpioCtrl: Copy, A: Write> Reg<pac::pads::regs::GpioCtrl, A> {
    pub unsafe fn write_value(&self, val: pac::pads::regs::GpioCtrl {
        (self.ptr as *mut pac::pads::regs::GpioCtrt).write_volatile(val)
    }
}
```
But here is also a write function that takes a closure that will create the
GpioCtrl instance for us and pass that into the closure as the argument to
it so we can set the functions we want (setting values using bit shifts really)
and then that write fuction will set that value by calling write_value.

### unborrow macro
```rust
    pub fn new(pin: impl Unborrow<Target = T> + 'd, initial_output: Level) -> Self {
        unborrow!(pin);
```

`rust
#[macro_export]
macro_rules! unborrow {
    ($($name:ident),*) => {
        $(
            let mut $name = unsafe { $name.unborrow() };
        )*
    }
}
```
This would expand to:
```rust
    let mut pin = unsafe { pin.unborrow() };
```
And this impl is generated by the peripheral macro:
```rust
    unsafe impl embassy::util::Unborrow for PIN_25 {
        type Target = PIN_25;
        #[inline]
        unsafe fn unborrow(self) -> PIN_25 {
            self
        }
    }
```


### Interrupts
```rust
declare!(IO_IRQ_BANK0);
```
Now I went looking for this `declare` macro in `embassy-macros/src/lib.rs` but
there I only found `interrupt_declare`:
```rust
#[proc_macro]
pub fn interrupt_declare(item: TokenStream) -> TokenStream {
    let name = syn::parse_macro_input!(item as syn::Ident);
    interrupt_declare::run(name).unwrap_or_else(|x| x).into()
}
```
This is because `embassy/src/interrupt.rs` has:
```rust
pub use embassy_macros::interrupt_declare as declare;
```
So we can find this procedural function like macro in
`embassy-macros/src/lib.rs`.
```rust
use macros::*;


#[proc_macro]
pub fn interrupt_declare(item: TokenStream) -> TokenStream {
    let name = syn::parse_macro_input!(item as syn::Ident);
    interrupt_declare::run(name).unwrap_or_else(|x| x).into()
}
```
And `interrupt_declare` is exposed by embassy-macros/src/macros/mod.rs:
```
pub mod interrupt;
pub mod interrupt_declare;
pub mod interrupt_take;
pub mod main;
pub mod task;
```
So we can look in `interrupt_declare.rs` to find the called macro:
```rust

```

Now, when we use the embassy-rp crate we will export the interrupt module:
```rust
pub mod interrupt;
```
And interrupt.rs has an irq module:
```
This expands to:
```rust
mod irqs {
        ...
        #[allow(non_camel_case_types)]
        pub struct IO_IRQ_BANK0(());
        unsafe impl ::embassy::interrupt::Interrupt for IO_IRQ_BANK0 {
            type Priority = crate::interrupt::Priority;

            fn number(&self) -> u16 {
                use cortex_m::interrupt::InterruptNumber;
                let irq = InterruptEnum::IO_IRQ_BANK0;
                irq.number() as u16
            }

            unsafe fn steal() -> Self {
                Self(())
            }

            unsafe fn __handler(&self) -> &'static ::embassy::interrupt::Handler {
                #[export_name = "__EMBASSY_IO_IRQ_BANK0_HANDLER"]
                static HANDLER: ::embassy::interrupt::Handler =
                    ::embassy::interrupt::Handler::new();
                &HANDLER
            }
        }
}
```
And we should be able to enable this struct using:
```rust
unsafe { interrupt::IO_IRQ_BANK0::steal().enable(); }
```
Notice that the impl is for `::embassy::interrupt::Interrupt` which can be
found in `embassy/src/interrupt.rs`:
```rust
pub unsafe trait Interrupt: crate::util::Unborrow<Target = Self> {
    type Priority: From<u8> + Into<u8> + Copy;
    fn number(&self) -> u16;
    unsafe fn steal() -> Self;

    /// Implementation detail, do not use outside embassy crates.
    #[doc(hidden)]
    unsafe fn __handler(&self) -> &'static Handler;
}

pub trait InterruptExt: Interrupt {
    fn set_handler(&self, func: unsafe fn(*mut ()));
    fn remove_handler(&self);
    fn set_handler_context(&self, ctx: *mut ());
    fn enable(&self);
    fn disable(&self);
    #[cfg(not(armv6m))]
    fn is_active(&self) -> bool;
    fn is_enabled(&self) -> bool;
    fn is_pending(&self) -> bool;
    fn pend(&self);
    fn unpend(&self);
    fn get_priority(&self) -> Self::Priority;
    fn set_priority(&self, prio: Self::Priority);
}
```
And above we can see that `enable` is part of the the Interrupt extension.
```rust
impl<T: Interrupt + ?Sized> InterruptExt for T {
    ...

    #[inline]
    fn enable(&self) {
        compiler_fence(Ordering::SeqCst);
        unsafe {
            NVIC::unmask(NrWrap(self.number()));
        }
    }
    ...
}


