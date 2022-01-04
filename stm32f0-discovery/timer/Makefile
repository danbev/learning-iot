include ../Makefile

VPATH = ../led

systick.elf : systick.o blue-led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex
