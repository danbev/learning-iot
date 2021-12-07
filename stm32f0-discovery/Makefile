AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g 

uart-tx-sync.elf : uart-tx-sync.o uart-tx.o delay.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $< uart-tx.o delay.o
	objcopy -O ihex $@ $@.hex

uart-tx.o: uart-tx.s
	$(AS) $(ASFLAGS) $< -asghl=led.lst -o $@

i2c.elf : i2c.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $<
	objcopy -O ihex $@ $@.hex

i2c.o: i2c.s
	$(AS) $(ASFLAGS) $< -asghl=led.lst -o $@

# I2C Peripheral, uses UART to write received data. 
i2c-p.elf : i2c-p.o i2c.o uart-tx.o delay.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $< i2c.o delay.o uart-tx.o
	objcopy -O ihex $@ $@.hex

i2c-p.o: i2c-p.s
	$(AS) $(ASFLAGS) $< -asghl=led.lst -o $@

# I2C Controller that writes data to the peripheral (does not use UART).
i2c-c.elf : i2c.o i2c-c.o delay.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $< i2c-c.o delay.o
	objcopy -O ihex $@ $@.hex

i2c-c.o: i2c-c.s
	$(AS) $(ASFLAGS) $< -asghl=led.lst -o $@


%.elf : %.o blue-led.o delay.o
	$(LD) $< -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ blue-led.o delay.o
	objcopy -O ihex $@ $@.hex

%.o: %.s
	$(AS) $(ASFLAGS) $< -asghl=led.lst -o $@

clean: 
	${RM} *.elf *.o *.elf.map *.lst *.hex *.map

.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
