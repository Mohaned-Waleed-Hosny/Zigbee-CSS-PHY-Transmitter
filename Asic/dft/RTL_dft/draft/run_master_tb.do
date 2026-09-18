vdel -all
vlib work
vmap work work

vlog -sv dqpsk_encoder.v qpsk_mapper.v form_ppdu.v new_controller.v zero_padding.v csk_waveform_selector.v dqpsk_csk_multiplier.v symbol_mapper.v csk_sequencer.v csk_waveform_rom.v demux_iq.v bit_interleaver.v css_phy_tx_top.v master_tb_css_phy_tx_top.v

vsim -voptargs=+acc work.master_tb_css_phy_tx_top

add wave -r sim:/master_tb_css_phy_tx_top/*

run -all