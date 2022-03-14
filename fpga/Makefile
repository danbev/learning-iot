
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

.PHONY clean:

clean:
	${RM} *.blif *.json *.asc, *.log
