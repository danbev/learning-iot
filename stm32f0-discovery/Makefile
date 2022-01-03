AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g 

TOP := $(dir $(firstword $(MAKEFILE_LIST)))

uart-tx-sync.elf : uart-tx-sync.o uart-tx.o delay.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

uart-tx.o: uart-tx.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

i2c.elf : i2c.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $<
	objcopy -O ihex $@ $@.hex

i2c.o: i2c.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

# I2C Peripheral, uses UART to write received data. 
i2c-p.elf : i2c-p.o i2c.o uart-tx.o delay.o blue-led.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

i2c-p.o: i2c-p.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

# I2C Controller that writes data to the peripheral (does not use UART).
i2c-c.elf : i2c-c.o i2c.o delay.o blue-led.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

i2c-c.o: i2c-c.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

pull-up.elf : pull-up.o uart-tx.o delay.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

pull-up.o: pull-up.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

# SPI Peripheral, uses UART to write received data.
spi-p.elf : spi-p.o spi.o uart-tx.o delay.o blue-led.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

spi-p.o: spi-p.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

# SPI Controller that writes data to the peripheral (does not use UART).
spi-c.elf : spi-c.o spi.o delay.o blue-led.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

spi-c.o: spi-c.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

# CAN Controller which sends data to the CAN bus.
can-c.elf : can-c.o can.o delay.o blue-led.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

# CAN peripheral which is the receiver of CAN messages.
can-p.elf : can-p.o can.o delay.o blue-led.o uart-tx.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

%.elf : %.o blue-led.o delay.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

%.o: %.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

util/delay.o: $(TOP)/util/delay.s
	$(AS) $(ASFLAGS) $< -asghl=$(TOP)/util/delay.lst -o util/$@

led/blue-led.o: $(TOP)/led/blue-led.s
	$(AS) $(ASFLAGS) $< -asghl=$(TOP)/led/blue-led.lst -o util/$@

clean: 
	${RM} *.elf *.o *.elf.map *.lst *.hex *.map

.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
