module uart_rx #(
    parameter CLKS_PER_BIT = 434
)(
    input        clk,
    input        rx_serial,
    output reg   rx_valid,
    output reg [7:0] rx_byte
);

    localparam IDLE       = 3'd0;
    localparam START_BIT  = 3'd1;
    localparam DATA_BITS  = 3'd2;
    localparam STOP_BIT   = 3'd3;
    localparam CLEANUP    = 3'd4;

    reg [2:0] state = IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] rx_shift = 0;

    always @(posedge clk) begin
        case (state)

            IDLE: begin
                rx_valid <= 1'b0;
                clk_count <= 0;
                bit_index <= 0;

                if (rx_serial == 1'b0)
                    state <= START_BIT;
            end

            START_BIT: begin
                if (clk_count == (CLKS_PER_BIT-1)/2) begin
                    if (rx_serial == 1'b0) begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                    end else begin
                        state <= IDLE;
                    end
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            DATA_BITS: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    rx_shift[bit_index] <= rx_serial;

                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                    end else begin
                        bit_index <= 0;
                        state <= STOP_BIT;
                    end
                end
            end

            STOP_BIT: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    rx_byte <= rx_shift;
                    rx_valid <= 1'b1;
                    clk_count <= 0;
                    state <= CLEANUP;
                end
            end

            CLEANUP: begin
                rx_valid <= 1'b0;
                state <= IDLE;
            end

            default: state <= IDLE;

        endcase
    end

endmodule