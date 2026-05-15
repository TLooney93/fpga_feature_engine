module market_data_top (
    input             CLOCK_50,
    input             rx_serial,
    output     [9:0]  LEDR
);

    wire        rx_valid;
    wire [7:0]  rx_byte;

    wire        packet_valid;
    wire [31:0] bid_price;
    wire [31:0] ask_price;
    wire [31:0] bid_size;
    wire [31:0] ask_size;

    wire        feature_valid;
    wire [31:0] spread;
    wire [31:0] mid_price;
    wire signed [31:0] imbalance;
	 
	 reg packet_valid_d = 1'b0;

	always @(posedge CLOCK_50) begin
		 packet_valid_d <= packet_valid;
	end
	
				 uart_rx #(
		 .CLKS_PER_BIT(434)
	) uart_rx_inst (
		 .clk(CLOCK_50),
		 .rx_serial(rx_serial),
		 .rx_valid(rx_valid),
		 .rx_byte(rx_byte)
	);

		packet_parser parser_inst (
    .clk(CLOCK_50),
    .rx_valid(rx_valid),
    .rx_byte(rx_byte),
    .packet_valid(packet_valid),
    .bid_price(bid_price),
    .ask_price(ask_price),
    .bid_size(bid_size),
    .ask_size(ask_size)
);
	
		 feature_engine feature_inst (
		 .clk(CLOCK_50),
		 .valid_in(packet_valid_d),
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
	reg        feature_seen = 1'b0;
	reg [31:0] spread_latched = 32'd0;
	reg signed [31:0] imbalance_latched = 32'd0;
	
	always @(posedge CLOCK_50) begin
		 if (feature_valid) begin
			  feature_seen <= 1'b1;
			  spread_latched <= spread;
			  imbalance_latched <= imbalance;
		 end
	end
	
	assign LEDR[7:0] = spread_latched[7:0];
	assign LEDR[8]   = feature_seen;
	assign LEDR[9]   = imbalance_latched[31];
	endmodule