module CC(
  in_s0,
  in_s1,
  in_s2,
  in_s3,
  in_s4,
  in_s5,
  in_s6,
  opt,
  a,
  b,
  s_id0,
  s_id1,
  s_id2,
  s_id3,
  s_id4,
  s_id5,
  s_id6,
  out

);
input wire [3:0] in_s0;
input wire [3:0] in_s1;
input wire [3:0] in_s2;
input wire [3:0] in_s3;
input wire [3:0] in_s4;
input wire [3:0] in_s5;
input wire [3:0] in_s6;
input wire [2:0] opt;
input wire [1:0] a;
input wire [2:0] b;
output reg [2:0] s_id0;
output reg [2:0] s_id1;
output reg [2:0] s_id2;
output reg [2:0] s_id3;
output reg [2:0] s_id4;
output reg [2:0] s_id5;
output reg [2:0] s_id6;
output reg [2:0] out; 
//==================================================================
// reg & wire
//==================================================================
wire signed [4:0] lv0_n0, lv0_n1, lv0_n2, lv0_n3, lv0_n4, lv0_n5, lv0_n6;
wire signed [4:0] lv1_n0, lv1_n1, lv1_n2, lv1_n3, lv1_n4, lv1_n5, lv1_n6;
wire signed [4:0] lv2_n0, lv2_n1, lv2_n2, lv2_n3, lv2_n4, lv2_n5, lv2_n6;
wire signed [4:0] lv3_n0, lv3_n1, lv3_n2, lv3_n3, lv3_n4, lv3_n5, lv3_n6;
wire signed [4:0] lv4_n0, lv4_n1, lv4_n2, lv4_n3, lv4_n4, lv4_n5, lv4_n6;
wire signed [4:0] lv5_n0, lv5_n1, lv5_n2, lv5_n3, lv5_n4, lv5_n5, lv5_n6;
wire signed [4:0] lv6_n0, lv6_n1, lv6_n2, lv6_n3, lv6_n4, lv6_n5, lv6_n6;
wire signed [4:0] lv7_n0, lv7_n1, lv7_n2, lv7_n3, lv7_n4, lv7_n5, lv7_n6;
wire signed [4:0] n0, n1, n2, n3, n4, n5, n6;
wire [6:0] lv1_flag, lv2_flag, lv3_flag, lv4_flag, lv5_flag, lv6_flag;
wire signed [9:0] sum;
wire signed [6:0] avg;
wire signed [2:0] signed_a;
wire signed [8:0] passScore;
wire signed [3:0] aPlus1;
wire signed [3:0] signed_b;
reg signed [8:0] score[6:0];

//==================================================================
// design
//==================================================================
assign lv0_n0 = opt[0] ? {in_s0[3], in_s0} : {1'b0, in_s0};
assign lv0_n1 = opt[0] ? {in_s1[3], in_s1} : {1'b0, in_s1};
assign lv0_n2 = opt[0] ? {in_s2[3], in_s2} : {1'b0, in_s2};
assign lv0_n3 = opt[0] ? {in_s3[3], in_s3} : {1'b0, in_s3};
assign lv0_n4 = opt[0] ? {in_s4[3], in_s4} : {1'b0, in_s4};
assign lv0_n5 = opt[0] ? {in_s5[3], in_s5} : {1'b0, in_s5};
assign lv0_n6 = opt[0] ? {in_s6[3], in_s6} : {1'b0, in_s6};

// begin of descend sorting
// lv1
assign lv1_n0 = lv0_n0 > lv0_n1 ? lv0_n0 : lv0_n1;
assign lv1_n1 = lv0_n0 > lv0_n1 ? lv0_n1 : lv0_n0;
assign lv1_n2 = lv0_n2 > lv0_n3 ? lv0_n2 : lv0_n3;
assign lv1_n3 = lv0_n2 > lv0_n3 ? lv0_n3 : lv0_n2;
assign lv1_n4 = lv0_n4 > lv0_n5 ? lv0_n4 : lv0_n5;
assign lv1_n5 = lv0_n4 > lv0_n5 ? lv0_n5 : lv0_n4;
assign lv1_n6 = lv0_n6;

// lv2
assign lv2_n0 = lv1_n0;
assign lv2_n1 = lv1_n1 > lv1_n2 ? lv1_n1 : lv1_n2;
assign lv2_n2 = lv1_n1 > lv1_n2 ? lv1_n2 : lv1_n1;
assign lv2_n3 = lv1_n3 > lv1_n4 ? lv1_n3 : lv1_n4;
assign lv2_n4 = lv1_n3 > lv1_n4 ? lv1_n4 : lv1_n3;
assign lv2_n5 = lv1_n5 > lv1_n6 ? lv1_n5 : lv1_n6;
assign lv2_n6 = lv1_n5 > lv1_n6 ? lv1_n6 : lv1_n5;

// lv3
assign lv3_n0 = lv2_n0 > lv2_n1 ? lv2_n0 : lv2_n1;
assign lv3_n1 = lv2_n0 > lv2_n1 ? lv2_n1 : lv2_n0;
assign lv3_n2 = lv2_n2 > lv2_n3 ? lv2_n2 : lv2_n3;
assign lv3_n3 = lv2_n2 > lv2_n3 ? lv2_n3 : lv2_n2;
assign lv3_n4 = lv2_n4 > lv2_n5 ? lv2_n4 : lv2_n5;
assign lv3_n5 = lv2_n4 > lv2_n5 ? lv2_n5 : lv2_n4;
assign lv3_n6 = lv2_n6;

// lv4
assign lv4_n0 = lv3_n0;
assign lv4_n1 = lv3_n1 > lv3_n2 ? lv3_n1 : lv3_n2;
assign lv4_n2 = lv3_n1 > lv3_n2 ? lv3_n2 : lv3_n1;
assign lv4_n3 = lv3_n3 > lv3_n4 ? lv3_n3 : lv3_n4;
assign lv4_n4 = lv3_n3 > lv3_n4 ? lv3_n4 : lv3_n3;
assign lv4_n5 = lv3_n5 > lv3_n6 ? lv3_n5 : lv3_n6;
assign lv4_n6 = lv3_n5 > lv3_n6 ? lv3_n6 : lv3_n5;

// lv5
assign lv5_n0 = lv4_n0 > lv4_n1 ? lv4_n0 : lv4_n1;
assign lv5_n1 = lv4_n0 > lv4_n1 ? lv4_n1 : lv4_n0;
assign lv5_n2 = lv4_n2 > lv4_n3 ? lv4_n2 : lv4_n3;
assign lv5_n3 = lv4_n2 > lv4_n3 ? lv4_n3 : lv4_n2;
assign lv5_n4 = lv4_n4 > lv4_n5 ? lv4_n4 : lv4_n5;
assign lv5_n5 = lv4_n4 > lv4_n5 ? lv4_n5 : lv4_n4;
assign lv5_n6 = lv4_n6;

// lv6
assign lv6_n0 = lv5_n0;
assign lv6_n1 = lv5_n1 > lv5_n2 ? lv5_n1 : lv5_n2;
assign lv6_n2 = lv5_n1 > lv5_n2 ? lv5_n2 : lv5_n1;
assign lv6_n3 = lv5_n3 > lv5_n4 ? lv5_n3 : lv5_n4;
assign lv6_n4 = lv5_n3 > lv5_n4 ? lv5_n4 : lv5_n3;
assign lv6_n5 = lv5_n5 > lv5_n6 ? lv5_n5 : lv5_n6;
assign lv6_n6 = lv5_n5 > lv5_n6 ? lv5_n6 : lv5_n5;

// lv7
assign lv7_n0 = lv6_n0 > lv6_n1 ? lv6_n0 : lv6_n1;
assign lv7_n1 = lv6_n0 > lv6_n1 ? lv6_n1 : lv6_n0;
assign lv7_n2 = lv6_n2 > lv6_n3 ? lv6_n2 : lv6_n3;
assign lv7_n3 = lv6_n2 > lv6_n3 ? lv6_n3 : lv6_n2;
assign lv7_n4 = lv6_n4 > lv6_n5 ? lv6_n4 : lv6_n5;
assign lv7_n5 = lv6_n4 > lv6_n5 ? lv6_n5 : lv6_n4;
assign lv7_n6 = lv6_n6;
// end of descend sorting

// flip or not
assign n0 = opt[1] ? lv7_n0 : lv7_n6;
assign n1 = opt[1] ? lv7_n1 : lv7_n5;
assign n2 = opt[1] ? lv7_n2 : lv7_n4;
assign n3 = lv7_n3;            
assign n4 = opt[1] ? lv7_n4 : lv7_n2;
assign n5 = opt[1] ? lv7_n5 : lv7_n1;
assign n6 = opt[1] ? lv7_n6 : lv7_n0;


always @(*)
	case(n0[3:0])
		in_s0: s_id0 = 0;
		in_s1: s_id0 = 1;
		in_s2: s_id0 = 2;
		in_s3: s_id0 = 3;
		in_s4: s_id0 = 4;
		in_s5: s_id0 = 5;
		in_s6: s_id0 = 6;
		default: s_id0 = 0;
	endcase

assign lv1_flag = 7'b1 << s_id0; 

always @(*)
	if (n1[3:0] == in_s0 && !lv1_flag[0])
		s_id1 = 0;
	else if (n1[3:0] == in_s1 && !lv1_flag[1])
		s_id1 = 1;
	else if (n1[3:0] == in_s2 && !lv1_flag[2])
		s_id1 = 2;
	else if (n1[3:0] == in_s3 && !lv1_flag[3])
		s_id1 = 3;
	else if (n1[3:0] == in_s4 && !lv1_flag[4])
		s_id1 = 4;
	else if (n1[3:0] == in_s5 && !lv1_flag[5])
		s_id1 = 5;
	else
		s_id1 = 6;
		
assign lv2_flag = lv1_flag | (7'b1 << s_id1);
		
always @(*)
	if (n2[3:0] == in_s0 && !lv2_flag[0])
		s_id2 = 0;
	else if (n2[3:0] == in_s1 && !lv2_flag[1])
		s_id2 = 1;             
	else if (n2[3:0] == in_s2 && !lv2_flag[2])
		s_id2 = 2;             
	else if (n2[3:0] == in_s3 && !lv2_flag[3])
		s_id2 = 3;             
	else if (n2[3:0] == in_s4 && !lv2_flag[4])
		s_id2 = 4;             
	else if (n2[3:0] == in_s5 && !lv2_flag[5])
		s_id2 = 5;
	else
		s_id2 = 6;
		
assign lv3_flag = lv2_flag | (7'b1 << s_id2);
		
always @(*)
	if (n3[3:0] == in_s0 && !lv3_flag[0])
		s_id3 = 0;
	else if (n3[3:0] == in_s1 && !lv3_flag[1])
		s_id3 = 1;             
	else if (n3[3:0] == in_s2 && !lv3_flag[2])
		s_id3 = 2;             
	else if (n3[3:0] == in_s3 && !lv3_flag[3])
		s_id3 = 3;             
	else if (n3[3:0] == in_s4 && !lv3_flag[4])
		s_id3 = 4;             
	else if (n3[3:0] == in_s5 && !lv3_flag[5])
		s_id3 = 5;
	else
		s_id3 = 6;
		
assign lv4_flag = lv3_flag | (7'b1 << s_id3);
		
always @(*)
	if (n4[3:0] == in_s0 && !lv4_flag[0])
		s_id4 = 0;
	else if (n4[3:0] == in_s1 && !lv4_flag[1])
		s_id4 = 1;             
	else if (n4[3:0] == in_s2 && !lv4_flag[2])
		s_id4 = 2;             
	else if (n4[3:0] == in_s3 && !lv4_flag[3])
		s_id4 = 3;             
	else if (n4[3:0] == in_s4 && !lv4_flag[4])
		s_id4 = 4;             
	else if (n4[3:0] == in_s5 && !lv4_flag[5])
		s_id4 = 5;
	else
		s_id4 = 6;
		
assign lv5_flag = lv4_flag | (7'b1 << s_id4);

always @(*)
	if (n5[3:0] == in_s0 && !lv5_flag[0])
		s_id5 = 0;
	else if (n5[3:0] == in_s1 && !lv5_flag[1])
		s_id5 = 1;             
	else if (n5[3:0] == in_s2 && !lv5_flag[2])
		s_id5 = 2;             
	else if (n5[3:0] == in_s3 && !lv5_flag[3])
		s_id5 = 3;             
	else if (n5[3:0] == in_s4 && !lv5_flag[4])
		s_id5 = 4;             
	else if (n5[3:0] == in_s5 && !lv5_flag[5])
		s_id5 = 5;
	else
		s_id5 = 6;

assign lv6_flag = lv5_flag | (7'b1 << s_id5);

always @(*)
	if (!lv6_flag[0])
		s_id6 = 0;
	else if (!lv6_flag[1])
		s_id6 = 1;
	else if (!lv6_flag[2])
		s_id6 = 2;
	else if (!lv6_flag[3])
		s_id6 = 3;
	else if (!lv6_flag[4])
		s_id6 = 4;
	else if (!lv6_flag[5])
		s_id6 = 5;
	else
		s_id6 = 6;		


assign sum = n0 + n1 + n2 + n3 + n4 + n5 + n6;
assign avg = sum / 7;
assign signed_a = {1'b0, a};
assign passScore = avg - signed_a;
assign aPlus1 = signed_a + 1;
assign signed_b = {1'b0, b};

always @(*)
	if (opt[0] && lv7_n0[4])
		score[0] = (lv7_n0 / aPlus1) + signed_b;
	else
		score[0] = aPlus1 * lv7_n0 + signed_b;

always @(*)
	if (opt[0] && lv7_n1[4])
		score[1] = (lv7_n1 / aPlus1) + signed_b;
	else
		score[1] = aPlus1 * lv7_n1 + signed_b;

always @(*)
	if (opt[0] && lv7_n2[4])
		score[2] = (lv7_n2 / aPlus1) + signed_b;
	else
		score[2] = aPlus1 * lv7_n2 + signed_b;
		
always @(*)
	if (opt[0] && lv7_n3[4])
		score[3] = (lv7_n3 / aPlus1) + signed_b;
	else
		score[3] = aPlus1 * lv7_n3 + signed_b;
		
always @(*)
	if (opt[0] && lv7_n4[4])
		score[4] = (lv7_n4 / aPlus1) + signed_b;
	else
		score[4] = aPlus1 * lv7_n4 + signed_b;
		
always @(*)
	if (opt[0] && lv7_n5[4])
		score[5] = (lv7_n5 / aPlus1) + signed_b;
	else
		score[5] = aPlus1 * lv7_n5 + signed_b;
		
always @(*)
	if (opt[0] && lv7_n6[4])
		score[6] = (lv7_n6 / aPlus1) + signed_b;
	else
		score[6] = aPlus1 * lv7_n6 + signed_b;
		
always @(*)
	if (score[0] < passScore)
		out = opt[2] ? 7 : 0;
	else if (score[1] < passScore && score[0] >= passScore)
		out = opt[2] ? 6 : 1;
	else if (score[2] < passScore && score[1] >= passScore)
		out = opt[2] ? 5 : 2;
	else if (score[3] < passScore && score[2] >= passScore)
		out = opt[2] ? 4 : 3;
	else if (score[4] < passScore && score[3] >= passScore)
		out = opt[2] ? 3 : 4;
	else if (score[5] < passScore && score[4] >= passScore)
		out = opt[2] ? 2 : 5;
	else if (score[6] < passScore && score[5] >= passScore)
		out = opt[2] ? 1 : 6;
	else
		out = opt[2] ? 0 : 7;

endmodule
