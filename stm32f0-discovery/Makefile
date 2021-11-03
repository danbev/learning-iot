AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g 

OBJS=led.o 

led.elf : led.o
	$(LD) $< -T linker_script.ld --cref -Map gpio.map -nostartfiles -o main.elf
	objcopy -O ihex main.elf main.hex

led.o: led.s
	$(AS) $(ASFLAGS) $< -asghl=led.lst -o $@

clean: 
	${RM} $(OBJS) led.elf 

.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
