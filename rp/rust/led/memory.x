MEMORY {
    BOOT2 : ORIGIN = 0x10000000, LENGTH = 0x100
    FLASH : ORIGIN = 0x10000100, LENGTH = 2048K - 0x100
    RAM   : ORIGIN = 0x20000000, LENGTH = 256K
}

/* 
   This will force an undefined symbol which will then be linked with the
   rp-pico library:

rp-hal/boards/rp-pico/src/lib.rs:
#[cfg(feature = "boot2")]                                                       
#[link_section = ".boot2"]                                                      
#[no_mangle]                                                                    
#[used]                                                                         
pub static BOOT2_FIRMWARE: [u8; 256] = rp2040_boot2::BOOT_LOADER_W25Q080;

$ nm -C target/thumbv6m-none-eabi/debug/led | grep BOOT
10000000 R BOOT2_FIRMWARE
R = is in read only section
*/
EXTERN(BOOT2_FIRMWARE)

SECTIONS {
    /* ### Boot loader */
    .boot2 ORIGIN(BOOT2) :
    {
        KEEP(*(.boot2));
    } > BOOT2
} INSERT BEFORE .text;
