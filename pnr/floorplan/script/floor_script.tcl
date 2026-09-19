set design "css_phy_tx_top"

# --- stages
set prev_stage "dlib"
set current_stage "floorplan"

# ============================================================ #
# ==================== dlib Setup ============================ #
# ============================================================ #

open_block ../../design_lib/dlib/${design}.dlib:${design}.design
copy_block -from_block ${design}.dlib:${design}.design -to_block ${design}_${current_stage}.design
current_block ${design}_${current_stage}.design

# ============================================================ #
# ==================== Layers Setup ========================== #
# ============================================================ #

# -- Metal Layers Directions
set_attribute [get_layers {M1 M3 M5 M7 M9}] routing_direction horizontal
set_attribute [get_layers {M2 M4 M6 M8 MRDL}] routing_direction vertical

# -- site def attribute
set Name_unit [get_site_defs]
set_attribute $Name_unit is_default true

# --- Access flipping symmetry to access power and ground rails from both sides of the cell
set_attribute $Name_unit symmetry {Y}

# ============================================================ #
# ================= Initialize Floorplan ===================== #
# ============================================================ #
# --- All parameters related to core and die

initialize_floorplan -control_type core \
                     -core_utilization 0.6 \
                     -shape R \
                     -core_offset {10} \
                     -flip_first_row true \
                     -side_ratio {1 1}

# ============================================================ #
# ==================== Placement Pins ======================== #
# ============================================================ #
# --- Auto Placement Pins

place_pins -self -ports [get_ports *]

# ============================================================ #
# ==================== Handle Files ========================== #
# ============================================================ #

sh rm -rf ../results
sh mkdir -p ../results/reports
sh mkdir -p ../results/outputs

# ============================================================ #
# ======================== Reports =========================== #
# ============================================================ #

report_qor \
    > ../results/reports/qor.rpt

report_utilization \
    > ../results/reports/utilization_default.rpt

get_placement_blockages \
    > ../results/reports/Blockage.rpt

# ============================================================ #
# ======================= Save Block ========================= #
# ============================================================ #

save_block -as ${design}_${current_stage} ${design}.dlib:${design}_${current_stage}.design

start_gui
