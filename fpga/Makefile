
# Synthesis
led.json: led.v
	yosys -ql led.log -p 'synth_ice40 -top led -json $@' $<

led_no_bounce.json: led_no_bounce.v
	yosys -ql led.log -p 'synth_ice40 -top led -json $@' $< debounce.v

# Place And Route
%.asc: %.json
	@# package refers to the Lattice iCE40HX8K chip package which can be
	@# found on the Lattice chip on the board.
	nextpnr-ice40 --hx8k --package ct256 --json $< --pcf $(*F).pcf --asc $@ -v --debug

# Create bitstream from P&R output
%.bin: %.asc
	icepack $< $@

.PHONY led_flash:
led_flash:
	@# usb-devices command can be used to get the vendor:product used below.
	iceprog -v -d i:0403:6001 -r led.bin

.PHONY led_pad:
led_pad: led.bin
	@# 377 octal is 255 decimal, which is 0xFF in hex, so we are generating
	@# a file of size 2M (all zeros) and then converting these zeros into
	@# 0xFF.
	@dd if=/dev/zero bs=2M count=1 | tr '\0' '\377' > led_padded.bin
	@# We now take our binary file and write it on top of the padded file.
	@dd if=led.bin conv=notrunc of=led_padded.bin

.PHONY led_flash_rom:
led_flash_rom: led_pad
	flashrom -p buspirate_spi:dev=/dev/ttyUSB0,spispeed=1M -w led_padded.bin

.PHONY clean:

clean:
	${RM} *.blif *.json *.asc *.log led.bin
