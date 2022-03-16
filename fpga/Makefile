
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
	iceprog -v -d d:001/010 first.bin
	#iceprog -v -d d:001/122 -r /tmp/flash-content.bin

.PHONY first_pad:
first_pad:
	dd if=/dev/zero bs=2M count=1 | tr '\0' '\377' > first.bin
	dd if=first.bin conv=notrunc of=first.bin

.PHONY first_flash_rom:
first_flash_rom: 
	flashrom -p buspirate_spi:dev=/dev/ttyUSB0,spispeed=250k -w first.bin

.PHONY clean:

clean:
	${RM} *.blif *.json *.asc, *.log
