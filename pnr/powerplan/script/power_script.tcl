# ========================================================== #
#                    Variable Setup                         #
# ========================================================== #
set design      "css_phy_tx_top"

set prev_stage    "floorplan"
set current_stage "powerplan"

# ========================================================== #
#                     dlib Setup                             #
# ========================================================== #

open_block ../../design_lib/dlib/${design}.dlib:${design}_${prev_stage}.design

copy_block -from_block ${design}_${prev_stage}.design -to_block ${design}_${current_stage}.design

current_block ${design}_${current_stage}.design

# ========================================================== #
#                    Initialization                          #
# ========================================================== #

remove_pg_via_master_rules -all
remove_pg_patterns       -all
remove_pg_strategies     -all
remove_pg_strategy       -all


# ========================================================== #
#                 Creation of VDD/VSS nets                   #
# ========================================================== #

create_net -power  VDD
create_net -ground VSS


# ========================================================== #
#                    Ring VDD/VSS                            #
#       Create region, pattern, strategy and compile        #
# ========================================================== #


set ring_offset   1
set ring_width    3
set ring_spacing  4
set hm_top        M9
set vm_top        M8
set name_stratege core_ring


create_pg_region power_ring_region -core -expand_by_edge \
    "{{side: 1} {offset: $ring_offset}} {{side: 2} {offset: $ring_offset}} {{side: 3} {offset: $ring_offset}} {{side: 4} {offset: $ring_offset}}"


create_pg_ring_pattern ring_pattern \
    -horizontal_layer   $hm_top \
    -vertical_layer     $vm_top \
    -horizontal_width   $ring_width \
    -vertical_width     $ring_width \
    -horizontal_spacing $ring_spacing \
    -vertical_spacing   $ring_spacing


set_pg_strategy $name_stratege \
    -pg_regions {power_ring_region} \
    -pattern {{name: ring_pattern} {nets: "VDD VSS"}}


compile_pg -strategies $name_stratege

# ========================================================== #
#                    Straps VDD/VSS                          #
# ========================================================== #

create_pg_mesh_pattern straps_vddvss -layers {
    {{vertical_layer: M8}   {width: 3} {pitch: 20} {spacing: interleaving} {offset: 1}}
    {{horizontal_layer: M9} {width: 3} {pitch: 20} {spacing: interleaving} {offset: 1}}
}


set_pg_strategy mesh_vddvss -core \
    -pattern {{pattern: straps_vddvss} {nets: "VDD VSS"}} \
    -extension {{stop: design_boundary_and_generate_pin}}

compile_pg -strategies mesh_vddvss

# ========================================================== #
#                    Rails VDD/VSS                           #
# ========================================================== #

# ---- Variables
set rail_startegie rails_M1
set rail_pattern   std_cell_rail
set rail_layer     M1
set rail_width     0.16


create_pg_std_cell_conn_pattern $rail_pattern \
    -layers $rail_layer \
    -rail_width $rail_width

set_pg_strategy $rail_startegie -core \
    -pattern {{name: std_cell_rail} {nets: "VDD VSS"}}

compile_pg -strategies $rail_startegie


connect_pg_net -net VDD [get_pins -hierarchical */VDD]
connect_pg_net -net VSS [get_pins -hierarchical */VSS]


# ========================================================== #
#             Verify PG routing / connectivity               #
# ========================================================== #

check_pg_drc

check_pg_connectivity

check_pg_missing_vias


# ========================================================== #
#                         Reports                            #
# ========================================================== #
sh rm -rf ../results
file mkdir ../results/reports
file mkdir ../results/outputs

check_pg_drc \
    > ../results/reports/pg_drc.rpt

check_pg_connectivity \
    > ../results/reports/pg_connectivity.rpt

check_pg_missing_vias \
    > ../results/reports/missing_via.rpt


# ========================================================== #
#                       Save Block                           #
# ========================================================== #

save_block

write_def ../results/outputs/${design}.def

write_verilog -include {all} ../results/outputs/${design}.v


# ========================================================== #
#                         DONE                               #
# ========================================================== #

puts "=========================================================="
puts " Power Planning completed successfully for ${design}"
puts " Reports : ../results/reports/"
puts " Outputs : ../results/outputs/"
puts "=========================================================="

start_gui

