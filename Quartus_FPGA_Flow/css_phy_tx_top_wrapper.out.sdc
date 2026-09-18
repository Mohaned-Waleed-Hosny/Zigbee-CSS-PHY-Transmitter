## Generated SDC file "css_phy_tx_top_wrapper.out.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"

## DATE    "Thu Sep 17 05:56:41 2026"

##
## DEVICE  "5CSXFC6D6F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 33.333 -waveform { 0.000 16.666 } [get_ports {altera_reserved_tck}]
create_clock -name {clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}] -setup 0.310  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}] -hold 0.270  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}] -setup 0.310  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}] -hold 0.270  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}] -setup 0.310  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}] -hold 0.270  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}] -setup 0.310  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}] -hold 0.270  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_imag[0]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_imag[0]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_imag[1]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_imag[1]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_imag[2]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_imag[2]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_imag[3]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_imag[3]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_imag[4]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_imag[4]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_imag[5]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_imag[5]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_imag[6]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_imag[6]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_imag[7]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_imag[7]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_real[0]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_real[0]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_real[1]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_real[1]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_real[2]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_real[2]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_real[3]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_real[3]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_real[4]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_real[4]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_real[5]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_real[5]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_real[6]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_real[6]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {Tx_real[7]}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {Tx_real[7]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {busy}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {busy}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {done_Tx}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  -0.500 [get_ports {done_Tx}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {reset}] 
set_false_path -from [get_ports {start_Tx data_rate payload_wr_en payloadLength[*]}] 
set_false_path -from [get_ports {start_Tx reset payload_wr_en payloadLength[7] payloadLength[6] payloadLength[5] payloadLength[4] payloadLength[3] payloadLength[2] payloadLength[1] payloadLength[0] data_rate}] 


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

