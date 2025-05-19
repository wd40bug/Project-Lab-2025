build/%: %_tb.v %.v
	iverilog -o $@ $^	

dump/%.vcd: build/%
	vvp $<

build/ultrasonic: ultrasonic.v ultrasonic_tb.v countdown.v
	iverilog -o $@ $^

FILE = $(DEBUG_FILE)
debug $(FILE): dump/$(FILE).vcd
	gtkwave $< -O /dev/null &
