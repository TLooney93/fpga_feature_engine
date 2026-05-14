module packet_parser (
    input             clk,
    input             rx_valid,
    input      [7:0]  rx_byte,

    output reg        packet_valid,
    output reg [31:0] bid_price,
    output reg [31:0] ask_price,
    output reg [31:0] bid_size,
    output reg [31:0] ask_size
);

    localparam WAIT_HEADER = 2'd0;
    localparam READ_PACKET = 2'd1;

    reg [1:0] state = WAIT_HEADER;
    reg [4:0] byte_count = 0;

    always @(posedge clk) begin
        packet_valid <= 1'b0;

        if (rx_valid) begin
            case (state)

                WAIT_HEADER: begin
                    byte_count <= 0;

                    if (rx_byte == 8'hAA) begin
                        state <= READ_PACKET;
                    end
                end

                READ_PACKET: begin
                    byte_count <= byte_count + 1;

                    case (byte_count)

                        // bid_price bytes
                        5'd0: bid_price[31:24] <= rx_byte;
                        5'd1: bid_price[23:16] <= rx_byte;
                        5'd2: bid_price[15:8]  <= rx_byte;
                        5'd3: bid_price[7:0]   <= rx_byte;

                        // ask_price bytes
                        5'd4: ask_price[31:24] <= rx_byte;
                        5'd5: ask_price[23:16] <= rx_byte;
                        5'd6: ask_price[15:8]  <= rx_byte;
                        5'd7: ask_price[7:0]   <= rx_byte;

                        // bid_size bytes
                        5'd8:  bid_size[31:24] <= rx_byte;
                        5'd9:  bid_size[23:16] <= rx_byte;
                        5'd10: bid_size[15:8]  <= rx_byte;
                        5'd11: bid_size[7:0]   <= rx_byte;

                        // ask_size bytes
                        5'd12: ask_size[31:24] <= rx_byte;
                        5'd13: ask_size[23:16] <= rx_byte;
                        5'd14: ask_size[15:8]  <= rx_byte;

                        5'd15: begin
                            ask_size[7:0] <= rx_byte;
                            packet_valid <= 1'b1;
                            state <= WAIT_HEADER;
                            byte_count <= 0;
                        end

                    endcase
                end

            endcase
        end
    end

endmodule