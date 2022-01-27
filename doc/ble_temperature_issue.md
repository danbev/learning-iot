### Error
This error occurs when trying to run the example nrf52/microbit/ble-temperature.

First we need to flash the Softdevice:
```console
$ probe-rs-cli download s113_nrf52_7.3.0_softdevice.hex --chip nRF52833_xxAA --format Hex
```

Then we can build and flash the example:
```console
$ env RUST_LOG=info cargo run --verbose
(HOST) INFO  flashing program (15 pages / 60.00 KiB)
(HOST) INFO  success!
────────────────────────────────────────────────────────────────────────────────
ERROR panicked at 'sd_softdevice_enable err SdmIncorrectInterruptConfiguration'
└─ nrf_softdevice::softdevice::{impl#0}::enable @ /home/danielbevenius/.cargo/git/checkouts/nrf-softdevice-03ef4aef10e777e4/716f030/nrf-softdevice/src/fmt.rs:101
ERROR panicked at 'explicit panic', /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/defmt-0.3.0/src/lib.rs:367:5
└─ panic_probe::print_defmt::print @ /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/panic-probe-0.3.0/src/lib.rs:91
────────────────────────────────────────────────────────────────────────────────
stack backtrace:
   0: HardFaultTrampoline
      <exception entry>
   1: lib::inline::__udf
        at ./asm/inline.rs:181:5
   2: __udf
        at ./asm/lib.rs:51:17
   3: cortex_m::asm::udf
        at /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/cortex-m-0.7.4/src/asm.rs:43:5
   4: rust_begin_unwind
        at /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/panic-probe-0.3.0/src/lib.rs:72:9
   5: core::panicking::panic_fmt
        at /rustc/c5ecc157043ba413568b09292001a4a74b541a4e/library/core/src/panicking.rs:107:14
   6: core::panicking::panic
        at /rustc/c5ecc157043ba413568b09292001a4a74b541a4e/library/core/src/panicking.rs:48:5
   7: __defmt_default_panic
        at /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/defmt-0.3.0/src/lib.rs:367:5
   8: nrf_softdevice::softdevice::Softdevice::enable
   9: ble::controller::BleController::new_sd
        at /home/danielbevenius/work/drougue/drogue-device/examples/apps/ble/src/controller.rs:44:6
  10: ble::microbit::MicrobitBleService<C>::new
        at /home/danielbevenius/work/drougue/drogue-device/examples/apps/ble/src/microbit.rs:31:18
  11: microbit_ble_temperature::__embassy_main::task::{{closure}}
        at src/main.rs:55:22
  12: <core::future::from_generator::GenFuture<T> as core::future::future::Future>::poll
        at /rustc/c5ecc157043ba413568b09292001a4a74b541a4e/library/core/src/future/mod.rs:84:19
  13: embassy::executor::raw::TaskStorage<F>::poll
        at /home/danielbevenius/.cargo/git/checkouts/embassy-9312dcb0ed774b29/0d67ceb/embassy/src/executor/raw/mod.rs:183:15
  14: embassy::executor::raw::timer_queue::TimerQueue::update
        at /home/danielbevenius/.cargo/git/checkouts/embassy-9312dcb0ed774b29/0d67ceb/embassy/src/executor/raw/timer_queue.rs:35:12
  15: embassy::executor::raw::Executor::poll::{{closure}}
        at /home/danielbevenius/.cargo/git/checkouts/embassy-9312dcb0ed774b29/0d67ceb/embassy/src/executor/raw/mod.rs:329:13
  16: embassy::executor::raw::run_queue::RunQueue::dequeue_all
        at /home/danielbevenius/.cargo/git/checkouts/embassy-9312dcb0ed774b29/0d67ceb/embassy/src/executor/raw/run_queue.rs:71:13
  17: embassy::executor::raw::Executor::poll
        at /home/danielbevenius/.cargo/git/checkouts/embassy-9312dcb0ed774b29/0d67ceb/embassy/src/executor/raw/mod.rs:308:9
  18: cortex_m::asm::wfe
        at /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/cortex-m-0.7.4/src/asm.rs:49:5
  19: embassy::executor::arch::Executor::run
        at /home/danielbevenius/.cargo/git/checkouts/embassy-9312dcb0ed774b29/0d67ceb/embassy/src/executor/arch/cortex_m.rs:54:13
  20: microbit_ble_temperature::__cortex_m_rt_main
        at src/main.rs:50:1
  21: main
        at src/main.rs:50:1
  22: ResetTrampoline
        at /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/cortex-m-rt-0.6.15/src/lib.rs:547:26
  23: Reset
        at /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/cortex-m-rt-0.6.15/src/lib.rs:550:13
  24: __DEFMT_MARKER_END
(HOST) ERROR error occurred during backtrace creation: debug information for address 0x1ae20 is missing. Likely fixes:
        1. compile the Rust code with `debug = 1` or higher. This is configured in the `profile.{release,bench}` sections of Cargo.toml (`profile.{dev,test}` default to `debug = 2`)
        2. use a recent version of the `cortex-m` crates (e.g. cortex-m 0.6.3 or newer). Check versions in Cargo.lock
        3. if linking to C code, compile the C code with the `-g` flag

Caused by:
    Do not have unwind info for the given address.
               the backtrace may be incomplete.
(HOST) ERROR the program panicked
```
The interrupt priorites are set in the `config` function:
```rust
fn config() -> Config {
    let mut config = embassy_nrf::config::Config::default();
    config.gpiote_interrupt_priority = Priority::P2;
    config.time_interrupt_priority = Priority::P2;
    config
}
```
Notice that the priority is being set to 2 in this case. Now if we set a
breakpoint in embassy-nrf::inif we can inspect the config value that is
getting used:
```console
$ openocd -f interface/cmsis-dap.cfg -f target/nrf52.cfg
$ arm-none-eabi-gdb ../target/thumbv7em-none-eabihf/debug/microbit-ble-temperature
(gdb) target remote localhost:3333

(gdb) br time_driver.rs:embassy_nrf::init 
Breakpoint 1 at 0x2283c: file /home/danielbevenius/.cargo/git/checkouts/embassy-9312dcb0ed774b29/0d67ceb/embassy-nrf/src/lib.rs, line 137.
Note: automatically using hardware breakpoints for read-only addresses.
(gdb) c
Continuing.

Breakpoint 1, embassy_nrf::init (config=...) at /home/danielbevenius/.cargo/git/checkouts/embassy-9312dcb0ed774b29/0d67ceb/embassy-nrf/src/lib.rs:137
warning: Source file is more recent than executable.
137	    let peripherals = Peripherals::take();
(gdb) n
142	    match config.hfclk_source {
(gdb) n
154	    match config.lfclk_source {
(gdb) n
182	    r.events_lfclkstarted.write(|w| unsafe { w.bits(0) });
(gdb) n
183	    r.tasks_lfclkstart.write(|w| unsafe { w.bits(1) });
(gdb) n
184	    while r.events_lfclkstarted.read().bits() == 0 {}
(gdb) n
188	    gpiote::init(config.gpiote_interrupt_priority);
(gdb) p config
$1 = embassy_nrf::config::Config {hfclk_source: embassy_nrf::config::HfclkSource::Internal, lfclk_source: embassy_nrf::config::LfclkSource::InternalRC, gpiote_interrupt_priority: embassy_hal_common::interrupt::Priority3::P0, time_interrupt_priority: embassy_hal_common::interrupt::Priority3::P0}
```
Notice that the priority is `P0` which is the default priority. I initially
thought this was this issue but looking closer I can see that the correct
priority is passed: 
```console
188	    gpiote::init(config.gpiote_interrupt_priority);
(gdb) s
embassy_nrf::gpiote::init (irq_prio=embassy_hal_common::interrupt::Priority3::P2)
    at /home/danielbevenius/.cargo/git/checkouts/embassy-9312dcb0ed774b29/d76cd5c/embassy-nrf/src/gpiote.rs:62
62	        p.detectmode.write(|w| w.detectmode().ldetect());
```

After trying out the nrf-softdevice/examples/src/bin/ble_peripheral_onoff.rs
which worked I tried placing the Softdevice configuration and enabling code
directly in the config() function to see if that worked. This did work but
I got another error after enabling the Softdevice:
```console
     Running `probe-run --chip nrf52833_xxAA /home/danielbevenius/work/drougue/drogue-device/examples/nrf52/microbit/target/thumbv7em-none-eabihf/debug/microbit-ble-temperature`
(HOST) INFO  flashing program (15 pages / 60.00 KiB)
(HOST) INFO  success!
────────────────────────────────────────────────────────────────────────────────
ERROR main.rs: configured priorites
└─ microbit_ble_temperature::config @ src/main.rs:49
ERROR before Softdevice enable
└─ microbit_ble_temperature::config @ src/main.rs:82
ERROR Softdevice enable...
└─ nrf_softdevice::softdevice::{impl#0}::enable @ /home/danielbevenius/.cargo/git/checkouts/nrf-softdevice-03ef4aef10e777e4/f81a201/nrf-softdevice/src/softdevice.rs:101
ERROR rd_softdevice_enable returned Ok(())
└─ nrf_softdevice::softdevice::{impl#0}::enable @ /home/danielbevenius/.cargo/git/checkouts/nrf-softdevice-03ef4aef10e777e4/f81a201/nrf-softdevice/src/softdevice.rs:111
ERROR after Softdevice enable
└─ microbit_ble_temperature::config @ src/main.rs:84
ERROR panicked at 'Softdevice memory access violation. Your program accessed registers for a peripheral reserved to the softdevice. PC=20db6 PREGION=1'
└─ nrf_softdevice::softdevice::fault_handler @ /home/danielbevenius/.cargo/git/checkouts/nrf-softdevice-03ef4aef10e777e4/f81a201/nrf-softdevice/src/fmt.rs:101
ERROR panicked at 'explicit panic', /home/danielbevenius/.cargo/registry/src/github.com-1ecc6299db9ec823/defmt-0.3.0/src/lib.rs:367:5
```
After taking a closer look and googling this error I came accross a mention
that there are certain restrictions that the Softdevice places on hardware
periperals: https://infocenter.nordicsemi.com/index.jsp?topic=%2Fsds_s132%2FSDS%2Fs1xx%2Fsd_resource_reqs%2Fhw_block_interrupt_vector.html

Notice that `TEMP` is restricted. But it is used in this example via usage
of the MicrobitBoard in device/src/bsp/boards/nrf52/microbit.rs. The example
in this case uses examples/apps/ble/src/microbit.rs which contains a
TemperatureMonitor which uses the Softdevice to interact with the TEMP
periperal
```rust
        let monitor = self.monitor.mount(
            spawner,
            TemperatureMonitor::new(self.sd, &self.server.temperature),
```

A suggestion for a workaround is to conditionally compile the Microbit board so
that when when `bsp+microbit+ble` feature is specified then the `temp` field
will not be used since it is considered restricted when a the Softdevice is in
use. 

