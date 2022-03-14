
first.json: first.v
	yosys -ql first.log -p 'synth_ice40 -top first -json $@' $<

first.asc: first.json
	nextpnr-ice40 --hx8k --package ct256 --json first.json --pcf first.pcf --asc first.asc -v --debug

.PHONY clean:

clean:
	${RM} *.blif *.json *.asc, *.log
