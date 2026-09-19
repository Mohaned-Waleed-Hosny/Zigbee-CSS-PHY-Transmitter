#################################### Defining Clock ####################################

set TIGHT_PER 5
set CLK_PER 50

#using too tight clk to maximize optimization
create_clock -name "CLK" -period $TIGHT_PER [get_port clk]

set_clock_uncertainty 1 [get_clocks "CLK"]

set_clock_transition 0.1 [get_clocks "CLK"]

set_clock_latency 0 [get_clocks "CLK"]

set_dont_touch_network [get_clocks "CLK"]

set_ideal_network [get_ports {clk reset}]

#################################### In/Out Delays ####################################

# 10% of clk period
set input_delay [expr 0.1 * $CLK_PER]
set output_delay [expr 0.1 * $CLK_PER]

set_input_delay $input_delay -clock [get_clocks "CLK"] [remove_from_collection [all_inputs] [get_ports {clk reset}]]
set_output_delay $output_delay -clock [get_clocks "CLK"] [all_outputs]

set_load 1 [all_outputs]

#################################### Max Values ####################################

set_max_transition 1.024 [current_design]

#################################### Driving Cell ####################################

set_driving_cell -library "saed90nm_max" -lib_cell IBUFFX2 [remove_from_collection [all_inputs] [get_port clk]]

#################################### Wire Model ####################################

set_wire_load_model -library saed90nm_max -name ForQA
current_design form_ppdu

set_wire_load_model -library saed90nm_max -name ForQA
current_design controller

set_wire_load_model -library saed90nm_max -name ForQA
current_design $design





