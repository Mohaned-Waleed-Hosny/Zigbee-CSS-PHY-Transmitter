# modelsim
# do ../Scripts/run.do
# vsim -do ../Scripts/run.do

vlib work
vlog ../RTL/*.v ../testbenches/*.v
vsim work.tb_controller
add wave *
run -all