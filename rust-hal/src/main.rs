#![no_std]
#![no_main]

use stm32f0xx_hal as hal;
use cortex_m_rt::entry;
use crate::hal::{pac, prelude::*};
use panic_halt as _;

#[entry]
fn main() -> ! {
    let mut per = pac::Peripherals::take().unwrap();
    let mut rcc = per.RCC.configure().sysclk(8.mhz()).freeze(&mut per.FLASH);
    let gpioa = per.GPIOA.split(&mut rcc);
    let mut led = cortex_m::interrupt::free(|cs| gpioa.pa4.into_push_pull_output(cs));
    led.set_high().ok();
    loop {
    }
}

