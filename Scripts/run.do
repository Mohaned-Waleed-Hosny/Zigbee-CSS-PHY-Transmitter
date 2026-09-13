# modelsim
# do ../Scripts/run.do
# vsim -do ../Scripts/run.do

vlib work
vlog ../RTL/*.v
vlog ../testbenches/*.v
vsim work.tb_csk_waveform_selector
add wave *
run -all