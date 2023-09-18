`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_OS.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
integer valid_time;
integer i;
integer lat;
integer patcount;
integer SEED = 20;

//================================================================
// wire & registers 
//================================================================
logic [7:0]  golden_DRAM[65536 + 256 * 8 - 1 : 65536];
logic        change_user;
User_id      user;
Action       act;
Item_id      item;
Item_num     item_num;
User_id      seller;
User_id      temp;
Money        money;
Shop_Info    user_shopinfo;
User_Info    user_userinfo;
Shop_Info    seller_shopinfo;
User_Info    seller_userinfo;
logic [8:0]  item_num_after_buy;
logic [5:0]  item_num_of_seller;
logic [8:0]  single_price;
logic [6:0]  fee;
logic [6:0]  exp_per_items;
logic [12:0] total_exp;
Money        total_price;
Money        total_price_wo_fee;
logic [16:0] total_seller_money;
logic        already_buy[0:255];
logic        returnAsBuyer[0:255];
logic        returnAsSeller[0:255];
logic [7:0]  mostRecentBuyer[0:255];
logic        check_seller;
logic [16:0] sum_of_money;

logic [31:0] golden_out_info;
logic        golden_complete;
logic [3:0]  golden_err_msg;


//================================================================
// initial
//================================================================
initial begin
    forever @(negedge clk) begin
        if (inf.out_valid === 1) begin
            patcount = patcount + 1;
        end
    end
end
initial begin
    reset_task;
    initialize_task;
    
    user      = 1;
    seller    = 0;
    item      = Medium;
    item_num  = 5;
    money     = 12000;
    for (i = 0; i < 10; i = i + 1) begin
        buy_task;
        // change_user = 0;
        deposit_task;
        buy_task;
        check_seller = 1;
        check_task;
        user        = user   + 2;
        seller      = seller + 2;
        change_user = 1;
    end
    
    for (i = 0; i < 10; i = i + 1) begin
        temp     = user;
        user     = seller;
        seller   = temp;
        item     = Large;
        item_num = 50;
        buy_task;
        // change_user = 0;
        buy_task;
        user        = user   + 2;
        seller      = seller + 2;
        change_user = 1;
        temp     = user;
        user     = seller;
        seller   = temp;
        item     = Small;
        item_num = 10;
        buy_task;
        // change_user = 0;
        buy_task;
        user        = user   + 2;
        seller      = seller + 2;
        change_user = 1;
    end

    money = 24000;
    for (i = 0; i < 10; i = i + 1) begin
        deposit_task;
        // change_user = 0;
        check_seller = 1;
        check_task;
        user        = user   + 2;
        seller      = seller + 2;
        change_user = 1;
    end
    
    money = 36000;
    for (i = 0; i < 5; i = i + 1) begin
        deposit_task;
        // change_user = 0;
        deposit_task;
        user        = user   + 2;
        seller      = seller + 2;
        change_user = 1;
    end
    
    money = 48000;
    for (i = 0; i < 5; i = i + 1) begin
        deposit_task;
        // change_user = 0;
        return_task;
        deposit_task;
        return_task;
        user        = user   + 2;
        seller      = seller + 2;
        change_user = 1;
    end
    
    money = 60000;
    for (i = 0; i < 5; i = i + 1) begin
        deposit_task;
        // change_user = 0;
        deposit_task;
        user        = user   + 2;
        seller      = seller + 2;
        change_user = 1;
    end
    
    item = Large;
    item_num  = 1;
    for (i = 0; i < 20; i = i + 1) begin
        buy_task;
        seller = seller + 2;
        return_task;
        user = user + 2;
    end
    
    for (i = 0; i < 20; i = i + 1) begin
        item = Large;
        item_num = 1;
        buy_task;
        item = Large;
        item_num = 2;
        return_task;
        item = Small;
        item_num = 1;
        return_task;
        user   = user   + 2;
        seller = seller + 2;
        check_task;
        return_task;
        user   = user   + 2;
        seller = seller + 2;
    end
    
    for (i = 0; i < 13; i = i + 1) begin
        check_task;
        check_task;
        user   = user   + 2;
        seller = seller + 2;
    end
    
    user   = 60;
    seller = 62;
    for (i = 0; i < 5; i = i + 1) begin
        check_task;
        user   = user   + 4;
        seller = seller + 4;
    end
    
    user   = 80;
    seller = 82;
    for (i = 0; i < 2; i = i + 1) begin
        check_task;
        check_task;
        user   = user   + 4;
        seller = seller + 4;
    end
    
    user   = 88;
    seller = 100;
    check_task;
    check_task;
    
    user   = 102;
    seller = 104;
    for (i = 0; i < 2; i = i + 1) begin
        check_task;
        check_task;
        user   = user   + 4;
        seller = seller + 4;
    end
    
    change_user = 1;
    check_seller = 0;
    user = 110;
    check_task;
    change_user = 0;
    for (i = 0; i < 78; i = i + 1) begin
        check_task;
    end
    
    $finish;
end

//================================================================
// task
//================================================================
task reset_task; begin
    inf.rst_n      = 1'b1;
    
    inf.id_valid   = 1'b0;
    inf.act_valid  = 1'b0;
    inf.item_valid = 1'b0;
    inf.num_valid  = 1'b0;
    inf.amnt_valid = 1'b0;
    inf.D          = 'bx;
    
    #10; inf.rst_n = 1'b0;
    #10; inf.rst_n = 1'b1;
    
end
endtask

task initialize_task; begin
    patcount = 0;
    $readmemh(DRAM_p_r, golden_DRAM);
    change_user = 1;
    for (i = 0; i < 256; i = i + 1) begin
        already_buy[i]     = 0;
        returnAsBuyer[i]   = 0;
        returnAsSeller[i]  = 0;
        mostRecentBuyer[i] = i;
    end
end
endtask

task buy_task; begin
    act = Buy;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // user id
    if (change_user === 1) begin
        inf.id_valid = 1'b1;
        inf.D        = {8'd0, user};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D        = 'bx;
        repeat($urandom_range(1, 1)) @(negedge clk);
    end
    
    // action
    inf.act_valid = 1'b1;
    inf.D         = {12'd0, act};
    @(negedge clk);
    inf.act_valid = 1'b0;
    inf.D         = 'bx;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // item id
    inf.item_valid = 1'b1;
    inf.D          = {14'd0, item};
    @(negedge clk);
    inf.item_valid = 1'b0;
    inf.D          = 'bx;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // item num
    inf.num_valid = 1'b1;
    inf.D         = {10'd0, item_num};
    @(negedge clk);
    inf.num_valid = 1'b0;
    inf.D         = 'bx;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // seller id
    inf.id_valid = 1'b1;
    inf.D        = {10'd0, seller};
    @(negedge clk);
    inf.id_valid = 1'b0;
    inf.D        = 'bx;
    
    cal_task;
    wait_out_valid_task;
    check_ans_task;
end
endtask

task check_task; begin
    act = Check;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // user id
    if (change_user === 1) begin
        inf.id_valid = 1'b1;
        inf.D        = {8'd0, user};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D        = 'bx;
        repeat($urandom_range(1, 1)) @(negedge clk);
    end
    
    // action
    inf.act_valid = 1'b1;
    inf.D         = {12'd0, act};
    @(negedge clk);
    inf.act_valid = 1'b0;
    inf.D         = 'bx;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // seller id
    if (check_seller === 1) begin
        inf.id_valid = 1'b1;
        inf.D        = {8'd0, seller};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D        = 'bx;
    end
    
    cal_task;
    wait_out_valid_task;
    check_ans_task;
end
endtask

task deposit_task; begin
    act = Deposit;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // user id
    if (change_user === 1) begin
        inf.id_valid = 1'b1;
        inf.D        = {8'd0, user};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D        = 'bx;
        repeat($urandom_range(1, 1)) @(negedge clk);
    end
    
    // action
    inf.act_valid = 1'b1;
    inf.D         = {12'd0, act};
    @(negedge clk);
    inf.act_valid = 1'b0;
    inf.D         = 'bx;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // money
    inf.amnt_valid = 1'b1;
    inf.D          = money;
    @(negedge clk);
    inf.amnt_valid = 1'b0;
    inf.D          = 'bx;
    
    cal_task;
    wait_out_valid_task;
    check_ans_task;
end
endtask

task return_task; begin
    act = Return;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // user id
    if (change_user === 1) begin
        inf.id_valid = 1'b1;
        inf.D        = {8'd0, user};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D        = 'bx;
        repeat($urandom_range(1, 1)) @(negedge clk);
    end
    
    // action
    inf.act_valid = 1'b1;
    inf.D         = {12'd0, act};
    @(negedge clk);
    inf.act_valid = 1'b0;
    inf.D         = 'bx;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // item id
    inf.item_valid = 1'b1;
    inf.D          = {14'd0, item};
    @(negedge clk);
    inf.item_valid = 1'b0;
    inf.D          = 'bx;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // item num
    inf.num_valid = 1'b1;
    inf.D         = {10'd0, item_num};
    @(negedge clk);
    inf.num_valid = 1'b0;
    inf.D         = 'bx;
    repeat($urandom_range(1, 1)) @(negedge clk);
    
    // seller id
    inf.id_valid = 1'b1;
    inf.D        = {10'd0, seller};
    @(negedge clk);
    inf.id_valid = 1'b0;
    inf.D        = 'bx;
    
    cal_task;
    wait_out_valid_task;
    check_ans_task;
end
endtask

task wait_out_valid_task; begin
    lat = -1;
    while (inf.out_valid !== 1) begin
        @(negedge clk);
    end
end
endtask

task cal_task; begin
    // get user info
    getshopinfo(.user(user  ), .info(user_shopinfo  ));
    getuserinfo(.user(user  ), .info(user_userinfo  ));
    // get seller info
    getshopinfo(.user(seller), .info(seller_shopinfo));
    getuserinfo(.user(seller), .info(seller_userinfo));
    
    // action
    if (act === Buy) begin
        if (item === Large) begin
            item_num_after_buy        = user_shopinfo.large_num + item_num;
            item_num_of_seller        = seller_shopinfo.large_num;
            single_price              = 300;
            user_shopinfo.large_num   = item_num_after_buy;
            seller_shopinfo.large_num = seller_shopinfo.large_num - item_num;
            exp_per_items             = 60;
        end
        else if (item === Medium) begin
            item_num_after_buy         = user_shopinfo.medium_num + item_num;
            item_num_of_seller         = seller_shopinfo.medium_num;
            single_price               = 200;
            user_shopinfo.medium_num   = item_num_after_buy;
            seller_shopinfo.medium_num = seller_shopinfo.medium_num - item_num;
            exp_per_items              = 40;
        end
        else if (item === Small) begin
            item_num_after_buy        = user_shopinfo.small_num + item_num;
            item_num_of_seller        = seller_shopinfo.small_num;
            single_price              = 100;
            user_shopinfo.small_num   = item_num_after_buy;
            seller_shopinfo.small_num = seller_shopinfo.small_num - item_num;
            exp_per_items             = 20;
        end
        
        if (user_shopinfo.level === Platinum) begin
            fee = 10;
        end
        else if (user_shopinfo.level === Gold) begin
            fee = 30;
        end
        else if (user_shopinfo.level === Silver) begin
            fee = 50;
        end
        else if (user_shopinfo.level === Copper) begin
            fee = 70;
        end
        
        total_price        = single_price * item_num + fee;
        total_price_wo_fee = single_price * item_num;
        total_exp          = user_shopinfo.exp + item_num * exp_per_items;
        
        if (item_num_after_buy > 63) begin
            golden_complete = 0;
            golden_err_msg  = 4'b0100; // INV_Full
            golden_out_info = 0;
        end
        else if (item_num > item_num_of_seller) begin
            golden_complete = 0;
            golden_err_msg  = 4'b0010; // INV_Not_Enough
            golden_out_info = 0;
        end
        else if (total_price > user_userinfo.money) begin
            golden_complete = 0;
            golden_err_msg  = 4'b0011; // Out_of_money
            golden_out_info = 0;
        end
        else begin
            golden_complete = 1;
            golden_err_msg  = 4'b0000; // No_Err
            
            // set return signal
            already_buy[user]       = 1;
            returnAsBuyer[user]     = 1;
            returnAsBuyer[seller]   = 0;
            returnAsSeller[seller]  = 1;
            returnAsSeller[user]    = 0;
            mostRecentBuyer[seller] = user;
            
            if (user_shopinfo.level === Gold) begin
                if (total_exp >= 4000) begin
                    user_shopinfo.level = Platinum;
                    user_shopinfo.exp = 0;
                end
                else begin
                    user_shopinfo.exp = total_exp;
                end
            end
            else if (user_shopinfo.level === Silver) begin
                if (total_exp >= 2500) begin
                    user_shopinfo.level = Gold;
                    user_shopinfo.exp = 0;
                end
                else begin
                    user_shopinfo.exp = total_exp;
                end
            end
            else if (user_shopinfo.level === Copper) begin
                if (total_exp >= 1000) begin
                    user_shopinfo.level = Silver;
                    user_shopinfo.exp = 0;
                end
                else begin
                    user_shopinfo.exp = total_exp;
                end
            end
            
            user_userinfo.money                  = user_userinfo.money - total_price;
            user_userinfo.shop_history.item_ID   = item;
            user_userinfo.shop_history.item_num  = item_num;
            user_userinfo.shop_history.seller_ID = seller;
            total_seller_money                   = seller_userinfo.money + total_price_wo_fee;
            if (total_seller_money > 65535) begin
                seller_userinfo.money = 65535;
            end
            else begin
                seller_userinfo.money = total_seller_money;
            end
            
            // golden_out_info
            golden_out_info = {user_shopinfo, user_userinfo};
            
            // update user info
            updateshopinfo(.user(user  ), .info(user_shopinfo  ));
            updateuserinfo(.user(user  ), .info(user_userinfo  ));
            // update seller info
            updateshopinfo(.user(seller), .info(seller_shopinfo));
            updateuserinfo(.user(seller), .info(seller_userinfo));
        end
    end
    else if (act === Check) begin
        getuserinfo(.user(user  ), .info(user_userinfo  ));
        getshopinfo(.user(seller), .info(seller_shopinfo));
        if (check_seller === 1) begin
            golden_complete = 1;
            golden_err_msg  = No_Err;
            golden_out_info = {14'd0, seller_shopinfo.large_num, seller_shopinfo.medium_num, seller_shopinfo.small_num};
            returnAsBuyer[user]    = 0;
            returnAsBuyer[seller]  = 0;
            returnAsSeller[user]   = 0;
            returnAsSeller[seller] = 0;
        end
        else begin
            golden_complete = 1;
            golden_err_msg  = No_Err;
            golden_out_info = {16'd0, user_userinfo.money};
            returnAsBuyer[user]    = 0;
            returnAsSeller[user]   = 0;
        end
    end
    else if (act === Deposit) begin
        sum_of_money = user_userinfo.money + money;
        if (sum_of_money > 16'b1111_1111_1111_1111) begin
            golden_complete = 0;
            golden_err_msg  = 4'b1000; // Wallet_is_Full
            golden_out_info = 32'd0;
        end
        else begin
            golden_complete = 1;
            golden_err_msg  = 4'b0000; // No_Err
            golden_out_info = {16'd0, sum_of_money[15:0]};
            returnAsBuyer[user]  = 0;
            returnAsSeller[user] = 0;
            user_userinfo.money = sum_of_money[15:0];
            
            // update user info
            updateuserinfo(.user(user), .info(user_userinfo));
        end
    end
    else if (act === Return) begin
        if (item === Large) begin
            user_shopinfo.large_num   = user_shopinfo.large_num - item_num;
            seller_shopinfo.large_num = seller_shopinfo.large_num + item_num;
            user_userinfo.money       = user_userinfo.money + 300 * item_num;
            seller_userinfo.money     = seller_userinfo.money - 300 * item_num;
        end
        else if (item === Medium) begin
            user_shopinfo.medium_num   = user_shopinfo.medium_num - item_num;
            seller_shopinfo.medium_num = seller_shopinfo.medium_num + item_num;
            user_userinfo.money        = user_userinfo.money + 200 * item_num;
            seller_userinfo.money      = seller_userinfo.money - 200 * item_num;
        end
        else if (item === Small) begin
            user_shopinfo.small_num   = user_shopinfo.small_num - item_num;
            seller_shopinfo.small_num = seller_shopinfo.small_num + item_num;
            user_userinfo.money       = user_userinfo.money + 100 * item_num;
            seller_userinfo.money     = seller_userinfo.money - 100 * item_num;
        end
        
        if (returnAsBuyer[user]
            && returnAsSeller[seller]
            && mostRecentBuyer[seller] === user
            && user_userinfo.shop_history.item_ID === item
            && user_userinfo.shop_history.item_num === item_num
            && user_userinfo.shop_history.seller_ID === seller) begin
            golden_complete = 1;
            golden_err_msg  = 4'b0000; // No_Err
            golden_out_info = {14'd0, user_shopinfo.large_num, user_shopinfo.medium_num, user_shopinfo.small_num};
            
            returnAsBuyer[user]    = 0;
            returnAsBuyer[seller]  = 0;
            returnAsSeller[user]   = 0;
            returnAsSeller[seller] = 0;
            // update user info
            updateshopinfo(.user(user  ), .info(user_shopinfo  ));
            updateuserinfo(.user(user  ), .info(user_userinfo  ));
            // update seller info
            updateshopinfo(.user(seller), .info(seller_shopinfo));
            updateuserinfo(.user(seller), .info(seller_userinfo));
        end
        else if (already_buy[user] === 0) begin
            golden_complete = 0;
            golden_err_msg  = 4'b1111; // Wrong_act
            golden_out_info = 32'd0;
        end
        else if (returnAsBuyer[user] === 0 || returnAsSeller[user_userinfo.shop_history.seller_ID] === 0) begin
            golden_complete = 0;
            golden_err_msg  = 4'b1111; // Wrong_act
            golden_out_info = 32'd0;
        end
        else if (mostRecentBuyer[user_userinfo.shop_history.seller_ID] !== user) begin
            golden_complete = 0;
            golden_err_msg  = 4'b1111; // Wrong_act
            golden_out_info = 32'd0;
        end
        else if (user_userinfo.shop_history.seller_ID !== seller) begin
            golden_complete = 0;
            golden_err_msg  = 4'b1001; // Wrong_ID
            golden_out_info = 32'd0;
        end
        else if (user_userinfo.shop_history.item_num !== item_num) begin
            golden_complete = 0;
            golden_err_msg  = 4'b1100; // Wrong_Num
            golden_out_info = 32'd0;
        end
        else begin
            golden_complete = 0;
            golden_err_msg  = 4'b1010; // Wrong_Item
            golden_out_info = 32'd0;
        end
    end
end
endtask

task check_ans_task; begin
    while (inf.out_valid === 1) begin
        if (inf.complete !== golden_complete || inf.err_msg !== golden_err_msg || inf.out_info !== golden_out_info) begin
            $display("Wrong Answer");
            $finish;
        end
        @(negedge clk);
    end
end
endtask

task getshopinfo;
    input User_id user;
    output Shop_Info info;
    
    info = {golden_DRAM[65536 + 8 * user + 0], golden_DRAM[65536 + 8 * user + 1], golden_DRAM[65536 + 8 * user + 2], golden_DRAM[65536 + 8 * user + 3]};
endtask

task getuserinfo;
    input User_id user;
    output User_Info info;
    
    info = {golden_DRAM[65536 + 8 * user + 4], golden_DRAM[65536 + 8 * user + 5], golden_DRAM[65536 + 8 * user + 6], golden_DRAM[65536 + 8 * user + 7]};
endtask

task updateshopinfo;
    input User_id user;
    input Shop_Info info;
    
    golden_DRAM[65536 + 8 * user + 0] = info[31:24];
    golden_DRAM[65536 + 8 * user + 1] = info[23:16];
    golden_DRAM[65536 + 8 * user + 2] = info[15: 8];
    golden_DRAM[65536 + 8 * user + 3] = info[ 7: 0];
endtask

task updateuserinfo;
    input User_id user;
    input User_Info info;
    
    golden_DRAM[65536 + 8 * user + 4] = info[31:24];
    golden_DRAM[65536 + 8 * user + 5] = info[23:16];
    golden_DRAM[65536 + 8 * user + 6] = info[15: 8];
    golden_DRAM[65536 + 8 * user + 7] = info[ 7: 0];
endtask

endprogram