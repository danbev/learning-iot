
include ../Makefile

VPATH = ../uart

# SPI Peripheral, uses UART to write received data.
spi-p.elf : spi-p.o spi.o uart-tx.o ../delay.o ../blue-led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

spi-p.o: spi-p.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

# SPI Controller that writes data to the peripheral (does not use UART).
spi-c.elf : spi-c.o spi.o ../delay.o ../blue-led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

spi-c.o: spi-c.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

