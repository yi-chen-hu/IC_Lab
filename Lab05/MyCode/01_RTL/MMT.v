module MMT(
// input signals
    clk,
    rst_n,
    in_valid,
	in_valid2,
    matrix,
	matrix_size,
    matrix_idx,
    mode,
	
// output signals
    out_valid,
    out_value
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input        clk, rst_n, in_valid, in_valid2;
input [7:0] matrix;
input [1:0]  matrix_size,mode;
input [4:0]  matrix_idx;

output reg       	     out_valid;
output reg signed [49:0] out_value;
//---------------------------------------------------------------------
//   integer and parameter
//---------------------------------------------------------------------
integer i;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------

wire [7:0] q[31:0];
reg wen[31:0];
reg [7:0] address[31:0];
reg [7:0] data_in[31:0];

wire [19:0] ab_out;
reg ab_wen;
reg [3:0] ab_address;
reg [19:0] ab_data_in;

wire [7:0] b_q;
reg b_wen;
reg [7:0] b_address;
reg [7:0] b_data_in;

wire [7:0] c_q;
reg c_wen;
reg [7:0] c_address;
reg [7:0] c_data_in;


reg [1:0] ms;
reg [7:0] cap;
reg [7:0] ctr, ctr_comb;
reg [5:0] idx, idx_comb;
reg [1:0] mod;
reg [4:0] idx_matrix[2:0];
reg [3:0] B_col;
reg [3:0] size;
reg [7:0] address_A;
reg [7:0] address_B;
reg [7:0] address_C;
reg [3:0] row;
reg [29:0] mult_a;
reg [29:0] mult_b;
wire [29:0] product;
reg [33:0] add_a;
reg [33:0] add_b;
wire [33:0] sum;
reg [7:0] prev_ctr, prev_prev_ctr;
reg [3:0] prev_B_col;
reg [3:0] prev_row, prev_prev_row;
reg [7:0] q_dff;
reg [33:0] trace_value;
wire same;

//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
reg [2:0] state;
reg [2:0] next_state;
reg [2:0] prev_state;
reg [2:0] prev_prev_state;

parameter S_IDLE 	= 0;
parameter S_INPUT1	= 1;
parameter S_INPUT2 	= 2;
parameter S_AB		= 3;
parameter S_ABC		= 4;
parameter S_OUT 	= 5;
parameter S_WAIT1	= 6;
parameter S_SAVE	= 7;

always @(posedge clk or negedge rst_n)
	if (!rst_n)
		state <= S_IDLE;
	else
		state <= next_state;
		
always @(*)
	case(state)
		S_IDLE:		next_state = in_valid ? S_INPUT1 : (in_valid2 ? S_INPUT2 : S_IDLE);
		S_INPUT1:	next_state = in_valid ? S_INPUT1 : S_IDLE;
		S_INPUT2:	next_state = in_valid2 ? S_INPUT2 : (same ? S_SAVE : S_AB);
		S_SAVE:		next_state = ctr == cap ? S_WAIT1 : S_SAVE;
		S_WAIT1:	next_state = S_AB;
		S_AB:		next_state = B_col == size && ctr == size ? S_ABC : S_AB;
		S_ABC:		next_state = ctr == size ? (row == size ? S_OUT : S_WAIT1) : S_ABC;
		S_OUT:		next_state = S_IDLE;
	endcase

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
genvar iii;
generate
	for (iii = 0; iii < 32; iii = iii + 1) begin: SRAM
		RA1SH SRAM (
			.Q(q[iii]),
			.CLK(clk),
			.CEN(1'b0),
			.WEN(wen[iii]),
			.A(address[iii]),
			.D(matrix),
			.OEN(1'b0)
			);
	end
endgenerate



RA1SH B (
	.Q(b_q),
	.CLK(clk),
	.CEN(1'b0),
	.WEN(b_wen),
	.A(b_address),
	.D(b_data_in),
	.OEN(1'b0)
	);
	
RA1SH C (
	.Q(c_q),
	.CLK(clk),
	.CEN(1'b0),
	.WEN(c_wen),
	.A(c_address),
	.D(c_data_in),
	.OEN(1'b0)
	);

always @(*)
	if (prev_state == S_SAVE)
		b_wen = 0;
	else
		b_wen = 1;
		
always @(*)
	if (prev_state == S_SAVE)
		c_wen = 0;
	else
		c_wen = 1;
		
always @(*)
	if (prev_state == S_SAVE)
		b_address = prev_ctr;
	else // else if (state == S_AB)
		b_address = address_B;
	
always @(*)
	if (prev_state == S_SAVE)
		c_address = prev_ctr;
	else // else if (state == S_ABC)
		c_address = address_C;
		
always @(*)
	b_data_in = q[idx_matrix[1]];
	// if (prev_state == S_SAVE)
		// b_data_in = q[idx_matrix[1]];
	// else
		// b_data_in = 0;
		
always @(*)
	c_data_in = q[idx_matrix[2]];
	// if (prev_state == S_SAVE)
		// c_data_in = q[idx_matrix[2]];
	// else
		// c_data_in = 0;



always @(posedge clk)
	if (state == S_IDLE && next_state == S_INPUT1)
		ms <= matrix_size;

always @(*)
	case(ms)
		0:		cap = 3;
		1:		cap = 15;
		2:		cap = 63;
		default:cap = 255;
	endcase
	
always @(*)
	case(ms)
		0:		size = 1;
		1:		size = 3;
		2:		size = 7;
		default:size = 15;
	endcase

	
always @(posedge clk)
	ctr <= ctr_comb;
		
always @(*)
	if (in_valid) begin
		if (ctr == cap)
			ctr_comb = 0;
		else
			ctr_comb = ctr + 1;
	end
	else if (state == S_IDLE)
		ctr_comb = 0;
	else if (state == S_SAVE) begin
		if (ctr == cap)
			ctr_comb = 0;
		else
			ctr_comb = ctr + 1;
	end
	else if (state == S_AB) begin
		if (ctr == size)
			ctr_comb = 0;
		else
			ctr_comb = ctr + 1;
	end
	else if (state == S_ABC) begin
		if (ctr == size)
			ctr_comb = 0;
		else
			ctr_comb = ctr + 1;
	end
	else
		ctr_comb = ctr;

always @(posedge clk)
	if (state == S_INPUT2)
		B_col <= 0;
	else if (state == S_AB && next_state == S_ABC)
		B_col <= 0;
	else if (state == S_WAIT1)
		B_col <= 0;
	else if (state == S_AB && ctr == size)
		B_col <= B_col + 1;

	
always @(posedge clk)
	if (state == S_INPUT2)
		row <= 0;
	else if (state == S_WAIT1 && prev_state != S_SAVE)
		row <= row + 1;

		
always @(posedge clk)
	idx <= idx_comb;
		
always @(*)
	if (in_valid2)
		idx_comb = idx + 1;
	else if (state == S_IDLE)
		idx_comb = 0;
	else if (ctr == cap)
		idx_comb = idx + 1;
	else
		idx_comb = idx;

always @(*)
	if (in_valid)
		for (i = 0; i < 32; i = i + 1)
			if (i == idx)
				wen[i] = 0;
			else
				wen[i] = 1;
	else
		for (i = 0; i < 32; i = i + 1)
			wen[i] = 1;
			
			
always @(*)
	if (mod == 2'b01) begin
		if (ms == 0)
			address_A = {6'b0, ctr[0], row[0]};
		else if (ms == 1)
			address_A = {4'b0, ctr[1:0], row[1:0]};
		else if (ms == 2)
			address_A = {2'b0, ctr[2:0], row[2:0]};
		else
			address_A = {ctr[3:0], row[3:0]};
	end	
	else begin
		if (ms == 0)
			address_A = {6'b0, row[0], ctr[0]};
		else if (ms == 1)
			address_A = {4'b0, row[1:0], ctr[1:0]};
		else if (ms == 2)
			address_A = {2'b0, row[2:0], ctr[2:0]};
		else
			address_A = {row[3:0], ctr[3:0]};
	end

always @(*)
	if (mod == 2'b10) begin
		if (ms == 0)
			address_B = {6'b0, B_col[0], ctr[0]};
		else if (ms == 1)
			address_B = {4'b0, B_col[1:0], ctr[1:0]};
		else if (ms == 2)
			address_B = {2'b0, B_col[2:0], ctr[2:0]};
		else
			address_B = {B_col[3:0], ctr[3:0]};
	end	
	else begin
		if (ms == 0)
			address_B = {6'b0, ctr[0], B_col[0]};
		else if (ms == 1)
			address_B = {4'b0, ctr[1:0], B_col[1:0]};
		else if (ms == 2)
			address_B = {2'b0, ctr[2:0], B_col[2:0]};
		else
			address_B = {ctr[3:0], B_col[3:0]};
	end
		
always @(*)
	if (mod == 2'b11) begin
		if (ms == 0)
			address_C = {6'b0, row[0], ctr[0]};
		else if (ms == 1)
			address_C = {4'b0, row[1:0], ctr[1:0]};
		else if (ms == 2)
			address_C = {2'b0, row[2:0], ctr[2:0]};
		else
			address_C = {row[3:0], ctr[3:0]};
	end	
	else begin
		if (ms == 0)
			address_C = {6'b0, ctr[0], row[0]};
		else if (ms == 1)
			address_C = {4'b0, ctr[1:0], row[1:0]};
		else if (ms == 2)
			address_C = {2'b0, ctr[2:0], row[2:0]};
		else
			address_C = {ctr[3:0], row[3:0]};
	end



	
always @(*)
	if (in_valid)
		for (i = 0; i < 32; i = i + 1)
			address[i] = ctr;
	else if (state == S_SAVE)
		for (i = 0; i < 32; i = i + 1)
			address[i] = ctr;
	else if (state == S_AB)
		for (i = 0; i < 32; i = i + 1)
			if (i == idx_matrix[0])
				address[i] = address_A;
			else // else if (i == idx_matrix[1])
				address[i] = address_B;
	else if (state == S_ABC)
		for (i = 0; i < 32; i = i + 1)
			address[i] = address_C;
	else
		for (i = 0; i < 32; i = i + 1)
			address[i] = address_C;
			
			
always @(posedge clk)
	if (state == S_IDLE && next_state == S_INPUT2)
		mod <= mode;
	else if (state == S_IDLE)
		mod <= 0;
		

always @(posedge clk)
	if (in_valid2) begin
		idx_matrix[0] <= idx_matrix[1];
		idx_matrix[1] <= idx_matrix[2];
		idx_matrix[2] <= matrix_idx;
	end
	
assign same = idx_matrix[0] == idx_matrix[1] || idx_matrix[1] == idx_matrix[2] || idx_matrix[0] == idx_matrix[2];

				
RA1SH_20bit AB (
	.Q(ab_out),
	.CLK(clk),
	.CEN(1'b0),
	.WEN(ab_wen),
	.A(ab_address),
	.D(ab_data_in),
	.OEN(1'b0)
	);

always @(posedge clk) begin
	prev_state <= state;
	prev_prev_state <= prev_state;
end

always @(posedge clk) begin
	prev_ctr <= ctr;
	prev_prev_ctr <= prev_ctr;
end

always @(posedge clk)
	if (same)
		q_dff <= c_q;
	else
		q_dff <= q[idx_matrix[2]];



always @(*)
	if (prev_prev_state == S_ABC)
		mult_a = ab_out[19] ? {{10{1'b1}}, ab_out} : {{10{1'b0}}, ab_out};
	else // else if (prev_state == S_AB)
		mult_a = q[idx_matrix[0]][7] ? {{22{1'b1}}, q[idx_matrix[0]]} : {{22{1'b0}}, q[idx_matrix[0]]};
		
always @(*)
	if (prev_prev_state == S_ABC)
		mult_b = q_dff[7] ? {{22{1'b1}}, q_dff} : {{22{1'b0}}, q_dff};
	else begin // else if (prev_state == S_AB)
		if (same)
			mult_b = b_q[7] ? {{22{1'b1}}, b_q} : {{22{1'b0}}, b_q};
		else
			mult_b = q[idx_matrix[1]][7] ? {{22{1'b1}}, q[idx_matrix[1]]} : {{22{1'b0}}, q[idx_matrix[1]]};
	end
	
// always @(*)
	// if (prev_prev_state == S_ABC)
		// add_a = product[29] ? {{4{1'b1}}, product} : {{4{1'b0}}, product};
	// else if (prev_state == S_AB)
		// add_a = product[29] ? {{4{1'b1}}, product} : {{4{1'b0}}, product};
	// else
		// add_a = 0;
		
always @(*)
	add_a = product[29] ? {{4{1'b1}}, product} : {{4{1'b0}}, product};
		

	


		
// always @(*)
	// if (prev_prev_state == S_ABC)
		// add_b = trace_value;
	// else if (prev_state == S_AB)
		// if (prev_ctr == 0)
			// add_b = 0;
		// else
			// add_b = ab_out[19] ? {{30{1'b1}}, ab_out} : {{30{1'b0}}, ab_out};
	// else
		// add_b = 0;
		
		
always @(*)
	if (prev_prev_state == S_ABC)
		add_b = trace_value;
	else begin
		if (prev_ctr == 0)
			add_b = 0;
		else
			add_b = ab_out[19] ? {{30{1'b1}}, ab_out} : {{30{1'b0}}, ab_out};
	end
			
always @(*)
	if (prev_state == S_AB)
		ab_wen = 0;
	else // else if (prev_state == S_ABC)
		ab_wen = 1;
		
always @(posedge clk)
	prev_B_col <= B_col;

always @(*)
	if (prev_state == S_AB)
		ab_address = prev_B_col;
	else // else if (prev_state == S_ABC)
		ab_address = prev_ctr;
		
// always @(*)
	// if (prev_state == S_AB)
		// ab_data_in = sum;
	// else
		// ab_data_in = 0;
		
always @(*)
	ab_data_in = sum;
		

		
always @(posedge clk) begin
	prev_row <= row;
	prev_prev_row <= prev_row;
end



always @(posedge clk)
	if (prev_prev_state == S_IDLE)
		trace_value <= 0;
	else if (prev_prev_state == S_ABC)
		trace_value <= sum;

		


multiplier multiplier (
	.a(mult_a),
	.b(mult_b),
	.product(product)
	);


adder adder (
	.a(add_a),
	.b(add_b),
	.sum(sum)
	);



always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_valid <= 0;
	else if (prev_prev_state == S_OUT)
		out_valid <= 1;
	else
		out_valid <= 0;

	
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_value <= 0;
	else if (prev_prev_state == S_OUT)
		out_value <= trace_value[33] ? {{16{1'b1}}, trace_value} : {{16{1'b0}}, trace_value};
	else
		out_value <= 0;


endmodule


module multiplier(
	a,
	b,
	product
	);

input signed [29:0] a;
input signed [29:0] b;
output reg [29:0] product;

always @(*)
	product = a * b;

endmodule

module adder(
	a,
	b,
	sum
	);

input signed [33:0] a;
input signed [33:0] b;
output reg [33:0] sum;

always @(*)
	sum = a + b;

endmodule