#![no_std]
#![no_main]
#![feature(type_alias_impl_trait)]

use embassy::executor::Spawner;
use embassy_stm32::Peripherals;
use embedded_hal::digital::v2::OutputPin;
use embassy_stm32::gpio::{Level, Output, Speed};
use panic_halt as _;

#[embassy::main]
async fn main(_spawner: Spawner, p: Peripherals) -> ! {
    let mut led = Output::new(p.PA4, Level::High, Speed::Low);
    led.set_high().unwrap();
    loop {
    }
}

