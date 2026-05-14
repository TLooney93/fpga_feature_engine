`timescale 1ns/1ps

module market_data_top_tb;

    parameter CLK_PERIOD   = 20;   // 50 MHz clock
    parameter CLKS_PER_BIT = 434;
    parameter BIT_PERIOD   = CLK_PERIOD * CLKS_PER_BIT;

    reg clk;
    reg rx_serial;

    wire feature_valid;
    wire [31:0] spread;
    wire [31:0] mid_price;
    wire signed [31:0] imbalance;

    wire [31:0] bid_price_debug;
    wire [31:0] ask_price_debug;
    wire [31:0] bid_size_debug;
    wire [31:0] ask_size_debug;

    market_data_top dut (
        .clk(clk),
        .rx_serial(rx_serial),

        .feature_valid(feature_valid),
        .spread(spread),
        .mid_price(mid_price),
        .imbalance(imbalance),

        .bid_price_debug(bid_price_debug),
        .ask_price_debug(ask_price_debug),
        .bid_size_debug(bid_size_debug),
        .ask_size_debug(ask_size_debug)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            rx_serial = 1'b0;
            #(BIT_PERIOD);

            // 8 data bits, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                rx_serial = data[i];
                #(BIT_PERIOD);
            end

            // Stop bit
            rx_serial = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    task send_packet;
        begin
            // Header
            send_uart_byte(8'hAA);

            // bid_price = 18525 = 0x0000485D
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h48);
            send_uart_byte(8'h5D);

            // ask_price = 18528 = 0x00004860
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h48);
            send_uart_byte(8'h60);

            // bid_size = 400 = 0x00000190
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h01);
            send_uart_byte(8'h90);

            // ask_size = 600 = 0x00000258
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h02);
            send_uart_byte(8'h58);
        end
    endtask

    initial begin
        clk = 0;
        rx_serial = 1'b1; // UART idle high

        #1000;

        send_packet();

        #(BIT_PERIOD * 4);

        $display("bid_price = %d, expected 18525", bid_price_debug);
        $display("ask_price = %d, expected 18528", ask_price_debug);
        $display("bid_size  = %d, expected 400", bid_size_debug);
        $display("ask_size  = %d, expected 600", ask_size_debug);
        $display("spread    = %d, expected 3", spread);
        $display("mid_price = %d, expected 18526", mid_price);
        $display("imbalance = %d, expected -200", imbalance);

        if (bid_price_debug == 32'd18525 &&
            ask_price_debug == 32'd18528 &&
            bid_size_debug  == 32'd400 &&
            ask_size_debug  == 32'd600 &&
            spread          == 32'd3 &&
            mid_price       == 32'd18526 &&
            imbalance       == -32'sd200)
            $display("PASS: Full UART -> parser -> feature_engine pipeline works.");
        else
            $display("FAIL: Integrated pipeline output incorrect.");

        $stop;
    end

endmodule