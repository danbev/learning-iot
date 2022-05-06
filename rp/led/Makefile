include ../Makefile

led-ext.elf : led-ext.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -o $@ $^
	objcopy -O ihex $@ $@.hex
	../elf2uf2 $@ $@.uf2
