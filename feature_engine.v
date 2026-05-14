// fpga feature calculator for live market data
// outputs :
// spread = ask_price - bid_price
// mid_price = avg of ask and bid 
// imbalance = bid_size - ask_size



module feature_engine (
 input clk,
 input valid_in,
 input [31:0] bid_price,
 input [31:0] ask_price,
 input [31:0] bid_size,
 input [31:0] ask_size,

 output reg valid_out,
 output reg [31:0] spread,
 output reg [31:0] mid_price,
 output reg signed [31:0] imbalance
);

always @(posedge clk) begin
    valid_out <= valid_in;

    if (valid_in) begin
        spread    <= ask_price - bid_price;
        mid_price <= (ask_price + bid_price) >> 1;
        imbalance <= $signed(bid_size) - $signed(ask_size);
    end
end

endmodule