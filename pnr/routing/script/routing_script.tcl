# ========================================================== #
#                    Variable Setup                         #
# ========================================================== #
set design      "css_phy_tx_top"

set prev_stage    "cts"
set current_stage "routing"

# ========================================================== #
#                     dlib Setup                             #
# ========================================================== #

open_block ../../design_lib/dlib/${design}.dlib:${design}_${prev_stage}.design

copy_block -from_block ${design}_${prev_stage}.design -to_block ${design}_${current_stage}.design

current_block ${design}_${current_stage}.design


#set_host_option -max_cores 16

# ========================================================== #
#                     Pre-Route Check                        #
# ========================================================== #

check_routability

# ========================================================== #
#                      Routing Layers                        #
# ========================================================== #

set_ignored_layer -max M9 -min M2

# ========================================================== #
#                        App Options                         #
# ========================================================== #

set_app_options -name opt.common.user_instance_name_prefix -value "ROUTE_"

# ========================================================== #
#                     Optimized Routing                      #
# ========================================================== #

route_auto

################### Solve Negative Slack ###################

set hold_paths [get_timing_paths -delay_type min -max_paths 10]

foreach_in_collection path $hold_paths {
    set current_slack [get_attribute $path slack]

    if {$current_slack < 0.0} {
        set end_point [get_attribute $path endpoint]
        set pin_name [get_attribute $end_point full_name]
        
        insert_buffer [get_pins $pin_name] saed90nm_max/NBUFFX2
    }
}
legalize_placement

route_eco


check_lvs -max_errors 0
check_pg_drc
check_pg_connectivity
check_legality

set dcap_fillers [get_lib_cell */DCAP*]

create_stdcell_fillers  -lib_cells $dcap_fillers \
		        -utilization 30 \
			-prefix "DECAP_" \
			-post_eco
		
connect_pg_net -net "VDD" [get_pins -hierarchical "*/VDD*"]
connect_pg_net -net "VSS" [get_pins -hierarchical "*/VSS*"]

connect_pg_net -automatic

remove_stdcell_fillers_with_violation

check_lvs -max_errors 0
check_pg_drc
check_pg_connectivity
check_legality

set_app_options -name place.legalize.enable_advanced_legalizer -value false


set std_fillers_128 "saed90nm_max/SHFILL128"
set std_fillers_64 "saed90nm_max/SHFILL64"
set std_fillers_3 "saed90nm_max/SHFILL3"
set std_fillers_2 "saed90nm_max/SHFILL2"
set std_fillers_1 "saed90nm_max/SHFILL1"

create_stdcell_fillers -lib_cells $std_fillers_128 \
			-prefix "FILLER128_" \
			-post_eco \
			-continue_on_error

create_stdcell_fillers -lib_cells $std_fillers_64 \
			-prefix "FILLER64_" \
			-post_eco \
			-continue_on_error


create_stdcell_fillers -lib_cells $std_fillers_3 \
			-prefix "FILLER3_" \
			-post_eco \
			-continue_on_error


create_stdcell_fillers -lib_cells $std_fillers_2 \
			-prefix "FILLER2_" \
			-post_eco \
			-continue_on_error


create_stdcell_fillers -lib_cells $std_fillers_1 \
			-prefix "FILLER1_" \
			-post_eco \
			-continue_on_error

connect_pg_net -net "VDD" [get_pins -hierarchical "*/VDD*"]
connect_pg_net -net "VSS" [get_pins -hierarchical "*/VSS*"]

route_eco

check_lvs -max_errors 0
check_pg_drc
check_routes
check_legality




##################### Outputs ######################

write_verilog "../results/${design}_post_route_netlist.v"
write_sdc -output "../results/${design}_post_route.sdc"
write_def "../results/${design}_post_route.def"

report_qor -summary > ../results/qor.rpt
check_lvs -max_errors 0 > ../results/lvs.rpt
check_pg_drc > ../results/pg_drc.rpt
check_routes > ../results/routes_drc.rpt
check_legality > ../results/legality.rpt
report_utilization > ../results/placement_utilization.rpt

save_block
