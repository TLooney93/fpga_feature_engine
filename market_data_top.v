module market_data_top (
    input             clk,
    input             rx_serial,

    output     [9:0]  LEDR,

    output            feature_valid,
    output     [31:0] spread,
    output     [31:0] mid_price,
    output signed [31:0] imbalance
);

    wire        rx_valid;
    wire [7:0]  rx_byte;

    wire        packet_valid;
    wire [31:0] bid_price;
    wire [31:0] ask_price;
    wire [31:0] bid_size;
    wire [31:0] ask_size;

    uart_rx #(
        .CLKS_PER_BIT(434)
    ) uart_rx_inst (
        .clk(clk),
        .rx_serial(rx_serial),
        .rx_valid(rx_valid),
        .rx_byte(rx_byte)
    );

    packet_parser parser_inst (
        .clk(clk),
        .rx_valid(rx_valid),
        .rx_byte(rx_byte),
        .packet_valid(packet_valid),
        .bid_price(bid_price),
        .ask_price(ask_price),
        .bid_size(bid_size),
        .ask_size(ask_size)
    );

    feature_engine feature_inst (
        .clk(clk),
        .valid_in(packet_valid),
        .bid_price(bid_price),
        .ask_price(ask_price),
        .bid_size(bid_size),
        .ask_size(ask_size),
        .valid_out(feature_valid),
        .spread(spread),
        .mid_price(mid_price),
        .imbalance(imbalance)
    );

    // LED debug output
    assign LEDR[7:0] = spread[7:0];       // shows spread value
    assign LEDR[8]   = feature_valid;     // blinks when feature result is valid
    assign LEDR[9]   = imbalance[31];     // sign bit: 1 = negative imbalance

endmodule