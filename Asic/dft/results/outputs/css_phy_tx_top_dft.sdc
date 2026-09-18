###################################################################

# Created by write_sdc on Fri Sep 18 01:21:50 2026

###################################################################
set sdc_version 2.1

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA
set_max_fanout 16 [current_design]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports reset]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports start_Tx]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports data_rate]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payloadLength[7]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payloadLength[6]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payloadLength[5]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payloadLength[4]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payloadLength[3]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payloadLength[2]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payloadLength[1]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payloadLength[0]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_addr[7]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_addr[6]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_addr[5]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_addr[4]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_addr[3]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_addr[2]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_addr[1]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_addr[0]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_din[7]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_din[6]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_din[5]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_din[4]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_din[3]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_din[2]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_din[1]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
{payload_din[0]}]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports            \
payload_wr_en]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports SI]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports SE]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports test_mode]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports scan_clk]
set_driving_cell -lib_cell IBUFFX2 -library saed90nm_max [get_ports scan_rst]
set_ideal_network [get_ports clk]
set_ideal_network [get_ports reset]
set_ideal_network [get_ports SE]
set_ideal_network [get_ports test_mode]
set_ideal_network [get_ports scan_clk]
set_ideal_network [get_ports scan_rst]
create_clock [get_ports clk]  -name CLK  -period 1000  -waveform {0 500}
set_clock_latency 0  [get_clocks CLK]
set_clock_uncertainty 2  [get_clocks CLK]
set_clock_transition -min -fall 2 [get_clocks CLK]
set_clock_transition -min -rise 2 [get_clocks CLK]
set_clock_transition -max -fall 2 [get_clocks CLK]
set_clock_transition -max -rise 2 [get_clocks CLK]
create_clock [get_ports scan_clk]  -name SCAN_CLK  -period 1000  -waveform {0 500}
set_clock_latency 0  [get_clocks SCAN_CLK]
set_clock_uncertainty 2  [get_clocks SCAN_CLK]
set_clock_transition -min -fall 2 [get_clocks SCAN_CLK]
set_clock_transition -min -rise 2 [get_clocks SCAN_CLK]
set_clock_transition -max -fall 2 [get_clocks SCAN_CLK]
set_clock_transition -max -rise 2 [get_clocks SCAN_CLK]
set_input_delay -clock CLK  300  [get_ports scan_clk]
set_input_delay -clock CLK  300  [get_ports reset]
set_input_delay -clock CLK  300  [get_ports start_Tx]
set_input_delay -clock CLK  300  [get_ports data_rate]
set_input_delay -clock CLK  300  [get_ports {payloadLength[7]}]
set_input_delay -clock CLK  300  [get_ports {payloadLength[6]}]
set_input_delay -clock CLK  300  [get_ports {payloadLength[5]}]
set_input_delay -clock CLK  300  [get_ports {payloadLength[4]}]
set_input_delay -clock CLK  300  [get_ports {payloadLength[3]}]
set_input_delay -clock CLK  300  [get_ports {payloadLength[2]}]
set_input_delay -clock CLK  300  [get_ports {payloadLength[1]}]
set_input_delay -clock CLK  300  [get_ports {payloadLength[0]}]
set_input_delay -clock CLK  300  [get_ports {payload_addr[7]}]
set_input_delay -clock CLK  300  [get_ports {payload_addr[6]}]
set_input_delay -clock CLK  300  [get_ports {payload_addr[5]}]
set_input_delay -clock CLK  300  [get_ports {payload_addr[4]}]
set_input_delay -clock CLK  300  [get_ports {payload_addr[3]}]
set_input_delay -clock CLK  300  [get_ports {payload_addr[2]}]
set_input_delay -clock CLK  300  [get_ports {payload_addr[1]}]
set_input_delay -clock CLK  300  [get_ports {payload_addr[0]}]
set_input_delay -clock CLK  300  [get_ports {payload_din[7]}]
set_input_delay -clock CLK  300  [get_ports {payload_din[6]}]
set_input_delay -clock CLK  300  [get_ports {payload_din[5]}]
set_input_delay -clock CLK  300  [get_ports {payload_din[4]}]
set_input_delay -clock CLK  300  [get_ports {payload_din[3]}]
set_input_delay -clock CLK  300  [get_ports {payload_din[2]}]
set_input_delay -clock CLK  300  [get_ports {payload_din[1]}]
set_input_delay -clock CLK  300  [get_ports {payload_din[0]}]
set_input_delay -clock CLK  300  [get_ports payload_wr_en]
set_input_delay -clock CLK  300  [get_ports SI]
set_input_delay -clock CLK  300  [get_ports SE]
set_input_delay -clock CLK  300  [get_ports test_mode]
set_input_delay -clock CLK  300  [get_ports scan_rst]
set_output_delay -clock CLK  300  [get_ports {Tx_real[7]}]
set_output_delay -clock CLK  300  [get_ports {Tx_real[6]}]
set_output_delay -clock CLK  300  [get_ports {Tx_real[5]}]
set_output_delay -clock CLK  300  [get_ports {Tx_real[4]}]
set_output_delay -clock CLK  300  [get_ports {Tx_real[3]}]
set_output_delay -clock CLK  300  [get_ports {Tx_real[2]}]
set_output_delay -clock CLK  300  [get_ports {Tx_real[1]}]
set_output_delay -clock CLK  300  [get_ports {Tx_real[0]}]
set_output_delay -clock CLK  300  [get_ports {Tx_imag[7]}]
set_output_delay -clock CLK  300  [get_ports {Tx_imag[6]}]
set_output_delay -clock CLK  300  [get_ports {Tx_imag[5]}]
set_output_delay -clock CLK  300  [get_ports {Tx_imag[4]}]
set_output_delay -clock CLK  300  [get_ports {Tx_imag[3]}]
set_output_delay -clock CLK  300  [get_ports {Tx_imag[2]}]
set_output_delay -clock CLK  300  [get_ports {Tx_imag[1]}]
set_output_delay -clock CLK  300  [get_ports {Tx_imag[0]}]
set_output_delay -clock CLK  300  [get_ports done_Tx]
set_output_delay -clock CLK  300  [get_ports busy]
set_output_delay -clock CLK  300  [get_ports SO]
set_clock_groups  -logically_exclusive -name CLK_1  -group [get_clocks CLK]    \
-group [get_clocks SCAN_CLK]
