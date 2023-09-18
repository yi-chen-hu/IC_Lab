//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : EC_TOP.v
//   	Module Name : EC_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "INV_IP.v"
//synopsys translate_on

module EC_TOP(
    // Input signals
    clk, rst_n, in_valid,
    in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a,
    // Output signals
    out_valid, out_Rx, out_Ry
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [6-1:0] in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a;
output reg out_valid;
output reg [6-1:0] out_Rx, out_Ry;

// ===============================================================
// Inst
// ===============================================================
reg [5:0] m01_in1, m01_in2;
wire [11:0] m01_out;

reg [11:0] mod01_in;
reg [5:0] mod01_p;
wire [5:0] mod01_out;

reg [11:0] mod02_in;
reg [5:0] mod02_p;
wire [5:0] mod02_out;

reg signed [7:0] sub01_in1, sub01_in2;
wire signed [7:0] sub01_out;

reg signed [7:0] add01_in1, add01_in2;
wire signed [7:0] add01_out;

reg signed [7:0] add02_in1, add02_in2;
wire signed [7:0] add02_out;

 
mult M01 (.in1(m01_in1), .in2(m01_in2), .out(m01_out));

mod	mod01 (.in(mod01_in), .p(mod01_p), .out(mod01_out));
mod	mod02 (.in(mod02_in), .p(mod02_p), .out(mod02_out));

sub	sub01 (.in1(sub01_in1), .in2(sub01_in2), .out(sub01_out));

add	add01 (.in1(add01_in1), .in2(add01_in2), .out(add01_out));
add	add02 (.in1(add02_in1), .in2(add02_in2), .out(add02_out));

// ===============================================================
// FSM
// ===============================================================
parameter S_IDLE 	= 0;
parameter S_1		= 1;
parameter S_2		= 2;
parameter S_3		= 3;
parameter S_4		= 4;
parameter S_OUT		= 5;

reg [2:0] state, next_state;

always @(posedge clk or negedge rst_n)
	if (!rst_n)
		state <= S_IDLE;
	else
		state <= next_state;
		
always @(*)
	case(state)
		S_IDLE:	next_state = in_valid ? S_1 : S_IDLE;
		S_1:	next_state = S_2;
		S_2:	next_state = S_3;
		S_3:	next_state = S_4;
		S_4:	next_state = S_OUT;
		S_OUT:	next_state = S_IDLE;
		default:next_state = S_IDLE;
	endcase

// ===============================================================
// wire & reg
// ===============================================================
reg [5:0] xp;
reg [5:0] yp;
reg [5:0] xq;
reg [5:0] yq;
reg [5:0] p;
reg [5:0] a;
reg same;
wire [6:0] yp_double;
reg [5:0] dff0, dff1;
wire [6:0] p_double;
reg [5:0] s;
reg [5:0] yr;
wire [5:0] inverse;

// ===============================================================
// Design
// ===============================================================
always @(posedge clk)
	if (in_valid) begin
		xp <= in_Px;
		yp <= in_Py;
		xq <= in_Qx;
		yq <= in_Qy;
		p <= in_prime;
		a <= in_a;
	end
		
always @(*)
	if (xp == xq && yp == yq)
		same = 1;
	else
		same = 0;

// M01
always @(*)
	if (state == S_1) begin
		m01_in1 = xp;
		m01_in2 = xp;
	end
	else if (state == S_2) begin
		m01_in1 = dff0;
		m01_in2 = 6'd3;
	end
	else if (state == S_3) begin
		m01_in1 = dff0;
		m01_in2 = dff1;
	end
	else if (state == S_4) begin
		m01_in1 = dff0;
		m01_in2 = dff0;
	end
	else begin
		m01_in1 = dff1;
		m01_in2 = s;
	end
	


	
// mod01
always @(*) begin
	mod01_in = m01_out;
    mod01_p = p;
end

// always @(*)
	// if (state == S_1) begin
		// mod01_in = m01_out;
		// mod01_p = p;
	// end
	// else if (state == S_2) begin
		// mod01_in = m01_out;
		// mod01_p = p;
	// end
	// else if (state == S_3) begin
		// mod01_in = m01_out;
		// mod01_p = p;
	// end
	// else begin
		// mod01_in = m01_out;
		// mod01_p = p;
	// end
	
	

assign yp_double = yp << 1;

// mod02
always @(*)
	if (state == S_1) begin
		mod02_in = {5'b0, yp_double};
		mod02_p = p;
	end
	else if (state == S_3) begin
		mod02_in = {4'b0, sub01_out};
		mod02_p = p;
	end
	else begin
		mod02_in = {4'b0, add01_out};
		mod02_p = p;
	end
	
// always @(*)
	// if (state == S_1) begin
		// mod02_in = {5'b0, yp_double};
		// mod02_p = p;
	// end
	// else if (state == S_2) begin
		// mod02_in = {4'b0, add01_out};
		// mod02_p = p;
	// end
	// else if (state == S_3) begin
		// mod02_in = {4'b0, sub01_out};
		// mod02_p = p;
	// end
	// else if (state == S_4) begin
		// mod02_in = {4'b0, add01_out};
		// mod02_p = p;
	// end

	
	

assign p_double = p << 1;


// sub01
always @(*)
	if (state == S_1) begin
		sub01_in1 = {2'b0, xq};
		sub01_in2 = {2'b0, xp};
	end
	else if (state == S_2) begin
		sub01_in1 = {2'b0, yq};
		sub01_in2 = {2'b0, yp};
	end
	else if (state == S_3) begin
		sub01_in1 = {1'b0, p_double};
		sub01_in2 = add01_out;
	end
	else if (state == S_4) begin
		sub01_in1 = {2'b0, xp};
		sub01_in2 = {2'b0, mod02_out};
	end
	else begin
		sub01_in1 = {2'b0, mod01_out};
		sub01_in2 = {2'b0, yp};
	end
		
		
// add01
always @(*)
	if (state == S_2) begin
		add01_in1 = {2'b0, mod01_out};
		add01_in2 = {2'b0, a};
	end
	else if (state == S_3) begin
		add01_in1 = {2'b0, xp};
		add01_in2 = {2'b0, xq};
	end
	else begin
		add01_in1 = {2'b0, mod01_out};
		add01_in2 = {2'b0, dff1};
	end

	
	

	
// add02
always @(*) begin
	add02_in1 = sub01_out;
    add02_in2 = {2'b0, p};
end
	
// always @(*)
	// if (state == S_1) begin
		// add02_in1 = sub01_out;
		// add02_in2 = {2'b0, p};
	// end
	// else if (state == S_2) begin
		// add02_in1 = sub01_out;
		// add02_in2 = {2'b0, p};
	// end
	// else if (state == S_4) begin
		// add02_in1 = {2'b0, sub01_out};
		// add02_in2 = {2'b0, p};
	// end
	// else begin
		// add02_in1 = sub01_out;
		// add02_in2 = {2'b0, p};
	// end

always @(posedge clk)
	if (state == S_1) begin
		dff0 <= mod01_out;
	end
	else if (state == S_2) begin
		if (!same) begin
			if (sub01_out[7])
				dff0 <= add02_out[5:0];
			else
				dff0 <= sub01_out[5:0];
		end
		else begin
			dff0 <= mod02_out;
		end	
	end
	else if (state == S_3) begin
		dff0 <= mod01_out;
	end
	else if (state == S_4) begin
		dff0 <= mod02_out;
	end
	
	
	
always @(posedge clk)
	if (state == S_1) begin
		if (!same) begin // point addition
			if (sub01_out[7])
				dff1 <= add02_out[5:0];
			else
				dff1 <= sub01_out[5:0];
		end
		else begin // point doubling
			dff1 <= mod02_out;
		end
	end
	else if (state == S_2) begin
		dff1 <= inverse;
	end
	else if (state == S_3) begin
		dff1 <= mod02_out;
	end
	else if (state == S_4) begin
		if (sub01_out[7])
			dff1 <= add02_out[5:0];
		else
			dff1 <= sub01_out[5:0];
	end
	


INV_IP #(.IP_WIDTH(6)) IP0 (.IN_1(p), .IN_2(dff1), .OUT_INV(inverse));

		


always @(posedge clk)
	if (state == S_3)
		s <= mod01_out;


always @(*)
	if (sub01_out[7])
		yr = add02_out[5:0];
	else
		yr = sub01_out[5:0];


always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_valid <= 0;
	else if (state == S_OUT)
		out_valid <= 1;
	else
		out_valid <= 0;
		
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_Rx <= 0;
	else if (state == S_OUT)
		out_Rx <= dff0;
	else
		out_Rx <= 0;
		
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_Ry <= 0;
	else if (state == S_OUT)
		out_Ry <= yr;
	else
		out_Ry <= 0;


endmodule



module mult (
	in1,
	in2,
	out
	);

input wire [5:0] in1;
input wire [5:0] in2;
output reg [11:0] out;

always @(*)
	out = in1 * in2;

endmodule


module mod (
	in,
	p,
	out
	);
	
input wire [11:0] in;
input wire [5:0] p;
output reg [5:0] out;

always @(*)
	out = in % p;

endmodule


module sub (
	in1,
	in2,
	out
	);
	
input wire signed [7:0] in1;
input wire signed [7:0] in2;
output reg signed [7:0] out;

always @(*)
	out = in1 - in2;

endmodule



module add (
	in1,
	in2,
	out
	);
	
input wire signed [7:0] in1;
input wire signed [7:0] in2;
output reg signed [7:0] out;

always @(*)
	out = in1 + in2;

endmodule