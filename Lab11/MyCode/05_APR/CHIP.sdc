###################################################################
set sdc_version 2.0

#define your sdc here

###################################################################

# Created by write_sdc on Mon Dec 19 23:28:32 2022

###################################################################
set sdc_version 2.1

create_clock -name "CLK" -add -period 30.0 -waveform {0.0 15.0} [get_ports clk]
set_propagated_clock [all_clocks]

set_clock_gating_check -setup 0.0
set_input_delay  -clock [get_clocks CLK] -add_delay 15 [get_ports rst_n]
set_input_delay  -clock [get_clocks CLK] -add_delay 15 [get_ports {in_valid}]
set_input_delay  -clock [get_clocks CLK] -add_delay 15 [get_ports {in_valid2}]
set_input_delay  -clock [get_clocks CLK] -add_delay 15 [get_ports {matrix}]
set_input_delay  -clock [get_clocks CLK] -add_delay 15 [get_ports {matrix_size[1]}]
set_input_delay  -clock [get_clocks CLK] -add_delay 15 [get_ports {matrix_size[0]}]
set_input_delay  -clock [get_clocks CLK] -add_delay 15 [get_ports {i_mat_idx}]
set_input_delay  -clock [get_clocks CLK] -add_delay 15 [get_ports {w_mat_idx}]

set_output_delay -clock [get_clocks CLK] -add_delay 15 [get_ports {out_valid}]
set_output_delay -clock [get_clocks CLK] -add_delay 15 [get_ports {out_value}]
