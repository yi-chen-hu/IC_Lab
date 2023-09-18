//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
//`include "Usertype_PKG.sv"

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

//covergroup Spec1 @();
//	
//       finish your covergroup here
//	
//	
//endgroup

//declare other cover group

covergroup Spec1 @(posedge clk iff(inf.amnt_valid));
    MONEY: coverpoint inf.D.d_money {
        option.at_least = 10;
        bins money_b1 = {[    0:12000]};
        bins money_b2 = {[12001:24000]};
        bins money_b3 = {[24001:36000]};
        bins money_b4 = {[36001:48000]};
        bins money_b5 = {[48001:60000]};
    }
    option.per_instance = 1;
endgroup

covergroup Spec2 @(posedge clk iff(inf.id_valid));
    ID: coverpoint inf.D.d_id[0] {
        option.at_least = 2;
        option.auto_bin_max = 256;
    }
    option.per_instance = 1;
endgroup

covergroup Spec3 @(posedge clk iff(inf.act_valid));
    ACT: coverpoint inf.D.d_act[0] {
        option.at_least = 10;
        bins act_t[] = (Buy, Check, Deposit, Return => Buy, Check, Deposit, Return);
    }
    option.per_instance = 1;
endgroup

covergroup Spec4 @(posedge clk iff(inf.item_valid));
    ITEM: coverpoint inf.D.d_item[0] {
        option.at_least = 20;
        bins item_b1 = {Large};
        bins item_b2 = {Medium};
        bins item_b3 = {Small};
    }
    option.per_instance = 1;
endgroup

covergroup Spec5 @(negedge clk iff(inf.out_valid));
    ERR_MSG: coverpoint inf.err_msg {
        option.at_least = 20;
        bins err_msg_b1 = {INV_Not_Enough};
        bins err_msg_b2 = {Out_of_money  };
        bins err_msg_b3 = {INV_Full      };
        bins err_msg_b4 = {Wallet_is_Full};
        bins err_msg_b5 = {Wrong_ID      };
        bins err_msg_b6 = {Wrong_Num     };
        bins err_msg_b7 = {Wrong_Item    };
        bins err_msg_b8 = {Wrong_act     };
    }
    option.per_instance = 1;
endgroup

covergroup Spec6 @(negedge clk iff(inf.out_valid));
    COMPLETE: coverpoint inf.complete {
        option.at_least = 200;
        bins complete_b1 = {0};
        bins complete_b2 = {1};
    }
    option.per_instance = 1;
endgroup

//declare the cover group 
//Spec1 cov_inst_1 = new();

Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();
Spec6 cov_inst_6 = new();

//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write other assertions at the below
// assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0)
// else
// begin
// 	$display("Assertion X is violated");
// 	$fatal; 
// end

//write other assertions


//===========================================//
//                   logic                   //
//===========================================//
logic       user_saved;
logic [2:0] ctr_5;
Act         act;
logic       first_patcount_user_saved;

//===========================================//
//                    FSM                    //
//===========================================//
parameter S_IDLE    = 0;
parameter S_USER    = 1;
parameter S_ACT     = 2;
parameter S_ITEM    = 3;
parameter S_NUM     = 4;
parameter S_CHECK   = 5;
parameter S_DEPOSIT = 6;
parameter S_COMPUTE = 7;
parameter S_WRONG   = 8;

logic [3:0] state, next_state;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        state <= S_IDLE;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin
    case (state)
        S_IDLE: begin
            if (inf.id_valid) begin
                next_state = S_USER;
            end
            else if (inf.act_valid) begin
                if (inf.D.d_act[0] == Buy || inf.D.d_act[0] == Return) begin
                    next_state = S_ACT;
                end
                else if (inf.D.d_act[0] == Check) begin
                    next_state = S_CHECK;
                end
                else begin
                    next_state = S_DEPOSIT;
                end
            end
            else if (inf.item_valid || inf.num_valid || inf.amnt_valid) begin
                next_state = S_WRONG;
            end
            else begin
                next_state = S_IDLE;
            end
        end
        S_USER: begin
            if (inf.id_valid) begin
                next_state = S_WRONG;
            end
            else if (inf.act_valid) begin
                if (inf.D.d_act[0] == Buy || inf.D.d_act[0] == Return) begin
                    next_state = S_ACT;
                end
                else if (inf.D.d_act[0] == Check) begin
                    next_state = S_CHECK;
                end
                else begin
                    next_state = S_DEPOSIT;
                end
            end
            else if (inf.item_valid || inf.num_valid || inf.amnt_valid) begin
                next_state = S_WRONG;
            end
            else begin
                next_state = S_USER;
            end
        end
        S_ACT: begin
            if (inf.id_valid || inf.act_valid || inf.num_valid || inf.amnt_valid) begin
                next_state = S_WRONG;
            end
            else if (inf.item_valid) begin
                next_state = S_ITEM;
            end
            else begin
                next_state = S_ACT;
            end
        end
        S_ITEM: begin
            if (inf.id_valid || inf.act_valid || inf.item_valid || inf.amnt_valid) begin
                next_state = S_WRONG;
            end
            else if (inf.num_valid) begin
                next_state = S_NUM;
            end
            else begin
                next_state = S_ITEM;
            end
        end
        S_NUM: begin
            if (inf.act_valid || inf.item_valid || inf.num_valid || inf.amnt_valid) begin
                next_state = S_WRONG;
            end
            else if (inf.id_valid) begin
                next_state = S_COMPUTE;
            end
            else begin
                next_state = S_NUM;
            end
        end
        S_CHECK: begin
            if (inf.act_valid || inf.item_valid || inf.num_valid || inf.amnt_valid) begin
                next_state = S_WRONG;
            end
            else if (ctr_5 == 5 && !inf.id_valid) begin
                next_state = S_COMPUTE;
            end
            else if (inf.id_valid) begin
                next_state = S_COMPUTE;
            end 
            else begin
                next_state = S_CHECK;
            end
        end
        S_DEPOSIT: begin
            if (inf.id_valid || inf.act_valid || inf.item_valid || inf.num_valid) begin
                next_state = S_WRONG;
            end
            else if (inf.amnt_valid) begin
                next_state = S_COMPUTE;
            end
            else begin
                next_state = S_DEPOSIT;
            end
        end
        S_COMPUTE: begin
            if (inf.id_valid || inf.act_valid || inf.item_valid || inf.num_valid || inf.amnt_valid) begin
                next_state = S_WRONG;
            end
            else if (inf.out_valid) begin
                next_state = S_IDLE;
            end
            else begin
                next_state = S_COMPUTE;
            end
        end
        S_WRONG: next_state = S_WRONG;
        default: next_state = S_IDLE;
    endcase
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        user_saved <= 0;
    end
    else if (inf.id_valid) begin
        user_saved <= 1;
    end
    else if (inf.act_valid) begin
        user_saved <= 1;
    end
    else if (state == S_IDLE) begin
        user_saved <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        ctr_5 <= 0;
    end
    else if (state == S_CHECK) begin
        ctr_5 <= ctr_5 + 1;
    end
    else if (state == S_IDLE) begin
        ctr_5 <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (inf.act_valid == 1) begin
        if (inf.D.d_act[0] == Buy) begin
            act <= act_Buy;
        end
        else if (inf.D.d_act[0] == Check) begin
            act <= act_Check;
        end
        else if (inf.D.d_act[0] == Deposit) begin
            act <= act_Deposit;
        end
        else begin
            act <= act_Return;
        end
    end
    else if (state == S_CHECK) begin
        if (ctr_5 == 5 && !inf.id_valid) begin
            act <= act_Check_Own_Money;
        end
        else if (inf.id_valid) begin
            act <= act_Check_Stock;
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        first_patcount_user_saved <= 0;
    end
    else if (inf.id_valid) begin
        first_patcount_user_saved <= 1;
    end
end

always @(negedge inf.rst_n) begin
    #1;
    assert_1 : assert (   inf.out_valid   === 0 && inf.err_msg  === No_Err && inf.complete   === 0 && inf.out_info === 0
                       && inf.C_addr      === 0 && inf.C_data_w === 0      && inf.C_in_valid === 0 && inf.C_r_wb   === 0
                       && inf.C_out_valid === 0 && inf.C_data_r === 0
                       && inf.AR_VALID    === 0 && inf.AR_ADDR  === 0      && inf.R_READY    === 0 && inf.AW_VALID === 0
                       && inf.AW_ADDR     === 0 && inf.W_VALID  === 0      && inf.W_DATA     === 0 && inf.B_READY  === 0)
    else begin
        $display("Assertion 1 is violated");
        $fatal;
    end
end

assert_2 : assert property (@(posedge clk) inf.complete === 1 |-> inf.err_msg === 4'b0)
else begin
    $display("Assertion 2 is violated");
    $fatal;
end

assert_3 : assert property (@(posedge clk) inf.complete === 0 |-> inf.out_info === 32'b0)
else begin
    $display("Assertion 3 is violated");
    $fatal;
end

assert_4_id_valid : assert property (@(posedge clk) inf.id_valid === 1 |=> inf.id_valid === 0)
else begin
    $display("Assertion 4 is violated");
    $fatal;
end

assert_4_act_valid : assert property (@(posedge clk) inf.act_valid === 1 |=> inf.act_valid === 0)
else begin
    $display("Assertion 4 is violated");
    $fatal;
end

assert_4_item_valid : assert property (@(posedge clk) inf.item_valid === 1 |=> inf.item_valid === 0)
else begin
    $display("Assertion 4 is violated");
    $fatal;
end

assert_4_num_valid : assert property (@(posedge clk) inf.num_valid === 1 |=> inf.num_valid === 0)
else begin
    $display("Assertion 4 is violated");
    $fatal;
end

assert_4_amnt_valid : assert property (@(posedge clk) inf.amnt_valid === 1 |=> inf.amnt_valid === 0)
else begin
    $display("Assertion 4 is violated");
    $fatal;
end

assert_5_id_valid : assert property (@(posedge clk) inf.id_valid === 1 |-> (inf.act_valid === 0 && inf.item_valid === 0 && inf.num_valid === 0 && inf.amnt_valid === 0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end

assert_5_act_valid : assert property (@(posedge clk) inf.act_valid === 1 |-> (inf.id_valid === 0 && inf.item_valid === 0 && inf.num_valid === 0 && inf.amnt_valid === 0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end

assert_5_item_valid : assert property (@(posedge clk) inf.item_valid === 1 |-> (inf.id_valid === 0 && inf.act_valid === 0 && inf.num_valid === 0 && inf.amnt_valid === 0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end

assert_5_num_valid : assert property (@(posedge clk) inf.num_valid === 1 |-> (inf.id_valid === 0 && inf.act_valid === 0 && inf.item_valid === 0 && inf.amnt_valid === 0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end

assert_5_amnt_valid : assert property (@(posedge clk) inf.amnt_valid === 1 |-> (inf.id_valid === 0 && inf.act_valid === 0 && inf.item_valid === 0 && inf.num_valid === 0))
else begin
    $display("Assertion 5 is violated");
    $fatal;
end

assert_6_user_at_least_one_cycle : assert property (@(posedge clk) (user_saved === 0 && inf.id_valid === 1) |=> (inf.act_valid === 0 && inf.item_valid === 0 && inf.num_valid === 0 && inf.amnt_valid === 0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

assert_6_act_at_least_one_cycle : assert property (@(posedge clk) (inf.act_valid === 1) |=> (inf.id_valid === 0 && inf.item_valid === 0 && inf.num_valid === 0 && inf.amnt_valid === 0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

assert_6_item_at_least_one_cycle : assert property (@(posedge clk) (inf.item_valid === 1) |=> (inf.id_valid === 0 && inf.act_valid === 0 && inf.num_valid === 0 && inf.amnt_valid === 0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

assert_6_num_at_least_one_cycle : assert property (@(posedge clk) (inf.num_valid === 1) |=> (inf.id_valid === 0 && inf.act_valid === 0 && inf.item_valid === 0 && inf.amnt_valid === 0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

assert_6_amnt_at_least_one_cycle : assert property (@(posedge clk) (inf.amnt_valid === 1) |=> (inf.id_valid === 0 && inf.act_valid === 0 && inf.item_valid === 0 && inf.num_valid === 0))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

always @(posedge clk) begin
    assert_6_first_patcount_user : assert (first_patcount_user_saved === 1)
    else begin
        #2;
        if (first_patcount_user_saved === 0 && inf.act_valid === 1) begin
            $display("Assertion 6 is violated");
            $fatal;
        end
    end
end

always @(posedge clk) begin
    assert_6_wrong_sequence : assert (state !== S_WRONG)
    else begin
        $display("Assertion 6 is violated");
        $fatal;
    end
end

assert_6_user : assert property (@(posedge clk) (user_saved === 0 && inf.id_valid === 1) |=> ##[1:5] inf.act_valid === 1)
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

assert_6_act_1 : assert property (@(posedge clk) (inf.act_valid === 1 && (inf.D.d_act[0] === Buy || inf.D.d_act[0] === Return) |=> ##[1:5] (inf.item_valid === 1)))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

assert_6_act_2 : assert property (@(posedge clk) (inf.act_valid === 1 && (inf.D.d_act[0] === Deposit) |=> ##[1:5] (inf.amnt_valid === 1)))
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

assert_6_item : assert property (@(posedge clk) inf.item_valid === 1 |=> ##[1:5] inf.num_valid === 1)
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

assert_6_num : assert property (@(posedge clk) inf.num_valid === 1 |=> ##[1:5] inf.id_valid === 1)
else begin
    $display("Assertion 6 is violated");
    $fatal;
end

assert_7 : assert property (@(posedge clk) inf.out_valid === 1 |=> inf.out_valid === 0)
else begin
    $display("Assertion 7 is violated");
    $fatal;
end

assert_8_1 : assert property (@(posedge clk) $fell(inf.out_valid) |-> (inf.id_valid === 0 && inf.act_valid === 0))
else begin
    $display("Assertion 8 is violated");
    $fatal;
end

assert_8_2 : assert property (@(posedge clk) $fell(inf.out_valid) |-> (##[1:9] (inf.id_valid === 1 || inf.act_valid === 1)))
else begin
    $display("Assertion 8 is violated");
    $fatal;
end

assert_9_1 : assert property (@(negedge clk) state == S_COMPUTE |=> ##[0:9999] inf.out_valid === 1)
else begin
    $display("Assertion 9 is violated");
    $fatal;
end

assert_9_2 : assert property (@(negedge clk) state == S_CHECK |=> ##[0:9999] inf.out_valid === 1)
else begin
    if (act === act_Check_Own_Money) begin
        $display("Assertion 9 is violated");
        $fatal;
    end
end

endmodule