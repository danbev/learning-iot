AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g 

OBJS=led.o 

led.elf : led.o
	$(LD) $< -T linker_script.ld --cref -Map gpio.map -nostartfiles -o main.elf
	objcopy -O ihex main.elf main.hex

led.o: led.s
	$(AS) $(ASFLAGS) $< -asghl=led.lst -o $@

led_bsrr.elf : led_bsrr.o
	$(LD) $< -T linker_script.ld --cref -Map gpio.map -nostartfiles -o led_bsrr_main.elf
	objcopy -O ihex led_bsrr_main.elf led_bsrr_main.hex

led_bsrr.o: led_bsrr.s
	$(AS) $(ASFLAGS) $< -asghl=led_bsrr.lst -o $@

led_button.elf : led_button.o
	$(LD) $< -T linker_script.ld --cref -Map gpio.map -nostartfiles -o led_button_main.elf
	objcopy -O ihex led_button_main.elf led_button_main.hex

led_button.o: led_button.s
	$(AS) $(ASFLAGS) $< -asghl=led_button.lst -o $@

uart.elf : uart.o
	$(LD) $< -T linker_script.ld --cref -Map gpio.map -nostartfiles -o uart_main.elf
	objcopy -O ihex uart_main.elf uart_main.hex

uart.o: uart.s
	$(AS) $(ASFLAGS) $< -asghl=uart.lst -o $@

clean: 
	${RM} $(OBJS) led.elf 

.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
