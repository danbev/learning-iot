include ../Makefile

led-ext.elf : uart-tx-sync.o uart-tx.o delay.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex
