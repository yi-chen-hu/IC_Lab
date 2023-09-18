//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2023-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;


//###########################################
//
// Wrtie down your design below
//
//###########################################

//####################################################
//               reg & wire
//####################################################
wire        [15:0] inst;
wire        [2:0]  opcode;
wire        [3:0]  rs;
wire        [3:0]  rt;
wire        [3:0]  rd;
wire               func;
wire signed [4:0]  imm;
wire        [12:0] address;
wire signed [15:0] offset;
reg  signed [15:0] pc;
reg  signed [15:0] rs_signed_data;
reg  signed [15:0] rt_signed_data;
reg  signed [15:0] rd_signed_data;
reg  signed [15:0] core_reg[0:15];
wire        [15:0] data;
wire signed [15:0] data_address;
reg                in_valid_inst_bridge;
reg                in_valid_data_bridge_read;
reg                in_valid_data_bridge_write;
wire               out_valid_inst_bridge;
wire               out_valid_data_bridge_read;
wire               out_valid_data_bridge_write;

//=====================================================//
//                       integer                       //
//=====================================================//
integer i;

//=====================================================//
//                         FSM                         //
//=====================================================//
parameter S_IDLE       = 0;
parameter S_INST       = 1;
parameter S_WAIT_INST  = 2;
parameter S_READ_REG   = 3;
parameter S_ALU        = 4;
parameter S_LOAD       = 5;
parameter S_STORE      = 6;
parameter S_WRITE_REG  = 7;
parameter S_WAIT_LOAD  = 8;
parameter S_WAIT_STORE = 9;

reg [3:0] state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state)
        S_IDLE:         next_state = S_INST;
        S_INST:         next_state = S_WAIT_INST;
        S_WAIT_INST:    next_state = out_valid_inst_bridge ? S_READ_REG : S_WAIT_INST;
        S_READ_REG:     next_state = S_ALU;
        S_ALU: begin
            if (opcode == 3'b011) begin
                next_state = S_LOAD;
            end
            else if (opcode == 3'b010) begin
                next_state = S_STORE;
            end
            else if (opcode == 3'b101 || opcode == 3'b100) begin
                next_state = S_INST;
            end
            else begin
                next_state = S_WRITE_REG;
            end
        end
        S_LOAD:         next_state = S_WAIT_LOAD;
        S_STORE:        next_state = S_WAIT_STORE;
        S_WRITE_REG:    next_state = S_INST;
        S_WAIT_LOAD:    next_state = out_valid_data_bridge_read ? S_INST : S_WAIT_LOAD;
        S_WAIT_STORE:   next_state = out_valid_data_bridge_write ? S_INST : S_WAIT_STORE;
        default:        next_state = S_IDLE;
    endcase
end

//=====================================================//
//                       Design                        //
//=====================================================//
assign opcode  = inst[15:13];
assign rs      = inst[12:9];
assign rt      = inst[8:5];
assign rd      = inst[4:1];
assign func    = inst[0];
assign imm     = inst[4:0];
assign address = {3'b0 ,inst[12:0]};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= 16'h1000;
    end
    else if (next_state == S_ALU) begin
        if (opcode == 3'b100) begin // jump
            pc <= address;
        end
        else if (opcode == 3'b101 && rs_signed_data == rt_signed_data) begin // branch on equal
            pc <= pc + 2 + imm * 2;
        end
        else begin // go to next pc
            pc <= pc + 2;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rs_signed_data <= 0;
    end
    else if (next_state == S_READ_REG) begin
        case (rs)
            0:      rs_signed_data <= core_r0;
            1:      rs_signed_data <= core_r1;
            2:      rs_signed_data <= core_r2;
            3:      rs_signed_data <= core_r3;
            4:      rs_signed_data <= core_r4;
            5:      rs_signed_data <= core_r5;
            6:      rs_signed_data <= core_r6;
            7:      rs_signed_data <= core_r7;
            8:      rs_signed_data <= core_r8;
            9:      rs_signed_data <= core_r9;
            10:     rs_signed_data <= core_r10;
            11:     rs_signed_data <= core_r11;
            12:     rs_signed_data <= core_r12;
            13:     rs_signed_data <= core_r13;
            14:     rs_signed_data <= core_r14;
            15:     rs_signed_data <= core_r15;
            default:rs_signed_data <= core_r0;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rt_signed_data <= 0;
    end
    else if (next_state == S_READ_REG) begin
        case (rt)
            0:      rt_signed_data <= core_r0;
            1:      rt_signed_data <= core_r1;
            2:      rt_signed_data <= core_r2;
            3:      rt_signed_data <= core_r3;
            4:      rt_signed_data <= core_r4;
            5:      rt_signed_data <= core_r5;
            6:      rt_signed_data <= core_r6;
            7:      rt_signed_data <= core_r7;
            8:      rt_signed_data <= core_r8;
            9:      rt_signed_data <= core_r9;
            10:     rt_signed_data <= core_r10;
            11:     rt_signed_data <= core_r11;
            12:     rt_signed_data <= core_r12;
            13:     rt_signed_data <= core_r13;
            14:     rt_signed_data <= core_r14;
            15:     rt_signed_data <= core_r15;
            default:rt_signed_data <= core_r0;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_signed_data <= 0;
    end
    else if (state == S_ALU) begin
        if (opcode == 3'b000 && func == 1'b1) begin // add
            rd_signed_data <= rs_signed_data + rt_signed_data;
        end
        else if (opcode == 3'b000 && func == 1'b0) begin // sub
            rd_signed_data <= rs_signed_data - rt_signed_data;
        end
        else if (opcode == 3'b001 && func == 1'b1) begin // set less than
            if (rs_signed_data < rt_signed_data) begin
                rd_signed_data <= 1;
            end
            else begin
                rd_signed_data <= 0;
            end
        end
        else if (opcode == 3'b001 && func == 1'b0) begin // mult
            rd_signed_data <= rs_signed_data * rt_signed_data;
        end
    end
end

/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            core_reg[i] <= 0;
        end
    end
    else if (state == S_WRITE_REG) begin
        core_reg[rd] <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read) begin
        core_reg[rt] <= data;
    end
end

always @(*) begin
    core_r0  = core_reg[0];
    core_r1  = core_reg[1];
    core_r2  = core_reg[2];
    core_r3  = core_reg[3];
    core_r4  = core_reg[4];
    core_r5  = core_reg[5];
    core_r6  = core_reg[6];
    core_r7  = core_reg[7];
    core_r8  = core_reg[8];
    core_r9  = core_reg[9];
    core_r10 = core_reg[10];
    core_r11 = core_reg[11];
    core_r12 = core_reg[12];
    core_r13 = core_reg[13];
    core_r14 = core_reg[14];
    core_r15 = core_reg[15];
end
*/

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r0 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 0) begin
        core_r0 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 0) begin
        core_r0 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r1 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 1) begin
        core_r1 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 1) begin
        core_r1 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r2 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 2) begin
        core_r2 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 2) begin
        core_r2 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r3 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 3) begin
        core_r3 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 3) begin
        core_r3 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r4 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 4) begin
        core_r4 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 4) begin
        core_r4 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r5 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 5) begin
        core_r5 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 5) begin
        core_r5 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r6 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 6) begin
        core_r6 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 6) begin
        core_r6 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r7 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 7) begin
        core_r7 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 7) begin
        core_r7 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r8 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 8) begin
        core_r8 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 8) begin
        core_r8 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r9 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 9) begin
        core_r9 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 9) begin
        core_r9 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r10 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 10) begin
        core_r10 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 10) begin
        core_r10 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r11 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 11) begin
        core_r11 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 11) begin
        core_r11 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r12 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 12) begin
        core_r12 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 12) begin
        core_r12 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r13 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 13) begin
        core_r13 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 13) begin
        core_r13 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r14 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 14) begin
        core_r14 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 14) begin
        core_r14 <= data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r15 <= 0;
    end
    else if (state == S_WRITE_REG && rd == 15) begin
        core_r15 <= rd_signed_data;
    end
    else if (out_valid_data_bridge_read && rt == 15) begin
        core_r15 <= data;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_inst_bridge <= 0;
    end
    else if (next_state == S_INST) begin
        in_valid_inst_bridge <= 1;
    end
    else begin
        in_valid_inst_bridge <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_data_bridge_read <= 0;
    end
    else if (next_state == S_LOAD) begin
        in_valid_data_bridge_read <= 1;
    end
    else begin
        in_valid_data_bridge_read <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_data_bridge_write <= 0;
    end
    else if (next_state == S_STORE) begin
        in_valid_data_bridge_write <= 1;
    end
    else begin
        in_valid_data_bridge_write <= 0;
    end
end

assign offset = 16'h1000;
assign data_address = (rs_signed_data + imm) * 2 + offset;

inst_bridge inst_bridge(
    .clk           (clk                  ),
    .rst_n         (rst_n                ),
    .in_valid      (in_valid_inst_bridge ),
    .in_address    (pc[11:1]             ),
    .out_valid     (out_valid_inst_bridge),
    .out_inst      (inst                 ),
    .arid_m_inf    (arid_m_inf[7:4]      ),
    .araddr_m_inf  (araddr_m_inf[63:32]  ),
    .arlen_m_inf   (arlen_m_inf[13:7]    ),
    .arsize_m_inf  (arsize_m_inf[5:3]    ),
    .arburst_m_inf (arburst_m_inf[3:2]   ),
    .arvalid_m_inf (arvalid_m_inf[1]     ),
    .arready_m_inf (arready_m_inf[1]     ),
    .rdata_m_inf   (rdata_m_inf[31:16]   ),
    .rlast_m_inf   (rlast_m_inf[1]       ),
    .rvalid_m_inf  (rvalid_m_inf[1]      ),
    .rready_m_inf  (rready_m_inf[1]      )
);

data_bridge data_bridge(
    .clk             (clk                        ),
    .rst_n           (rst_n                      ),
    .in_valid_read   (in_valid_data_bridge_read  ),
    .in_valid_write  (in_valid_data_bridge_write ),
    .in_address      (data_address[11:1]         ),
    .in_data         (rt_signed_data             ),
    .out_valid_read  (out_valid_data_bridge_read ),
    .out_valid_write (out_valid_data_bridge_write),
    .out_data        (data                       ),
    .arid_m_inf      (arid_m_inf[3:0]            ),
    .araddr_m_inf    (araddr_m_inf[31:0]         ),
    .arlen_m_inf     (arlen_m_inf[6:0]           ),
    .arsize_m_inf    (arsize_m_inf[2:0]          ),
    .arburst_m_inf   (arburst_m_inf[1:0]         ),
    .arvalid_m_inf   (arvalid_m_inf[0]           ),
    .arready_m_inf   (arready_m_inf[0]           ),
    .rdata_m_inf     (rdata_m_inf[15:0]          ),
    .rlast_m_inf     (rlast_m_inf[0]             ),
    .rvalid_m_inf    (rvalid_m_inf[0]            ),
    .rready_m_inf    (rready_m_inf[0]            ),
    .awid_m_inf      (awid_m_inf                 ),
    .awaddr_m_inf    (awaddr_m_inf               ),
    .awlen_m_inf     (awlen_m_inf                ),
    .awsize_m_inf    (awsize_m_inf               ),
    .awburst_m_inf   (awburst_m_inf              ),
    .awvalid_m_inf   (awvalid_m_inf              ),
    .awready_m_inf   (awready_m_inf              ),
    .wdata_m_inf     (wdata_m_inf                ),
    .wlast_m_inf     (wlast_m_inf                ),
    .wvalid_m_inf    (wvalid_m_inf               ),
    .wready_m_inf    (wready_m_inf               ),
    .bvalid_m_inf    (bvalid_m_inf               ),
    .bready_m_inf    (bready_m_inf               )
); 

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        IO_stall <= 1;
    end
    else if (state != S_IDLE && next_state == S_INST) begin
        IO_stall <= 0;
    end
    else begin
        IO_stall <= 1;
    end
end

endmodule

module inst_bridge(
    clk,
    rst_n,
    in_valid,
    in_address,
    out_valid,
    out_inst,
    arid_m_inf,
    araddr_m_inf,
    arlen_m_inf,
    arsize_m_inf,
    arburst_m_inf,
    arvalid_m_inf,
    arready_m_inf, 
    rdata_m_inf,
    rlast_m_inf,
    rvalid_m_inf,
    rready_m_inf
);

//=====================================================//
//                         I/O                         //
//=====================================================//
input wire        clk;
input wire        rst_n;
input wire        in_valid;
input wire [10:0] in_address;
output reg        out_valid;
output reg [15:0] out_inst;

output wire [3:0]     arid_m_inf;
output wire [31:0]  araddr_m_inf;
output wire [6:0]    arlen_m_inf;
output wire [2:0]   arsize_m_inf;
output wire [1:0]  arburst_m_inf;
output wire        arvalid_m_inf;
input  wire        arready_m_inf;

input  wire [15:0]   rdata_m_inf;
input  wire          rlast_m_inf;
input  wire         rvalid_m_inf;
output wire         rready_m_inf;

//=====================================================//
//                      wire & reg                     //
//=====================================================//
reg         SRAM_saved;
reg  [3:0]  prev_SRAM_address;
reg         out_of_SRAM_range;
reg  [6:0]  in_address_SRAM;
wire [15:0] out_inst_SRAM;
reg         wen;
reg         get_wanted_inst_from_DRAM;

//=====================================================//
//                         FSM                         //
//=====================================================//
parameter S_IDLE       = 0;
parameter S_READ_DRAM  = 1;
parameter S_READ_SRAM  = 2;
parameter S_WAIT_RLAST = 3;
parameter S_WAIT_SRAM  = 4;
parameter S_OUT        = 5;

reg [2:0] state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state)
        S_IDLE:         next_state = in_valid ? (SRAM_saved && !out_of_SRAM_range ? S_READ_SRAM : S_READ_DRAM) : S_IDLE;
        S_READ_DRAM:    next_state = arready_m_inf ? S_WAIT_RLAST : S_READ_DRAM;
        S_READ_SRAM:    next_state = S_WAIT_SRAM;
        S_WAIT_RLAST:   next_state = rlast_m_inf ? S_OUT : S_WAIT_RLAST;
        S_WAIT_SRAM:    next_state = S_OUT;
        S_OUT:          next_state = S_IDLE;
        default:        next_state = S_IDLE;
    endcase
end

//=====================================================//
//                       Design                        //
//=====================================================//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        SRAM_saved <= 0;
    end
    else if (next_state == S_READ_DRAM) begin
        SRAM_saved <= 1;
    end
end

// Because SRAM can save 128 words which is 7 bits, we just need to save the the other 4 bits (11 - 7) and then we can use it to make sure if the new in_address is out of SRAM range or not
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prev_SRAM_address <= 0;
    end
    else if (next_state == S_READ_DRAM) begin
        prev_SRAM_address <= in_address[10:7];
    end
end

always @(*) begin
    if (prev_SRAM_address == in_address[10:7]) begin
        out_of_SRAM_range = 0;
    end
    else begin
        out_of_SRAM_range = 1;
    end
end

always @(*) begin
    if (state == S_WAIT_RLAST) begin
        wen = 0;
    end
    else begin
        wen = 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_address_SRAM <= 0;
    end
    else if (next_state == S_IDLE) begin
        in_address_SRAM <= 0;
    end
    else if (rvalid_m_inf) begin
        in_address_SRAM <= in_address_SRAM + 1;
    end
    else if (next_state == S_READ_SRAM) begin
        in_address_SRAM <= in_address[6:0];
    end
end

RA1SH inst_SRAM (
    .Q   (out_inst_SRAM  ),
    .CLK (clk            ),
    .CEN (1'b0           ),
    .WEN (wen            ),
    .A   (in_address_SRAM),
    .D   (rdata_m_inf    ),
    .OEN (1'b0           )
);

always @(*) begin
    if (state == S_WAIT_RLAST && rvalid_m_inf && in_address_SRAM == in_address[6:0]) begin
        get_wanted_inst_from_DRAM = 1;
    end
    else begin
        get_wanted_inst_from_DRAM = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (next_state == S_OUT) begin
        out_valid <= 1;
    end
    else begin
        out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_inst <= 0;
    end
    else if (get_wanted_inst_from_DRAM) begin
        out_inst <= rdata_m_inf;
    end
    else if (state == S_WAIT_SRAM) begin
        out_inst <= out_inst_SRAM;
    end
end

//=====================================================//
//                        AXI-4                        //
//=====================================================//
assign arid_m_inf    = 0;
assign araddr_m_inf  = {20'b1, in_address[10:7], 8'b0}; // get the +/- 64 inst
assign arlen_m_inf   = 7'b1111111;
assign arsize_m_inf  = 3'b001;
assign arburst_m_inf = 2'b01;
assign arvalid_m_inf = state == S_READ_DRAM ? 1 : 0;
assign rready_m_inf  = state == S_WAIT_RLAST ? 1 : 0;

endmodule

module data_bridge(
    clk,
    rst_n,
    in_valid_read,
    in_valid_write,
    in_address,
    in_data,
    out_valid_read,
    out_valid_write,
    out_data,

    arid_m_inf,
    araddr_m_inf,
    arlen_m_inf,
    arsize_m_inf,
    arburst_m_inf,
    arvalid_m_inf,
    arready_m_inf,
    rdata_m_inf,
    rlast_m_inf,
    rvalid_m_inf,
    rready_m_inf,

    awid_m_inf,
    awaddr_m_inf,
    awlen_m_inf,
    awsize_m_inf,
    awburst_m_inf,
    awvalid_m_inf,
    awready_m_inf,
    wdata_m_inf,
    wlast_m_inf,
    wvalid_m_inf,
    wready_m_inf,
    bvalid_m_inf,
    bready_m_inf
);

//=====================================================//
//                         I/O                         //
//=====================================================//
input  wire          clk;
input  wire          rst_n;
input  wire          in_valid_read;
input  wire          in_valid_write;
input  wire [10:0]   in_address;
input  wire [15:0]   in_data;
output reg           out_valid_read;
output reg           out_valid_write;
output reg  [15:0]   out_data;

output wire [3:0]      arid_m_inf;
output wire [31:0]   araddr_m_inf;
output wire [6:0]     arlen_m_inf;
output wire [2:0]    arsize_m_inf;
output wire [1:0]   arburst_m_inf;
output wire         arvalid_m_inf;
input  wire         arready_m_inf;

input  wire [15:0]    rdata_m_inf;
input  wire           rlast_m_inf;
input  wire          rvalid_m_inf;
output wire          rready_m_inf;

output wire [3:0]      awid_m_inf;
output wire [31:0]   awaddr_m_inf;
output wire [6:0]     awlen_m_inf;
output wire [2:0]    awsize_m_inf;
output wire [1:0]   awburst_m_inf;
output wire         awvalid_m_inf;
input  wire         awready_m_inf;

output reg  [15:0]    wdata_m_inf;
output wire           wlast_m_inf;
output wire          wvalid_m_inf;
input  wire          wready_m_inf;

input  wire          bvalid_m_inf;
output wire          bready_m_inf;

//=====================================================//
//                     wire & reg                      //
//=====================================================//
reg         SRAM_saved;
reg  [3:0]  prev_SRAM_address;
reg         out_of_SRAM_range;
reg  [6:0]  in_address_SRAM;
wire [15:0] out_data_SRAM;
reg  [15:0] in_data_SRAM;
reg         wen;
reg         get_wanted_data_from_DRAM;

//=====================================================//
//                         FSM                         //
//=====================================================//
parameter S_IDLE         = 0;
parameter S_READ_DRAM    = 1;
parameter S_READ_SRAM    = 2;
parameter S_WAIT_RLAST   = 3;
parameter S_WAIT_SRAM    = 4;
parameter S_OUT_READ     = 5;

parameter S_WAIT_AWREADY = 6;
parameter S_WAIT_WREADY  = 7;
parameter S_WAIT_BVALID  = 8;
parameter S_OUT_WRITE    = 9;

reg [3:0] state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state)
        S_IDLE: begin
            if (in_valid_read) begin
                if (SRAM_saved && !out_of_SRAM_range) begin
                    next_state = S_READ_SRAM;
                end
                else begin
                    next_state = S_READ_DRAM;
                end
            end
            else if (in_valid_write) begin
                next_state = S_WAIT_AWREADY;
            end
            else begin
                next_state = S_IDLE;
            end
        end
        S_READ_DRAM:    next_state = arready_m_inf ? S_WAIT_RLAST : S_READ_DRAM;
        S_READ_SRAM:    next_state = S_WAIT_SRAM;
        S_WAIT_RLAST:   next_state = rlast_m_inf ? S_OUT_READ : S_WAIT_RLAST;
        S_WAIT_SRAM:    next_state = S_OUT_READ;
        S_OUT_READ:     next_state = S_IDLE;
        S_WAIT_AWREADY: next_state = awready_m_inf ? S_WAIT_WREADY : S_WAIT_AWREADY;
        S_WAIT_WREADY:  next_state = wready_m_inf ? S_WAIT_BVALID : S_WAIT_WREADY;
        S_WAIT_BVALID:  next_state = bvalid_m_inf ? S_OUT_WRITE : S_WAIT_BVALID;
        S_OUT_WRITE:    next_state = S_IDLE;
        default:        next_state = S_IDLE;
    endcase
end

//=====================================================//
//                        Design                       //
//=====================================================//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        SRAM_saved <= 0;
    end
    else if (next_state == S_READ_DRAM) begin
        SRAM_saved <= 1;
    end
end

// Because SRAM can save 128 words which is 7 bits, we just need to save the the other 4 bits (11 - 7) and then we can use it to make sure if the new in_address is out of SRAM range or not
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prev_SRAM_address <= 0;
    end
    else if (next_state == S_READ_DRAM) begin
        prev_SRAM_address <= in_address[10:7];
    end
end

always @(*) begin
    if (prev_SRAM_address == in_address[10:7]) begin
        out_of_SRAM_range = 0;
    end
    else begin
        out_of_SRAM_range = 1;
    end
end

always @(*) begin
    if (state == S_WAIT_RLAST) begin
        wen = 0;
    end
    else if (state == S_OUT_WRITE && !out_of_SRAM_range) begin
        wen = 0;
    end
    else begin
        wen = 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_address_SRAM <= 0;
    end
    else if (next_state == S_IDLE) begin
        in_address_SRAM <= 0;
    end
    else if (rvalid_m_inf) begin
        in_address_SRAM <= in_address_SRAM + 1;
    end
    else if (next_state == S_READ_SRAM || next_state == S_OUT_WRITE) begin
        in_address_SRAM <= in_address[6:0];
    end
end

RA1SH data_SRAM (
    .Q   (out_data_SRAM  ),
    .CLK (clk            ),
    .CEN (1'b0           ),
    .WEN (wen            ),
    .A   (in_address_SRAM),
    .D   (in_data_SRAM   ),
    .OEN (1'b0           )
);

always @(*) begin
    if (state == S_OUT_WRITE) begin
        in_data_SRAM = in_data;
    end
    else begin
        in_data_SRAM = rdata_m_inf;
    end
end

always @(*) begin
    if (state == S_WAIT_RLAST && rvalid_m_inf && in_address_SRAM == in_address[6:0]) begin
        get_wanted_data_from_DRAM = 1;
    end
    else begin
        get_wanted_data_from_DRAM = 0;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid_read <= 0;
    end
    else if (next_state == S_OUT_READ) begin
        out_valid_read <= 1;
    end
    else begin
        out_valid_read <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= 0;
    end
    else if (get_wanted_data_from_DRAM) begin
        out_data <= rdata_m_inf;
    end
    else if (state == S_WAIT_SRAM) begin
        out_data <= out_data_SRAM;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid_write <= 0;
    end
    else if (next_state == S_OUT_WRITE) begin
        out_valid_write <= 1;
    end
    else begin
        out_valid_write <= 0;
    end
end

//=====================================================//
//                        AXI-4                        //
//=====================================================//
//-----------------------------------------------------//
//                    read channel                     //
//-----------------------------------------------------//
assign arid_m_inf    = 0;
assign arlen_m_inf   = 7'b111_1111;
assign arsize_m_inf  = 3'b001;
assign arburst_m_inf = 2'b01;
assign araddr_m_inf  = {20'b1, in_address[10:7], 8'b0};
assign rready_m_inf  = state == S_WAIT_RLAST ? 1 : 0;
assign arvalid_m_inf = state == S_READ_DRAM ? 1 : 0;
//-----------------------------------------------------//
//                    write channel                    //
//-----------------------------------------------------//
assign awid_m_inf    = 0;
assign awlen_m_inf   = 0;
assign awsize_m_inf  = 3'b001;
assign awburst_m_inf = 2'b01;
assign awaddr_m_inf  = {20'b1, in_address, 1'b0};
assign bready_m_inf  = state == S_WAIT_BVALID ? 1 : 0;
assign awvalid_m_inf = state == S_WAIT_AWREADY ? 1 : 0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wdata_m_inf <= 0;
    end
    else if (in_valid_write) begin
        wdata_m_inf <= in_data;
    end
end

assign wlast_m_inf = state == S_WAIT_WREADY ? 1 : 0;
assign wvalid_m_inf = state == S_WAIT_WREADY ? 1 : 0;

endmodule