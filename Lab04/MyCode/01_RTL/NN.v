// synopsys translate_off
`include "/usr/synthesis/dw/sim_ver/DW_fp_add.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_mult.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_exp.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_recip.v"
// synopsys translate_on

module NN(
	// Input signals
	clk,
	rst_n,
	in_valid,
	weight_u,
	weight_w,
	weight_v,
	data_x,
	data_h,
	// Output signals
	out_valid,
	out
);

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [inst_sig_width + inst_exp_width:0] weight_u, weight_w, weight_v;
input [inst_sig_width + inst_exp_width:0] data_x,data_h;
output reg out_valid;
output reg [inst_sig_width + inst_exp_width:0] out;

//---------------------------------------------------------------------
//   IP core
//---------------------------------------------------------------------
// multiplier1
reg [inst_sig_width + inst_exp_width:0] ma1;
reg [inst_sig_width + inst_exp_width:0] mb1;
wire [inst_sig_width + inst_exp_width:0] p1;

// multiplier2
reg [inst_sig_width + inst_exp_width:0] ma2;
reg [inst_sig_width + inst_exp_width:0] mb2;
wire [inst_sig_width + inst_exp_width:0] p2;

// multiplier3
reg [inst_sig_width + inst_exp_width:0] ma3;
reg [inst_sig_width + inst_exp_width:0] mb3;
wire [inst_sig_width + inst_exp_width:0] p3;

// adder1
reg [inst_sig_width + inst_exp_width:0] aa1;
reg [inst_sig_width + inst_exp_width:0] ab1;
wire [inst_sig_width + inst_exp_width:0] s1;

// adder2
reg [inst_sig_width + inst_exp_width:0] aa2;
reg [inst_sig_width + inst_exp_width:0] ab2;
wire [inst_sig_width + inst_exp_width:0] s2;

// adder3
reg [inst_sig_width + inst_exp_width:0] aa3;
reg [inst_sig_width + inst_exp_width:0] ab3;
wire [inst_sig_width + inst_exp_width:0] s3;

// exp
reg [inst_sig_width + inst_exp_width:0] ea;
wire [inst_sig_width + inst_exp_width:0] exp;

// recip
reg [inst_sig_width + inst_exp_width:0] ra;
wire [inst_sig_width + inst_exp_width:0] sig;

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
	multiplier1 (
		.a(ma1),
		.b(mb1),
		.rnd(3'b000),
		.z(p1)
		);
																				
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
	multiplier2 (
		.a(ma2),
		.b(mb2),
		.rnd(3'b000),
		.z(p2)
		);

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
	multiplier3 (
		.a(ma3),
		.b(mb3),
		.rnd(3'b000),
		.z(p3)
		);
																				
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
	adder1 (
		.a(aa1),
		.b(ab1),
		.rnd(3'b000),
		.z(s1)
		);
																			
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
	adder2 (
		.a(aa2),
		.b(ab2),
		.rnd(3'b000),
		.z(s2)
		);
																			
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
	adder3 (
		.a(aa3),
		.b(ab3),
		.rnd(3'b000),
		.z(s3)
		);
																			
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
	exponential	(
		.a(ea),
		.z(exp)
		);
																		
DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
	recip (
		.a(s3),
		.rnd(3'b000),
		.z(sig)
		);

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [inst_sig_width + inst_exp_width:0] u[8:0];
reg [inst_sig_width + inst_exp_width:0] w[8:0];
reg [inst_sig_width + inst_exp_width:0] v[8:0];
reg [inst_sig_width + inst_exp_width:0] x[8:0];
reg [inst_sig_width + inst_exp_width:0] h0[2:0];
reg [3:0] ctr;
reg [3:0] prev_ctr;
reg [inst_sig_width + inst_exp_width:0] h[2:0][2:0];
reg [inst_sig_width + inst_exp_width:0] h_comb[2:0];
reg [1:0] idxOfH;
reg [inst_sig_width + inst_exp_width:0] exp1;

//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
parameter S_IDLE 	= 0;
parameter S_INPUT 	= 1;
parameter S_RELU 	= 2;
parameter S_UX 		= 3;
parameter S_WH		= 4;
parameter S_PIPE	= 5;

reg [2:0] state, next_state;

always @(posedge clk or negedge rst_n)
	if (!rst_n)
		state <= S_IDLE;
	else
		state <= next_state;

always @(*)
	case(state)
		S_IDLE:			next_state = in_valid ? S_INPUT : S_IDLE;
		S_INPUT:		next_state = in_valid ? S_INPUT : S_RELU;
		S_RELU:			next_state = idxOfH == 2 ? S_PIPE : S_UX;
		S_UX:			next_state = ctr == 2 ? S_WH : S_UX;
		S_WH:			next_state = ctr == 2 ? S_RELU : S_WH;
		S_PIPE:			next_state = ctr == 10 ? S_IDLE : S_PIPE;
		default:		next_state = S_IDLE;
	endcase

//---------------------------------------------------------------------
//   Design
//---------------------------------------------------------------------
always @(posedge clk)
	if (next_state == S_IDLE || state == S_RELU || (state == S_UX && next_state == S_WH))
		ctr <= 0;
	else
		ctr <= ctr + 1;
	
always @(posedge clk)
	prev_ctr <= ctr;
	
always @(posedge clk)
	if (next_state == S_IDLE)
		idxOfH <= 0;
	else if (state == S_RELU)
		idxOfH <= idxOfH + 1;



always @(posedge clk)
	if (in_valid) begin
		u[0] <= u[1];
		u[1] <= u[2];
		u[2] <= u[3];
		u[3] <= u[4];
		u[4] <= u[5];
		u[5] <= u[6];
		u[6] <= u[7];
		u[7] <= u[8];
		u[8] <= weight_u;
	end
	else if (state == S_UX) begin
		u[0] <= u[3];
		u[1] <= u[4];
		u[2] <= u[5];
		u[3] <= u[6];
		u[4] <= u[7];
		u[5] <= u[8];
		u[6] <= u[0];
		u[7] <= u[1];
		u[8] <= u[2];
	end

always @(posedge clk)
	if (in_valid) begin
		w[0] <= w[1];
		w[1] <= w[2];
		w[2] <= w[3];
		w[3] <= w[4];
		w[4] <= w[5];
		w[5] <= w[6];
		w[6] <= w[7];
		w[7] <= w[8];
		w[8] <= weight_w;
	end
	else if (state == S_WH) begin
		w[0] <= w[3];
		w[1] <= w[4];
		w[2] <= w[5];
		w[3] <= w[6];
		w[4] <= w[7];
		w[5] <= w[8];
		w[6] <= w[0];
		w[7] <= w[1];
		w[8] <= w[2];
	end

always @(posedge clk)
	if (in_valid) begin
		v[0] <= v[1];
		v[1] <= v[2];
		v[2] <= v[3];
		v[3] <= v[4];
		v[4] <= v[5];
		v[5] <= v[6];
		v[6] <= v[7];
		v[7] <= v[8];
		v[8] <= weight_v;
	end
	else if (state == S_PIPE) begin
		v[0] <= v[3];
		v[1] <= v[4];
		v[2] <= v[5];
		v[3] <= v[6];
		v[4] <= v[7];
		v[5] <= v[8];
		v[6] <= v[0];
		v[7] <= v[1];
		v[8] <= v[2];
	end
		
always @(posedge clk)
	if (in_valid)
		x[ctr] <= data_x;
	else if (state == S_RELU) begin
		x[0] <= x[3];
		x[1] <= x[4];
		x[2] <= x[5];
		x[3] <= x[6];
		x[4] <= x[7];
		x[5] <= x[8];
	end

always @(posedge clk)
	if (in_valid) begin
		h0[ctr] <= data_h;
	end

always @(*)
	if (state == S_INPUT)
		ma1 = u[8];
	else if (state == S_RELU)
		ma1 = h[idxOfH][0];
	else if (state == S_UX)
		ma1 = u[0];
	else if (state == S_WH)
		ma1 = w[0];
	else
		ma1 = v[0];

always @(*)
	if (state == S_INPUT)
		mb1 = x[prev_ctr % 'd3]; // TODO: think about whether it is suitable to use (% 'd3)
	else if (state == S_RELU)
		mb1 = 32'b00111101110011001100110011001101; // It is 0.1
	else if (state == S_UX)
		mb1 = x[0];
	else if (state == S_WH)
		mb1 = h[idxOfH - 1][0];
	else
		mb1 = h[0][0];
		
always @(*)
	if (state == S_INPUT)
		ma2 = w[8];
	else if (state == S_RELU)
		ma2 = h[idxOfH][1];
	else if (state == S_UX)
		ma2 = u[1];
	else if (state == S_WH)
		ma2 = w[1];
	else
		ma2 = v[1];

always @(*)
	if (state == S_INPUT)
		mb2 = h0[prev_ctr % 'd3]; // TODO: think about whether it is suitable to use (% 'd3)
	else if (state == S_RELU)
		mb2 = 32'b00111101110011001100110011001101; // It is 0.1
	else if (state == S_UX)
		mb2 = x[1];
	else if (state == S_WH)
		mb2 = h[idxOfH - 1][1];
	else
		mb2 = h[0][1];

	

always @(*)
	if (state == S_RELU)
		ma3 = h[idxOfH][2];
	else if (state == S_UX)
		ma3 = u[2];
	else if (state == S_WH)
		ma3 = w[2];
	else
		ma3 = v[2];
	

always @(*)
	if (state == S_RELU)
		mb3 = 32'b00111101110011001100110011001101; // It is 0.1
	else if (state == S_UX)
		mb3 = x[2];
	else if (state == S_WH)
		mb3 = h[idxOfH - 1][2];
	else
		mb3 = h[0][2];

		
always @(*)
	if (h[idxOfH][0][31])
		h_comb[0] = p1;
	else
		h_comb[0] = h[idxOfH][0];
		
always @(*)
	if (h[idxOfH][1][31])
		h_comb[1] = p2;
	else
		h_comb[1] = h[idxOfH][1];

always @(*)
	if (h[idxOfH][2][31])
		h_comb[2] = p3;
	else
		h_comb[2] = h[idxOfH][2];

always @(posedge clk)
	if (next_state == S_IDLE) begin
		h[0][0] <= 0;
		h[0][1] <= 0;
		h[0][2] <= 0;	
		h[1][0] <= 0;
		h[1][1] <= 0;
		h[1][2] <= 0;	
		h[2][0] <= 0;
		h[2][1] <= 0;
		h[2][2] <= 0;
	end
	else if (state == S_INPUT) begin
		if (prev_ctr < 3)
			h[0][0] <= s2;
		else if (prev_ctr < 6)
			h[0][1] <= s2;
		else
			h[0][2] <= s2;
	end
	else if (state == S_UX)
		h[idxOfH][ctr] <= s2;	
	else if (state == S_WH)
		h[idxOfH][ctr] <= s2;
	else if (state == S_RELU) begin
		h[idxOfH][0] <= h_comb[0];
		h[idxOfH][1] <= h_comb[1];
		h[idxOfH][2] <= h_comb[2];
	end
	else if (state == S_PIPE) begin
		if (ctr == 2 || ctr == 5 || ctr == 8) begin
			h[0][0] <= h[1][0];
			h[0][1] <= h[1][1];
			h[0][2] <= h[1][2];
			h[1][0] <= h[2][0];
			h[1][1] <= h[2][1];
			h[1][2] <= h[2][2];
		end
	end

always @(*)
	if (state == S_INPUT) begin
		if (prev_ctr < 3)
			aa1 = h[idxOfH][0];
		else if (prev_ctr < 6)
			aa1 = h[idxOfH][1];
		else
			aa1 = h[idxOfH][2];
	end
	else
		aa1 = p1;

		
always @(*)
	if (state == S_INPUT)
		ab1 = p1;
	else
		ab1 = p2;
		
always @(*)
	aa2 = s1;
		
always @(*)
	if (state == S_INPUT)
		ab2 = p2;
	else if (state == S_WH)
		ab2 = s3;
	else
		ab2 = p3;
		
always @(posedge clk)
	ea <= {~s2[31], s2[30:0]};
	
always @(posedge clk)
	exp1 <= exp;


always @(*)
	if (state == S_WH)
		aa3 = p3;
	else
		aa3 = exp1;
	
always @(*)
	if (state == S_WH)
		ab3 = h[idxOfH][ctr];
	else
		ab3 = 32'b00111111100000000000000000000000; // It is 1



always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_valid <= 0;
	else if (state == S_PIPE && ctr > 1)
		out_valid <= 1;
	else
		out_valid <= 0;
		
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out <= 0;
	else if (state == S_PIPE && ctr > 1)
		out <= sig;
	else
		out <= 0;


endmodule