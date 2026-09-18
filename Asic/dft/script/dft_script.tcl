#################################### Generic Vars ####################################

set library "saed90nm_max.db"
set design "css_phy_tx_top"

#################################### Open SVF File ####################################

set_svf "../results/outputs/${design}_dft.svf"

##################### Define Working Library Directory ######################
                                                   
define_design_lib work -path ./work

#################################### Set DC Variables ####################################

lappend search_path "../../std_cells"
lappend search_path "../RTL_dft"
set target_library "saed90nm_max.db"
set link_library [list "*" "saed90nm_max.db"]

#################################### Reading RTL Files ####################################
puts "###############################################"
puts "############## Reading RTL Files ##############"
puts "###############################################"

set file_format "verilog"

#read_file -format $file_format [glob ../RTL_dft/*.v]
read_ddc ../../syn/results/outputs/${design}_syn.ddc

###################### Defining toplevel ###################################

current_design $design

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## Liniking All The Design Parts ########"
puts "###############################################"

link 

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## checking design consistency ##########"
puts "###############################################"

check_design

#################### Constraints File #########################
puts "###############################################"
puts "################## Compile ####################"
puts "###############################################"

source -e -v "../cons/dft_cons.tcl"

#################### DFT Config #########################

set_scan_configuration -clock_mixing no_mix -style multiplexed_flip_flop -max_length 1000 -replace true

#################### Compile #########################

compile -scan

###################### DFT Signals ########################
puts "###############################################"
puts "########## DFT Signals #############"
puts "###############################################"

set test_default_period 1000
set test_default_strobe 300

set_dft_signal -port [get_port scan_clk] -type ScanClock -view existing_dft -timing {500 1000}
set_dft_signal -port [get_port scan_rst] -type Reset -view existing_dft -active_state 1
set_dft_signal -port [get_port SI] -type ScanDataIn -view spec
set_dft_signal -port [get_port SO] -type ScanDataOut -view spec
set_dft_signal -port [get_port SE] -type ScanEnable -view spec -active_state 1
set_dft_signal -port [get_port test_mode] -type Constant -view existing_dft -active_state 1
set_dft_signal -port [get_port test_mode] -type TestMode -view spec -active_state 1

###################### Test Protocol ########################
puts "###############################################"
puts "########## Test Protocol #############"
puts "###############################################"

create_test_protocol

###################### Pre-DFT DRC ########################
puts "###############################################"
puts "########## Pre-DFT DRC #############"
puts "###############################################"

dft_drc -verbose

###################### Preview DFT ########################
puts "###############################################"
puts "########## Preview DFT #############"
puts "###############################################"

preview_dft -show scan_summary

###################### DFT Insertion ########################
puts "###############################################"
puts "########## DFT Insertion #############"
puts "###############################################"

insert_dft

###################### Optimization ########################
puts "###############################################"
puts "########## Post-DFT Optimizing #############"
puts "###############################################"

compile -scan -incremental

#using real dedicated clk
create_clock -name "CLK" -period $CLK_PER [get_port clk]
create_clock -name "SCAN_CLK" -period $CLK_PER [get_port scan_clk]

update_timing

###################### Post-DFT DRC ########################
puts "###############################################"
puts "########## Post-DFT DRC #############"
puts "###############################################"

dft_drc -verbose -coverage_estimate

#################### Outputs #########################

write_file -format verilog -hierarchy -output ../results/outputs/${design}_dft_netlist.v
write_file -format ddc -hierarchy -output ../results/outputs/${design}_dft.ddc
write_sdc ../results/outputs/${design}_dft.sdc

#################### Reports #########################

report_clock -attributes > ../results/reports/clock_dft.rpt
report_timing -max_paths 10 -delay_type max > ../results/reports/setup_dft.rpt
report_timing -max_paths 10 -delay_type min > ../results/reports/hold_dft.rpt
report_area -hierarchy > ../results/reports/area_dft.rpt
report_power -hierarchy > ../results/reports/power_dft.rpt
report_constraint -all_violators > ../results/reports/constraint_dft.rpt

#################################### Close SVF File ####################################

set_svf -off

#exit
