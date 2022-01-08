#![no_std]
#![no_main]
#![feature(type_alias_impl_trait)]

use embassy::executor::Spawner;
use embassy_stm32::Peripherals;
use embassy_stm32::gpio::{Level, Output, Speed};
use drogue_device::traits::led::Led as TraitLed;
use embassy_stm32::peripherals::{PA4};
use drogue_device::drivers::led::{ActiveHigh, Led};
use panic_halt as _;

pub type PINPA4 = Output<'static, PA4>;
pub type LEDPA4 = Led<PINPA4, ActiveHigh>;

#[embassy::main]
async fn main(_spawner: Spawner, p: Peripherals) -> ! {
    let mut led: LEDPA4 = Led::new(Output::new(p.PA4, Level::High, Speed::Low));
    led.on().unwrap();
    loop {
    }
}

