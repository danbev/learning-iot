
first.blif: first.v
	yosys -p "read_verilog $<; synth_ice40 -blif $@"

.PHONY clean:

clean:
	${RM} *.blif
