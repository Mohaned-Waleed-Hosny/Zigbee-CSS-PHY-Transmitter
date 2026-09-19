#################################### Generic Vars ####################################

set library "saed90nm_max.db"
set design "css_phy_tx_top"

#################################### Open SVF File ####################################

set_svf "../results/outputs/${design}_syn.svf"

##################### Define Working Library Directory ######################
                                                   
define_design_lib work -path ./work

#################################### Set DC Variables ####################################

lappend search_path "../../std_cells"
lappend search_path "../../project/RTL"
set target_library "saed90nm_max.db"
set link_library [list "*" "saed90nm_max.db"]

#################################### Reading RTL Files ####################################
puts "###############################################"
puts "############## Reading RTL Files ##############"
puts "###############################################"

set file_format "verilog"

read_file -format $file_format [glob ../../project/RTL/*.v]

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

source -e -v "../cons/cons.tcl"

#################### Compile #########################

compile -map_effort high

#using real dedicated clk
create_clock -name "CLK" -period $CLK_PER [get_port clk]

update_timing

#################### Outputs #########################

write_file -format verilog -hierarchy -output ../results/outputs/${design}_syn_netlist.v
write_file -format ddc -hierarchy -output ../results/outputs/${design}_syn.ddc
write_sdc ../results/outputs/${design}.sdc

#################### Reports #########################

report_clock -attributes > ../results/reports/clock.rpt
report_timing -max_paths 10 -delay_type max -sort_by slack > ../results/reports/setup_syn.rpt
report_timing -max_paths 10 -delay_type min -sort_by slack > ../results/reports/hold_syn.rpt
report_area -hierarchy > ../results/reports/area.rpt
report_power -hierarchy > ../results/reports/power.rpt
report_constraint -all_violators > ../results/reports/constraint.rpt

#################################### Close SVF File ####################################

set_svf -off

#gui_start
#exit



