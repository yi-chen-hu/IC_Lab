`ifdef RTL
    `define CYCLE_TIME 10.0
`endif
`ifdef GATE
    `define CYCLE_TIME 10.0
`endif


module PATTERN(
    // Output Signals
    clk,
    rst_n,
    in_valid,
    init,
    in0,
    in1,
    in2,
    in3,
    // Input Signals
    out_valid,
    out
);


/* Input for design */
output reg       clk, rst_n;
output reg       in_valid;
output reg [1:0] init;
output reg [1:0] in0, in1, in2, in3; 


/* Output for pattern */
input            out_valid;
input      [1:0] out; 

//=======================
//	integer & parameter
//=======================
integer seed = 20;
integer PATNUM = 200;
integer numOfTrain;
integer valid_time;
integer lat;
integer i;
integer patcount;
integer t;
//=======================
//	wire & reg
//=======================
reg [1:0] map[0:3][0:63];
reg [1:0] initPosition;
reg [1:0] In[3:0];
reg [1:0] idxOfTrain[2:0];
reg signed [3:0] position;

//=======================
//	clk
//=======================
real CYCLE = `CYCLE_TIME;
always #(CYCLE / 2.0) clk = ~clk;

//=======================
//	initial
//=======================
initial begin
	reset_task;
	for (patcount = 0; patcount < PATNUM; patcount = patcount + 1) begin
		input_task;
		wait_out_valid_task;
		check_ans_task;
	end


	$finish;
end
//=======================
//	task
//=======================
task reset_task; begin
	rst_n = 1'b1;
	
	in_valid = 1'b0;
	init = 2'bx;
	in0 = 2'bx;
	in1 = 2'bx;
	in2 = 2'bx;
	in3 = 2'bx;
	
	force clk = 0;
	#CYCLE; rst_n = 1'b0;
	#CYCLE; rst_n = 1'b1;
	
	if (out_valid !== 1'b0 || out !== 2'b0) begin
		$display("SPEC 3 IS FAIL!");
		$finish;
	end
	#CYCLE; release clk;
end
endtask

task input_task; begin
	// TODO: SPEC 4 should be implemeted every clk cycle in input_task 
	// to make sure that priority of SPEC 4 is higher than SPEC 5

	// t is latency between 2 diff patterns
	t = 1;
	for (i = 0; i < t; i = i + 1)begin
		reset_out_while_out_valid_is_low;
		@(negedge clk);
	end
	
	// generate lower or higher obstacle and save it first
	// then generate train and overwrite it
	in_valid = 1'b1;
		
	for (i = 0; i < 64; i = i + 1) begin
		reset_out_while_out_valid_is_low;
		check_out_valid_while_input;
		
		// initialize
		In[0] = 2'b00;
		In[1] = 2'b00;
		In[2] = 2'b00;
		In[3] = 2'b00;
		
		// determine road, lower obstacle or higher obstacle
		if (i % 2 === 0 && i % 8 !== 0) begin
			In[0] = $random(seed) % 'd3;
			In[1] = $random(seed) % 'd3;
			In[2] = $random(seed) % 'd3;
			In[3] = $random(seed) % 'd3;	 
		end
		
		// determine which place is train and save it to idxOfTrain[2:0]
		if (i % 8 === 0) begin
			numOfTrain = ($random(seed) % 'd3) + 'd1;
			
			if (numOfTrain === 1) begin
				idxOfTrain[0] = $random(seed) % 'd4;
				In[idxOfTrain[0]] = 2'b11;
			end
			else if (numOfTrain === 2) begin
				idxOfTrain[0] = $random(seed) % 'd4;
				idxOfTrain[1] = $random(seed) % 'd4;
				while(idxOfTrain[1] === idxOfTrain[0])
					idxOfTrain[1] = $random(seed) % 'd4;
				In[idxOfTrain[0]] = 2'b11;
				In[idxOfTrain[1]] = 2'b11;
			end
			else if (numOfTrain === 3) begin
				idxOfTrain[0] = $random(seed) % 'd4;
				idxOfTrain[1] = $random(seed) % 'd4;
				idxOfTrain[2] = $random(seed) % 'd4;
				while (idxOfTrain[1] === idxOfTrain[0])
					idxOfTrain[1] = $random(seed) % 'd4;
				while (idxOfTrain[2] === idxOfTrain[1] || idxOfTrain[2] === idxOfTrain[0])
					idxOfTrain[2] = $random(seed) % 'd4;
			end
		end
		
		// After train is determined, determine which place is init
		if (i === 0) begin
			if (numOfTrain === 1) begin
				initPosition = $random(seed) % 'd4;
				while (initPosition === idxOfTrain[0])
					initPosition = $random(seed) % 'd4;
			end
			else if (numOfTrain === 2) begin
				initPosition = $random(seed) % 'd4;
				while (initPosition === idxOfTrain[0] || initPosition === idxOfTrain[1])
					initPosition = $random(seed) % 'd4;
			end
			else if (numOfTrain === 3) begin
				initPosition = $random(seed) % 'd4;
				while (initPosition === idxOfTrain[0] || initPosition === idxOfTrain[1] || initPosition === idxOfTrain[2])
					initPosition = $random(seed) % 'd4;
			end
			
			init = initPosition;
			position = {1'b0, initPosition};
		end
		else
			init = 2'bx;
		
		// generate train depending on idxOfTrain[2:0]
		if (i % 8 === 0 || i % 8 === 1 || i % 8 === 2 || i % 8 === 3) begin
			if (numOfTrain === 1) begin
				In[idxOfTrain[0]] = 2'b11;
			end
			else if (numOfTrain === 2) begin
				In[idxOfTrain[0]] = 2'b11;
				In[idxOfTrain[1]] = 2'b11;
			end
			else if (numOfTrain === 3) begin
				In[idxOfTrain[0]] = 2'b11;
				In[idxOfTrain[1]] = 2'b11;
				In[idxOfTrain[2]] = 2'b11;
			end
		end
		
		// return In[3:0]
		in0 = In[0];
		in1 = In[1];
		in2 = In[2];
		in3 = In[3];
		
		// save the value above to map[0:3][0:63]
		map[0][i] = In[0];
		map[1][i] = In[1];
		map[2][i] = In[2];
		map[3][i] = In[3];
		
		@(negedge clk);
		
	end
	
	in_valid = 0;
	in0 = 2'bx;
	in1 = 2'bx;
	in2 = 2'bx;
	in3 = 2'bx;
end
endtask

task reset_out_while_out_valid_is_low; begin
	if (out_valid === 1'b0 && out !== 2'b0) begin
		$display("SPEC 4 IS FAIL!");
		$finish;
	end
end
endtask

task check_out_valid_while_input; begin
	if (in_valid === 1'b1 && out_valid !== 0) begin
		$display("SPEC 5 IS FAIL!");
		$finish;
	end	
end
endtask

task wait_out_valid_task; begin
	lat = -1;
	while (out_valid === 0) begin
		reset_out_while_out_valid_is_low;
		lat = lat + 1;
		if (lat === 3000) begin
			$display("SPEC 6 IS FAIL!");
			$finish;
		end
		@(negedge clk);
	end
end
endtask

task check_ans_task; begin
	valid_time = 0;
	while (out_valid) begin
		valid_time = valid_time + 1;
		
		if (valid_time > 63) begin
			$display("SPEC 7 IS FAIL!");
			$finish;
		end
		
		if (valid_time >= 1  && valid_time <= 63) begin
			// TODO: write the if block to implement all rules of SPEC 8
			
			// go forward
			if (out === 2'd0) begin
				if (map[position][valid_time] === 2'b01) begin
					$display("SPEC 8-2 IS FAIL!");
					$finish;
				end
				else if (map[position][valid_time] === 2'b11) begin
					$display("SPEC 8-4 IS FAIL!");
					$finish;
				end
			end
			// go right
			else if (out === 2'd1) begin
				position = position + 1;
				
				// run outside the map or not
				if (position > 3) begin
					$display("SPEC 8-1 IS FAIL!");
					$finish;
				end
				
				if (map[position][valid_time] === 2'b01) begin
					$display("SPEC 8-2 IS FAIL!");
					$finish;
				end
				else if (map[position][valid_time] === 2'b10) begin
					$display("SPEC 8-3 IS FAIL!");
					$finish;
				end
				else if (map[position][valid_time] === 2'b11) begin
					$display("SPEC 8-4 IS FAIL!");
					$finish;
				end
			end
			// go left
			else if (out === 2'd2) begin
				position = position - 1;
				
				// run outside the map or not
				if (position < 0) begin
					$display("SPEC 8-1 IS FAIL!");
					$finish;
				end
				
				if (map[position][valid_time] === 2'b01) begin
					$display("SPEC 8-2 IS FAIL!");
					$finish;
				end
				else if (map[position][valid_time] === 2'b10) begin
					$display("SPEC 8-3 IS FAIL!");
					$finish;
				end
				else if (map[position][valid_time] === 2'b11) begin
					$display("SPEC 8-4 IS FAIL!");
					$finish;
				end
			end
			// jump forward
			else if (out === 2'd3) begin
				if (map[position][valid_time] === 2'b10) begin
					$display("SPEC 8-3 IS FAIL!");
					$finish;
				end
				else if (map[position][valid_time] === 2'b11) begin
					$display("SPEC 8-4 IS FAIL!");
					$finish;
				end
				
				if (map[position][valid_time - 1] === 2'b01) begin
					$display("SPEC 8-5 IS FAIL!");
					$finish;
				end
				
			end
		end
		@(negedge clk);
	end
	reset_out_while_out_valid_is_low;
	
	if (valid_time < 63) begin
		$display("SPEC 7 IS FAIL!");
		$finish;
	end
	if (out !== 0) begin
		$display("SPEC 4 IS FAIL!");
		$finish;
	end
	

end
endtask



endmodule