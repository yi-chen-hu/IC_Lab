module QUEEN(
    //Input Port
    clk,
    rst_n,

    in_valid,
    col,
    row,

    in_valid_num,
    in_num,

    out_valid,
    out,

    );

input               clk, rst_n, in_valid,in_valid_num;
input       [3:0]   col,row;
input       [2:0]   in_num;

output reg          out_valid;
output reg  [3:0]   out;

//==============================================//
//                 reg declaration              //
//==============================================//
reg [3:0] state;
reg [3:0] next_state;
reg P[11:0][11:0], P_comb[11:0][11:0];
reg Q[11:0][11:0], Q_comb[11:0][11:0];
wire RowYes[11:0];
wire ColYes[11:0];
wire pS[22:0];
wire nS[22:0];
reg [3:0] i, j, ii, jj, x, y, k;
wire noSolution;
wire dead;
wire done;
reg [11:0] allOne;
reg [11:0] flagCol;
wire [11:0] flagCol_comb;
reg [3:0] selRow, selRow_comb;
reg [3:0] selCol, selCol_comb;
reg [3:0] rowOfQueenStack[11:0];
reg [3:0] colOfQueenStack[11:0];
reg [3:0] tail[11:0];
reg [3:0] tail_comb[11:0];
reg [3:0] tail_case[11:0];
wire [11:0] col_12[11:0];
reg [3:0] rowReg;
reg [3:0] colReg;
reg full;
reg [3:0] stack_dff1, stack_dff2;
reg [2:0] num;
reg [3:0] ctr;
reg [3:0] out_comb;
//==============================================//
//             Parameter and Integer            //
//==============================================//
parameter S_IDLE 	= 0;
parameter S_INPUT 	= 1;
parameter S_NEXTCOL	= 2;
parameter S_RETURN  = 3;
parameter S_OUT     = 4;
parameter S_RETURN1 = 5;
parameter S_TRYDOWN = 6;
parameter S_TRYDOWN1 = 7;
parameter S_NEXTCOL1 = 8;
//==============================================//
//            FSM State Declaration             //
//==============================================//
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		state <= S_IDLE;
	else
		state <= next_state;
		
always @(*)
	case(state)
		S_IDLE: 	next_state = in_valid ? S_INPUT : S_IDLE;
		S_INPUT: 	next_state = in_valid ? S_INPUT : S_NEXTCOL1;
		S_NEXTCOL:	next_state = noSolution ? S_RETURN : (done ? S_OUT : S_NEXTCOL1);
		S_NEXTCOL1: next_state = S_NEXTCOL;
		S_RETURN:   next_state = S_RETURN1;
		S_RETURN1:  next_state = full ? S_RETURN : S_TRYDOWN;
		S_TRYDOWN:  next_state = S_TRYDOWN1;
		S_TRYDOWN1: next_state = noSolution ? (full ? S_RETURN : S_TRYDOWN) : S_NEXTCOL1;
		S_OUT: 		next_state = ctr == 12 ? S_IDLE : S_OUT;
		default: 	next_state = S_IDLE;
	endcase


//==============================================//
//                  Input Block                 //
//==============================================//
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		num <= 0;
	else if (in_valid_num)
		num <= in_num;


always @(*)
	case(stack_dff2)
		0: 		full = P[1][selCol] & P[2][selCol] & P[3][selCol] & P[4][selCol] & P[5][selCol] & P[6][selCol] & P[7][selCol] & P[8][selCol] & P[9][selCol] & P[10][selCol] & P[11][selCol];
		1:		full = P[2][selCol] & P[3][selCol] & P[4][selCol] & P[5][selCol] & P[6][selCol] & P[7][selCol] & P[8][selCol] & P[9][selCol] & P[10][selCol] & P[11][selCol];
		2:		full = P[3][selCol] & P[4][selCol] & P[5][selCol] & P[6][selCol] & P[7][selCol] & P[8][selCol] & P[9][selCol] & P[10][selCol] & P[11][selCol];
		3:		full = P[4][selCol] & P[5][selCol] & P[6][selCol] & P[7][selCol] & P[8][selCol] & P[9][selCol] & P[10][selCol] & P[11][selCol];
		4:		full = P[5][selCol] & P[6][selCol] & P[7][selCol] & P[8][selCol] & P[9][selCol] & P[10][selCol] & P[11][selCol];
		5:		full = P[6][selCol] & P[7][selCol] & P[8][selCol] & P[9][selCol] & P[10][selCol] & P[11][selCol];
		6:		full = P[7][selCol] & P[8][selCol] & P[9][selCol] & P[10][selCol] & P[11][selCol];
		7:		full = P[8][selCol] & P[9][selCol] & P[10][selCol] & P[11][selCol];
		8:		full = P[9][selCol] & P[10][selCol] & P[11][selCol];
		9:		full = P[10][selCol] & P[11][selCol];
		10:		full = P[11][selCol];
		default:full = 1;
	endcase


always @(posedge clk)	
	if (next_state == S_IDLE) begin
		rowOfQueenStack[0]  <= 12;
		rowOfQueenStack[1]  <= 12;
		rowOfQueenStack[2]  <= 12;
		rowOfQueenStack[3]  <= 12;
		rowOfQueenStack[4]  <= 12;
		rowOfQueenStack[5]  <= 12;
		rowOfQueenStack[6]  <= 12;
		rowOfQueenStack[7]  <= 12;
		rowOfQueenStack[8]  <= 12;
		rowOfQueenStack[9]  <= 12;
		rowOfQueenStack[10] <= 12;
		rowOfQueenStack[11] <= 12;
	end
	else if (next_state == S_NEXTCOL || next_state == S_TRYDOWN1) begin      
		rowOfQueenStack[0]  <= rowOfQueenStack[1];
		rowOfQueenStack[1]  <= rowOfQueenStack[2];
		rowOfQueenStack[2]  <= rowOfQueenStack[3];
		rowOfQueenStack[3]  <= rowOfQueenStack[4];
		rowOfQueenStack[4]  <= rowOfQueenStack[5];
		rowOfQueenStack[5]  <= rowOfQueenStack[6];
		rowOfQueenStack[6]  <= rowOfQueenStack[7];
		rowOfQueenStack[7]  <= rowOfQueenStack[8];
		rowOfQueenStack[8]  <= rowOfQueenStack[9];
		rowOfQueenStack[9]  <= rowOfQueenStack[10];
		rowOfQueenStack[10] <= rowOfQueenStack[11];
		rowOfQueenStack[11] <= selRow;
	end
	else if (next_state == S_RETURN) begin
		rowOfQueenStack[0]  <= 12;
		rowOfQueenStack[1]  <= rowOfQueenStack[0];
		rowOfQueenStack[2]  <= rowOfQueenStack[1];
		rowOfQueenStack[3]  <= rowOfQueenStack[2];
		rowOfQueenStack[4]  <= rowOfQueenStack[3];
		rowOfQueenStack[5]  <= rowOfQueenStack[4];
		rowOfQueenStack[6]  <= rowOfQueenStack[5];
		rowOfQueenStack[7]  <= rowOfQueenStack[6];
		rowOfQueenStack[8]  <= rowOfQueenStack[7];
		rowOfQueenStack[9]  <= rowOfQueenStack[8];
		rowOfQueenStack[10] <= rowOfQueenStack[9];
		rowOfQueenStack[11] <= rowOfQueenStack[10];
	end


/*
always @(posedge clk)
	case(next_state)
		S_IDLE:		begin
					rowOfQueenStack[0]  <= 12;
					rowOfQueenStack[1]  <= 12;
					rowOfQueenStack[2]  <= 12;
					rowOfQueenStack[3]  <= 12;
					rowOfQueenStack[4]  <= 12;
					rowOfQueenStack[5]  <= 12;
					rowOfQueenStack[6]  <= 12;
					rowOfQueenStack[7]  <= 12;
					rowOfQueenStack[8]  <= 12;
					rowOfQueenStack[9]  <= 12;
					rowOfQueenStack[10] <= 12;
					rowOfQueenStack[11] <= 12;
					end
		S_NEXTCOL:	begin
					rowOfQueenStack[0]  <= rowOfQueenStack[1];
					rowOfQueenStack[1]  <= rowOfQueenStack[2];
					rowOfQueenStack[2]  <= rowOfQueenStack[3];
					rowOfQueenStack[3]  <= rowOfQueenStack[4];
					rowOfQueenStack[4]  <= rowOfQueenStack[5];
					rowOfQueenStack[5]  <= rowOfQueenStack[6];
					rowOfQueenStack[6]  <= rowOfQueenStack[7];
					rowOfQueenStack[7]  <= rowOfQueenStack[8];
					rowOfQueenStack[8]  <= rowOfQueenStack[9];
					rowOfQueenStack[9]  <= rowOfQueenStack[10];
					rowOfQueenStack[10] <= rowOfQueenStack[11];
					rowOfQueenStack[11] <= selRow;
					end
		S_TRYDOWN1:	begin
					rowOfQueenStack[0]  <= rowOfQueenStack[1];
					rowOfQueenStack[1]  <= rowOfQueenStack[2];
					rowOfQueenStack[2]  <= rowOfQueenStack[3];
					rowOfQueenStack[3]  <= rowOfQueenStack[4];
					rowOfQueenStack[4]  <= rowOfQueenStack[5];
					rowOfQueenStack[5]  <= rowOfQueenStack[6];
					rowOfQueenStack[6]  <= rowOfQueenStack[7];
					rowOfQueenStack[7]  <= rowOfQueenStack[8];
					rowOfQueenStack[8]  <= rowOfQueenStack[9];
					rowOfQueenStack[9]  <= rowOfQueenStack[10];
					rowOfQueenStack[10] <= rowOfQueenStack[11];
					rowOfQueenStack[11] <= selRow;
					end
		S_RETURN:	begin
					rowOfQueenStack[0]  <= 12;
					rowOfQueenStack[1]  <= rowOfQueenStack[0];
					rowOfQueenStack[2]  <= rowOfQueenStack[1];
					rowOfQueenStack[3]  <= rowOfQueenStack[2];
					rowOfQueenStack[4]  <= rowOfQueenStack[3];
					rowOfQueenStack[5]  <= rowOfQueenStack[4];
					rowOfQueenStack[6]  <= rowOfQueenStack[5];
					rowOfQueenStack[7]  <= rowOfQueenStack[6];
					rowOfQueenStack[8]  <= rowOfQueenStack[7];
					rowOfQueenStack[9]  <= rowOfQueenStack[8];
					rowOfQueenStack[10] <= rowOfQueenStack[9];
					rowOfQueenStack[11] <= rowOfQueenStack[10];
					end
		endcase
*/					

always @(posedge clk)	
	if (next_state == S_IDLE) begin
		colOfQueenStack[0]  <= 12;
		colOfQueenStack[1]  <= 12;
		colOfQueenStack[2]  <= 12;
		colOfQueenStack[3]  <= 12;
		colOfQueenStack[4]  <= 12;
		colOfQueenStack[5]  <= 12;
		colOfQueenStack[6]  <= 12;
		colOfQueenStack[7]  <= 12;
		colOfQueenStack[8]  <= 12;
		colOfQueenStack[9]  <= 12;
		colOfQueenStack[10] <= 12;
		colOfQueenStack[11] <= 12;
	end
	else if (next_state == S_NEXTCOL || next_state == S_TRYDOWN1) begin      
		colOfQueenStack[0]  <= colOfQueenStack[1];
		colOfQueenStack[1]  <= colOfQueenStack[2];
		colOfQueenStack[2]  <= colOfQueenStack[3];
		colOfQueenStack[3]  <= colOfQueenStack[4];
		colOfQueenStack[4]  <= colOfQueenStack[5];
		colOfQueenStack[5]  <= colOfQueenStack[6];
		colOfQueenStack[6]  <= colOfQueenStack[7];
		colOfQueenStack[7]  <= colOfQueenStack[8];
		colOfQueenStack[8]  <= colOfQueenStack[9];
		colOfQueenStack[9]  <= colOfQueenStack[10];
		colOfQueenStack[10] <= colOfQueenStack[11];
		colOfQueenStack[11] <= selCol;
	end
	else if (next_state == S_RETURN) begin
		colOfQueenStack[0]  <= 12;
		colOfQueenStack[1]  <= colOfQueenStack[0];
		colOfQueenStack[2]  <= colOfQueenStack[1];
		colOfQueenStack[3]  <= colOfQueenStack[2];
		colOfQueenStack[4]  <= colOfQueenStack[3];
		colOfQueenStack[5]  <= colOfQueenStack[4];
		colOfQueenStack[6]  <= colOfQueenStack[5];
		colOfQueenStack[7]  <= colOfQueenStack[6];
		colOfQueenStack[8]  <= colOfQueenStack[7];
		colOfQueenStack[9]  <= colOfQueenStack[8];
		colOfQueenStack[10] <= colOfQueenStack[9];
		colOfQueenStack[11] <= colOfQueenStack[10];
	end

always @(*)
	for (k = 0; k < 12; k = k + 1)
		allOne[k] = P[0][k] & P[1][k] & P[2][k]  & P[3][k] & P[4][k] & P[5][k] & P[6][k] & P[7][k] & P[8][k] & P[9][k] & P[10][k] & P[11][k];


assign noSolution = flagCol == allOne ? 0 : 1;

assign done = colOfQueenStack[num] != 12 ? 1 : 0;

always @(posedge clk or negedge rst_n)
	if (!rst_n)
		flagCol <= 0;
	else
		flagCol <= flagCol_comb;

assign flagCol_comb = {ColYes[11], ColYes[10], ColYes[9], ColYes[8], ColYes[7], ColYes[6], ColYes[5], ColYes[4], ColYes[3], ColYes[2], ColYes[1], ColYes[0]};
		
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		selCol <= 0;
	else
		selCol <= selCol_comb;
		
always @(*)
	casez(flagCol_comb)
		12'b???????????0: selCol_comb = 0;
		12'b??????????01: selCol_comb = 1;
		12'b?????????011: selCol_comb = 2;
		12'b????????0111: selCol_comb = 3;
		12'b???????01111: selCol_comb = 4;
		12'b??????011111: selCol_comb = 5;
		12'b?????0111111: selCol_comb = 6;
		12'b????01111111: selCol_comb = 7;
		12'b???011111111: selCol_comb = 8;
		12'b??0111111111: selCol_comb = 9;
		12'b?01111111111: selCol_comb = 10;
		default:		  selCol_comb = 11;
	endcase

always @(posedge clk or negedge rst_n)
	if (!rst_n)
		selRow <= 0;
	else
		selRow <= selRow_comb;

always @(posedge clk) begin
	stack_dff1 <= rowOfQueenStack[11]; 
	stack_dff2 <= stack_dff1;
end

always @(*)
	if (next_state == S_TRYDOWN)
		case(stack_dff2)
			0:		if (P[1][selCol] == 0)
						selRow_comb = 1;
					else if (P[2][selCol] == 0)
						selRow_comb = 2;
					else if (P[3][selCol] == 0)
						selRow_comb = 3;
					else if (P[4][selCol] == 0)
						selRow_comb = 4;
					else if (P[5][selCol] == 0)
						selRow_comb = 5;
					else if (P[6][selCol] == 0)
						selRow_comb = 6;
					else if (P[7][selCol] == 0)
						selRow_comb = 7;
					else if (P[8][selCol] == 0)
						selRow_comb = 8;
					else if (P[9][selCol] == 0)
						selRow_comb = 9;
					else if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			1:		if (P[2][selCol] == 0)
						selRow_comb = 2;
					else if (P[3][selCol] == 0)
						selRow_comb = 3;
					else if (P[4][selCol] == 0)
						selRow_comb = 4;
					else if (P[5][selCol] == 0)
						selRow_comb = 5;
					else if (P[6][selCol] == 0)
						selRow_comb = 6;
					else if (P[7][selCol] == 0)
						selRow_comb = 7;
					else if (P[8][selCol] == 0)
						selRow_comb = 8;
					else if (P[9][selCol] == 0)
						selRow_comb = 9;
					else if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			2:		if (P[3][selCol] == 0)
						selRow_comb = 3;
					else if (P[4][selCol] == 0)
						selRow_comb = 4;
					else if (P[5][selCol] == 0)
						selRow_comb = 5;
					else if (P[6][selCol] == 0)
						selRow_comb = 6;
					else if (P[7][selCol] == 0)
						selRow_comb = 7;
					else if (P[8][selCol] == 0)
						selRow_comb = 8;
					else if (P[9][selCol] == 0)
						selRow_comb = 9;
					else if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			3:		if (P[4][selCol] == 0)
						selRow_comb = 4;
					else if (P[5][selCol] == 0)
						selRow_comb = 5;
					else if (P[6][selCol] == 0)
						selRow_comb = 6;
					else if (P[7][selCol] == 0)
						selRow_comb = 7;
					else if (P[8][selCol] == 0)
						selRow_comb = 8;
					else if (P[9][selCol] == 0)
						selRow_comb = 9;
					else if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			4:		if (P[5][selCol] == 0)
						selRow_comb = 5;
					else if (P[6][selCol] == 0)
						selRow_comb = 6;
					else if (P[7][selCol] == 0)
						selRow_comb = 7;
					else if (P[8][selCol] == 0)
						selRow_comb = 8;
					else if (P[9][selCol] == 0)
						selRow_comb = 9;
					else if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			5:		if (P[6][selCol] == 0)
						selRow_comb = 6;
					else if (P[7][selCol] == 0)
						selRow_comb = 7;
					else if (P[8][selCol] == 0)
						selRow_comb = 8;
					else if (P[9][selCol] == 0)
						selRow_comb = 9;
					else if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			6:		if (P[7][selCol] == 0)
						selRow_comb = 7;
					else if (P[8][selCol] == 0)
						selRow_comb = 8;
					else if (P[9][selCol] == 0)
						selRow_comb = 9;
					else if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			7:		if (P[8][selCol] == 0)
						selRow_comb = 8;
					else if (P[9][selCol] == 0)
						selRow_comb = 9;
					else if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			8:		if (P[9][selCol] == 0)
						selRow_comb = 9;
					else if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			9:		if (P[10][selCol] == 0)
						selRow_comb = 10;
					else
						selRow_comb = 11;
			default:selRow_comb = 11;
		endcase	
	else
		if (P[0][selCol_comb] == 0)
			selRow_comb = 0;
		else if (P[1][selCol_comb] == 0)
			selRow_comb = 1;
		else if (P[2][selCol_comb] == 0)
			selRow_comb = 2;   
		else if (P[3][selCol_comb] == 0)
			selRow_comb = 3;   
		else if (P[4][selCol_comb] == 0)
			selRow_comb = 4;   
		else if (P[5][selCol_comb] == 0)
			selRow_comb = 5;   
		else if (P[6][selCol_comb] == 0)
			selRow_comb = 6;   
		else if (P[7][selCol_comb] == 0)
			selRow_comb = 7; 
		else if (P[8][selCol_comb] == 0)
			selRow_comb = 8;   
		else if (P[9][selCol_comb] == 0)
			selRow_comb = 9;
		else if (P[10][selCol_comb] == 0)
			selRow_comb = 10;
		else
			selRow_comb = 11;



always @(posedge clk or negedge rst_n)
	if (!rst_n)
		for (i = 0; i < 12; i = i + 1)
			for (j = 0; j < 12; j = j + 1)
				P[i][j] <= 0;
	else
		for (i = 0; i < 12; i = i + 1)
			for (j = 0; j < 12; j = j + 1)
				P[i][j] <= P_comb[i][j];
				
always @(*) begin
	P_comb[0][0]   = RowYes[0] | ColYes[0]  | pS[0]  | nS[11];
	P_comb[0][1]   = RowYes[0] | ColYes[1]  | pS[1]  | nS[10];
	P_comb[0][2]   = RowYes[0] | ColYes[2]  | pS[2]  | nS[9];
	P_comb[0][3]   = RowYes[0] | ColYes[3]  | pS[3]  | nS[8];
	P_comb[0][4]   = RowYes[0] | ColYes[4]  | pS[4]  | nS[7];
	P_comb[0][5]   = RowYes[0] | ColYes[5]  | pS[5]  | nS[6];
	P_comb[0][6]   = RowYes[0] | ColYes[6]  | pS[6]  | nS[5];
	P_comb[0][7]   = RowYes[0] | ColYes[7]  | pS[7]  | nS[4];
	P_comb[0][8]   = RowYes[0] | ColYes[8]  | pS[8]  | nS[3];
	P_comb[0][9]   = RowYes[0] | ColYes[9]  | pS[9]  | nS[2];
	P_comb[0][10]  = RowYes[0] | ColYes[10] | pS[10] | nS[1];
	P_comb[0][11]  = RowYes[0] | ColYes[11] | pS[11] | nS[0];
	
	P_comb[1][0]   = RowYes[1] | ColYes[0]  | pS[1]  | nS[12];
	P_comb[1][1]   = RowYes[1] | ColYes[1]  | pS[2]  | nS[11];
	P_comb[1][2]   = RowYes[1] | ColYes[2]  | pS[3]  | nS[10];
	P_comb[1][3]   = RowYes[1] | ColYes[3]  | pS[4]  | nS[9];
	P_comb[1][4]   = RowYes[1] | ColYes[4]  | pS[5]  | nS[8];
	P_comb[1][5]   = RowYes[1] | ColYes[5]  | pS[6]  | nS[7];
	P_comb[1][6]   = RowYes[1] | ColYes[6]  | pS[7]  | nS[6];
	P_comb[1][7]   = RowYes[1] | ColYes[7]  | pS[8]  | nS[5];
	P_comb[1][8]   = RowYes[1] | ColYes[8]  | pS[9]  | nS[4];
	P_comb[1][9]   = RowYes[1] | ColYes[9]  | pS[10] | nS[3];
	P_comb[1][10]  = RowYes[1] | ColYes[10] | pS[11] | nS[2];
	P_comb[1][11]  = RowYes[1] | ColYes[11] | pS[12] | nS[1];
	
	P_comb[2][0]   = RowYes[2] | ColYes[0]  | pS[2]  | nS[13];
	P_comb[2][1]   = RowYes[2] | ColYes[1]  | pS[3]  | nS[12];
	P_comb[2][2]   = RowYes[2] | ColYes[2]  | pS[4]  | nS[11];
	P_comb[2][3]   = RowYes[2] | ColYes[3]  | pS[5]  | nS[10];
	P_comb[2][4]   = RowYes[2] | ColYes[4]  | pS[6]  | nS[9];
	P_comb[2][5]   = RowYes[2] | ColYes[5]  | pS[7]  | nS[8];
	P_comb[2][6]   = RowYes[2] | ColYes[6]  | pS[8]  | nS[7];
	P_comb[2][7]   = RowYes[2] | ColYes[7]  | pS[9]  | nS[6];
	P_comb[2][8]   = RowYes[2] | ColYes[8]  | pS[10] | nS[5];
	P_comb[2][9]   = RowYes[2] | ColYes[9]  | pS[11] | nS[4];
	P_comb[2][10]  = RowYes[2] | ColYes[10] | pS[12] | nS[3];
	P_comb[2][11]  = RowYes[2] | ColYes[11] | pS[13] | nS[2];

	P_comb[3][0]   = RowYes[3] | ColYes[0]  | pS[3]  | nS[14];
	P_comb[3][1]   = RowYes[3] | ColYes[1]  | pS[4]  | nS[13];
	P_comb[3][2]   = RowYes[3] | ColYes[2]  | pS[5]  | nS[12];
	P_comb[3][3]   = RowYes[3] | ColYes[3]  | pS[6]  | nS[11];
	P_comb[3][4]   = RowYes[3] | ColYes[4]  | pS[7]  | nS[10];
	P_comb[3][5]   = RowYes[3] | ColYes[5]  | pS[8]  | nS[9];
	P_comb[3][6]   = RowYes[3] | ColYes[6]  | pS[9]  | nS[8];
	P_comb[3][7]   = RowYes[3] | ColYes[7]  | pS[10] | nS[7];
	P_comb[3][8]   = RowYes[3] | ColYes[8]  | pS[11] | nS[6];
	P_comb[3][9]   = RowYes[3] | ColYes[9]  | pS[12] | nS[5];
	P_comb[3][10]  = RowYes[3] | ColYes[10] | pS[13] | nS[4];
	P_comb[3][11]  = RowYes[3] | ColYes[11] | pS[14] | nS[3];
	
	P_comb[4][0]   = RowYes[4] | ColYes[0]  | pS[4]  | nS[15];
	P_comb[4][1]   = RowYes[4] | ColYes[1]  | pS[5]  | nS[14];
	P_comb[4][2]   = RowYes[4] | ColYes[2]  | pS[6]  | nS[13];
	P_comb[4][3]   = RowYes[4] | ColYes[3]  | pS[7]  | nS[12];
	P_comb[4][4]   = RowYes[4] | ColYes[4]  | pS[8]  | nS[11];
	P_comb[4][5]   = RowYes[4] | ColYes[5]  | pS[9]  | nS[10];
	P_comb[4][6]   = RowYes[4] | ColYes[6]  | pS[10] | nS[9];
	P_comb[4][7]   = RowYes[4] | ColYes[7]  | pS[11] | nS[8];
	P_comb[4][8]   = RowYes[4] | ColYes[8]  | pS[12] | nS[7];
	P_comb[4][9]   = RowYes[4] | ColYes[9]  | pS[13] | nS[6];
	P_comb[4][10]  = RowYes[4] | ColYes[10] | pS[14] | nS[5];
	P_comb[4][11]  = RowYes[4] | ColYes[11] | pS[15] | nS[4];
	
	P_comb[5][0]   = RowYes[5] | ColYes[0]  | pS[5]  | nS[16];
	P_comb[5][1]   = RowYes[5] | ColYes[1]  | pS[6]  | nS[15];
	P_comb[5][2]   = RowYes[5] | ColYes[2]  | pS[7]  | nS[14];
	P_comb[5][3]   = RowYes[5] | ColYes[3]  | pS[8]  | nS[13];
	P_comb[5][4]   = RowYes[5] | ColYes[4]  | pS[9]  | nS[12];
	P_comb[5][5]   = RowYes[5] | ColYes[5]  | pS[10] | nS[11];
	P_comb[5][6]   = RowYes[5] | ColYes[6]  | pS[11] | nS[10];
	P_comb[5][7]   = RowYes[5] | ColYes[7]  | pS[12] | nS[9];
	P_comb[5][8]   = RowYes[5] | ColYes[8]  | pS[13] | nS[8];
	P_comb[5][9]   = RowYes[5] | ColYes[9]  | pS[14] | nS[7];
	P_comb[5][10]  = RowYes[5] | ColYes[10] | pS[15] | nS[6];
	P_comb[5][11]  = RowYes[5] | ColYes[11] | pS[16] | nS[5];
	
	P_comb[6][0]   = RowYes[6] | ColYes[0]  | pS[6]  | nS[17];
	P_comb[6][1]   = RowYes[6] | ColYes[1]  | pS[7]  | nS[16];
	P_comb[6][2]   = RowYes[6] | ColYes[2]  | pS[8]  | nS[15];
	P_comb[6][3]   = RowYes[6] | ColYes[3]  | pS[9]  | nS[14];
	P_comb[6][4]   = RowYes[6] | ColYes[4]  | pS[10] | nS[13];
	P_comb[6][5]   = RowYes[6] | ColYes[5]  | pS[11] | nS[12];
	P_comb[6][6]   = RowYes[6] | ColYes[6]  | pS[12] | nS[11];
	P_comb[6][7]   = RowYes[6] | ColYes[7]  | pS[13] | nS[10];
	P_comb[6][8]   = RowYes[6] | ColYes[8]  | pS[14] | nS[9];
	P_comb[6][9]   = RowYes[6] | ColYes[9]  | pS[15] | nS[8];
	P_comb[6][10]  = RowYes[6] | ColYes[10] | pS[16] | nS[7];
	P_comb[6][11]  = RowYes[6] | ColYes[11] | pS[17] | nS[6];
	
	P_comb[7][0]   = RowYes[7] | ColYes[0]  | pS[7]  | nS[18];
	P_comb[7][1]   = RowYes[7] | ColYes[1]  | pS[8]  | nS[17];
	P_comb[7][2]   = RowYes[7] | ColYes[2]  | pS[9]  | nS[16];
	P_comb[7][3]   = RowYes[7] | ColYes[3]  | pS[10] | nS[15];
	P_comb[7][4]   = RowYes[7] | ColYes[4]  | pS[11] | nS[14];
	P_comb[7][5]   = RowYes[7] | ColYes[5]  | pS[12] | nS[13];
	P_comb[7][6]   = RowYes[7] | ColYes[6]  | pS[13] | nS[12];
	P_comb[7][7]   = RowYes[7] | ColYes[7]  | pS[14] | nS[11];
	P_comb[7][8]   = RowYes[7] | ColYes[8]  | pS[15] | nS[10];
	P_comb[7][9]   = RowYes[7] | ColYes[9]  | pS[16] | nS[9];
	P_comb[7][10]  = RowYes[7] | ColYes[10] | pS[17] | nS[8];
	P_comb[7][11]  = RowYes[7] | ColYes[11] | pS[18] | nS[7];
	
	P_comb[8][0]   = RowYes[8] | ColYes[0]  | pS[8]  | nS[19];
	P_comb[8][1]   = RowYes[8] | ColYes[1]  | pS[9]  | nS[18];
	P_comb[8][2]   = RowYes[8] | ColYes[2]  | pS[10] | nS[17];
	P_comb[8][3]   = RowYes[8] | ColYes[3]  | pS[11] | nS[16];
	P_comb[8][4]   = RowYes[8] | ColYes[4]  | pS[12] | nS[15];
	P_comb[8][5]   = RowYes[8] | ColYes[5]  | pS[13] | nS[14];
	P_comb[8][6]   = RowYes[8] | ColYes[6]  | pS[14] | nS[13];
	P_comb[8][7]   = RowYes[8] | ColYes[7]  | pS[15] | nS[12];
	P_comb[8][8]   = RowYes[8] | ColYes[8]  | pS[16] | nS[11];
	P_comb[8][9]   = RowYes[8] | ColYes[9]  | pS[17] | nS[10];
	P_comb[8][10]  = RowYes[8] | ColYes[10] | pS[18] | nS[9];
	P_comb[8][11]  = RowYes[8] | ColYes[11] | pS[19] | nS[8];
	                                                    
	P_comb[9][0]   = RowYes[9] | ColYes[0]  | pS[9]  | nS[20];
	P_comb[9][1]   = RowYes[9] | ColYes[1]  | pS[10] | nS[19];
	P_comb[9][2]   = RowYes[9] | ColYes[2]  | pS[11] | nS[18];
	P_comb[9][3]   = RowYes[9] | ColYes[3]  | pS[12] | nS[17];
	P_comb[9][4]   = RowYes[9] | ColYes[4]  | pS[13] | nS[16];
	P_comb[9][5]   = RowYes[9] | ColYes[5]  | pS[14] | nS[15];
	P_comb[9][6]   = RowYes[9] | ColYes[6]  | pS[15] | nS[14];
	P_comb[9][7]   = RowYes[9] | ColYes[7]  | pS[16] | nS[13];
	P_comb[9][8]   = RowYes[9] | ColYes[8]  | pS[17] | nS[12];
	P_comb[9][9]   = RowYes[9] | ColYes[9]  | pS[18] | nS[11];
	P_comb[9][10]  = RowYes[9] | ColYes[10] | pS[19] | nS[10];
	P_comb[9][11]  = RowYes[9] | ColYes[11] | pS[20] | nS[9];
	
	P_comb[10][0]   = RowYes[10] | ColYes[0]  | pS[10] | nS[21];
	P_comb[10][1]   = RowYes[10] | ColYes[1]  | pS[11] | nS[20];
	P_comb[10][2]   = RowYes[10] | ColYes[2]  | pS[12] | nS[19];
	P_comb[10][3]   = RowYes[10] | ColYes[3]  | pS[13] | nS[18];
	P_comb[10][4]   = RowYes[10] | ColYes[4]  | pS[14] | nS[17];
	P_comb[10][5]   = RowYes[10] | ColYes[5]  | pS[15] | nS[16];
	P_comb[10][6]   = RowYes[10] | ColYes[6]  | pS[16] | nS[15];
	P_comb[10][7]   = RowYes[10] | ColYes[7]  | pS[17] | nS[14];
	P_comb[10][8]   = RowYes[10] | ColYes[8]  | pS[18] | nS[13];
	P_comb[10][9]   = RowYes[10] | ColYes[9]  | pS[19] | nS[12];
	P_comb[10][10]  = RowYes[10] | ColYes[10] | pS[20] | nS[11];
	P_comb[10][11]  = RowYes[10] | ColYes[11] | pS[21] | nS[10];
	
	P_comb[11][0]   = RowYes[11] | ColYes[0]  | pS[11] | nS[22];
	P_comb[11][1]   = RowYes[11] | ColYes[1]  | pS[12] | nS[21];
	P_comb[11][2]   = RowYes[11] | ColYes[2]  | pS[13] | nS[20];
	P_comb[11][3]   = RowYes[11] | ColYes[3]  | pS[14] | nS[19];
	P_comb[11][4]   = RowYes[11] | ColYes[4]  | pS[15] | nS[18];
	P_comb[11][5]   = RowYes[11] | ColYes[5]  | pS[16] | nS[17];
	P_comb[11][6]   = RowYes[11] | ColYes[6]  | pS[17] | nS[16];
	P_comb[11][7]   = RowYes[11] | ColYes[7]  | pS[18] | nS[15];
	P_comb[11][8]   = RowYes[11] | ColYes[8]  | pS[19] | nS[14];
	P_comb[11][9]   = RowYes[11] | ColYes[9]  | pS[20] | nS[13];
	P_comb[11][10]  = RowYes[11] | ColYes[10] | pS[21] | nS[12];
	P_comb[11][11]  = RowYes[11] | ColYes[11] | pS[22] | nS[11];
end	
	
assign nS[0]  = Q_comb[0][11];
assign nS[1]  = Q_comb[0][10] | Q_comb[1][11];
assign nS[2]  = Q_comb[0][9]  | Q_comb[1][10] | Q_comb[2][11];
assign nS[3]  = Q_comb[0][8]  | Q_comb[1][9]  | Q_comb[2][10] | Q_comb[3][11];
assign nS[4]  = Q_comb[0][7]  | Q_comb[1][8]  | Q_comb[2][9]  | Q_comb[3][10] | Q_comb[4][11];
assign nS[5]  = Q_comb[0][6]  | Q_comb[1][7]  | Q_comb[2][8]  | Q_comb[3][9]  | Q_comb[4][10] | Q_comb[5][11];
assign nS[6]  = Q_comb[0][5]  | Q_comb[1][6]  | Q_comb[2][7]  | Q_comb[3][8]  | Q_comb[4][9]  | Q_comb[5][10] | Q_comb[6][11];
assign nS[7]  = Q_comb[0][4]  | Q_comb[1][5]  | Q_comb[2][6]  | Q_comb[3][7]  | Q_comb[4][8]  | Q_comb[5][9]  | Q_comb[6][10] | Q_comb[7][11];
assign nS[8]  = Q_comb[0][3]  |	Q_comb[1][4]  | Q_comb[2][5]  | Q_comb[3][6]  | Q_comb[4][7]  | Q_comb[5][8]  | Q_comb[6][9]  | Q_comb[7][10] | Q_comb[8][11]; 
assign nS[9]  = Q_comb[0][2]  | Q_comb[1][3]  | Q_comb[2][4]  | Q_comb[3][5]  | Q_comb[4][6]  | Q_comb[5][7]  | Q_comb[6][8]  | Q_comb[7][9]  | Q_comb[8][10] | Q_comb[9][11];
assign nS[10] = Q_comb[0][1]  | Q_comb[1][2]  | Q_comb[2][3]  | Q_comb[3][4]  | Q_comb[4][5]  | Q_comb[5][6]  | Q_comb[6][7]  | Q_comb[7][8]  | Q_comb[8][9]  | Q_comb[9][10] | Q_comb[10][11];
assign nS[11] = Q_comb[0][0]  | Q_comb[1][1]  | Q_comb[2][2]  | Q_comb[3][3]  | Q_comb[4][4]  | Q_comb[5][5]  | Q_comb[6][6]  | Q_comb[7][7]  | Q_comb[8][8]  | Q_comb[9][9]  | Q_comb[10][10] | Q_comb[11][11];
assign nS[12] = Q_comb[1][0]  | Q_comb[2][1]  | Q_comb[3][2]  | Q_comb[4][3]  | Q_comb[5][4]  | Q_comb[6][5]  | Q_comb[7][6]  | Q_comb[8][7]  | Q_comb[9][8]  | Q_comb[10][9] | Q_comb[11][10];                                                                                                              
assign nS[13] = Q_comb[2][0]  | Q_comb[3][1]  | Q_comb[4][2]  | Q_comb[5][3]  | Q_comb[6][4]  | Q_comb[7][5]  | Q_comb[8][6]  | Q_comb[9][7]  | Q_comb[10][8] | Q_comb[11][9];
assign nS[14] = Q_comb[3][0]  | Q_comb[4][1]  | Q_comb[5][2]  | Q_comb[6][3]  | Q_comb[7][4]  | Q_comb[8][5]  | Q_comb[9][6]  | Q_comb[10][7] | Q_comb[11][8];
assign nS[15] = Q_comb[4][0]  | Q_comb[5][1]  | Q_comb[6][2]  | Q_comb[7][3]  | Q_comb[8][4]  | Q_comb[9][5]  | Q_comb[10][6] | Q_comb[11][7];
assign nS[16] = Q_comb[5][0]  | Q_comb[6][1]  | Q_comb[7][2]  | Q_comb[8][3]  | Q_comb[9][4]  | Q_comb[10][5] | Q_comb[11][6];
assign nS[17] = Q_comb[6][0]  | Q_comb[7][1]  | Q_comb[8][2]  | Q_comb[9][3]  | Q_comb[10][4] | Q_comb[11][5];
assign nS[18] = Q_comb[7][0]  | Q_comb[8][1]  | Q_comb[9][2]  | Q_comb[10][3] | Q_comb[11][4];                
assign nS[19] = Q_comb[8][0]  | Q_comb[9][1]  | Q_comb[10][2] | Q_comb[11][3];
assign nS[20] = Q_comb[9][0]  | Q_comb[10][1] | Q_comb[11][2];
assign nS[21] = Q_comb[10][0] | Q_comb[11][1];
assign nS[22] = Q_comb[11][0];



assign pS[0]  = Q_comb[0][0];
assign pS[1]  = Q_comb[0][1]  | Q_comb[1][0];
assign pS[2]  = Q_comb[0][2]  | Q_comb[1][1]  | Q_comb[2][0];
assign pS[3]  = Q_comb[0][3]  | Q_comb[1][2]  | Q_comb[2][1]  | Q_comb[3][0];
assign pS[4]  = Q_comb[0][4]  | Q_comb[1][3]  | Q_comb[2][2]  | Q_comb[3][1]  | Q_comb[4][0];
assign pS[5]  = Q_comb[0][5]  | Q_comb[1][4]  | Q_comb[2][3]  | Q_comb[3][2]  | Q_comb[4][1]  | Q_comb[5][0];
assign pS[6]  = Q_comb[0][6]  | Q_comb[1][5]  | Q_comb[2][4]  | Q_comb[3][3]  | Q_comb[4][2]  | Q_comb[5][1]  | Q_comb[6][0];
assign pS[7]  = Q_comb[0][7]  | Q_comb[1][6]  | Q_comb[2][5]  | Q_comb[3][4]  | Q_comb[4][3]  | Q_comb[5][2]  | Q_comb[6][1]  | Q_comb[7][0];
assign pS[8]  = Q_comb[0][8]  |	Q_comb[1][7]  | Q_comb[2][6]  | Q_comb[3][5]  | Q_comb[4][4]  | Q_comb[5][3]  | Q_comb[6][2]  | Q_comb[7][1]  | Q_comb[8][0]; 
assign pS[9]  = Q_comb[0][9]  | Q_comb[1][8]  | Q_comb[2][7]  | Q_comb[3][6]  | Q_comb[4][5]  | Q_comb[5][4]  | Q_comb[6][3]  | Q_comb[7][2]  | Q_comb[8][1]  | Q_comb[9][0];
assign pS[10] = Q_comb[0][10] | Q_comb[1][9]  | Q_comb[2][8]  | Q_comb[3][7]  | Q_comb[4][6]  | Q_comb[5][5]  | Q_comb[6][4]  | Q_comb[7][3]  | Q_comb[8][2]  | Q_comb[9][1]  | Q_comb[10][0];
assign pS[11] = Q_comb[0][11] | Q_comb[1][10] | Q_comb[2][9]  | Q_comb[3][8]  | Q_comb[4][7]  | Q_comb[5][6]  | Q_comb[6][5]  | Q_comb[7][4]  | Q_comb[8][3]  | Q_comb[9][2]  | Q_comb[10][1] | Q_comb[11][0];
assign pS[12] = Q_comb[1][11] | Q_comb[2][10] | Q_comb[3][9]  | Q_comb[4][8]  | Q_comb[5][7]  | Q_comb[6][6]  | Q_comb[7][5]  | Q_comb[8][4]  | Q_comb[9][3]  | Q_comb[10][2] | Q_comb[11][1];                                                                                                              
assign pS[13] = Q_comb[2][11] | Q_comb[3][10] | Q_comb[4][9]  | Q_comb[5][8]  | Q_comb[6][7]  | Q_comb[7][6]  | Q_comb[8][5]  | Q_comb[9][4]  | Q_comb[10][3] | Q_comb[11][2];
assign pS[14] = Q_comb[3][11] | Q_comb[4][10] | Q_comb[5][9]  | Q_comb[6][8]  | Q_comb[7][7]  | Q_comb[8][6]  | Q_comb[9][5]  | Q_comb[10][4] | Q_comb[11][3];
assign pS[15] = Q_comb[4][11] | Q_comb[5][10] | Q_comb[6][9]  | Q_comb[7][8]  | Q_comb[8][7]  | Q_comb[9][6]  | Q_comb[10][5] | Q_comb[11][4];
assign pS[16] = Q_comb[5][11] | Q_comb[6][10] | Q_comb[7][9]  | Q_comb[8][8]  | Q_comb[9][7]  | Q_comb[10][6] | Q_comb[11][5];
assign pS[17] = Q_comb[6][11] | Q_comb[7][10] | Q_comb[8][9]  | Q_comb[9][8]  | Q_comb[10][7] | Q_comb[11][6];
assign pS[18] = Q_comb[7][11] | Q_comb[8][10] | Q_comb[9][9]  | Q_comb[10][8] | Q_comb[11][7];                
assign pS[19] = Q_comb[8][11] | Q_comb[9][10] | Q_comb[10][9] | Q_comb[11][8];
assign pS[20] = Q_comb[9][11] | Q_comb[10][10]| Q_comb[11][9];
assign pS[21] = Q_comb[10][11]| Q_comb[11][10];
assign pS[22] = Q_comb[11][11];



assign RowYes[0] = Q_comb[0][0] | Q_comb[0][1] | Q_comb[0][2]  | Q_comb[0][3] 
				 | Q_comb[0][4] | Q_comb[0][5] | Q_comb[0][6]  | Q_comb[0][7] 
				 | Q_comb[0][8] | Q_comb[0][9] | Q_comb[0][10] | Q_comb[0][11];

assign RowYes[1] = Q_comb[1][0] | Q_comb[1][1] | Q_comb[1][2]  | Q_comb[1][3] 
				 | Q_comb[1][4] | Q_comb[1][5] | Q_comb[1][6]  | Q_comb[1][7] 
				 | Q_comb[1][8] | Q_comb[1][9] | Q_comb[1][10] | Q_comb[1][11];

assign RowYes[2] = Q_comb[2][0] | Q_comb[2][1] | Q_comb[2][2]  | Q_comb[2][3] 
				 | Q_comb[2][4] | Q_comb[2][5] | Q_comb[2][6]  | Q_comb[2][7] 
				 | Q_comb[2][8] | Q_comb[2][9] | Q_comb[2][10] | Q_comb[2][11];

assign RowYes[3] = Q_comb[3][0] | Q_comb[3][1] | Q_comb[3][2]  | Q_comb[3][3] 
				 | Q_comb[3][4] | Q_comb[3][5] | Q_comb[3][6]  | Q_comb[3][7] 
				 | Q_comb[3][8] | Q_comb[3][9] | Q_comb[3][10] | Q_comb[3][11];

assign RowYes[4] = Q_comb[4][0] | Q_comb[4][1] | Q_comb[4][2]  | Q_comb[4][3] 
				 | Q_comb[4][4] | Q_comb[4][5] | Q_comb[4][6]  | Q_comb[4][7] 
				 | Q_comb[4][8] | Q_comb[4][9] | Q_comb[4][10] | Q_comb[4][11];

assign RowYes[5] = Q_comb[5][0] | Q_comb[5][1] | Q_comb[5][2]  | Q_comb[5][3] 
				 | Q_comb[5][4] | Q_comb[5][5] | Q_comb[5][6]  | Q_comb[5][7] 
				 | Q_comb[5][8] | Q_comb[5][9] | Q_comb[5][10] | Q_comb[5][11];

assign RowYes[6] = Q_comb[6][0] | Q_comb[6][1] | Q_comb[6][2]  | Q_comb[6][3] 
				 | Q_comb[6][4] | Q_comb[6][5] | Q_comb[6][6]  | Q_comb[6][7] 
				 | Q_comb[6][8] | Q_comb[6][9] | Q_comb[6][10] | Q_comb[6][11];

assign RowYes[7] = Q_comb[7][0] | Q_comb[7][1] | Q_comb[7][2]  | Q_comb[7][3] 
				 | Q_comb[7][4] | Q_comb[7][5] | Q_comb[7][6]  | Q_comb[7][7] 
				 | Q_comb[7][8] | Q_comb[7][9] | Q_comb[7][10] | Q_comb[7][11];

assign RowYes[8] = Q_comb[8][0] | Q_comb[8][1] | Q_comb[8][2]  | Q_comb[8][3] 
				 | Q_comb[8][4] | Q_comb[8][5] | Q_comb[8][6]  | Q_comb[8][7] 
				 | Q_comb[8][8] | Q_comb[8][9] | Q_comb[8][10] | Q_comb[8][11];

assign RowYes[9] = Q_comb[9][0] | Q_comb[9][1] | Q_comb[9][2]  | Q_comb[9][3] 
				 | Q_comb[9][4] | Q_comb[9][5] | Q_comb[9][6]  | Q_comb[9][7] 
				 | Q_comb[9][8] | Q_comb[9][9] | Q_comb[9][10] | Q_comb[9][11];

assign RowYes[10]= Q_comb[10][0] | Q_comb[10][1] | Q_comb[10][2]  | Q_comb[10][3] 
				 | Q_comb[10][4] | Q_comb[10][5] | Q_comb[10][6]  | Q_comb[10][7] 
				 | Q_comb[10][8] | Q_comb[10][9] | Q_comb[10][10] | Q_comb[10][11];

assign RowYes[11]= Q_comb[11][0] | Q_comb[11][1] | Q_comb[11][2]  | Q_comb[11][3] 
				 | Q_comb[11][4] | Q_comb[11][5] | Q_comb[11][6]  | Q_comb[11][7] 
				 | Q_comb[11][8] | Q_comb[11][9] | Q_comb[11][10] | Q_comb[11][11];	

assign ColYes[0] = Q_comb[0][0] | Q_comb[1][0] |  Q_comb[2][0] |  Q_comb[3][0]
				 | Q_comb[4][0] | Q_comb[5][0] |  Q_comb[6][0] |  Q_comb[7][0]
				 | Q_comb[8][0] | Q_comb[9][0] | Q_comb[10][0] | Q_comb[11][0];

assign ColYes[1] = Q_comb[0][1] | Q_comb[1][1] |  Q_comb[2][1] |  Q_comb[3][1]
				 | Q_comb[4][1] | Q_comb[5][1] |  Q_comb[6][1] |  Q_comb[7][1]
				 | Q_comb[8][1] | Q_comb[9][1] | Q_comb[10][1] | Q_comb[11][1];
				 
assign ColYes[2] = Q_comb[0][2] | Q_comb[1][2] |  Q_comb[2][2] |  Q_comb[3][2]
				 | Q_comb[4][2] | Q_comb[5][2] |  Q_comb[6][2] |  Q_comb[7][2]
				 | Q_comb[8][2] | Q_comb[9][2] | Q_comb[10][2] | Q_comb[11][2];

assign ColYes[3] = Q_comb[0][3] | Q_comb[1][3] |  Q_comb[2][3] |  Q_comb[3][3]
				 | Q_comb[4][3] | Q_comb[5][3] |  Q_comb[6][3] |  Q_comb[7][3]
				 | Q_comb[8][3] | Q_comb[9][3] | Q_comb[10][3] | Q_comb[11][3];
				 
assign ColYes[4] = Q_comb[0][4] | Q_comb[1][4] |  Q_comb[2][4] |  Q_comb[3][4]
				 | Q_comb[4][4] | Q_comb[5][4] |  Q_comb[6][4] |  Q_comb[7][4]
				 | Q_comb[8][4] | Q_comb[9][4] | Q_comb[10][4] | Q_comb[11][4];

assign ColYes[5] = Q_comb[0][5] | Q_comb[1][5] |  Q_comb[2][5] |  Q_comb[3][5]
				 | Q_comb[4][5] | Q_comb[5][5] |  Q_comb[6][5] |  Q_comb[7][5]
				 | Q_comb[8][5] | Q_comb[9][5] | Q_comb[10][5] | Q_comb[11][5];

assign ColYes[6] = Q_comb[0][6] | Q_comb[1][6] |  Q_comb[2][6] |  Q_comb[3][6]
				 | Q_comb[4][6] | Q_comb[5][6] |  Q_comb[6][6] |  Q_comb[7][6]
				 | Q_comb[8][6] | Q_comb[9][6] | Q_comb[10][6] | Q_comb[11][6];

assign ColYes[7] = Q_comb[0][7] | Q_comb[1][7] |  Q_comb[2][7] |  Q_comb[3][7]
				 | Q_comb[4][7] | Q_comb[5][7] |  Q_comb[6][7] |  Q_comb[7][7]
				 | Q_comb[8][7] | Q_comb[9][7] | Q_comb[10][7] | Q_comb[11][7];

assign ColYes[8] = Q_comb[0][8] | Q_comb[1][8] |  Q_comb[2][8] |  Q_comb[3][8]
				 | Q_comb[4][8] | Q_comb[5][8] |  Q_comb[6][8] |  Q_comb[7][8]
				 | Q_comb[8][8] | Q_comb[9][8] | Q_comb[10][8] | Q_comb[11][8];

assign ColYes[9] = Q_comb[0][9] | Q_comb[1][9] |  Q_comb[2][9] |  Q_comb[3][9]
				 | Q_comb[4][9] | Q_comb[5][9] |  Q_comb[6][9] |  Q_comb[7][9]
				 | Q_comb[8][9] | Q_comb[9][9] | Q_comb[10][9] | Q_comb[11][9];
				 
assign ColYes[10]= Q_comb[0][10] | Q_comb[1][10] |  Q_comb[2][10] |  Q_comb[3][10]
				 | Q_comb[4][10] | Q_comb[5][10] |  Q_comb[6][10] |  Q_comb[7][10]
				 | Q_comb[8][10] | Q_comb[9][10] | Q_comb[10][10] | Q_comb[11][10];

assign ColYes[11]= Q_comb[0][11] | Q_comb[1][11] |  Q_comb[2][11] |  Q_comb[3][11]
				 | Q_comb[4][11] | Q_comb[5][11] |  Q_comb[6][11] |  Q_comb[7][11]
				 | Q_comb[8][11] | Q_comb[9][11] | Q_comb[10][11] | Q_comb[11][11];
				 


always @(posedge clk) 
	for (ii = 0; ii < 12; ii = ii + 1)
		for (jj = 0; jj < 12; jj = jj + 1)
			Q[ii][jj] <= Q_comb[ii][jj];
/*				
always @(*)
	if (next_state == S_IDLE)
		for (x = 0; x < 12; x = x + 1)
			for (y = 0; y < 12; y = y + 1)
				Q_comb[x][y] = 0;	
	else if (next_state == S_INPUT)
		for (x = 0; x < 12; x = x + 1)
			for (y = 0; y < 12; y = y + 1)
				if (x == row && y == col)
					Q_comb[x][y] = 1;
				else
					Q_comb[x][y] = Q[x][y];
	else if (next_state == S_NEXTCOL)
		for (x = 0; x < 12; x = x + 1)
			for (y = 0; y < 12; y = y + 1)
				if (x == selRow && y == selCol)
					Q_comb[x][y] = 1;
				else
					Q_comb[x][y] = Q[x][y];
	else if (next_state == S_RETURN)
		for (x = 0; x < 12; x = x + 1)
			for (y = 0; y < 12; y = y + 1)
				if (x == rowOfQueenStack[11] && y == colOfQueenStack[11])
					Q_comb[x][y] = 0;
				else
					Q_comb[x][y] = Q[x][y];
	else if (next_state == S_TRYDOWN1)
		for (x = 0; x < 12; x = x + 1)
			for (y = 0; y < 12; y = y + 1)
				if (x == selRow && y == selCol)
					Q_comb[x][y] = 1;
				else
					Q_comb[x][y] = Q[x][y];
	else
		for (x = 0; x < 12; x = x + 1)
			for (y = 0; y < 12; y = y + 1)
				Q_comb[x][y] = Q[x][y];
*/

always @(*)
	case(next_state)
		S_IDLE:		for (x = 0; x < 12; x = x + 1)
						for (y = 0; y < 12; y = y + 1)
							Q_comb[x][y] = 0;
		S_INPUT:	for (x = 0; x < 12; x = x + 1)
						for (y = 0; y < 12; y = y + 1)
							if (x == row && y == col)
								Q_comb[x][y] = 1;
							else
								Q_comb[x][y] = Q[x][y];
		S_NEXTCOL:	for (x = 0; x < 12; x = x + 1)
						for (y = 0; y < 12; y = y + 1)
							if (x == selRow && y == selCol)
								Q_comb[x][y] = 1;
							else
								Q_comb[x][y] = Q[x][y];
		S_RETURN:	for (x = 0; x < 12; x = x + 1)
						for (y = 0; y < 12; y = y + 1)
							if (x == rowOfQueenStack[11] && y == colOfQueenStack[11])
								Q_comb[x][y] = 0;
							else
								Q_comb[x][y] = Q[x][y];
		S_TRYDOWN1:	for (x = 0; x < 12; x = x + 1)
						for (y = 0; y < 12; y = y + 1)
							if (x == selRow && y == selCol)
								Q_comb[x][y] = 1;
							else
								Q_comb[x][y] = Q[x][y];
		default:	for (x = 0; x < 12; x = x + 1)
						for (y = 0; y < 12; y = y + 1)
							Q_comb[x][y] = Q[x][y];
	endcase

always @(posedge clk)	
	if (next_state == S_IDLE)
		ctr <= 0;
	else if (next_state == S_OUT)
		ctr <= ctr + 1;

	
always @(*)
	if (Q[0][ctr] == 1)
		out_comb = 0;
	else if (Q[1][ctr] == 1)
		out_comb = 1;
	else if (Q[2][ctr] == 1)
		out_comb = 2;
	else if (Q[3][ctr] == 1)
		out_comb = 3;
	else if (Q[4][ctr] == 1)
		out_comb = 4;
	else if (Q[5][ctr] == 1)
		out_comb = 5;
	else if (Q[6][ctr] == 1)
		out_comb = 6;
	else if (Q[7][ctr] == 1)
		out_comb = 7;
	else if (Q[8][ctr] == 1)
		out_comb = 8;
	else if (Q[9][ctr] == 1)
		out_comb = 9;
	else if (Q[10][ctr] == 1)
		out_comb = 10;
	else
		out_comb = 11;

always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out_valid <= 0;
	else if (next_state == S_OUT)
		out_valid <= 1;
	else
		out_valid <= 0;
		
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		out <= 0;
	else if (next_state == S_OUT)
		out <= out_comb;
	else
		out <= 0;

endmodule 
