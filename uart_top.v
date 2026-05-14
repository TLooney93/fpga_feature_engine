module uart_top (
    input        CLOCK_50,
    input        UART_RX,
    output [7:0] LEDR
);

    wire rx_valid;
    wire [7:0] rx_byte;

    uart_rx #(
        .CLKS_PER_BIT(434)
    ) receiver (
        .clk(CLOCK_50),
        .rx_serial(UART_RX),
        .rx_valid(rx_valid),
        .rx_byte(rx_byte)
    );

    assign LEDR = rx_byte;

endmodule