################################################################################
#
# Design name:  css_phy_tx_top_cts
#
# Created by icc2 write_sdc on Fri Sep 18 07:30:59 2026
#
################################################################################

set sdc_version 2.1
set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA

################################################################################
#
# Units
# time_unit               : 1e-09
# resistance_unit         : 1000000
# capacitive_load_unit    : 1e-15
# voltage_unit            : 1
# current_unit            : 1e-06
# power_unit              : 1e-12
################################################################################


# Mode: default
# Corner: default
# Scenario: default

# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 74; \
#   /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 75; \
#   /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/pnr/cts/script/cts_script.tcl, \
#   line 43
create_clock -name CLK -period 1000 -waveform {0 500} [get_ports {clk}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 81; \
#   /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 82; \
#   /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/pnr/cts/script/cts_script.tcl, \
#   line 43
create_clock -name SCAN_CLK -period 1000 -waveform {0 500} [get_ports \
    {scan_clk}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 141
set_clock_groups -name CLK_1 -logically_exclusive -group [get_clocks {CLK}] \
    -group [get_clocks {SCAN_CLK}]
set_propagated_clock [get_clocks {CLK}]
set_propagated_clock [get_clocks {SCAN_CLK}]
# Set latency for io paths.
# -origin user
set_clock_latency -min 3.55749 [get_clocks {CLK}]
# -origin user
set_clock_latency -max 3.73281 [get_clocks {CLK}]
# -origin user
set_clock_latency -min 3.14815 [get_clocks {SCAN_CLK}]
# -origin user
set_clock_latency -max 3.31364 [get_clocks {SCAN_CLK}]
# Set propagated on clock sources to avoid removing latency for IO paths.
set_propagated_clock  [get_ports {clk}]
set_propagated_clock  [get_ports {scan_clk}]
set_clock_uncertainty 2 [get_clocks {CLK}]
set_clock_uncertainty 2 [get_clocks {SCAN_CLK}]
set_clock_transition 0.368762 [get_clocks {CLK}]
set_clock_transition 0.368762 [get_clocks {SCAN_CLK}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 10
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {reset}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 11
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {start_Tx}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 12
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {data_rate}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 14
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 16
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 18
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 20
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 22
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 24
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 26
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 28
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 30
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 32
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 34
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 36
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 38
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 40
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 42
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 44
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 46
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 48
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 50
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 52
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 54
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 56
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 58
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 60
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 62
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_wr_en}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 63
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {SI}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 64
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {SE}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 65
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {test_mode}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 66
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {scan_clk}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 67
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {scan_rst}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 89
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {reset}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 90
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {start_Tx}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 91
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {data_rate}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 92
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payloadLength[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 93
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payloadLength[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 94
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payloadLength[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 95
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payloadLength[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 96
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payloadLength[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 97
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payloadLength[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 98
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payloadLength[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 99
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payloadLength[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 100
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_addr[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 101
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_addr[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 102
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_addr[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 103
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_addr[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 104
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_addr[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 105
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_addr[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 106
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_addr[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 107
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_addr[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 108
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_din[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 109
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_din[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 110
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_din[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 111
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_din[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 112
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_din[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 113
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_din[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 114
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_din[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 115
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_din[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 116
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {payload_wr_en}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 121
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_real[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 122
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_real[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 123
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_real[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 124
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_real[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 125
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_real[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 126
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_real[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 127
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_real[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 128
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_real[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 129
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_imag[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 130
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_imag[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 131
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_imag[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 132
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_imag[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 133
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_imag[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 134
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_imag[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 135
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_imag[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 136
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {Tx_imag[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 137
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {done_Tx}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 138
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {busy}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 117
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {SI}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 118
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {SE}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 119
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {test_mode}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 88
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {scan_clk}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 120
set_input_delay -clock [get_clocks {CLK}] 300 [get_ports {scan_rst}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/dft/results/outputs/css_phy_tx_top_dft.sdc, \
#   line 139
set_output_delay -clock [get_clocks {CLK}] 300 [get_ports {SO}]
set_max_transition 1 [get_clocks {CLK}] -clock_path
set_max_transition 1 [get_clocks {SCAN_CLK}] -clock_path
