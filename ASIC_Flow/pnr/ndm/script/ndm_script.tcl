#################### Creating Workspace ####################

set tech_file "../../../std_cells/astroTechFile.tf"
create_workspace -flow exploration -technology $tech_file saed90_ndm

#################### Set Options ####################

set_app_options -list {lib.workspace.keep_all_physical_cells {true}}
set_app_options -list {lib.workspace.save_design_views {true}}
set_app_options -list {lib.workspace.save_layout_views {true}}

#################### Reading ####################

read_db "../../../std_cells/saed90nm_max.db"

read_lef "../../../std_cells/saed90nmEditted.lef"

#################### Grouping ####################

group_libs

#################### Generating Files ####################

sh rm -rf ../ndm
process_workspaces -directory "../ndm"

gui_start
#exit
