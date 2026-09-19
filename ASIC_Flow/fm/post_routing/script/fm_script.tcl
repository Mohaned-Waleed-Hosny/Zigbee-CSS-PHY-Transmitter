set design css_phy_tx_top

############################# Options ############################# 

set synopsys_auto_setup true

########################### Ref Container ###########################

read_verilog -netlist -container Ref "../../../syn/results/outputs/${design}_syn_netlist.v"

read_db -container Ref "../../../std_cells/saed90nm_max.db"

set_reference_design "css_phy_tx_top"
set_top "css_phy_tx_top"

########################### Imp Container ###########################

read_verilog -netlist -container Imp "../../../pnr/routing/results/${design}_post_route_netlist.v"

read_db -container Imp "../../../std_cells/saed90nm_max.db"

set_implementation_design "css_phy_tx_top"
set_top "css_phy_tx_top"


set_dont_verify_points -type port Ref:/WORK/*/SI
set_dont_verify_points -type port Imp:/WORK/*/SI

set_dont_verify_points -type port Ref:/WORK/*/SO
set_dont_verify_points -type port Imp:/WORK/*/SO

set_constant Ref:/WORK/*/test_mode 0
set_constant Imp:/WORK/*/test_mode 0

set_constant Ref:/WORK/*/SE 0
set_constant Imp:/WORK/*/SE 0

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
