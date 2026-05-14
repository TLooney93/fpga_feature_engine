`timescale 1ns/1ps

module packet_parser_tb;

    reg clk;
    reg rx_valid;
    reg [7:0] rx_byte;

    wire packet_valid;
    wire [31:0] bid_price;
    wire [31:0] ask_price;
    wire [31:0] bid_size;
    wire [31:0] ask_size;

    packet_parser dut (
        .clk(clk),
        .rx_valid(rx_valid),
        .rx_byte(rx_byte),
        .packet_valid(packet_valid),
        .bid_price(bid_price),
        .ask_price(ask_price),
        .bid_size(bid_size),
        .ask_size(ask_size)
    );

    always #10 clk = ~clk; // 50 MHz clock

    task send_byte;
        input [7:0] data;
        begin
            rx_byte = data;
            rx_valid = 1'b1;
            #20;
            rx_valid = 1'b0;
            #20;
        end
    endtask

    initial begin
        clk = 0;
        rx_valid = 0;
        rx_byte = 8'h00;

        #50;

        // Packet:
        // AA
        // bid_price = 18525 = 0000485D
        // ask_price = 18528 = 00004860
        // bid_size  = 400   = 00000190
        // ask_size  = 600   = 00000258

        send_byte(8'hAA);

        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h48);
        send_byte(8'h5D);

        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h48);
        send_byte(8'h60);

        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h01);
        send_byte(8'h90);

        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h02);
        send_byte(8'h58);

        #40;

        $display("bid_price = %d, expected 18525", bid_price);
        $display("ask_price = %d, expected 18528", ask_price);
        $display("bid_size  = %d, expected 400", bid_size);
        $display("ask_size  = %d, expected 600", ask_size);

        if (bid_price == 32'd18525 &&
            ask_price == 32'd18528 &&
            bid_size  == 32'd400 &&
            ask_size  == 32'd600)
            $display("PASS: Packet parsed correctly.");
        else
            $display("FAIL: Packet parse incorrect.");

        $stop;
    end

endmodule