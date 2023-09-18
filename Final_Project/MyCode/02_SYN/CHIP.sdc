###################################################################

# Created by write_sdc on Sun Jun  4 16:42:00 2023

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -power mW -voltage V       \
-current mA
set_wire_load_mode top
set_load -pin_load 0.05 [get_ports IO_stall]
set_load -pin_load 0.05 [get_ports {awid_m_inf[3]}]
set_load -pin_load 0.05 [get_ports {awid_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {awid_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {awid_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[31]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[30]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[29]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[28]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[27]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[26]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[25]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[24]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[23]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[22]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[21]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[20]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[19]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[18]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[17]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[16]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[15]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[14]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[13]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[12]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[11]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[10]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[9]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[8]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[7]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[6]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[5]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[4]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[3]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {awaddr_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {awsize_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {awsize_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {awsize_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {awburst_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {awburst_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {awlen_m_inf[6]}]
set_load -pin_load 0.05 [get_ports {awlen_m_inf[5]}]
set_load -pin_load 0.05 [get_ports {awlen_m_inf[4]}]
set_load -pin_load 0.05 [get_ports {awlen_m_inf[3]}]
set_load -pin_load 0.05 [get_ports {awlen_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {awlen_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {awlen_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {awvalid_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[15]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[14]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[13]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[12]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[11]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[10]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[9]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[8]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[7]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[6]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[5]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[4]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[3]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {wdata_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {wlast_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {wvalid_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {bready_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {arid_m_inf[7]}]
set_load -pin_load 0.05 [get_ports {arid_m_inf[6]}]
set_load -pin_load 0.05 [get_ports {arid_m_inf[5]}]
set_load -pin_load 0.05 [get_ports {arid_m_inf[4]}]
set_load -pin_load 0.05 [get_ports {arid_m_inf[3]}]
set_load -pin_load 0.05 [get_ports {arid_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {arid_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {arid_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[63]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[62]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[61]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[60]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[59]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[58]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[57]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[56]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[55]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[54]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[53]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[52]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[51]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[50]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[49]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[48]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[47]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[46]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[45]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[44]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[43]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[42]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[41]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[40]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[39]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[38]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[37]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[36]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[35]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[34]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[33]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[32]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[31]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[30]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[29]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[28]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[27]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[26]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[25]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[24]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[23]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[22]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[21]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[20]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[19]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[18]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[17]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[16]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[15]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[14]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[13]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[12]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[11]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[10]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[9]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[8]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[7]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[6]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[5]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[4]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[3]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {araddr_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[13]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[12]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[11]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[10]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[9]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[8]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[7]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[6]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[5]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[4]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[3]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {arlen_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {arsize_m_inf[5]}]
set_load -pin_load 0.05 [get_ports {arsize_m_inf[4]}]
set_load -pin_load 0.05 [get_ports {arsize_m_inf[3]}]
set_load -pin_load 0.05 [get_ports {arsize_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {arsize_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {arsize_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {arburst_m_inf[3]}]
set_load -pin_load 0.05 [get_ports {arburst_m_inf[2]}]
set_load -pin_load 0.05 [get_ports {arburst_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {arburst_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {arvalid_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {arvalid_m_inf[0]}]
set_load -pin_load 0.05 [get_ports {rready_m_inf[1]}]
set_load -pin_load 0.05 [get_ports {rready_m_inf[0]}]
create_clock [get_ports clk]  -period 3.4  -waveform {0 1.7}
set_input_delay -clock clk  0  [get_ports clk]
set_input_delay -clock clk  0  [get_ports rst_n]
set_input_delay -clock clk  0  [get_ports {awready_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {wready_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {bid_m_inf[3]}]
set_input_delay -clock clk  0  [get_ports {bid_m_inf[2]}]
set_input_delay -clock clk  0  [get_ports {bid_m_inf[1]}]
set_input_delay -clock clk  0  [get_ports {bid_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {bresp_m_inf[1]}]
set_input_delay -clock clk  0  [get_ports {bresp_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {bvalid_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {arready_m_inf[1]}]
set_input_delay -clock clk  0  [get_ports {arready_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {rid_m_inf[7]}]
set_input_delay -clock clk  0  [get_ports {rid_m_inf[6]}]
set_input_delay -clock clk  0  [get_ports {rid_m_inf[5]}]
set_input_delay -clock clk  0  [get_ports {rid_m_inf[4]}]
set_input_delay -clock clk  0  [get_ports {rid_m_inf[3]}]
set_input_delay -clock clk  0  [get_ports {rid_m_inf[2]}]
set_input_delay -clock clk  0  [get_ports {rid_m_inf[1]}]
set_input_delay -clock clk  0  [get_ports {rid_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[31]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[30]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[29]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[28]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[27]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[26]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[25]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[24]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[23]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[22]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[21]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[20]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[19]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[18]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[17]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[16]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[15]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[14]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[13]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[12]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[11]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[10]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[9]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[8]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[7]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[6]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[5]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[4]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[3]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[2]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[1]}]
set_input_delay -clock clk  0  [get_ports {rdata_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {rresp_m_inf[3]}]
set_input_delay -clock clk  0  [get_ports {rresp_m_inf[2]}]
set_input_delay -clock clk  0  [get_ports {rresp_m_inf[1]}]
set_input_delay -clock clk  0  [get_ports {rresp_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {rlast_m_inf[1]}]
set_input_delay -clock clk  0  [get_ports {rlast_m_inf[0]}]
set_input_delay -clock clk  0  [get_ports {rvalid_m_inf[1]}]
set_input_delay -clock clk  0  [get_ports {rvalid_m_inf[0]}]
set_output_delay -clock clk  1.7  [get_ports IO_stall]
set_output_delay -clock clk  0  [get_ports {awid_m_inf[3]}]
set_output_delay -clock clk  0  [get_ports {awid_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {awid_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {awid_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[31]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[30]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[29]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[28]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[27]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[26]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[25]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[24]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[23]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[22]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[21]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[20]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[19]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[18]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[17]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[16]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[15]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[14]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[13]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[12]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[11]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[10]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[9]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[8]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[7]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[6]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[5]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[4]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[3]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {awaddr_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {awsize_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {awsize_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {awsize_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {awburst_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {awburst_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {awlen_m_inf[6]}]
set_output_delay -clock clk  0  [get_ports {awlen_m_inf[5]}]
set_output_delay -clock clk  0  [get_ports {awlen_m_inf[4]}]
set_output_delay -clock clk  0  [get_ports {awlen_m_inf[3]}]
set_output_delay -clock clk  0  [get_ports {awlen_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {awlen_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {awlen_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {awvalid_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[15]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[14]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[13]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[12]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[11]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[10]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[9]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[8]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[7]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[6]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[5]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[4]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[3]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {wdata_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {wlast_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {wvalid_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {bready_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {arid_m_inf[7]}]
set_output_delay -clock clk  0  [get_ports {arid_m_inf[6]}]
set_output_delay -clock clk  0  [get_ports {arid_m_inf[5]}]
set_output_delay -clock clk  0  [get_ports {arid_m_inf[4]}]
set_output_delay -clock clk  0  [get_ports {arid_m_inf[3]}]
set_output_delay -clock clk  0  [get_ports {arid_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {arid_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {arid_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[63]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[62]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[61]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[60]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[59]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[58]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[57]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[56]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[55]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[54]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[53]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[52]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[51]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[50]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[49]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[48]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[47]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[46]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[45]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[44]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[43]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[42]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[41]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[40]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[39]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[38]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[37]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[36]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[35]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[34]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[33]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[32]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[31]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[30]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[29]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[28]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[27]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[26]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[25]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[24]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[23]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[22]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[21]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[20]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[19]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[18]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[17]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[16]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[15]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[14]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[13]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[12]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[11]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[10]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[9]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[8]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[7]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[6]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[5]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[4]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[3]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {araddr_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[13]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[12]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[11]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[10]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[9]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[8]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[7]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[6]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[5]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[4]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[3]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {arlen_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {arsize_m_inf[5]}]
set_output_delay -clock clk  0  [get_ports {arsize_m_inf[4]}]
set_output_delay -clock clk  0  [get_ports {arsize_m_inf[3]}]
set_output_delay -clock clk  0  [get_ports {arsize_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {arsize_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {arsize_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {arburst_m_inf[3]}]
set_output_delay -clock clk  0  [get_ports {arburst_m_inf[2]}]
set_output_delay -clock clk  0  [get_ports {arburst_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {arburst_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {arvalid_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {arvalid_m_inf[0]}]
set_output_delay -clock clk  0  [get_ports {rready_m_inf[1]}]
set_output_delay -clock clk  0  [get_ports {rready_m_inf[0]}]
