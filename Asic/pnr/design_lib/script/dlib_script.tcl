######################## Set Vars ########################

set tech_file "../../../std_cells/astroTechFile.tf"

set reference_library [glob ../../ndm/ndm/*.ndm]

set design "css_phy_tx_top"
set std_worst "saed90nm_max.db"

set target_library $std_worst

set link_library [list * $target_library]

######################## Creating Library ########################

sh rm -fr ../dlib
sh mkdir ../dlib

create_lib -technology $tech_file -ref_libs $reference_library ../dlib/${design}.dlib

######################## Reading Files ########################

read_verilog -top ${design} "../../../dft/results/outputs/${design}_dft_netlist.v"
link_block

read_sdc "../../../dft/results/outputs/${design}_dft.sdc"

read_parasitic_tech -layermap "../../../std_cells/tech2itf.map" \
-tlup "../../../std_cells/saed90nm_1p9m_1t_Cmax.tluplus" \
-name tlup_max

read_parasitic_tech -layermap "../../../std_cells/tech2itf.map" \
-tlup "../../../std_cells/saed90nm_1p9m_1t_Cmin.tluplus" \
-name tlup_min

set_parasitic_parameters -late_spec tlup_max -early_spec tlup_min

######################## Saving ########################

save_block -as ${design}.dlib:${design}.design


exit
