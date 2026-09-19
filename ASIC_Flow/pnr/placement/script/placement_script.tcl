
# ============================================================
# Variable Setup
# ============================================================
set design      "css_phy_tx_top"

# Stage
set prev_stage    "powerplan"
set current_stage "placement"

# ============================================================
# Design Library Setup
# ============================================================
open_block ../../design_lib/dlib/${design}.dlib:${design}_${prev_stage}.design

copy_block -from_block ${design}_${prev_stage}.design -to_block ${design}_${current_stage}.design

current_block ${design}_${current_stage}.design

# ============================================================
# Important Checks
# ============================================================

check_pg_connectivity -check_std_cell_pins none

check_pg_drc -ignore_std_cells

check_pg_missing_vias

check_legality -verbose

check_design -checks pre_placement_stage

# ============================================================
# Placement Global Settings
# ============================================================

set_app_options -name place.legalize.legalizer_search_and_repair \
                -value true

set_app_options -name place.coarse.auto_density_control \
                -value true

set_app_options -name place.coarse.auto_timing_control \
                -value true

set_app_options -name place.coarse.legalizer_driven_placement \
                -value true

set_app_options -list {place.coarse.continue_on_missing_scandef {true}}

set_app_options -list {place.coarse.detect_detours {true}}

# ============================================================
# Optimization Options
# ============================================================

set_app_options -list {opt.tie_cell.max_fanout 1}
set_app_options -list {opt.common.max_fanout {10}}

set_app_options -list {opt.timing.effort {high}}

set_app_options -list {place_opt.congestion.effort {high}}

set_app_options -name opt.common.user_instance_name_prefix \
                -value "PLACE_"

# ============================================================
# Ideal Network
# ============================================================

report_ideal_network

remove_ideal_network {reset}

report_ideal_network

# ============================================================
# Detailed Placement
# ============================================================

create_placement -effort high \
                 -timing_driven \
                 -congestion \
                 -congestion_effort high

legalize_placement -incremental

report_net_fanout -threshold 20

# ============================================================
# TIE Cell Attributes
# ============================================================

report_attributes -nosplit [get_lib_cells */TIEH] > ../results/TIEH_attr.rpt

set_attribute [get_lib_cells */TIEH*] dont_touch false
set_attribute [get_lib_cells */TIEL*] dont_touch false

set_attribute [get_lib_cells */TIEL*] dont_use false
set_attribute [get_lib_cells */TIEH*] dont_use false

# ============================================================
# Placement Optimization
# ============================================================

place_opt

sizeof_collection [get_cells "PLACE_*"]

# ============================================================
# Spare Cells
# ============================================================

get_lib_cell */NAND*

add_spare_cells -num_cells {
    NAND2X1 4
    INVX1   4
    OR2X1   3
    SDFFX1  3
    MUX21X1 4
} \
-cell_name SpareCell \
-random_distribution \
-input_pin_connect_type tie_low

set spare_cells [get_cells "*SpareCell*"]

spread_spare_cells -cells $spare_cells

place_eco_cells -cells $spare_cells -legalize_only

# ============================================================
# TIE Cells
# ============================================================

set tie_cells_high [get_lib_cells */TIEH*]

set tie_cells_high $tie_cells_high
set_dont_touch $spare_cells

set tie_cells_low  [get_lib_cells */TIEL*]
set tie_cells_high [get_lib_cells */TIEH*]

set_attribute [get_lib_cells */TIEH*] dont_touch false

add_tie_cells -objects $spare_cells \
              -tie_low_lib_cells $tie_cells_low \
              -tie_high_lib_cells $tie_cells_high \
              -legalize

# ============================================================
# Connect Power/Ground
# ============================================================

connect_pg_net -net "VDD" [get_pins -hierarchical */VDD]
connect_pg_net -net "VSS" [get_pins -hierarchical */VSS]

# ============================================================
# Final Placement Checks
# ============================================================

check_legality -verbose
check_pg_connectivity -check_std_cell_pins none
check_pg_drc -ignore_std_cells

# ============================================================
# Reports
# ============================================================

report_design > ../results/placement_design.rpt
report_utilization > ../results/placement_utilization.rpt
report_net_fanout -threshold 20 > ../results/placement_fanout.rpt

save_block
save_lib

puts "============================================================"
puts " Placement stage completed for ${design}"
puts " Block: ${design}_${current_stage}.design"
puts "============================================================"
