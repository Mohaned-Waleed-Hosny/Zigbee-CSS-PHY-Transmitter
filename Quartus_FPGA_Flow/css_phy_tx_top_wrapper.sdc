# ============================================================================
# SDC Timing Constraints File: css_phy_tx_top_wrapper.sdc
# Target Board: Terasic DE10-Standard (Cyclone V 5CSXFC6D6F31C6N)
# System Clock: 50 MHz (20 ns Period)
# ============================================================================

# 1. Define Primary Clock (50 MHz Oscillator)
create_clock -name {clk} -period 20.000 -waveform {0.000 10.000} [get_ports {clk}]

# 2. Cut Timing Paths for Asynchronous Reset
set_false_path -from [get_ports {reset altera_reserved_tdi altera_reserved_tms}]
set_false_path -from [get_ports {start_Tx data_rate payload_wr_en payloadLength[*]}]
set_false_path -to [get_ports {altera_reserved_tdo}]
# 3. Physical Input Ports Delays
set_input_delay -clock {clk} -max 3.000 [get_ports {payload_addr[*] payload_din[*]}]
set_input_delay -clock {clk} -min 1.000 [get_ports {payload_addr[*] payload_din[*]}]

# 4. Physical Output Ports Delays
set_output_delay -clock {clk} -max 3.000 [get_ports {done_Tx busy Tx_real[*] Tx_imag[*]}]
set_output_delay -clock {clk} -min 0.500 [get_ports {done_Tx busy Tx_real[*] Tx_imag[*]}]

