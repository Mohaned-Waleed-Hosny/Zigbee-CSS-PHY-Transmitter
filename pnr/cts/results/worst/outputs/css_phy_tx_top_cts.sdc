################################################################################
#
# Design name:  css_phy_tx_top_cts
#
# Created by icc2 write_sdc on Sat Sep 19 06:28:23 2026
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

# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 84; \
#   /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 85; \
#   /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/pnr/cts/script/cts_script.tcl, \
#   line 43
create_clock -name CLK -period 50 -waveform {0 25} [get_ports {clk}]
set_propagated_clock [get_clocks {CLK}]
set_load -pin_load 1 [get_ports {Tx_real[7]}]
set_load -pin_load 1 [get_ports {Tx_real[6]}]
set_load -pin_load 1 [get_ports {Tx_real[5]}]
set_load -pin_load 1 [get_ports {Tx_real[4]}]
set_load -pin_load 1 [get_ports {Tx_real[3]}]
set_load -pin_load 1 [get_ports {Tx_real[2]}]
set_load -pin_load 1 [get_ports {Tx_real[1]}]
set_load -pin_load 1 [get_ports {Tx_real[0]}]
set_load -pin_load 1 [get_ports {Tx_imag[7]}]
set_load -pin_load 1 [get_ports {Tx_imag[6]}]
set_load -pin_load 1 [get_ports {Tx_imag[5]}]
set_load -pin_load 1 [get_ports {Tx_imag[4]}]
set_load -pin_load 1 [get_ports {Tx_imag[3]}]
set_load -pin_load 1 [get_ports {Tx_imag[2]}]
set_load -pin_load 1 [get_ports {Tx_imag[1]}]
set_load -pin_load 1 [get_ports {Tx_imag[0]}]
set_load -pin_load 1 [get_ports {done_Tx}]
set_load -pin_load 1 [get_ports {busy}]
# Set latency for io paths.
# -origin user
set_clock_latency -min 1.12181 [get_clocks {CLK}]
# -origin user
set_clock_latency -max 1.19293 [get_clocks {CLK}]
# Set propagated on clock sources to avoid removing latency for IO paths.
set_propagated_clock  [get_ports {clk}]
set_clock_uncertainty 1 [get_clocks {CLK}]
set_clock_transition 0.1 [get_clocks {CLK}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 11
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {reset}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 12
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {start_Tx}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 13
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports {data_rate}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 15
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 17
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 19
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 21
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 23
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 25
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 27
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 29
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payloadLength[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 31
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 33
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 35
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 37
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 39
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 41
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 43
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 45
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_addr[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 47
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 49
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 51
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 53
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 55
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 57
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 59
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 61
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_din[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 63
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports \
    {payload_wr_en}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 91
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {start_Tx}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 92
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {data_rate}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 93
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payloadLength[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 94
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payloadLength[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 95
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payloadLength[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 96
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payloadLength[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 97
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payloadLength[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 98
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payloadLength[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 99
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payloadLength[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 100
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payloadLength[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 101
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_addr[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 102
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_addr[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 103
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_addr[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 104
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_addr[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 105
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_addr[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 106
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_addr[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 107
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_addr[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 108
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_addr[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 109
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_din[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 110
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_din[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 111
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_din[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 112
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_din[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 113
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_din[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 114
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_din[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 115
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_din[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 116
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_din[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 117
set_input_delay -clock [get_clocks {CLK}] 5 [get_ports {payload_wr_en}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 118
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_real[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 119
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_real[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 120
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_real[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 121
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_real[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 122
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_real[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 123
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_real[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 124
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_real[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 125
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_real[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 126
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_imag[7]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 127
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_imag[6]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 128
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_imag[5]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 129
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_imag[4]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 130
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_imag[3]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 131
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_imag[2]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 132
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_imag[1]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 133
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {Tx_imag[0]}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 134
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {done_Tx}]
# /mnt/hgfs/Shared_Folder/Zigbee-CSS-PHY-Transmitter-main/syn/results/outputs/css_phy_tx_top.sdc, \
#   line 135
set_output_delay -clock [get_clocks {CLK}] 5 [get_ports {busy}]
set_max_transition 1.024 [current_design]
set_max_transition 1 [get_clocks {CLK}] -clock_path
