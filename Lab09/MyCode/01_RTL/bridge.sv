module bridge(input clk, INF.bridge_inf inf);
import usertype::*;

//===========================================
//  logic
//===========================================
logic [7:0] address;
logic [63:0] data;

//===========================================
//  FSM
//===========================================
parameter S_IDLE          = 0;
parameter S_WAIT_ARREADY  = 1;
parameter S_WAIT_R_VALID  = 2;
parameter S_WAIT_AW_READY = 3;
parameter S_WAIT_B_VALID  = 4;
parameter S_OUT           = 5;

logic [2:0] state, next_state;

always_ff @(posedge clk or negedge inf.rst_n) begin 
    if (!inf.rst_n) begin
        state <= S_IDLE;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin
    case(state)
        S_IDLE:             next_state = inf.C_in_valid ? (inf.C_r_wb ? S_WAIT_ARREADY : S_WAIT_AW_READY) : S_IDLE;
        S_WAIT_ARREADY:     next_state = inf.AR_READY ? S_WAIT_R_VALID : S_WAIT_ARREADY;
        S_WAIT_R_VALID:     next_state = inf.R_VALID ? S_OUT : S_WAIT_R_VALID;
        S_WAIT_AW_READY:    next_state = inf.AW_READY ? S_WAIT_B_VALID : S_WAIT_AW_READY;
        S_WAIT_B_VALID:     next_state = inf.B_VALID ? S_OUT : S_WAIT_B_VALID;
        S_OUT:              next_state = S_IDLE;
        default:            next_state = S_IDLE;
    endcase
end

//===========================================
//  Design
//===========================================
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        address <= 0;
    end
    else if (inf.C_in_valid) begin
        address <= inf.C_addr;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        data <= 0;
    end
    else if (inf.C_in_valid && !inf.C_r_wb) begin
        data <= inf.C_data_w;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin 
    if (!inf.rst_n) begin
        inf.C_out_valid <= 0 ;
    end
    else if (next_state == S_OUT) begin
        inf.C_out_valid <= 1;
    end
    else begin
        inf.C_out_valid <= 0 ;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin 
        inf.C_data_r <= 0;
    end
    else if (inf.R_VALID) begin
        inf.C_data_r <= inf.R_DATA;
    end
    else begin
        inf.C_data_r <= 0;
    end
end

//===========================================
//  AXI-4
//===========================================
//-------------------------------------------
//  write channel
//-------------------------------------------
always_comb begin
    if (state == S_WAIT_AW_READY) begin
        inf.AW_VALID = 1;
    end
    else begin
        inf.AW_VALID = 0;
    end
end

always_comb begin
    if (state == S_WAIT_AW_READY) begin
        inf.AW_ADDR = {1'b1, 5'b0, address, 3'b0};
        // inf.AW_ADDR = 65536 + address * 8;
    end
    else begin
        inf.AW_ADDR = 0;
    end
end

assign inf.W_DATA = data;

always_comb begin
    if (state == S_WAIT_B_VALID) begin
        inf.W_VALID = 1;
    end
    else begin
        inf.W_VALID = 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.B_READY <= 0;
    end
    else begin
        inf.B_READY <= 1;
    end
end

//-------------------------------------------
//  read channel
//-------------------------------------------
always_comb begin
    if (state == S_WAIT_ARREADY) begin
        inf.AR_VALID = 1;
    end
    else begin
        inf.AR_VALID = 0;
    end
end

always_comb begin
    if (state == S_WAIT_ARREADY) begin
        inf.AR_ADDR = {1'b1, 5'b0, address, 3'b0};
        // inf.AR_ADDR = 65536 + address * 8;
    end
    else begin
        inf.AR_ADDR = 0;
    end
end

always_comb begin
    if (state == S_WAIT_R_VALID) begin
        inf.R_READY = 1;
    end
    else begin
        inf.R_READY = 0;
    end
end

endmodule