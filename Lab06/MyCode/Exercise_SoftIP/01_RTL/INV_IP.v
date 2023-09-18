//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : INV_IP.v
//   	Module Name : INV_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module INV_IP #(parameter IP_WIDTH = 6) (
    // Input signals
    IN_1, IN_2,
    // Output signals
    OUT_INV
);

// ===============================================================
// Declaration
// ===============================================================
input wire [IP_WIDTH-1:0] IN_1, IN_2;
output reg [IP_WIDTH-1:0] OUT_INV;

// IP_WIDTH == 7 => NUM = 8
// IP_WIDTH == 6 => NUM = 6
// IP_WIDTH == 5 => NUM = 5
		


wire [IP_WIDTH - 1:0] prime;
wire [IP_WIDTH - 1:0] num;

wire [IP_WIDTH:0] in_1[7:0];
wire [IP_WIDTH:0] in_2[7:0];
wire [IP_WIDTH:0] inverse_1[7:0];
wire [IP_WIDTH:0] inverse_2[7:0];
wire [IP_WIDTH:0] remainder[7:0];
wire [IP_WIDTH:0] inverse[7:0];
wire [IP_WIDTH:0] sum;


assign prime = IN_1 > IN_2 ? IN_1 : IN_2;
assign num = IN_1 > IN_2 ? IN_2 : IN_1;


genvar i;
generate
	if (IP_WIDTH == 7) begin
		for (i = 0; i < 8; i = i + 1) begin : loop_i
			subAndModUnit
			#(.IP_WIDTH(7))
			uut(
				.in_1(in_1[i]), 
				.in_2(in_2[i]),
				.inverse_1(inverse_1[i]),
				.inverse_2(inverse_2[i]),
				.remainder(remainder[i]),
				.inverse(inverse[i])
			);
		end
	end
	else begin
		for (i = 0; i < IP_WIDTH; i = i + 1) begin : loop_i
			subAndModUnit
			#(.IP_WIDTH(IP_WIDTH))
			uut(
				.in_1(in_1[i]), 
				.in_2(in_2[i]),
				.inverse_1(inverse_1[i]),
				.inverse_2(inverse_2[i]),
				.remainder(remainder[i]),
				.inverse(inverse[i])
			);
		end
	end
endgenerate

genvar j;
generate
	if (IP_WIDTH == 7) begin
		for (j = 0; j < 8; j = j + 1) begin : loop_j
			if (j == 0) begin
				assign in_1[0] = {1'b0, prime};
				assign in_2[0] = {1'b0, num};
				assign inverse_1[0] = 0;
				assign inverse_2[0] = 1;
			end
			else begin
				assign in_1[j] = in_2[j - 1];
				assign in_2[j] = remainder[j - 1];
				assign inverse_1[j] = inverse_2[j - 1];
				assign inverse_2[j] = inverse[j - 1];
			end
		end
	end
	else begin
		for (j = 0; j < IP_WIDTH; j = j + 1) begin : loop_j
			if (j == 0) begin
				assign in_1[0] = {1'b0, prime};
				assign in_2[0] = {1'b0, num};
				assign inverse_1[0] = 0;
				assign inverse_2[0] = 1;
			end
			else begin
				assign in_1[j] = in_2[j - 1];
				assign in_2[j] = remainder[j - 1];
				assign inverse_1[j] = inverse_2[j - 1];
				assign inverse_2[j] = inverse[j - 1];
			end
		end
	end
endgenerate
	

generate
	if (IP_WIDTH == 7) begin
		assign sum = inverse[7] + in_1[0];
		
		always @(*)
			OUT_INV = inverse[7][7] ? sum[6:0] : inverse[7][6:0];
	end
	else begin
		assign sum = inverse[IP_WIDTH - 1] + in_1[0];
		
		always @(*)
			OUT_INV = inverse[IP_WIDTH - 1][IP_WIDTH] ? sum[IP_WIDTH - 1:0] : inverse[IP_WIDTH - 1][IP_WIDTH - 1:0];
	end
endgenerate


endmodule

module subAndModUnit #(parameter IP_WIDTH = 6) (
	in_1,
	in_2,
	inverse_1,
	inverse_2,
	remainder,
	inverse,
	);
	
input wire [IP_WIDTH:0] in_1;
input wire [IP_WIDTH:0] in_2;
input wire signed [IP_WIDTH:0] inverse_1;
input wire signed [IP_WIDTH:0] inverse_2;
output reg [IP_WIDTH:0] remainder;
output reg [IP_WIDTH:0] inverse;

wire [IP_WIDTH - 2:0] quotient;

always @(*)
	if (in_2 == 1)
		remainder = 1;
	else
		remainder = in_1 % in_2;
		

assign quotient = in_1 / in_2;
		

always @(*)
	if (in_2 == 1)
		inverse = inverse_2;
	else
		inverse = inverse_1 - inverse_2 * quotient;

endmodule

