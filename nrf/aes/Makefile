include ../Makefile

VPATH = ../led

rand.elf : rand.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

aes-ccm.elf : aes-ccm.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex
