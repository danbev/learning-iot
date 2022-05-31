#![no_main]
#![no_std]
use panic_halt as _;
//extern crate panic_semihosting;

//use cortex_m_semihosting::syscall;
//use cortex_m::asm;
use core::fmt::Write;

extern crate cortex_m_rt;
extern crate cortex_m;
use cortex_m_rt::{entry};
use cortex_m_semihosting::hio;

#[entry]
fn main() -> ! {
    let mut stdout = hio::hstdout().unwrap();
    loop {
        stdout.write_str("semihosting example\n").unwrap();
        //asm::nop();
    }
}
