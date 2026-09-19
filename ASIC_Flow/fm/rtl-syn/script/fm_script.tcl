set design css_phy_tx_top
############################# Options ############################# 

set synopsys_auto_setup true

########################### SVF File ###########################

set_svf "../../../syn/results/outputs/css_phy_tx_top_syn.svf"

########################### Ref Container ###########################

read_verilog -container Ref [glob ../../../project/RTL/*.v]

read_db -container Ref "../../../std_cells/saed90nm_max.db"

set_reference_design "css_phy_tx_top"
set_top "css_phy_tx_top"

########################### Imp Container ###########################

read_verilog -netlist -container Imp "../../../syn/results/outputs/${design}_syn_netlist.v"

read_db -container Imp "../../../std_cells/saed90nm_max.db"

set_implementation_design "css_phy_tx_top"
set_top "css_phy_tx_top"

############################# Match ############################# 

match

############################# Verify ############################# 

set successful [verify]
if {!$successful} {
diagnose
analyze_points -failing
}

############################# Reports ############################# 

report_passing_points > ../results/passing_points.rpt
report_failing_points > ../results/failing_points.rpt
report_unverified_points > ../results/unverified_points.rpt
report_aborted_points > ../results/aborted_points.rpt

start_gui

#exit
