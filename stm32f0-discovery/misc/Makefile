include ../Makefile

pull-up.elf : pull-up.o uart-tx.o delay.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

pull-up.o: pull-up.s
	$(AS) $(ASFLAGS) $< -asghl=$*.lst -o $@
