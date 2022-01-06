## Rust Hardware Abstraction Layer (HAL) example
This example shows how using an stm32 HAL works and what is required. This
example does the same things as [rust-low-level](../rust-low-level/README.md)
and the goal is to understand the advantages that this higher level API
provides.

### Building
```console
$ cargo build
```

### Flashing and Running
Start openocd:
```console
$ openocd -f board/stm32f0discovery.cfg
```

Start a telnet session:
```console
$ telnet localhost 4444
```

Flash the program:
```console
> reset halt
> flash write_image erase target/thumbv6m-none-eabi/debug/rust-hal
> reset run
```
Running should turn on the led:

![Rust HAL LED example](./img/rust-pac-led-example.jpg "Example of Rusta HAL LED example")

Debug:
```console
$ arm-none-eabi-gdb target/thumbv6m-none-eabi/debug/rust-hal
```
