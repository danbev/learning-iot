
include ../Makefile


# CAN loopback example (no external transceiver required).
can-loopback.elf : can-loopback.o ../can.o ../delay.o ../blue-led.o ../uart-tx.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex
