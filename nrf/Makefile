AS=arm-none-eabi-as
LD=arm-none-eabi-ld
ASFLAGS=-mcpu=cortex-m4 -mthumb -g

%.o: %.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@

clean:
	${RM} *.elf *.o *.elf.map *.lst *.hex *.map

.PHONY openocd:
openocd:
	openocd -f interface/cmsis-dap.cfg -f target/nrf52.cfg

.PHONY openocd_jlink:
openocd_jlink: 
	openocd -c 'interface jlink; transport select swd; source [find target/nrf52.cfg]'
