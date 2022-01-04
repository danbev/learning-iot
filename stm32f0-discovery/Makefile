AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m0 -mthumb -g 

pull-up.elf : pull-up.o uart-tx.o delay.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

pull-up.o: pull-up.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

%.elf : %.o blue-led.o delay.o
	$(LD) -T linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

%.o: %.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

clean: 
	${RM} *.elf *.o *.elf.map *.lst *.hex *.map

.PHONY openocd:
openocd:
	openocd -f board/stm32f0discovery.cfg
