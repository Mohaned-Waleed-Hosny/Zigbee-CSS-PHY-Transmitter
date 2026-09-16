transcript on

# ============================================================
# Clean and create work library
# ============================================================

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work


# ============================================================
# Compile RTL
# ============================================================

vlog ../new_controller.v
vlog ../zero_padding.v
vlog ../demux_iq.v
vlog ../symbol_mapper.v
vlog ../bit_interleaver.v
vlog ../form_ppdu.v
vlog ../qpsk_mapper.v
vlog ../dqpsk_encoder.v

vlog ../csk_sequencer.v
vlog ../csk_waveform_selector.v
vlog ../csk_waveform_rom.v
vlog ../dqpsk_csk_multiplier.v

vlog ../css_phy_tx_top.v


# ============================================================
# Compile MATLAB Golden Testbench
# ============================================================

vlog matlab_golden_tb.v


# ============================================================
# Run MATLAB Golden Testbench
# ============================================================

echo ""
echo "============================================================"
echo "        RUNNING MATLAB GOLDEN REGRESSION"
echo "============================================================"
echo ""

vsim -c work.matlab_golden_tb

run -all

quit -sim


vlog matlab_stage_debug_tb.v
vsim -c work.matlab_stage_debug_tb
run -all



