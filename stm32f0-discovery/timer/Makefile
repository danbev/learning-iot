include ../Makefile

VPATH = ../led

systick.elf : systick.o blue-led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -o $@ $^
	objcopy -O ihex $@ $@.hex

systickint.elf : systickint.o blue-led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -o $@ $^
	objcopy -O ihex $@ $@.hex
