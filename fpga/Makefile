PROGRAMMER = buspirate_spi:dev=/dev/buspirate,spispeed=2M

# Synthesis
led.json: src/led.v
	yosys -ql $(basename $@).log -p 'synth_ice40 -top led -json $@' $<

led_no_bounce.json: src/led_no_bounce.v src/debounce.v
	yosys -ql $(basename $@).log -p 'synth_ice40 -top led -json $@' $^

blink.json: src/blink.v
	yosys -ql $(basename $@).log -p 'synth_ice40 -top blink -json $@' $^

# Place And Route
%.asc: %.json
	@# package refers to the Lattice iCE40HX8K chip package which can be
	@# found on the Lattice chip on the board.
	nextpnr-ice40 --hx8k --package ct256 --json $< --pcf src/$(*F).pcf --asc $@ -v --debug

# Create bitstream from P&R output
%.bin: %.asc
	icepack $< $@

define pad
@# 377 octal is 255 decimal, which is 0xFF in hex, so we are generating
@# a file of size 2M (all zeros) and then converting these zeros into
@# 0xFF.
@dd if=/dev/zero bs=2M count=1 | tr '\0' '\377' > $1_padded.bin
@# We now take our binary file and write it on top of the padded file.
@dd if=$1.bin conv=notrunc of=$1_padded.bin
@echo "Generated $1_padded.bin"
endef

.PHONY led_pad:
led_pad: led.bin
	@$(call pad,$(basename $(<)))

.PHONY led_no_bounce_pad:
led_no_bounce_pad: led_no_bounce.bin
	@$(call pad,$(basename $(<)))

.PHONY blink_pad:
blink_pad: blink.bin
	@$(call pad,$(basename $(<)))

.PHONY led_flash_rom:
led_flash_rom: led_pad
	flashrom -p $(PROGRAMMER) -w led_padded.bin

.PHONY led_no_bounce_flash_rom:
led_no_bounce_flash_rom: led_no_bounce_pad
	flashrom -p $(PROGRAMMER) -w led_no_bounce_padded.bin -V

.PHONY blink_flash_rom:
blink_flash_rom: blink_pad
	flashrom -p $(PROGRAMMER) -w blink_padded.bin -V

.PHONY flash_name:
flash_name: 
	flashrom -p $(PROGRAMMER) --flash-name

.PHONY clean:

clean:
	${RM} *.blif *.json *.asc *.log *.bin
