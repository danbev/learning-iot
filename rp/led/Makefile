include ../Makefile

led.elf : led.o
	$(LD) -T ../linker_script.ld --cref -Map $@.map -o $@ $^
	${OBJCOPY} -O ihex $@ $@.hex
	@# Copy the object file into binary.
	${OBJCOPY} -O binary led.o led.bin
	@# Run pad_checksum on the binary file with will produce a padded
	@#assembly file.
	${PAD_CHECKSUM} -s 0xffffffff led.bin led_padded.s
	@# Next assemble the source file.
	${AS} -o led_padded.o led_padded.s
	@# And link it specifying the start section.
	${LD} -o led.elf --section-start .boot2=0x10000000 led_padded.o
