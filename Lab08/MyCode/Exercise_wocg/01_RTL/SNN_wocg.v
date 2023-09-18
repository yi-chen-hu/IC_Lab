module SNN(
    // Input signals
    clk,
    rst_n,
    in_valid,
    img,
    ker,
    weight,
    // Output signals
    out_valid,
    out_data
);

input clk;
input rst_n;
input in_valid;
input [7:0] img;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
integer i;

//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [5:0] ctr;
// DFF of input
reg [7:0] image[0:35];
reg [7:0] kernel[0:8];
reg [7:0] w[0:3];

// all index
reg  [3:0] idx_16_reg;
wire [4:0] idx_36_comb;
reg  [1:0] idx_maxPool_reg;
wire [3:0] idx_maxPool_comb;

// DFF of all calculation
reg [7:0] first_quantize[0:15];
reg [7:0] maxPool[0:2];
reg [7:0] out_image1[0:3];

// all valid signals
reg maxPool_valid;
reg fc_and_second_qunatize_valid;

// all combinational circuit
reg  [15:0] product_comb[0:8];
wire [19:0] conv_comb;
wire [7:0]  first_quantize_comb;
reg  [7:0]  max_comb[0:2];
reg  [16:0] fc_comb[0:3];
reg  [7:0]  second_qunatize_comb[0:3];
reg  [7:0]  out_image2_comb[0:3];
reg  [7:0]  L1_comb[0:3];
wire [9:0]  L1_sum_comb;
reg  [9:0]  out_comb;

//==============================================//
//                     FSM                      //
//==============================================//
parameter S_IDLE        = 0;
parameter S_IN1         = 1;
parameter S_CONV1       = 2;
parameter S_IN2         = 3;
parameter S_CONV2       = 4;
parameter S_OUT         = 5;

reg [2:0] state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state)
        S_IDLE:         next_state = in_valid ? S_IN1 : S_IDLE;
        S_IN1:          next_state = ctr == 20 ? S_CONV1 : S_IN1;
        S_CONV1:        next_state = ctr == 0 ? S_IN2 : S_CONV1;
        S_IN2:          next_state = ctr == 20 ? S_CONV2 : S_IN2;
        S_CONV2:        next_state = ctr == 0 ? S_OUT : S_CONV2;
        S_OUT:          next_state = S_IDLE;
        default:        next_state = S_IDLE;
    endcase
end
//==============================================//
//                  design                      //
//==============================================//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ctr <= 0;
    end
    else if (ctr == 35) begin
        ctr <= 0;
    end
    else if (state == S_OUT) begin
        ctr <= 0;
    end
    else if (state == S_IDLE && in_valid) begin
        ctr <= ctr + 1;
    end
    else if (state == S_IDLE) begin
        ctr <= 0;
    end
    else begin
        ctr <= ctr + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 36; i = i + 1) begin
            image[i] <= 0;
        end
    end
    else if (next_state == S_IN1 || next_state == S_CONV1 || next_state == S_IN2 || next_state == S_CONV2) begin
        image[ctr] <= img;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 9; i = i + 1) begin
            kernel[i] <= 0;
        end
    end
    else if (next_state == S_IN1) begin
        kernel[ctr] <= ker;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 4; i = i + 1) begin
            w[i] <= 0;
        end
    end
    else if (next_state == S_IN1) begin
        w[ctr] <= weight;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        idx_16_reg <= 0;
    end
    else if (state == S_CONV1 || state == S_CONV2) begin
        idx_16_reg <= idx_16_reg + 1;
    end
end

assign idx_36_comb = idx_16_reg[3:2] * 6 + idx_16_reg[1:0];

always @(*) begin
    product_comb[0] = image[idx_36_comb     ] * kernel[0];
    product_comb[1] = image[idx_36_comb +  1] * kernel[1];
    product_comb[2] = image[idx_36_comb +  2] * kernel[2];
    product_comb[3] = image[idx_36_comb +  6] * kernel[3];
    product_comb[4] = image[idx_36_comb +  7] * kernel[4];
    product_comb[5] = image[idx_36_comb +  8] * kernel[5];
    product_comb[6] = image[idx_36_comb + 12] * kernel[6];
    product_comb[7] = image[idx_36_comb + 13] * kernel[7];
    product_comb[8] = image[idx_36_comb + 14] * kernel[8];
end

assign conv_comb = product_comb[0] + product_comb[1] + product_comb[2] + product_comb[3] 
                 + product_comb[4] + product_comb[5] + product_comb[6] + product_comb[7]
                 + product_comb[8];

assign first_quantize_comb = conv_comb / 2295;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            first_quantize[i] <= 0;
        end
    end
    else if (state == S_CONV1 || state == S_CONV2) begin
        first_quantize[idx_16_reg] <= first_quantize_comb;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        maxPool_valid <= 0;
    end
    else if (idx_16_reg >= 12) begin
        maxPool_valid <= 1;
    end
    else begin
        maxPool_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        idx_maxPool_reg <= 0;
    end
    else if (maxPool_valid) begin
        idx_maxPool_reg <= idx_maxPool_reg + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0 ; i < 3; i = i + 1) begin
            maxPool[i] <= 0;
        end
    end
    else if (maxPool_valid) begin
        maxPool[idx_maxPool_reg] <= max_comb[2];
    end
end

assign idx_maxPool_comb = {idx_maxPool_reg[1], 1'b0, idx_maxPool_reg[0], 1'b0};

always @(*) begin
    if (first_quantize[idx_maxPool_comb] > first_quantize[idx_maxPool_comb + 1]) begin
        max_comb[0] = first_quantize[idx_maxPool_comb];
    end
    else begin
        max_comb[0] = first_quantize[idx_maxPool_comb + 1];
    end
end

always @(*) begin
    if (max_comb[0] > first_quantize[idx_maxPool_comb + 4]) begin
        max_comb[1] = max_comb[0];
    end
    else begin
        max_comb[1] = first_quantize[idx_maxPool_comb + 4];
    end
end

always @(*) begin
    if (max_comb[1] > first_quantize[idx_maxPool_comb + 5]) begin
        max_comb[2] = max_comb[1];
    end
    else begin
        max_comb[2] = first_quantize[idx_maxPool_comb + 5];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fc_and_second_qunatize_valid <= 0;
    end
    else begin
        if (ctr == 0 && state > 1) begin
            fc_and_second_qunatize_valid <= 1;
        end
        else begin
            fc_and_second_qunatize_valid <= 0;
        end
    end
end

always @(*) begin
    fc_comb[0] = maxPool[0] * w[0] + maxPool[1] * w[2];
    fc_comb[1] = maxPool[0] * w[1] + maxPool[1] * w[3];
    fc_comb[2] = maxPool[2] * w[0] + max_comb[2] * w[2];
    fc_comb[3] = maxPool[2] * w[1] + max_comb[2] * w[3];
end

always @(*) begin
    second_qunatize_comb[0] = fc_comb[0] / 510;
    second_qunatize_comb[1] = fc_comb[1] / 510;
    second_qunatize_comb[2] = fc_comb[2] / 510;
    second_qunatize_comb[3] = fc_comb[3] / 510;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_image1[0] <= 0;
        out_image1[1] <= 0;
        out_image1[2] <= 0;
        out_image1[3] <= 0;
    end
    else if (fc_and_second_qunatize_valid && state == S_IN2) begin
        out_image1[0] <= second_qunatize_comb[0];
        out_image1[1] <= second_qunatize_comb[1];
        out_image1[2] <= second_qunatize_comb[2];
        out_image1[3] <= second_qunatize_comb[3];
    end
end

always @(*) begin
    out_image2_comb[0] = second_qunatize_comb[0];
    out_image2_comb[1] = second_qunatize_comb[1];
    out_image2_comb[2] = second_qunatize_comb[2];
    out_image2_comb[3] = second_qunatize_comb[3];
end

always @(*) begin
    if (out_image1[0] > out_image2_comb[0]) begin
        L1_comb[0] = out_image1[0] - out_image2_comb[0];
    end
    else begin
        L1_comb[0] = out_image2_comb[0] - out_image1[0];
    end
end

always @(*) begin
    if (out_image1[1] > out_image2_comb[1]) begin
        L1_comb[1] = out_image1[1] - out_image2_comb[1];
    end
    else begin
        L1_comb[1] = out_image2_comb[1] - out_image1[1];
    end
end

always @(*) begin
    if (out_image1[2] > out_image2_comb[2]) begin
        L1_comb[2] = out_image1[2] - out_image2_comb[2];
    end
    else begin
        L1_comb[2] = out_image2_comb[2] - out_image1[2];
    end
end

always @(*) begin
    if (out_image1[3] > out_image2_comb[3]) begin
        L1_comb[3] = out_image1[3] - out_image2_comb[3];
    end
    else begin
        L1_comb[3] = out_image2_comb[3] - out_image1[3];
    end
end

assign L1_sum_comb = L1_comb[0] + L1_comb[1] + L1_comb[2] + L1_comb[3];

always @(*) begin
    if (L1_sum_comb < 16) begin
        out_comb = 0;
    end
    else begin
        out_comb = L1_sum_comb;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (state == S_OUT) begin
        out_valid <= 1;
    end
    else begin
        out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= 0;
    end
    else if (state == S_OUT) begin
        out_data <= out_comb;
    end
    else begin
        out_data <= 0;
    end
end

endmodule