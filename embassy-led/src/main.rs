#![no_std]
#![no_main]
#![feature(type_alias_impl_trait)]

use embassy_executor::executor::Spawner;
use embassy_stm32::Peripherals;
use embedded_hal::digital::v2::OutputPin;
use embassy_stm32::gpio::{Level, Output, Speed};
use embassy_stm32::usart::{Config, Uart};
use embassy_stm32::dma::NoDma;
use embedded_hal::blocking::serial::Write;
use panic_halt as _;

#[embassy_executor::main]
async fn main(_spawner: Spawner, p: Peripherals) -> ! {
    let config = Config::default();
    let tx = p.PA9;
    let rx = p.PA10;
    let mut usart = Uart::new(p.USART1, rx, tx, NoDma, NoDma, config);

    let mut led = Output::new(p.PA4, Level::High, Speed::Low);
    led.set_high();

    usart.bwrite_all(b"embassy example\r\n").unwrap();

    loop {

    }
}

