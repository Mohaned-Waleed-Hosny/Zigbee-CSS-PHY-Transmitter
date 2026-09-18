##########################setup#########################

set design      "css_phy_tx_top"

set prev_stage    "placement"
set current_stage "cts"

########################open########################

open_block ../../design_lib/dlib/${design}.dlib:${design}_${prev_stage}.design

copy_block -from_block ${design}_${prev_stage}.design -to_block ${design}_${current_stage}.design

current_block ${design}_${current_stage}.design

##########################CTS#################################

set_host_option -max_cores 4

report_qor -summary       
report_clocks

set_ignored_layers -max_routing_layer M7 -min_routing_layer M2

set_lib_cell_purpose -exclude cts  [get_lib_cells */*]
set_lib_cell_purpose -exclude hold [get_lib_cells */*]
set_lib_cell_purpose -include cts {saed90nm_max/IBUFFX2 saed90nm_max/IBUFFX4 saed90nm_max/IBUFFX8 saed90nm_max/IBUFFX16}
set_lib_cell_purpose -include cts {saed90nm_max/NBUFFX2 saed90nm_max/NBUFFX4 saed90nm_max/NBUFFX8 saed90nm_max/NBUFFX16}
set_lib_cell_purpose -include cts {saed90nm_max/INVX2  saed90nm_max/INVX4 saed90nm_max/INVX8 saed90nm_max/INVX16}
set_lib_cell_purpose -include hold  [get_lib_cells */*DELLN*]



create_routing_rule clk_network_NDR_root     -multiplier_spacing 2 -multiplier_width 2
create_routing_rule clk_network_NDR_internal -multiplier_spacing 2 -multiplier_width 2
set_clock_routing_rules -net_type root -clocks {CLK SCAN_CLK} -rules clk_network_NDR_root -max_routing_layer M7 -min_routing_layer M5
set_clock_routing_rules -net_type internal -clocks {CLK SCAN_CLK} -rules clk_network_NDR_internal -max_routing_layer M5 -min_routing_layer M3
set_clock_routing_rules -net_type sink -clocks {CLK SCAN_CLK} -default_rule  -max_routing_layer M3 -min_routing_layer M1

report_ideal_network

remove_ideal_network -all
remove_clock_latency     [all_clocks]
remove_propagated_clock [all_clocks]
remove_clock_tree_options -all -target_skew -target_latency

set_max_transition 1 -clock_path    [get_clocks {CLK SCAN_CLK}]
set_max_capacitance 100 -clock_path [get_clocks {CLK SCAN_CLK}] 

set_clock_tree_options -target_skew 0.1 -clocks {CLK SCAN_CLK}
set_clock_tree_options -target_latency 0.0 -clocks {CLK SCAN_CLK}

report_clock_settings
report_clock_tree_options 
######################3
set_app_options -list {time.enable_si_timing_windows {true}}
set_app_options -list {time.si_enable_analysis      {true}}
set_app_options -name time.disable_recovery_removal_checks -value false
set_app_options -name time.remove_clock_reconvergence_pessimism -value true
set_app_options -list {cts.common.max_fanout      {5}}
set_app_options -list {cts.compile.enable_global_route true}
set_app_options -name cts.compile.remove_existing_clock_trees -value true
set_app_options -list {clock_opt.hold.effort      {high}}
set_app_options -name clock_opt.flow.optimize_ndr -value true
set_app_options -name clock_opt.flow.enable_clock_power_recovery -value area
set_app_options -list {clock_opt.flow.enable_ccd      {true}}
set_app_options -name ccd.hold_control_effort -value high
set_app_options -list {cts.common.max_net_length      {100}}
set_app_options -name cts.common.user_instance_name_prefix -value "CTS_"
set_app_options -name opt.common.user_instance_name_prefix -value "OPT_"

#########################3
clock_opt -from  build_clock -to build_clock
clock_opt -from  route_clock -to route_clock
clock_opt -from final_opto  -to final_opto

sizeof_collection [get_cells -hierarchical  "CTS_*"]
sizeof_collection [get_cells -hierarchical  "OPT_*"]

report_qor -summary


connect_pg_net -net "VDD" [get_pins -hierarchical */VDD]
connect_pg_net -net "VSS" [get_pins -hierarchical */VSS]

check_pg_drc            
check_pg_connectivity  
check_pg_missing_vias   
check_routes -drc true

########################handel################################

sh rm -rf ../results/worst
sh mkdir -p ../results/worst
sh mkdir -p ../results/worst/reports
sh mkdir -p ../results/worst/outputs

###############################reports#####################

report_timing -delay_type max  -max_paths 10                    > ../results/worst/reports/setup.rpt
report_timing -delay_type min  -max_paths 10                    > ../results/worst/reports/hold.rpt
report_constraint -all_violators                                > ../results/worst/reports/constraints_violated.rpt
report_qor                                                      > ../results/worst/reports/syn_qor.rpt
report_clock_qor -type structure                                > ../results/worst/reports/clock_qor.rpt


write_def                        ../results/worst/outputs/${design}_${current_stage}.def
write_verilog     -include {all} ../results/worst/outputs/${design}_${current_stage}.v
write_sdc         -output     ../results/worst/outputs/${design}_${current_stage}.sdc


##################save####################################

save_block -as ${design}_${current_stage} ${design}.dlib:${design}_${current_stage}.design

#open_block ${dlib_dir}/${design}.dlib:${design}_${current_stage}.design
