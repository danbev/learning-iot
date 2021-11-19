AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g 

led.elf : led.o
	$(LD) $< -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@
	objcopy -O ihex $@ $@.hex

led.o: led.s
	$(AS) $(ASFLAGS) $< -asghl=led.lst -o $@

led_bsrr.elf : led_bsrr.o
	$(LD) $< -T linker_script.ld --cref -Map  $@.map -nostartfiles -o  $@
	objcopy -O ihex $@ $@.hex

led_bsrr.o: led_bsrr.s
	$(AS) $(ASFLAGS) $< -asghl=led_bsrr.lst -o $@

led_button.elf : led_button.o
	$(LD) $< -T linker_script.ld --cref -Map gpio.map -nostartfiles -o $@
	objcopy -O ihex $@ $@.hex

led_button.o: led_button.s
	$(AS) $(ASFLAGS) $< -asghl=led_button.lst -o $@

uart.elf : uart.o
	$(LD) $< -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@
	objcopy -O ihex $@ $@.hex

uart.o: uart.s
	$(AS) $(ASFLAGS) $< -asghl=uart.lst -o $@

clean: 
	${RM} *.elf *.o *.elf.map *.lst *.hex *.map

.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
