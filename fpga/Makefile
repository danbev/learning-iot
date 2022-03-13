
first.blif: first.v
	yosys -p "read_verilog $<; synth_ice40 -blif $@"

.PHONY pnr-first:
pnr-first:
	nextpnr-ice40 --hx8k --pcf first.pcf --read first.blif --asc first.asc --package ct256 -v

.PHONY clean:

clean:
	${RM} *.blif
