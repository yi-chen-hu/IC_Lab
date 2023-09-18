//synopsys translate_off
`include "DW_div.v"
`include "DW_div_seq.v"
`include "DW_div_pipe.v"
//synopsys translate_on

module TRIANGLE(
    clk,
    rst_n,
    in_valid,
    in_length,
    out_cos,
    out_valid,
    out_tri
);
input wire clk, rst_n, in_valid;
input wire [7:0] in_length;

output reg out_valid;
output reg [15:0] out_cos;
output reg [1:0] out_tri;

//=========================
//	parameter
//=========================
parameter a_width = 31;
parameter b_width = 19;
parameter num_cyc = 20;



//=========================
//	wire & reg
//=========================
reg [7:0] A_len, B_len, C_len;
reg [4:0] ctr;
reg [15:0] a_square, b_square, c_square;
reg [16:0] double_bc, double_ac, double_ab;

reg signed [17:0] bca;
reg signed [17:0] acb;
reg signed [17:0] abc;

reg signed [17:0] bca_reg;
reg signed [17:0] acb_reg;
reg signed [17:0] abc_reg;

reg start;
wire complete;
wire [a_width - 1:0] quotient_a, quotient_b, quotient_c;


reg [15:0] out_a;
reg [15:0] out_b;
reg [15:0] out_c;
reg [1:0] mode;

//=========================
//	FSM
//=========================
reg [2:0] state, next_state;

parameter S_IDLE 	= 0;
parameter S_INPUT 	= 1;
parameter S_START 	= 2;
parameter S_DIVIDE 	= 3;
parameter S_SAVE	= 4;
parameter S_OUT1 	= 5;
parameter S_OUT2 	= 6;
parameter S_OUT3 	= 7;

always@(posedge clk or negedge rst_n)
	if (!rst_n)
		state <= S_IDLE;
	else
		state <= next_state;

always@(*)
	case(state)
		S_IDLE: 	next_state = in_valid ? S_INPUT : S_IDLE;
		S_INPUT: 	next_state = !in_valid ? S_START : S_INPUT;
		S_START:	next_state = S_DIVIDE;
		S_DIVIDE:	next_state = complete ? S_SAVE : S_DIVIDE;
		S_SAVE:		next_state = S_OUT1;
		S_OUT1:		next_state = S_OUT2;
		S_OUT2:		next_state = S_OUT3;
		S_OUT3:		next_state = S_IDLE;
		default: 	next_state = S_IDLE;
	endcase

//=========================
//	Design
//=========================

always @(posedge clk)
	if (bca == 0 || acb == 0 || abc == 0)
		mode <= 2'b11;
	else if (bca < 0 || acb < 0 || abc < 0)
		mode <= 2'b01;
	else
		mode <= 2'b00;


always @(posedge clk)
	if (state == S_SAVE) begin
		out_a <= quotient_a[15:0];
		out_b <= quotient_b[15:0];
		out_c <= quotient_c[15:0];
	end
		


always @(*)
	if (state == S_START)
		start <= 1;
	else
		start <= 0;


DW_div_seq #(.a_width(a_width), .b_width(b_width), .tc_mode(1), .num_cyc(num_cyc))
		DIV_A 	(
				.clk(clk),
				.rst_n(rst_n),
				.hold(0),
				.start(start),
				.a({bca_reg, 13'b0}),
				.b({2'b0, double_bc}),
				.complete(complete),
				.quotient(quotient_a)
				);

DW_div_seq #(.a_width(a_width), .b_width(b_width), .tc_mode(1), .num_cyc(num_cyc))
		 DIV_B	(
				.clk(clk),
				.rst_n(rst_n),
				.hold(0),
				.start(start),
				.a({acb_reg, 13'b0}),
				.b({2'b0, double_ac}),
				.quotient(quotient_b)
				);

DW_div_seq #(.a_width(a_width), .b_width(b_width), .tc_mode(1), .num_cyc(num_cyc))
		DIV_C1	(
				.clk(clk),
				.rst_n(rst_n),
				.hold(0),
				.start(start),
				.a({abc_reg, 13'b0}),
				.b({2'b0, double_ab}),
				.quotient(quotient_c)
				);


always @(posedge clk or negedge rst_n)
	if (!rst_n)
		ctr <= 0;
	else if (state == S_OUT1)
		ctr <= 0;
	else if (in_valid)
		ctr <= ctr + 1;
	else if (state == S_INPUT && next_state == S_START)
		ctr <= 0;
	else if (state == S_SAVE)
		ctr <= ctr + 1;


always @(posedge clk)
	if (in_valid && ctr == 0) 
		A_len <= in_length;
	

always @(posedge clk)
	if (in_valid && ctr == 1) 
		B_len <= in_length;

always @(posedge clk)
	if (in_valid && ctr == 2) 
		C_len <= in_length;

always @(*) begin
	a_square = A_len * A_len;
	b_square = B_len * B_len;
	c_square = C_len * C_len;
end



always @(*) begin
	bca = b_square + c_square - a_square;
	acb = a_square + c_square - b_square;
	abc = a_square + b_square - c_square;
end

always @(posedge clk) begin
	bca_reg <= bca;
	acb_reg <= acb;
	abc_reg <= abc;
end


always @(posedge clk) begin
	double_bc <= 2 * B_len * C_len;
	double_ac <= 2 * A_len * C_len;
	double_ab <= 2 * A_len * B_len;
end


always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_valid <= 0;
	else if (state == S_OUT1 || state == S_OUT2 || state == S_OUT3)
		out_valid <= 1;
	else
		out_valid <= 0;


always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_cos <= 0;
	else if (state == S_OUT1)
		out_cos <= out_a;
	else if (state == S_OUT2)
		out_cos <= out_b;
	else if (state == S_OUT3)
		out_cos <= out_c;
	else
		out_cos <= 0;


always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_tri <= 0;
	else if (state == S_OUT1)
		out_tri <= mode;
	else
		out_tri <= 0;




endmodule
