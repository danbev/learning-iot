#![no_std]
#![no_main]
#![allow(dead_code)]

use stm32f0::stm32f0x0;
use cortex_m_rt::entry;
use panic_halt as _;

#[entry]
fn main() -> ! {
    let per = stm32f0x0::Peripherals::take().unwrap();
    let rcc = per.RCC;
    rcc.ahbenr.write(|w| w.iopaen().set_bit());

    let gpioa = &per.GPIOA;
    gpioa.moder.write(|w| w.moder4().output());
    gpioa.otyper.write(|w| w.ot4().push_pull());
    gpioa.pupdr.write(|w| w.pupdr4().floating());
    gpioa.ospeedr.write(|w| w.ospeedr4().medium_speed());
    gpioa.odr.modify(|_, w| w.odr4().set_bit());
    loop {
    }
}

