module SUBWAY(
    //Input Port
    clk,
    rst_n,
    in_valid,
    init,
    in0,
    in1,
    in2,
    in3,
    //Output Port
    out_valid,
    out
);


input clk, rst_n;
input in_valid;
input [1:0] init;
input [1:0] in0, in1, in2, in3; 
output reg       out_valid;
output reg [1:0] out;


//==============================================//
//       parameter & integer declaration        //
//==============================================//
parameter S_IDLE = 0;
parameter S_INPUT = 1;
parameter S_INPUTANDCOMPUTE = 2;
parameter S_COMPUTEANDOUT = 3;
parameter S_OUT = 4;

integer i, j, ii;

//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [2:0] state, next_state;
reg [1:0] queueOfIn[0:3][0:3];
reg [1:0] queueOfOut[0:59];
reg [5:0] ctr;
reg [1:0] action;
reg [1:0] position;
reg [1:0] position_comb;
reg [1:0] in[3:0];
reg [1:0] exit;
//==============================================//
//                     FSM                      //
//==============================================//
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		state <= S_IDLE;
	else
		state <= next_state;
		
always @(*)
	case(state)
		S_IDLE:				next_state = in_valid ? S_INPUT : S_IDLE;
		S_INPUT:			next_state = ctr == 4 ? S_INPUTANDCOMPUTE : S_INPUT;
		S_INPUTANDCOMPUTE:	next_state = in_valid ? S_INPUTANDCOMPUTE : S_COMPUTEANDOUT;
		S_COMPUTEANDOUT:	next_state = ctr == 4 ? S_OUT : S_COMPUTEANDOUT; // TODO: make sure those ctr condition is correct
		S_OUT:				next_state = ctr == 63 ? S_IDLE : S_OUT;
		default:			next_state = S_IDLE;
	endcase


//==============================================//
//                  design                      //
//==============================================//
always @(posedge clk)
	if (state == S_IDLE && next_state == S_INPUT)
		position <= init;
	else if (next_state == S_INPUTANDCOMPUTE)
		position <= position_comb;
		
always @(*)
	if (action == 2'd1)
		position_comb = position + 1; // TODO: think about it is possible to use one adder instead of use one adder and one subtractor
	else if (action == 2'd2)
		position_comb = position - 1;
	else
		position_comb = position;

always @(posedge clk)
	if (next_state == S_INPUT || next_state == S_COMPUTEANDOUT || next_state == S_OUT)
		ctr <= ctr + 1;
	else
		ctr <= 0;

always @(posedge clk)
	if (next_state == S_IDLE) // TODO: think about it is need to reset when next_state == S_IDLE or not
		for (i = 0; i < 4; i = i + 1)
			for (j = 0; j < 4; j = j + 1)
				queueOfIn[i][j] <= 0;
	else if (next_state == S_INPUT || next_state == S_INPUTANDCOMPUTE || next_state == S_COMPUTEANDOUT)
		for (i = 0; i < 4; i = i + 1)
			for (j = 0; j < 4; j = j + 1)
				if (j == 3) begin
					queueOfIn[0][j] <= in0;
					queueOfIn[1][j] <= in1;
					queueOfIn[2][j] <= in2;
					queueOfIn[3][j] <= in3;
				end
				else
					queueOfIn[i][j] <= queueOfIn[i][j + 1];
	
always @(posedge clk)
	if (next_state == S_IDLE) // TODO: think about it is need to reset when next_state == S_IDLE or not
		for (ii = 0; ii < 60; ii = ii + 1)
				queueOfOut[ii] <= 0;
	else if (next_state == S_INPUTANDCOMPUTE || next_state == S_COMPUTEANDOUT || next_state == S_OUT)
		for (ii = 0; ii < 60; ii = ii + 1)
			if (ii == 59)
				queueOfOut[ii] <= action;
			else
				queueOfOut[ii] <= queueOfOut[ii + 1];
				
assign trainInterval = queueOfIn[0][0] == 2'b11 || queueOfIn[1][0] == 2'b11 || queueOfIn[2][0] == 2'b11 || queueOfIn[3][0] == 2'b11; 
	
always @(*) // TODO: think about it is possible to use less mux or not
	if (next_state == S_INPUTANDCOMPUTE) begin
		if (position == 0) begin
			if (trainInterval) begin
				if (queueOfIn[0][1] == 2'b01)
					action = 2'd3;
				else
					action = 2'd0;
			end
			else if (position < exit && queueOfIn[1][1] == 2'b00)
				action = 2'd1;
			else if (queueOfIn[0][1] == 2'b01)
				action = 2'd3;
			else
				action = 2'd0;
		end
		else if (position == 1) begin
			if (trainInterval) begin
				if (queueOfIn[1][1] == 2'b01)
					action = 2'd3;
				else
					action = 2'd0;
			end
			else if (position < exit && queueOfIn[2][1] == 2'b00)
				action = 2'd1;
			else if (position > exit && queueOfIn[0][1] == 2'b00)
				action = 2'd2;
			else if (queueOfIn[1][1] == 2'b01)
				action = 2'd3;
			else
				action = 2'd0;
		end
		else if (position == 2)
			if (trainInterval) begin
				if (queueOfIn[2][1] == 2'b01)
					action = 2'd3;
				else
					action = 2'd0;
			end
			else if (position < exit && queueOfIn[3][1] == 2'b00)
				action = 2'd1;
			else if (position > exit && queueOfIn[1][1] == 2'b00)
				action = 2'd2;
			else if (queueOfIn[2][1] == 2'b01)
				action = 2'd3;
			else
				action = 2'd0;
		else begin
			if (trainInterval) begin
				if (queueOfIn[3][1] == 2'b01)
					action = 2'd3;
				else
					action = 2'd0;
			end
			else if (position > exit && queueOfIn[2][1] == 2'b00)
				action = 2'd2;
			else if (queueOfIn[3][1] == 2'b01)
				action = 2'd3;
			else
				action = 2'd0;
		end		
	end
	else begin
		if (queueOfIn[position][1] == 2'b01)
			action = 2'd3;
		else
			action = 2'd0;
	end


always @(*) begin
	in[0] = in0;
	in[1] = in1;
	in[2] = in2;
	in[3] = in3;
end

always @(*)
	if (in[position] != 2'b11)
		exit = position;
	else if (in1 != 2'b11 && in2 != 2'b11)
		if (position == 0)
			exit = 1;
		else
			exit = 2;
	else if (in1 != 2'b11)
		exit = 1;
	else if (in2 != 2'b11)
		exit = 2;
	else if (in0 != 2'b11 && in3 != 2'b11)
		if (position == 1)
			exit = 0;
		else
			exit = 3;
	else if (in0 != 2'b11)
		exit = 0;
	else
		exit = 3;
			




always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_valid <= 0;
	else if (next_state == S_COMPUTEANDOUT || next_state == S_OUT)
		out_valid <= 1;
	else
		out_valid <= 0;
		
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out <= 0;
	else if (next_state == S_COMPUTEANDOUT || next_state == S_OUT)
		out <= queueOfOut[0]; // TODO: remember to modify it
	else
		out <= 0;



endmodule

