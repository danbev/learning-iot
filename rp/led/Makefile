include ../Makefile

led.elf : led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -o $@ $^
	${OBJCOPY} -O ihex $@ $@.hex
	@# Copy the object file into binary.
	${OBJCOPY} -O binary $< $^.bin
	@# Run pad_checksum on the binary file with will produce add the
	@# binary code to .byte entries, pad and then calculate a checksum
	@# outputting an assembly source file. This is done because part of the
	@# boot sequence will load 256 bytes from flash and check the checksum
	@# and if that check does not pass it will not boot into USB Mass
	@# Storage boot mode. If it passes the check, then execution will start
	@# at the beginning on those 256 bytes.
	${PAD_CHECKSUM} -s 0xffffffff $^.bin $^_padded.s
	@# Next assemble the assembly source file generated above.
	${AS} -g -o $^_padded.o $^_padded.s
	@# And link it specifying the start section.
	${LD} -o $@ --section-start .boot2=0x10000000 $^_padded.o
