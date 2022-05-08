#![no_std]
#![no_main]

use cortex_m_rt::entry;
use embedded_hal::digital::v2::OutputPin;
use embedded_time::rate::*;

//  Link with panic_abort crate which which will a #[panic_handler] that 
//  abort 
use panic_abort as _;

// rp-rs/boards/rp-pico
use rp_pico::hal::prelude::*;
/* 
  boards/rp-pic/src/lib.rs contains the following import for pac:
     pub extern crate rp2040_hal as hal;
     pub use hal::pac;

  So we need to look in rp2040_hal to see what pac, rp2040-hal/src/lib.rs:
     pub extern crate rp2040_pac as pac;
  And in that create we can find the Peripherals struct.
*/
use rp_pico::hal::pac;

use rp_pico::hal;

#[entry]
fn main() -> ! {
    let mut pac = pac::Peripherals::take().unwrap();
    let core = pac::CorePeripherals::take().unwrap();

    let mut watchdog = hal::Watchdog::new(pac.WATCHDOG);

    let clocks = hal::clocks::init_clocks_and_plls(
        rp_pico::XOSC_CRYSTAL_FREQ,
        pac.XOSC,
        pac.CLOCKS,
        pac.PLL_SYS,
        pac.PLL_USB,
        &mut pac.RESETS,
        &mut watchdog,
    )
    .ok()
    .unwrap();

    let sio = hal::Sio::new(pac.SIO);

    let pins = rp_pico::Pins::new(
        pac.IO_BANK0,
        pac.PADS_BANK0,
        sio.gpio_bank0,
        &mut pac.RESETS,
    );

    let mut led_pin = pins.led.into_push_pull_output();

    let mut delay = cortex_m::delay::Delay::new(core.SYST, clocks.system_clock.freq().integer());
    loop {
        led_pin.set_high().unwrap();
        delay.delay_ms(500);
        led_pin.set_low().unwrap();
        delay.delay_ms(500);
    }
}
