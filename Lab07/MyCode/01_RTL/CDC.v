`include "AFIFO.v"

module CDC #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Input Port
	rst_n,
	clk1,
    clk2,
	in_valid,
    doraemon_id,
    size,
    iq_score,
    eq_score,
    size_weight,
    iq_weight,
    eq_weight,
    //Output Port
	ready,
    out_valid,
	out,
    
); 
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
output reg  [7:0] out;
output reg	out_valid,ready;

input rst_n, clk1, clk2, in_valid;
input  [4:0]doraemon_id;
input  [7:0]size;
input  [7:0]iq_score;
input  [7:0]eq_score;
input [2:0]size_weight,iq_weight,eq_weight;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg read;
wire empty_info;
wire full_weight;
reg [2:0] read_ctr;

wire [7:0] SW_ID;
wire [7:0] SIZE;
wire [7:0] IQ;
wire [7:0] EQ;
wire [7:0] IW_EW;

reg [12:0] score[0:4];
reg [4:0] id[0:4];
reg [7:0] s[0:4];
reg [7:0] iq[0:4];
reg [7:0] eq[0:4];
reg [2:0] sw;
reg [2:0] iw;
reg [2:0] ew;
reg [2:0] door;
reg read_reg;
reg [7:0] out_comb;

reg [12:0] ctr_6000;
reg done;

//---------------------------------------------------------------------
//   Sub modules
//---------------------------------------------------------------------
always @(posedge clk1 or negedge rst_n)
	if (!rst_n)
		ctr_6000 <= 0;
	else if (in_valid)
		ctr_6000 <= ctr_6000 + 1;
		
always @(posedge clk1 or negedge rst_n)
	if (!rst_n)
		done <= 0;
	else if (ctr_6000 == 6000)
		done <= 1;


always @(*)
	if (!rst_n)
		ready = 0;
	else
		ready = !full_weight && !done;

always @(*)
	if (!empty_info)
		read = 1;
	else
		read = 0;


AFIFO SW_ID_FIFO (
	.rst_n(rst_n),
    //Input Port (read)
    .rclk(clk2),
    .rinc(read),
	//Input Port (write)
    .wclk(clk1),
    .winc(in_valid),
	.wdata({size_weight, doraemon_id}),

    //Output Port (read)
    .rempty(empty_info),
	.rdata(SW_ID)
);

AFIFO SIZE_FIFO(
	.rst_n(rst_n),
    //Input Port (read)
    .rclk(clk2),
    .rinc(read),
	//Input Port (write)
    .wclk(clk1),
    .winc(in_valid),
	.wdata(size),

    //Output Port (read)
	.rdata(SIZE)
);

AFIFO IQ_FIFO(
	.rst_n(rst_n),
    //Input Port (read)
    .rclk(clk2),
    .rinc(read),
	//Input Port (write)
    .wclk(clk1),
    .winc(in_valid),
	.wdata(iq_score),

    //Output Port (read)
	.rdata(IQ)
);

AFIFO EQ_FIFO(
	.rst_n(rst_n),
    //Input Port (read)
    .rclk(clk2),
    .rinc(read),
	//Input Port (write)
    .wclk(clk1),
    .winc(in_valid),
	.wdata(eq_score),

    //Output Port (read)
	.rdata(EQ)
);

AFIFO IW_EW_FIFO(
	.rst_n(rst_n),
    //Input Port (read)
    .rclk(clk2),
    .rinc(read),
	//Input Port (write)
    .wclk(clk1),
    .winc(in_valid),
	.wdata({2'b0, iq_weight, eq_weight}),

    //Output Port (read)
	.rdata(IW_EW),
    //Output Port (write)
    .wfull(full_weight)
);


//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
always @(*) begin
	score[0] = sw * s[0] + iw * iq[0] + ew * eq[0];
	score[1] = sw * s[1] + iw * iq[1] + ew * eq[1];
	score[2] = sw * s[2] + iw * iq[2] + ew * eq[2];
	score[3] = sw * s[3] + iw * iq[3] + ew * eq[3];
	score[4] = sw * s[4] + iw * iq[4] + ew * eq[4];
end

always @(*)
	if (score[0] >= score[1] && score[0] >= score[2] && score[0] >= score[3] && score[0] >= score[4]) begin
		out_comb = {3'd0, id[0]};
		door = 0;
	end
	else if (score[1] >= score[0] && score[1] >= score[2] && score[1] >= score[3] && score[1] >= score[4]) begin
		out_comb = {3'd1, id[1]};
		door = 1;
	end
	else if (score[2] >= score[0] && score[2] >= score[1] && score[2] >= score[3] && score[2] >= score[4]) begin
		out_comb = {3'd2, id[2]};
		door = 2;
	end
	else if (score[3] >= score[0] && score[3] >= score[1] && score[3] >= score[2] && score[3] >= score[4]) begin
		out_comb = {3'd3, id[3]};
		door = 3;
	end
	else begin
		out_comb = {3'd4, id[4]};
		door = 4;
	end


always @(posedge clk2 or negedge rst_n)
	if (!rst_n)
		read_ctr <= 0;
	else if (read_ctr == 5)
		read_ctr <= 5;
	else if (read)
		read_ctr <= read_ctr + 1;

always @(posedge clk2 or negedge rst_n)
	if (!rst_n) begin
		id[0] <= 0;
		id[1] <= 0;
		id[2] <= 0;
		id[3] <= 0;
		id[4] <= 0;
	end
	else if (read) begin
		if (read_ctr < 5)
			id[read_ctr] <= SW_ID[4:0];
		else
			id[door] <= SW_ID[4:0];
	end


always @(posedge clk2 or negedge rst_n)
	if (!rst_n) begin
		s[0] <= 0;
		s[1] <= 0;
		s[2] <= 0;
		s[3] <= 0;
		s[4] <= 0;
	end
	else if (read) begin
		if (read_ctr < 5)
			s[read_ctr] <= SIZE;
		else
			s[door] <= SIZE;
	end
	
	
always @(posedge clk2 or negedge rst_n)
	if (!rst_n) begin
		iq[0] <= 0;
		iq[1] <= 0;
		iq[2] <= 0;
		iq[3] <= 0;
		iq[4] <= 0;
	end
	else if (read) begin
		if (read_ctr < 5)
			iq[read_ctr] <= IQ;
		else
			iq[door] <= IQ;
	end
	
	
always @(posedge clk2 or negedge rst_n)
	if (!rst_n) begin
		eq[0] <= 0;
		eq[1] <= 0;
		eq[2] <= 0;
		eq[3] <= 0;
		eq[4] <= 0;
	end
	else if (read) begin
		if (read_ctr < 5)
			eq[read_ctr] <= EQ;
		else
			eq[door] <= EQ;
	end

	
always @(posedge clk2 or negedge rst_n)
	if (!rst_n) begin
		sw <= 0;
	end
	else if (read) begin
		if (read_ctr == 4)
			sw <= SW_ID[7:5];
		else
			sw <= SW_ID[7:5];
	end

	
always @(posedge clk2 or negedge rst_n)
	if (!rst_n) begin
		iw <= 0;
	end
	else if (read) begin
		if (read_ctr == 4)
			iw <= IW_EW[5:3];
		else
			iw <= IW_EW[5:3];
	end

	
always @(posedge clk2 or negedge rst_n)
	if (!rst_n) begin
		ew <= 0;
	end
	else if (read) begin
		if (read_ctr == 4)
			ew <= IW_EW[2:0];
		else
			ew <= IW_EW[2:0];
	end

always @(posedge clk2 or negedge rst_n)
	if (!rst_n) begin
		read_reg <= 0;
	end
	else
		read_reg <= read;

always @(posedge clk2 or negedge rst_n)
	if (!rst_n)
		out_valid <= 0;
	else if (read_reg && read_ctr == 5)
		out_valid <= 1;
	else
		out_valid <= 0;
		
always @(posedge clk2 or negedge rst_n)
	if (!rst_n)
		out <= 0;
	else if (read_reg && read_ctr == 5)
		out <= out_comb;
	else
		out <= 0;

endmodule