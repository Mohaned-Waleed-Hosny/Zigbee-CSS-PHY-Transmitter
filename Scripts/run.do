# modelsim
# do ../Scripts/run.do
# vsim -do ../Scripts/run.do

vlib work
vlog ../RTL/*.v ../testbenches/*.v
vsim work.tb_part2
add wave *
run -all