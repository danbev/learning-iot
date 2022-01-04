
include ../Makefile
VPATH = ../uart ../led ../timer

# CAN loopback example (no external transceiver required).
can-loopback.elf : can-loopback.o can.o delay.o blue-led.o uart-tx.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex
	
# CAN Controller which sends data to the CAN bus.
can-c.elf : can-c.o can.o delay.o blue-led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex

# CAN peripheral which is the receiver of CAN messages.
can-p.elf : can-p.o can.o delay.o blue-led.o uart-tx.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -nostartfiles -o $@ $^
	objcopy -O ihex $@ $@.hex
