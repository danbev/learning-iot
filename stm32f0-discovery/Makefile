AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g 

OBJS=blinky.o 

gpio.elf : gpio.o
	$(LD) $< -T linker_script.ld --cref -Map gpio.map -nostartfiles -o main.elf
	objcopy -O ihex main.elf main.hex

gpio.o: gpio.s
	$(AS) $(ASFLAGS) $< -asghl=gpio.lst -o $@

clean: 
	${RM} $(OBJS) gpio.elf 

.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
