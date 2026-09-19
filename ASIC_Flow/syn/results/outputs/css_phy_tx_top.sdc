###################################################################

# Created by write_sdc on Sat Sep 19 03:37:40 2026

###################################################################
set sdc_version 2.1

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA
set_wire_load_model -name ForQA -library saed90nm_max
set_max_transition 1.024 [current_design]
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
set_load -pin_load 1 [get_ports done_Tx]
set_load -pin_load 1 [get_ports busy]
set_ideal_network [get_ports clk]
set_ideal_network [get_ports reset]
create_clock [get_ports clk]  -name CLK  -period 50  -waveform {0 25}
set_clock_latency 0  [get_clocks CLK]
set_clock_uncertainty 1  [get_clocks CLK]
set_clock_transition -min -fall 0.1 [get_clocks CLK]
set_clock_transition -min -rise 0.1 [get_clocks CLK]
set_clock_transition -max -fall 0.1 [get_clocks CLK]
set_clock_transition -max -rise 0.1 [get_clocks CLK]
set_input_delay -clock CLK  5  [get_ports start_Tx]
set_input_delay -clock CLK  5  [get_ports data_rate]
set_input_delay -clock CLK  5  [get_ports {payloadLength[7]}]
set_input_delay -clock CLK  5  [get_ports {payloadLength[6]}]
set_input_delay -clock CLK  5  [get_ports {payloadLength[5]}]
set_input_delay -clock CLK  5  [get_ports {payloadLength[4]}]
set_input_delay -clock CLK  5  [get_ports {payloadLength[3]}]
set_input_delay -clock CLK  5  [get_ports {payloadLength[2]}]
set_input_delay -clock CLK  5  [get_ports {payloadLength[1]}]
set_input_delay -clock CLK  5  [get_ports {payloadLength[0]}]
set_input_delay -clock CLK  5  [get_ports {payload_addr[7]}]
set_input_delay -clock CLK  5  [get_ports {payload_addr[6]}]
set_input_delay -clock CLK  5  [get_ports {payload_addr[5]}]
set_input_delay -clock CLK  5  [get_ports {payload_addr[4]}]
set_input_delay -clock CLK  5  [get_ports {payload_addr[3]}]
set_input_delay -clock CLK  5  [get_ports {payload_addr[2]}]
set_input_delay -clock CLK  5  [get_ports {payload_addr[1]}]
set_input_delay -clock CLK  5  [get_ports {payload_addr[0]}]
set_input_delay -clock CLK  5  [get_ports {payload_din[7]}]
set_input_delay -clock CLK  5  [get_ports {payload_din[6]}]
set_input_delay -clock CLK  5  [get_ports {payload_din[5]}]
set_input_delay -clock CLK  5  [get_ports {payload_din[4]}]
set_input_delay -clock CLK  5  [get_ports {payload_din[3]}]
set_input_delay -clock CLK  5  [get_ports {payload_din[2]}]
set_input_delay -clock CLK  5  [get_ports {payload_din[1]}]
set_input_delay -clock CLK  5  [get_ports {payload_din[0]}]
set_input_delay -clock CLK  5  [get_ports payload_wr_en]
set_output_delay -clock CLK  5  [get_ports {Tx_real[7]}]
set_output_delay -clock CLK  5  [get_ports {Tx_real[6]}]
set_output_delay -clock CLK  5  [get_ports {Tx_real[5]}]
set_output_delay -clock CLK  5  [get_ports {Tx_real[4]}]
set_output_delay -clock CLK  5  [get_ports {Tx_real[3]}]
set_output_delay -clock CLK  5  [get_ports {Tx_real[2]}]
set_output_delay -clock CLK  5  [get_ports {Tx_real[1]}]
set_output_delay -clock CLK  5  [get_ports {Tx_real[0]}]
set_output_delay -clock CLK  5  [get_ports {Tx_imag[7]}]
set_output_delay -clock CLK  5  [get_ports {Tx_imag[6]}]
set_output_delay -clock CLK  5  [get_ports {Tx_imag[5]}]
set_output_delay -clock CLK  5  [get_ports {Tx_imag[4]}]
set_output_delay -clock CLK  5  [get_ports {Tx_imag[3]}]
set_output_delay -clock CLK  5  [get_ports {Tx_imag[2]}]
set_output_delay -clock CLK  5  [get_ports {Tx_imag[1]}]
set_output_delay -clock CLK  5  [get_ports {Tx_imag[0]}]
set_output_delay -clock CLK  5  [get_ports done_Tx]
set_output_delay -clock CLK  5  [get_ports busy]
