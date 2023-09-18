//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NCTU ED415
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 spring
//   Midterm Proejct            : GLCM 
//   Author                     : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : GLCM.v
//   Module Name : GLCM
//   Release version : V1.0 (Release Date: 2023-04)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module GLCM(
            clk,
            rst_n,
    
            in_addr_M,
            in_addr_G,
            in_dir,
            in_dis,
            in_valid,
            out_valid,

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
parameter ID_WIDTH = 4, ADDR_WIDTH = 32, DATA_WIDTH = 32;
input clk, rst_n;



// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
       therefore I declared output of AXI as wire in Poly_Ring
*/
   
// -----------------------------
// IO port
input [ADDR_WIDTH-1:0]      in_addr_M;
input [ADDR_WIDTH-1:0]      in_addr_G;
input [1:0]                 in_dir;
input [3:0]                 in_dis;
input                       in_valid;
output reg                  out_valid;
// -----------------------------


// axi write address channel 
output  wire [ID_WIDTH-1:0]        awid_m_inf;
output  wire [ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [2:0]               awsize_m_inf;
output  wire [1:0]              awburst_m_inf;
output  wire [3:0]                awlen_m_inf;
output  wire                    awvalid_m_inf;
input   wire                    awready_m_inf;
// axi write data channel 
output  wire [ DATA_WIDTH-1:0]    wdata_m_inf;
output  wire                      wlast_m_inf;
output  wire                     wvalid_m_inf;
input   wire                     wready_m_inf;
// axi write response channel
input   wire [ID_WIDTH-1:0]         bid_m_inf;
input   wire [1:0]                bresp_m_inf;
input   wire                     bvalid_m_inf;
output  wire                     bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [ID_WIDTH-1:0]        arid_m_inf;
output  wire [ADDR_WIDTH-1:0]    araddr_m_inf;
output  wire [3:0]                arlen_m_inf;
output  wire [2:0]               arsize_m_inf;
output  wire [1:0]              arburst_m_inf;
output  wire                    arvalid_m_inf;
input   wire                    arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [ID_WIDTH-1:0]         rid_m_inf;
input   wire [DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [1:0]                rresp_m_inf;
input   wire                      rlast_m_inf;
input   wire                     rvalid_m_inf;
output  wire                     rready_m_inf;
// -----------------------------

//=============================================
//  wire & reg
//=============================================
reg [11:0] address_4096;
reg fetched;
reg [3:0] row, row_cap, row_comb;
reg [3:0] col, col_cap, col_comb;
wire [8:0] row_comb_mult_16;
wire [11:0] addr_G_cap;
reg [3:0] row_offset;
reg [3:0] col_offset;
reg [11:0] addr_M_reg;
reg [11:0] addr_G_reg;
reg addr_next;
reg [7:0] GLCM_matrix[0:1023];

//=============================================
//  FSM
//=============================================
reg [2:0] state, next_state;

parameter S_IDLE        = 0;
parameter S_INPUT       = 1;
parameter S_PREFETCH    = 2;
parameter S_COMPUTE     = 3;
parameter S_WAIT1       = 4;
parameter S_WAIT2       = 5;
parameter S_WRITE       = 6;
parameter S_OUT         = 7;

always @(posedge clk or negedge rst_n)
    if (!rst_n)
        state <= S_IDLE;
    else
        state <= next_state;

always @(*)
    case(state)
        S_IDLE:         next_state = in_valid ? S_INPUT : S_IDLE;
        S_INPUT:        next_state = fetched ? S_COMPUTE : S_PREFETCH;
        S_PREFETCH:     next_state = address_4096 == 4095 ? S_COMPUTE : S_PREFETCH;	
        S_COMPUTE:      next_state = (row == row_cap && col == col_cap && addr_next) ? S_WAIT1 : S_COMPUTE;
        S_WAIT1:        next_state = S_WAIT2;
        S_WAIT2:        next_state = S_WRITE;
        S_WRITE:        next_state = (address_4096 == addr_G_cap && bvalid_m_inf) ? S_OUT : S_WRITE;
        S_OUT:          next_state = S_IDLE;
        default:        next_state = S_IDLE;
    endcase

//=============================================
//  Design
//=============================================
always @(posedge clk or negedge rst_n)
    if (!rst_n)
        fetched <= 0;
    else if (state == S_COMPUTE)
        fetched <= 1;

assign addr_G_cap = addr_G_reg + 1024;

assign row_comb_mult_16 = {row_comb, 4'b0};

always @(posedge clk)
    if (state == S_IDLE)
        address_4096 <= 0;
    else if (state == S_PREFETCH) begin
        if (address_4096 == 4095)
            address_4096 <= addr_M_reg;
        else if (rvalid_m_inf)
            address_4096 <= address_4096 + 1;
    end
    else if (state == S_INPUT && next_state == S_COMPUTE)
        address_4096 <= addr_M_reg;
    else if (state == S_COMPUTE)
        address_4096 <= addr_M_reg + row_comb_mult_16 + col_comb;
    else if (state == S_WAIT1)
        address_4096 <= addr_G_reg;
    else if (state == S_WRITE)
        if (wready_m_inf)
            address_4096 <= address_4096 + 4;

always @(posedge clk)
    col <= col_comb;

always @(*)
    if (state == S_IDLE)
        col_comb = 0;
    else if (state == S_COMPUTE) begin
        if (addr_next) begin
            if (col == col_cap)
                col_comb = 0;
            else
                col_comb = col + 1;
        end
        else
            col_comb = col;
    end
    else
        col_comb = col;

always @(posedge clk)
    row <= row_comb;

always @(*)
    if (state == S_IDLE)
        row_comb = 0;
    else if (state == S_COMPUTE) begin
        if (addr_next) begin
            if (col == col_cap && row != row_cap)
                row_comb = row + 1;
            else
                row_comb = row;
        end
        else
            row_comb = row;
    end
    else
        row_comb = row;


always @(posedge clk)
    if (in_valid) begin
        case (in_dir)
            1:      begin
                    row_offset <= in_dis;
                    col_offset <= 0;
                    end
            2:      begin
                    row_offset <= 0;
                    col_offset <= in_dis;
                    end
            default:begin
                    row_offset <= in_dis;
                    col_offset <= in_dis;
                    end
        endcase
    end

always @(posedge clk)
    if (state == S_INPUT) begin
        row_cap <= 15 - row_offset;
        col_cap <= 15 - col_offset;
    end

always @(posedge clk)
    if (in_valid)
        addr_M_reg <= in_addr_M;

always @(posedge clk)
    if (in_valid)
        addr_G_reg <= in_addr_G;

always @(posedge clk)
    if (state == S_IDLE)
        addr_next <= 0;
    else if (state >= S_COMPUTE)
        addr_next <= ~addr_next;

always @(posedge clk or negedge rst_n)
    if (!rst_n)
        out_valid <= 0;
    else if (state == S_OUT)
        out_valid <= 1;
    else
        out_valid <= 0;


//=============================================
//  AXI-4 protocol
//=============================================

//--------------------------------------------
//  read channel
//--------------------------------------------
reg [31:0] araddr_m_inf_reg;
reg arvalid_m_inf_reg;
wire [7:0] data[0:3];
reg rready_m_inf_reg;
reg [1:0] ctr_4;

always @(posedge clk)
    if (state == S_INPUT && next_state == S_PREFETCH)
        ctr_4 <= 0;
    else if (rready_m_inf)
        ctr_4 <= 0;
    else if (rvalid_m_inf && !rready_m_inf_reg)
        ctr_4 <= ctr_4 + 1;

assign arid_m_inf = 0;
assign araddr_m_inf = {20'h1, address_4096};
assign arlen_m_inf = 4'd15;	
assign arsize_m_inf = 3'b010;
assign arburst_m_inf = 2'b01;
assign arvalid_m_inf = arvalid_m_inf_reg;
always @(posedge clk)
    if (state == S_IDLE)
        arvalid_m_inf_reg <= 0;
    else if (state == S_INPUT && next_state == S_PREFETCH)
        arvalid_m_inf_reg <= 1;
    else if (state == S_PREFETCH) begin
        if (arready_m_inf)
            arvalid_m_inf_reg <= 0;
        else if (address_4096 == 4095)
            arvalid_m_inf_reg <= 0;
        else if (rlast_m_inf && rready_m_inf)
            arvalid_m_inf_reg <= 1;
    end

assign data[3] = rdata_m_inf[31:24];
assign data[2] = rdata_m_inf[23:16];
assign data[1] = rdata_m_inf[15:8];
assign data[0] = rdata_m_inf[7:0];

always @(posedge clk)
    if (state == S_IDLE)
        rready_m_inf_reg <= 0;
    else if (state == S_PREFETCH) begin
        if (ctr_4 == 2)
            rready_m_inf_reg <= 1;
        else if (rvalid_m_inf)
            rready_m_inf_reg <= 0;
        
    end

assign rready_m_inf = rready_m_inf_reg;

//--------------------------------------------
//  write channel
//--------------------------------------------
reg [3:0] ctr_16;
reg awvalid_m_inf_reg;
reg wvalid_m_inf_reg;
reg bready_m_inf_reg;

always @(posedge clk)
    if (state == S_IDLE)
        ctr_16 <= 0;
    else if (wvalid_m_inf && wready_m_inf)
        ctr_16 <= ctr_16 + 1;


assign awid_m_inf = 1;
assign awaddr_m_inf = {20'h2, address_4096};
assign awlen_m_inf = 15;
assign awsize_m_inf = 3'b010;
assign awburst_m_inf = 2'b01;

always @(posedge clk)
    if (state == S_IDLE)
        awvalid_m_inf_reg <= 0;
    else if (state == S_WAIT2 && next_state == S_WRITE)
        awvalid_m_inf_reg <= 1;
    else if (next_state == S_OUT)
        awvalid_m_inf_reg <= 0;
    else if (bready_m_inf)
        awvalid_m_inf_reg <= 1;
    else if (state == S_WRITE)
        if (awready_m_inf)
            awvalid_m_inf_reg <= 0;

assign awvalid_m_inf = awvalid_m_inf_reg;


assign wdata_m_inf = {GLCM_matrix[3], GLCM_matrix[2], GLCM_matrix[1], GLCM_matrix[0]};
assign wlast_m_inf = ctr_16 == 15 ? 1 : 0;

always @(posedge clk)
    if (state == S_IDLE)
        wvalid_m_inf_reg <= 0;
    else if (state == S_WRITE)
        if (awready_m_inf)
            wvalid_m_inf_reg <= 1;
        else if (ctr_16 == 15)
            wvalid_m_inf_reg <= 0;

assign wvalid_m_inf = wvalid_m_inf_reg;

always @(posedge clk)
    bready_m_inf_reg <= bvalid_m_inf;

assign bready_m_inf = bready_m_inf_reg;



//=============================================
//  SRAM which words = 4096 and bits = 8
//=============================================
reg [7:0] SRAM_data_in;
wire [7:0] SRAM_data_out;
reg [11:0] SRAM_address;
reg wen;
reg [4:0] ref_reg, c_reg;
reg flag_addr_next;
wire [9:0] index_GLCM;
wire [7:0] addr_offset;
integer i;
 
RA1SH RA1SH (
   .Q(SRAM_data_out),
   .CLK(clk),
   .CEN(1'b0),
   .WEN(wen),
   .A(SRAM_address),
   .D(SRAM_data_in),
   .OEN(1'b0)
);

always @(posedge clk) begin
    c_reg <= SRAM_data_out;
    ref_reg <= c_reg;
end

assign index_GLCM = {ref_reg, c_reg};

always @(posedge clk)
    if (state == S_IDLE)
        for (i = 0; i < 1024; i = i + 1)
            GLCM_matrix[i] <= 0;
    else if ((state == S_COMPUTE || state == S_WAIT2) && flag_addr_next && addr_next)
        GLCM_matrix[index_GLCM] <= GLCM_matrix[index_GLCM] + 1;
    else if (state == S_WRITE)
        if (wready_m_inf)
            for (i = 0; i < 1024; i = i + 1)
                if (i < 1020)
                    GLCM_matrix[i] <= GLCM_matrix[i + 4];
                else
                    GLCM_matrix[i] <= 0;


always @(posedge clk)
    if (state == S_IDLE)
        flag_addr_next <= 0;
    else if (addr_next)
        flag_addr_next <= 1;


always @(*)
    if (state == S_PREFETCH)
        if (rvalid_m_inf)
            wen = 0;
        else
            wen = 1;
    else
        wen = 1;

assign addr_offset = {row_offset, col_offset};

always @(*)
    if (state == S_PREFETCH)
        SRAM_address = address_4096;
    else begin
        if (addr_next)
            SRAM_address = address_4096 + addr_offset;
        else
            SRAM_address = address_4096;
    end

always @(*)
    SRAM_data_in = data[ctr_4];

endmodule







