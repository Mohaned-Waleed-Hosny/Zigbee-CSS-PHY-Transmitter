# modelsim
# do ../Scripts/run.do
# vsim -do ../Scripts/run.do

vlib work
vlog ../RTL/*.v
vlog ../testbenches/*.v
vsim work.tb_dqpsk_csk_multiplier
add wave *
run -all