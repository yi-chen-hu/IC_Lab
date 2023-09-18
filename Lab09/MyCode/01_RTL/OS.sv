module OS(input clk, INF.OS_inf inf);
import usertype::*;

//======================================
//  integer
//======================================
integer i;
integer ii;
integer iii;
integer j;

//======================================
//  logic
//======================================
User_id      user;
Act          act;
Item_id      item_ID;
Item_num     num;
Money        money;
User_id      seller;
logic [2:0]  ctr_4;
User_Info    user_userinfo;
User_Info    seller_userinfo;
Shop_Info    user_shopinfo;
Shop_Info    seller_shopinfo;
logic        user_saved;
logic        seller_saved;
logic        money_saved;
logic        complete_comb;
logic        one_cycle_c_in_valid;
logic        seller_valid;
User_Info    user_userinfo_after_buy;
User_Info    seller_userinfo_after_buy;
Shop_Info    user_shopinfo_after_buy;
Shop_Info    seller_shopinfo_after_buy;
logic [8:0]  single_price;
logic [6:0]  fee;
logic [6:0]  exp_per_items;
logic [12:0] total_exp;
logic [14:0] total_price;
logic [14:0] total_price_wo_fee;
logic        invent_full;
logic        invent_not_enough;
logic        out_of_money;
logic [3:0]  err_msg_comb;
logic [31:0] out_info_comb;
logic        already_buy[0:255];
User_Info    user_userinfo_after_deposit;
Shop_Info    user_shopinfo_after_deposit;
logic        returnAsBuyer[0:255];
logic        returnAsSeller[0:255];
logic [7:0]  mostRecentBuyer[0:255];
logic [16:0] sum_of_money;
User_Info    user_userinfo_after_return;
Shop_Info    user_shopinfo_after_return;
User_Info    seller_userinfo_after_return;
Shop_Info    seller_shopinfo_after_return;
logic [16:0] seller_money_after_buy_17bit;
logic [15:0] seller_money_after_buy;

//======================================
//  FSM
//======================================
FSM state, next_state;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        state <= S_IDLE;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin
    case(state)
        S_IDLE:             next_state = inf.id_valid ? S_USER : (inf.act_valid ? S_ACT : S_IDLE);
        S_USER:             next_state = inf.act_valid ? S_ACT : S_WAIT_ACT;
        S_WAIT_ACT:         next_state = inf.act_valid ? S_ACT : S_WAIT_ACT;
        S_ACT:              begin
                                if      (act == act_Buy    ) next_state = S_BUY;
                                else if (act == act_Check  ) next_state = S_CHECK;
                                else if (act == act_Deposit) next_state = S_DEPOSIT;
                                else                         next_state = S_RETURN;
                            end
        S_BUY:              next_state = (user_saved && seller_saved) ? (complete_comb == 0 ? S_OUT : S_WRITE_USER) : S_BUY;
        S_CHECK:            next_state = inf.id_valid ? S_STOCK : (ctr_4 == 4 ? S_OWN : S_CHECK);
        S_OWN:              next_state = user_saved ? S_OUT : S_OWN;
        S_STOCK:            next_state = (user_saved && seller_saved) ? S_OUT : S_STOCK;
        S_DEPOSIT:          next_state = (user_saved && money_saved) ? (complete_comb == 0 ? S_OUT : S_WRITE_USER) : S_DEPOSIT;
        S_RETURN:           next_state = (user_saved && seller_saved) ? (complete_comb == 0 ? S_OUT : S_WRITE_USER) : S_RETURN;
        S_WRITE_USER:       next_state = S_WAIT_USER;
        S_WAIT_USER:        begin
                                if (inf.C_out_valid) begin
                                    if (act == act_Deposit) begin
                                        next_state = S_OUT;
                                    end
                                    else begin
                                        next_state = S_WRITE_SELLER;
                                    end
                                end
                                else begin
                                    next_state = S_WAIT_USER;
                                end
                            end
        S_WRITE_SELLER:     next_state = S_WAIT_SELLER;
        S_WAIT_SELLER:      next_state = inf.C_out_valid ? S_OUT : S_WAIT_SELLER;
        S_OUT:              next_state = S_IDLE;
        default:            next_state = S_IDLE;
    endcase
end

//======================================//
//                Design                //
//======================================//
//---------------------------------------------------------
//  input signals from PATTERN.sv
//---------------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        user <= 0;
    end
    else if (inf.id_valid && state == S_IDLE) begin
        user <= inf.D.d_id[0];
    end
end

// 0: Buy
// 1: Check
// 2: Deposit
// 3: Return
// 4: check own money
// 5: check seller's stock
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        act <= act_Buy;
    end
    else if (inf.act_valid) begin
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
    else if (next_state == S_OWN) begin
        act <= act_Check_Own_Money;
    end
    else if (next_state == S_STOCK) begin
        act <= act_Check_Stock;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        item_ID <= No_item;
    end
    else if (inf.item_valid) begin
        item_ID <= inf.D.d_item[0];
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        num <= 0;
    end
    else if (inf.num_valid)begin
        num <= inf.D.d_item_num;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        money <= 0;
    end
    else if (inf.amnt_valid)begin
        money <= inf.D.d_money;
    end
end

//------------------------------------------------------------
//  all ctrl signals used for controlling the FSM
//------------------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        seller_valid <= 0;
    end
    else if (state == S_IDLE) begin
        seller_valid <= 0;
    end
    else if (inf.id_valid) begin
        seller_valid <= 1;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        money_saved <= 0;
    end
    else if (state == S_IDLE) begin
        money_saved <= 0;
    end
    else if (inf.amnt_valid)begin
        money_saved <= 1;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        seller <= 0;
    end
    else if ((state == S_BUY || state == S_CHECK || state == S_RETURN) && inf.id_valid) begin
        seller <= inf.D.d_id[0];
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        ctr_4 <= 0;
    end
    else if (next_state == S_OUT) begin
        ctr_4 <= 0;
    end
    else if (state == S_CHECK) begin
        ctr_4 <= ctr_4 + 1;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        one_cycle_c_in_valid <= 1;
    end
    else if (state == S_IDLE) begin
        one_cycle_c_in_valid <= 1;
    end
    else if (user_saved && !seller_saved && seller_valid) begin
        one_cycle_c_in_valid <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        user_saved <= 0;
    end
    else if (state == S_USER) begin
        user_saved <= 0;
    end
    else if (inf.C_out_valid && !user_saved) begin
        user_saved <= 1;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        seller_saved <= 0;
    end
    else if (state == S_IDLE) begin
        seller_saved <= 0;
    end
    else if (inf.C_out_valid && !seller_saved && user_saved && seller_valid) begin
        seller_saved <= 1;
    end
end

//---------------------------------------------------------------------------------------------------------------------------
//  DFF of userinfo and shopinfo 
//---------------------------------------------------------------------------------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        user_shopinfo <= 0;
    end
    else if (inf.C_out_valid && !user_saved) begin
        user_shopinfo <= {inf.C_data_r[7:0], inf.C_data_r[15:8], inf.C_data_r[23:16], inf.C_data_r[31:24]};
    end
    else if (inf.complete) begin
        if (act == act_Buy) begin
            user_shopinfo <= user_shopinfo_after_buy;
        end
        else if (act == act_Return) begin
            user_shopinfo <= user_shopinfo_after_return;
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        user_userinfo <= 0;
    end
    else if (inf.C_out_valid & !user_saved) begin
        user_userinfo <= {inf.C_data_r[39:32], inf.C_data_r[47:40], inf.C_data_r[55:48], inf.C_data_r[63:56]};
    end
    else if (inf.complete) begin
        if (act == act_Buy) begin
            user_userinfo <= user_userinfo_after_buy;
        end
        else if (act == act_Deposit) begin
            user_userinfo <= user_userinfo_after_deposit;
        end
        else if (act == act_Return) begin
            user_userinfo <= user_userinfo_after_return;
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        seller_shopinfo <= 0;
    end
    else if (inf.C_out_valid && !seller_saved && user_saved) begin
        seller_shopinfo <= {inf.C_data_r[7:0], inf.C_data_r[15:8], inf.C_data_r[23:16], inf.C_data_r[31:24]};
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        seller_userinfo <= 0;
    end
    else if (inf.C_out_valid & !seller_saved && user_saved) begin
        seller_userinfo <= {inf.C_data_r[39:32], inf.C_data_r[47:40], inf.C_data_r[55:48], inf.C_data_r[63:56]};
    end
end

//---------------------------------------------------------------------------------------------------------------------------
//  all output signals connecting to PATTERN.sv
//---------------------------------------------------------------------------------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.out_valid <= 0;
    end
    else if (next_state == S_OUT) begin
        inf.out_valid <= 1;
    end
    else begin
        inf.out_valid <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.err_msg <= No_Err;
    end
    else if (next_state == S_OUT) begin
        inf.err_msg <= err_msg_comb;
    end
    else begin
        inf.err_msg <= No_Err;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.complete <= 0;
    end
    else if (next_state == S_OUT) begin
        inf.complete <= complete_comb;
    end
    else begin
        inf.complete <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.out_info <= 0;
    end
    else if (next_state == S_OUT) begin
        inf.out_info <= out_info_comb;
    end
    else begin
        inf.out_info <= 0;
    end
end

//---------------------------------------------------------------------------------------------------------------------------
//  user_shopinfo_after_buy
//---------------------------------------------------------------------------------------------------------------------------
assign user_shopinfo_after_buy.large_num  = item_ID == Large  ? user_shopinfo.large_num  + num : user_shopinfo.large_num;
assign user_shopinfo_after_buy.medium_num = item_ID == Medium ? user_shopinfo.medium_num + num : user_shopinfo.medium_num;
assign user_shopinfo_after_buy.small_num  = item_ID == Small  ? user_shopinfo.small_num  + num : user_shopinfo.small_num;

always_comb begin
    if (user_shopinfo.level == Platinum) begin
        user_shopinfo_after_buy.level = Platinum;
        user_shopinfo_after_buy.exp = 0;
    end
    else if (user_shopinfo.level == Gold) begin
        if (total_exp >= 4000) begin
            user_shopinfo_after_buy.level = Platinum;
            user_shopinfo_after_buy.exp = 0;
        end
        else begin
            user_shopinfo_after_buy.level = Gold;
            user_shopinfo_after_buy.exp = total_exp;
        end
    end
    else if (user_shopinfo.level == Silver) begin
        if (total_exp >= 2500) begin
            user_shopinfo_after_buy.level = Gold;
            user_shopinfo_after_buy.exp = 0;
        end
        else begin
            user_shopinfo_after_buy.level = Silver;
            user_shopinfo_after_buy.exp = total_exp;
        end
    end
    else begin
        if (total_exp >= 1000) begin
            user_shopinfo_after_buy.level = Silver;
            user_shopinfo_after_buy.exp = 0;
        end
        else begin
            user_shopinfo_after_buy.level = Copper;
            user_shopinfo_after_buy.exp = total_exp;
        end
    end
end

//---------------------------------------------------------------------------------------------------------------------------
//  user_userinfo_after_buy
//---------------------------------------------------------------------------------------------------------------------------
assign user_userinfo_after_buy.money = user_userinfo.money - total_price;
assign user_userinfo_after_buy.shop_history.item_ID = item_ID;
assign user_userinfo_after_buy.shop_history.item_num = num;
assign user_userinfo_after_buy.shop_history.seller_ID = seller;

//---------------------------------------------------------------------------------------------------------------------------
//  seller_shopinfo_after_buy
//---------------------------------------------------------------------------------------------------------------------------
assign seller_shopinfo_after_buy.large_num  = item_ID == Large  ? seller_shopinfo.large_num  - num : seller_shopinfo.large_num;
assign seller_shopinfo_after_buy.medium_num = item_ID == Medium ? seller_shopinfo.medium_num - num : seller_shopinfo.medium_num;
assign seller_shopinfo_after_buy.small_num  = item_ID == Small  ? seller_shopinfo.small_num  - num : seller_shopinfo.small_num;
assign seller_shopinfo_after_buy.level      = seller_shopinfo.level;
assign seller_shopinfo_after_buy.exp        = seller_shopinfo.exp;

//---------------------------------------------------------------------------------------------------------------------------
//  seller_userinfo_after_buy
//---------------------------------------------------------------------------------------------------------------------------
assign seller_money_after_buy_17bit = seller_userinfo.money + total_price_wo_fee;
assign seller_money_after_buy = seller_money_after_buy_17bit > 16'b1111111111111111 ? 16'b1111111111111111 : seller_money_after_buy_17bit[15:0];


assign seller_userinfo_after_buy.money = seller_money_after_buy;
assign seller_userinfo_after_buy.shop_history = seller_userinfo;

//---------------------------------------------------------------------------------------------------------------------------
//  user_shopinfo_after_deposit
//---------------------------------------------------------------------------------------------------------------------------
assign user_shopinfo_after_deposit = user_shopinfo;

//---------------------------------------------------------------------------------------------------------------------------
//  user_userinfo_after_deposit
//---------------------------------------------------------------------------------------------------------------------------
assign sum_of_money = user_userinfo.money + money;
assign user_userinfo_after_deposit.money = sum_of_money[15:0];
assign user_userinfo_after_deposit.shop_history = user_userinfo.shop_history;

//---------------------------------------------------------------------------------------------------------------------------
//  user_shopinfo_after_return
//---------------------------------------------------------------------------------------------------------------------------
assign user_shopinfo_after_return.large_num  = item_ID == Large  ? user_shopinfo.large_num  - num : user_shopinfo.large_num;
assign user_shopinfo_after_return.medium_num = item_ID == Medium ? user_shopinfo.medium_num - num : user_shopinfo.medium_num;
assign user_shopinfo_after_return.small_num  = item_ID == Small  ? user_shopinfo.small_num  - num : user_shopinfo.small_num;
assign user_shopinfo_after_return.level      = user_shopinfo.level;
assign user_shopinfo_after_return.exp        = user_shopinfo.exp;

//---------------------------------------------------------------------------------------------------------------------------
//  user_userinfo_after_return
//---------------------------------------------------------------------------------------------------------------------------
assign user_userinfo_after_return.money = user_userinfo.money + total_price_wo_fee;
assign user_userinfo_after_return.shop_history = user_userinfo.shop_history;

//---------------------------------------------------------------------------------------------------------------------------
//  seller_shopinfo_after_return
//---------------------------------------------------------------------------------------------------------------------------
assign seller_shopinfo_after_return.large_num  = item_ID == Large  ? seller_shopinfo.large_num  + num : seller_shopinfo.large_num;
assign seller_shopinfo_after_return.medium_num = item_ID == Medium ? seller_shopinfo.medium_num + num : seller_shopinfo.medium_num;
assign seller_shopinfo_after_return.small_num  = item_ID == Small  ? seller_shopinfo.small_num  + num : seller_shopinfo.small_num;
assign seller_shopinfo_after_return.level      = seller_shopinfo.level;
assign seller_shopinfo_after_return.exp        = seller_shopinfo.exp;

//---------------------------------------------------------------------------------------------------------------------------
//  seller_userinfo_after_return
//---------------------------------------------------------------------------------------------------------------------------
assign seller_userinfo_after_return.money = seller_userinfo.money - total_price_wo_fee;
assign seller_userinfo_after_return.shop_history = seller_userinfo.shop_history;

//---------------------------------------------------------------------------------------------------------------------------
//  generate the comb of all output signals
//---------------------------------------------------------------------------------------------------------------------------
always_comb begin
    if (act == act_Buy) begin
        if (invent_full) begin
            complete_comb = 0;
            err_msg_comb = 4'b0100; // INV_Full;
            out_info_comb = 32'd0;
        end
        else if (invent_not_enough)begin
            complete_comb = 0;
            err_msg_comb = 4'b0010; // INV_Not_Enough;
            out_info_comb = 32'd0;
        end
        else if (out_of_money) begin
            complete_comb = 0;
            err_msg_comb = 4'b0011; // Out_of_money;
            out_info_comb = 32'd0;
        end
        else begin
            complete_comb = 1;
            err_msg_comb = 4'b0000; // No_Err;
            out_info_comb = user_userinfo_after_buy;
        end
    end
    else if (act == act_Deposit) begin
        if (sum_of_money > 16'b1111111111111111) begin
            complete_comb = 0;
            err_msg_comb = 4'b1000; // Wallet_is_Full;
            out_info_comb = 32'd0;
        end
        else begin
            complete_comb = 1;
            err_msg_comb = 4'b0000; // No_Err;
            out_info_comb = {16'd0, user_userinfo_after_deposit.money};
        end
    end
    else if (act == act_Return) begin
        if (returnAsBuyer[user] 
            && returnAsSeller[seller]
            && mostRecentBuyer[seller] == user
            && user_userinfo.shop_history.item_ID == item_ID
            && user_userinfo.shop_history.item_num == num
            && user_userinfo.shop_history.seller_ID == seller) begin
            complete_comb = 1;
            err_msg_comb = 4'b0000; // No_Err;
            out_info_comb = {14'd0, user_shopinfo_after_return.large_num, user_shopinfo_after_return.medium_num, user_shopinfo_after_return.small_num};
        end
        else if (already_buy[user] == 0) begin
            complete_comb = 0;
            err_msg_comb = 4'b1111; // Wrong_act;
            out_info_comb = 32'd0;
        end
        else if (returnAsBuyer[user] == 0 || returnAsSeller[user_userinfo.shop_history.seller_ID] == 0) begin
            complete_comb = 0;
            err_msg_comb = 4'b1111; // Wrong_act;
            out_info_comb = 32'd0;
        end
        else if (mostRecentBuyer[user_userinfo.shop_history.seller_ID] != user) begin
            complete_comb = 0;
            err_msg_comb = 4'b1111; // Wrong_act;
            out_info_comb = 32'd0;
        end
        else if (user_userinfo.shop_history.seller_ID != seller) begin
            complete_comb = 0;
            err_msg_comb = 4'b1001; // Wrong_ID;
            out_info_comb = 32'd0;
        end
        else if (user_userinfo.shop_history.item_num != num) begin
            complete_comb = 0;
            err_msg_comb = 4'b1100; // Wrong_Num;
            out_info_comb = 32'd0;
        end
        else begin
            complete_comb = 0;
            err_msg_comb = 4'b1010; // Wrong_Item;
            out_info_comb = 32'd0;
        end
    end
    else if (act == act_Check_Own_Money) begin
        complete_comb = 1;
        err_msg_comb = 4'b0000; // No_Err;
        out_info_comb = {16'd0, user_userinfo.money};
    end
    else begin
        complete_comb = 1;
        err_msg_comb = 4'b0000; // No_Err;
        out_info_comb = {14'd0, seller_shopinfo.large_num, seller_shopinfo.medium_num, seller_shopinfo.small_num};
    end
end

//---------------------------------------------------------------------------------------------------------------------------
//  signals used for Buy
//---------------------------------------------------------------------------------------------------------------------------
always_comb begin
    if (item_ID == Large) begin
        if (user_shopinfo.large_num + num > 63) begin
            invent_full = 1;
        end
        else begin
            invent_full = 0;
        end
    end
    else if (item_ID == Medium) begin
        if (user_shopinfo.medium_num + num > 63) begin
            invent_full = 1;
        end
        else begin
            invent_full = 0;
        end
    end
    else begin
        if (user_shopinfo.small_num + num > 63) begin
            invent_full = 1;
        end
        else begin
            invent_full = 0;
        end
    end
end

always_comb begin
    if (item_ID == Large) begin
        if (num > seller_shopinfo.large_num) begin
            invent_not_enough = 1;
        end
        else begin
            invent_not_enough = 0;
        end
    end
    else if (item_ID == Medium) begin
        if (num > seller_shopinfo.medium_num) begin
            invent_not_enough = 1;
        end
        else begin
            invent_not_enough = 0;
        end
    end
    else begin
        if (num > seller_shopinfo.small_num) begin
            invent_not_enough = 1;
        end
        else begin
            invent_not_enough = 0;
        end
    end
end

always_comb begin
    if (item_ID == Large) begin
        single_price = 300;
    end
    else if (item_ID == Medium) begin
        single_price = 200;
    end
    else begin
        single_price = 100;
    end
end

always_comb begin
    if (user_shopinfo.level == Platinum) begin
        fee = 10;
    end
    else if (user_shopinfo.level == Gold) begin
        fee = 30;
    end
    else if (user_shopinfo.level == Silver) begin
        fee = 50;
    end
    else begin
        fee = 70;
    end
end

always_comb begin
    if (item_ID == Large) begin
        exp_per_items = 60;
    end
    else if (item_ID == Medium) begin
        exp_per_items = 40;
    end
    else begin
        exp_per_items = 20;
    end
end

assign total_exp = user_shopinfo.exp + num * exp_per_items;
assign total_price_wo_fee = single_price * num;
assign total_price = total_price_wo_fee + fee;

always_comb begin
    if (total_price > user_userinfo.money) begin
        out_of_money = 1;
    end
    else begin
        out_of_money = 0;
    end
end

//---------------------------------------------------------------------------------------------------------------------------
//  signals used for Return
//---------------------------------------------------------------------------------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        for (j = 0; j < 256; j = j + 1) begin
            already_buy[j] <= 0;
        end
    end
    else if (inf.complete && act == act_Buy)begin
        already_buy[user] <= 1;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        for (i = 0; i < 256; i = i + 1) begin
            returnAsBuyer[i] <= 0;
        end
    end
    else if (inf.complete && act == act_Buy) begin
        for (i = 0; i < 256; i = i + 1) begin
            if (i == user) begin
                returnAsBuyer[i] <= 1;
            end
            else if (i == seller) begin
                returnAsBuyer[i] <= 0;
            end
        end
    end
    else if (inf.complete && act == act_Check_Own_Money) begin
        returnAsBuyer[user] <= 0;
    end
    else if (inf.complete && act == act_Check_Stock) begin
        for (i = 0; i < 256; i = i + 1) begin
            if (i == user || i == seller) begin
                returnAsBuyer[i] <= 0;
            end
        end
    end
    else if (inf.complete && act == act_Deposit) begin
        returnAsBuyer[user] <= 0;
    end
    else if (inf.complete && act == act_Return) begin
        for (i = 0; i < 256; i = i + 1) begin
            if (i == user || i == seller) begin
                returnAsBuyer[i] <= 0;
            end
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        for (ii = 0; ii < 256; ii = ii + 1) begin
            returnAsSeller[ii] <= 0;
        end
    end
    else if (inf.complete && act == act_Buy) begin
        for (ii = 0; ii < 256; ii = ii + 1) begin
            if (ii == seller) begin
                returnAsSeller[ii] <= 1;
            end
            else if (ii == user) begin
                returnAsSeller[ii] <= 0;
            end
        end
    end
    else if (inf.complete && act == act_Check_Own_Money) begin
        returnAsSeller[user] <= 0;
    end
    else if (inf.complete && act == act_Check_Stock) begin
        for (ii = 0; ii < 256; ii = ii + 1) begin
            if (ii == user || ii == seller) begin
                returnAsSeller[ii] <= 0;
            end
        end
    end
    else if (inf.complete && act == act_Deposit) begin
        returnAsSeller[user] <= 0;
    end
    else if (inf.complete && act == act_Return) begin
        for (ii = 0; ii < 256; ii = ii + 1) begin
            if (ii == user || ii == seller) begin
                returnAsSeller[ii] <= 0;
            end
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        for (iii = 0; iii < 256; iii = iii + 1) begin
            mostRecentBuyer[iii] <= iii;
        end
    end
    else if (inf.complete && act == act_Buy) begin
        mostRecentBuyer[seller] <= user;
    end
end

//---------------------------------------------------------------------------------------------------------------------------
//  all output signals connecting to bridge.sv
//---------------------------------------------------------------------------------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.C_in_valid <= 0;
    end
    else if (state == S_USER) begin
        inf.C_in_valid <= 1;
    end
    else if (user_saved && !seller_saved && one_cycle_c_in_valid && seller_valid) begin
        inf.C_in_valid <= 1;
    end
    else if (state == S_WRITE_USER) begin
        inf.C_in_valid <= 1;
    end
    else if (state == S_WRITE_SELLER) begin
        inf.C_in_valid <= 1;
    end
    else begin
        inf.C_in_valid <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (! inf.rst_n) begin
        inf.C_addr <= 0;
    end
    else if (state == S_USER) begin
        inf.C_addr <= user;
    end
    else if (user_saved && !seller_saved && one_cycle_c_in_valid && seller_valid) begin
        inf.C_addr <= seller;
    end
    else if (state == S_WRITE_USER) begin
        inf.C_addr <= user;
    end
    else if (state == S_WRITE_SELLER) begin
        inf.C_addr <= seller;
    end
    else begin
        inf.C_addr <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.C_r_wb <= 0;
    end
    else if (state == S_USER)begin
        inf.C_r_wb <= 1;
    end
    else if (user_saved && !seller_saved && one_cycle_c_in_valid && seller_valid) begin
        inf.C_r_wb <= 1;
    end
    else if (state == S_WRITE_USER) begin
        inf.C_r_wb <= 0;
    end
    else if (state == S_WRITE_SELLER) begin
        inf.C_r_wb <= 0;
    end
    else begin
        inf.C_r_wb <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.C_data_w <= 0;
    end
    else if (state == S_WRITE_USER) begin
        if (act == act_Buy) begin
            inf.C_data_w <= {user_userinfo_after_buy[7:0], user_userinfo_after_buy[15:8], user_userinfo_after_buy[23:16], user_userinfo_after_buy[31:24],
                             user_shopinfo_after_buy[7:0], user_shopinfo_after_buy[15:8], user_shopinfo_after_buy[23:16], user_shopinfo_after_buy[31:24]};
        end
        else if (act == act_Deposit) begin
            inf.C_data_w <= {user_userinfo_after_deposit[7:0], user_userinfo_after_deposit[15:8], user_userinfo_after_deposit[23:16], user_userinfo_after_deposit[31:24],
                             user_shopinfo_after_deposit[7:0], user_shopinfo_after_deposit[15:8], user_shopinfo_after_deposit[23:16], user_shopinfo_after_deposit[31:24]};
        end
        else if (act == act_Return) begin
            inf.C_data_w <= {user_userinfo_after_return[7:0], user_userinfo_after_return[15:8], user_userinfo_after_return[23:16], user_userinfo_after_return[31:24],
                             user_shopinfo_after_return[7:0], user_shopinfo_after_return[15:8], user_shopinfo_after_return[23:16], user_shopinfo_after_return[31:24]};
        end
    end
    else if (state == S_WRITE_SELLER) begin
        if (act == act_Buy) begin
            inf.C_data_w <= {seller_userinfo_after_buy[7:0], seller_userinfo_after_buy[15:8], seller_userinfo_after_buy[23:16], seller_userinfo_after_buy[31:24],
                             seller_shopinfo_after_buy[7:0], seller_shopinfo_after_buy[15:8], seller_shopinfo_after_buy[23:16], seller_shopinfo_after_buy[31:24]};
        end
        else if (act == act_Return) begin
            inf.C_data_w <= {seller_userinfo_after_return[7:0], seller_userinfo_after_return[15:8], seller_userinfo_after_return[23:16], seller_userinfo_after_return[31:24],
                             seller_shopinfo_after_return[7:0], seller_shopinfo_after_return[15:8], seller_shopinfo_after_return[23:16], seller_shopinfo_after_return[31:24]};
        end
    end
    else begin
        inf.C_data_w <= 0;
    end
end

endmodule