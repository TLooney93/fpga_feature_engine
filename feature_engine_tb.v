`timescale 1ns/1ps

module feature_engine_tb;

    reg clk;
    reg valid_in;
    reg [31:0] bid_price;
    reg [31:0] ask_price;
    reg [31:0] bid_size;
    reg [31:0] ask_size;

    wire valid_out;
    wire [31:0] spread;
    wire [31:0] mid_price;
    wire signed [31:0] imbalance;

    feature_engine dut (
        .clk(clk),
        .valid_in(valid_in),
        .bid_price(bid_price),
        .ask_price(ask_price),
        .bid_size(bid_size),
        .ask_size(ask_size),
        .valid_out(valid_out),
        .spread(spread),
        .mid_price(mid_price),
        .imbalance(imbalance)
    );

    always #10 clk = ~clk;   // 50 MHz clock: 20 ns period

    initial begin
        clk = 0;
        valid_in = 0;
        bid_price = 0;
        ask_price = 0;
        bid_size = 0;
        ask_size = 0;

        #25;

        // Test 1: AAPL-like quote
        bid_price = 32'd18525;
        ask_price = 32'd18528;
        bid_size  = 32'd400;
        ask_size  = 32'd600;
        valid_in  = 1'b1;

        #20;

        valid_in = 1'b0;

        #20;

        $display("Test 1:");
        $display("spread    = %d, expected 3", spread);
        $display("mid_price = %d, expected 18526", mid_price);
        $display("imbalance = %d, expected -200", imbalance);

        // Test 2: positive imbalance
        bid_price = 32'd42110;
        ask_price = 32'd42114;
        bid_size  = 32'd900;
        ask_size  = 32'd300;
        valid_in  = 1'b1;

        #20;

        valid_in = 1'b0;

        #20;

        $display("Test 2:");
        $display("spread    = %d, expected 4", spread);
        $display("mid_price = %d, expected 42112", mid_price);
        $display("imbalance = %d, expected 600", imbalance);

        // Test 3: zero spread / equal sizes
        bid_price = 32'd10000;
        ask_price = 32'd10000;
        bid_size  = 32'd500;
        ask_size  = 32'd500;
        valid_in  = 1'b1;

        #20;

        valid_in = 1'b0;

        #20;

        $display("Test 3:");
        $display("spread    = %d, expected 0", spread);
        $display("mid_price = %d, expected 10000", mid_price);
        $display("imbalance = %d, expected 0", imbalance);

        $stop;
    end

endmodule