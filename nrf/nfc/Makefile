include ../Makefile

VPATH = ../led

nfc.elf : nfc.o led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex
