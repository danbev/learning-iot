
# Synthesis
first.json: first.v
	yosys -ql first.log -p 'synth_ice40 -top first -json $@' $<

# Place And Route
first.asc: first.json
	# packate refers to the Lattice iCE40HX8K chip package which can be
	# found on the Lattice chip on the board.
	nextpnr-ice40 --hx8k --package ct256 --json $< --pcf first.pcf --asc $@ -v --debug

# Create bitstream from P&R output
first.bin: first.asc
	icepack $< $@

.PHONY first_flash:
first_flash:
	iceprog -v -d d:001/017 -r first.bin

.PHONY first_pad:
first_pad: first.bin
	# 377 octal is 255 decimal, which is 0xFF in hex, so we are generating
	# a file of size 2M (all zeros) and then converting these zeros into
	# 0xFF.
	dd if=/dev/zero bs=2M count=1 | tr '\0' '\377' > first_padded.bin
	# We now take our binary file and write it on top of the padded file.
	dd if=first.bin conv=notrunc of=first_padded.bin

.PHONY first_flash_rom:
first_flash_rom: first_pad
	flashrom -p buspirate_spi:dev=/dev/ttyUSB0,spispeed=1M -w first_padded.bin
	#flashrom -p buspirate_spi:dev=/dev/ttyUSB0,spispeed=250k,serialspeed=115200 -w first.bin

.PHONY blinky_pad:
blinky_pad:
	dd if=/dev/zero bs=2M count=1 | tr '\0' '\377' > blinky.bin
	dd if=blinky.bin conv=notrunc of=blinky.bin

.PHONY blinky_flash_rom:
blinky_flash_rom:
	flashrom -p buspirate_spi:dev=/dev/ttyUSB0,spispeed=1M -w blinky.bin -V

.PHONY clean:

clean:
	${RM} *.blif *.json *.asc *.log first.bin
