include ../Makefile

VPATH = ../led

systick.elf : systick.o led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex
