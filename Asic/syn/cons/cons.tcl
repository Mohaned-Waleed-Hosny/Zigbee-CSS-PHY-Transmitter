#################################### Defining Clock ####################################

set TIGHT_PER 600
set CLK_PER 1000

#using too tight clk to maximize optimization
create_clock -name "CLK" -period $TIGHT_PER [get_port clk]

set_clock_uncertainty 2 [get_clocks "CLK"]

set_clock_transition 2 [get_clocks "CLK"]

set_clock_latency 0 [get_clocks "CLK"]

set_dont_touch_network [get_clocks "CLK"]

set_ideal_network [get_ports {clk scan_clk reset scan_rst test_mode}]

#################################### In/Out Delays ####################################

# 30% of clk period
set input_delay [expr 0.3 * $CLK_PER]
set output_delay [expr 0.3 * $CLK_PER]

set_input_delay $input_delay -clock [get_clocks "CLK"] [remove_from_collection [all_inputs] [get_port clk]]
set_output_delay $output_delay -clock [get_clocks "CLK"] [all_outputs]

#################################### Driving Cell ####################################

set_driving_cell -library "saed90nm_max" -lib_cell IBUFFX2 [remove_from_collection [all_inputs] [get_port clk]]

