
include ../Makefile

VPATH = ../uart ../led ../timer

i2c.elf : i2c.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $<
	objcopy -O ihex $@ $@.hex

i2c.o: i2c.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

# I2C Peripheral, uses UART to write received data. 
i2c-p.elf : i2c-p.o i2c.o uart-tx.o delay.o blue-led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

i2c-p.o: i2c-p.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

# I2C Controller that writes data to the peripheral (does not use UART).
i2c-c.elf : i2c-c.o i2c.o delay.o blue-led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

i2c-c.o: i2c-c.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@
