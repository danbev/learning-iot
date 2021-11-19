AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g 

%.elf : %.o
	$(LD) $< -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@
	objcopy -O ihex $@ $@.hex

%.o: %.s
	$(AS) $(ASFLAGS) $< -asghl=led.lst -o $@

clean: 
	${RM} *.elf *.o *.elf.map *.lst *.hex *.map

.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
