#################################### Defining Clock ####################################

set TIGHT_PER 600
set CLK_PER 1000

#using too tight clk to maximize optimization
create_clock -name "CLK" -period $TIGHT_PER [get_port clk]

set_clock_uncertainty 2 [get_clocks "CLK"]

set_clock_transition 2 [get_clocks "CLK"]

set_clock_latency 0 [get_clocks "CLK"]

set_dont_touch_network [get_clocks "CLK"]
set_dont_touch_network [get_port reset]

#################################### Defining Scan Clock ####################################

set SCAN_TIGHT_PER 250
set SCAN_CLK_PER 1000

create_clock -name "SCAN_CLK" -period $SCAN_TIGHT_PER [get_port scan_clk]

set_clock_uncertainty 2 [get_clocks "SCAN_CLK"]

set_clock_transition 2 [get_clocks "SCAN_CLK"]

set_clock_latency 0 [get_clocks "SCAN_CLK"]

set_dont_touch_network [get_clocks "SCAN_CLK"]
set_dont_touch_network [get_port "scan_rst"]

#################################### Clock Relations ####################################

set_clock_groups -logically_exclusive -group [get_clocks "CLK"] \
				      -group [get_clocks "SCAN_CLK"]

#################################### Test Mode Value ####################################

#set_case_analysis 0 [get_port test_mode]

#################################### In/Out Delays ####################################

# 30% of clk period
set input_delay [expr 0.3 * $CLK_PER]
set output_delay [expr 0.3 * $CLK_PER]

set_input_delay $input_delay -clock [get_clocks "CLK"] [remove_from_collection [all_inputs] [get_ports {clk reset SI SE test_mode scan_clk scan_rst}]]
set_output_delay $output_delay -clock [get_clocks "CLK"] [remove_from_collection [all_outputs] [get_port SO] ]

#################################### Driving Cell ####################################

set_driving_cell -library "saed90nm_max" -lib_cell IBUFFX2 [remove_from_collection [all_inputs] [get_ports {clk reset SI SE test_mode scan_clk scan_rst}]]

set_max_fanout 16 [current_design]
set_ideal_network [get_ports SE]


