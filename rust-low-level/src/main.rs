#![no_std]
#![no_main]
#![allow(dead_code)]

use core::panic::PanicInfo;
use core::ptr::{write_volatile, read_volatile};

const RCC_BASE: u32 = 0x40021000;
const GPIOA_BASE: u32 = 0x48000000;

const AHBENR_OFFSET: u32 = 0x14;
const GPIOA_MODER_OFFSET: u32 = 0x00;
const GPIOA_OTYPER_OFFSET: u32 = 0x04;
const GPIOA_IDR_OFFSET: u32 = 0x10;
const GPIOA_ODR_OFFSET: u32 = 0x14;
const GPIOA_PUPDR_OFFSET: u32 = 0x0C;
const GPIOA_SPEEDR_OFFSET: u32 = 0x08;

const RCC_AHBENR: *mut u32 = (RCC_BASE + AHBENR_OFFSET) as *mut u32;
const GPIOA_MODER: *mut u32 = (GPIOA_BASE + GPIOA_MODER_OFFSET) as *mut u32;
const GPIOA_OTYPER: *mut u32 = (GPIOA_BASE + GPIOA_OTYPER_OFFSET) as *mut u32;
const GPIOA_ODR: *mut u32 = (GPIOA_BASE + GPIOA_ODR_OFFSET) as *mut u32;
const GPIOA_PUPDR: *mut u32 = (GPIOA_BASE + GPIOA_PUPDR_OFFSET) as *mut u32;
const GPIOA_SPEEDR: *mut u32 = (GPIOA_BASE + GPIOA_SPEEDR_OFFSET) as *mut u32;

const GPIO_PORTA_ENABLE: u32 = 1 << 17;
const GPIOA_MODER_PA4: u32 = 1 << 8;
const GPIOA_OTYPER_PA4: u32 = 0 << 4;
const GPIOA_SPEEDR_PA4: u32 = 1 << 8;
const GPIOA_PUPDR_PA4: u32 = 0x00 << 8;
const GPIOA_ODR_PA4: u32 = 1 << 4;

#[link_section = ".text"]
#[no_mangle]
pub unsafe extern "C" fn Reset() -> ! {
    /* Enable Port A clock */
    write_volatile(RCC_AHBENR, read_volatile(RCC_AHBENR) | GPIO_PORTA_ENABLE);
    write_volatile(GPIOA_MODER, read_volatile(GPIOA_MODER) | GPIOA_MODER_PA4);
    write_volatile(GPIOA_OTYPER , read_volatile(GPIOA_OTYPER) |GPIOA_OTYPER_PA4);
    write_volatile(GPIOA_PUPDR , read_volatile(GPIOA_PUPDR) | GPIOA_PUPDR_PA4);
    write_volatile(GPIOA_SPEEDR , read_volatile(GPIOA_SPEEDR) | GPIOA_SPEEDR_PA4);
    write_volatile(GPIOA_ODR , read_volatile(GPIOA_ODR) | GPIOA_ODR_PA4);
    loop {}
}

#[link_section = ".vector_table.reset_vector"]
#[no_mangle]
pub static RESET_HANDLER: unsafe extern "C" fn() -> ! = Reset;

#[panic_handler]
fn panic(_panic: &PanicInfo<'_>) -> ! {
    loop {}
}
