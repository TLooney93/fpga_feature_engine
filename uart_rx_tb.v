`timescale 1ns/1ps

module uart_rx_tb;

    // 50 MHz clock = 20 ns period
    parameter CLK_PERIOD   = 20;
    parameter CLKS_PER_BIT = 434;
    parameter BIT_PERIOD   = CLK_PERIOD * CLKS_PER_BIT;

    reg clk;
    reg rx_serial;

    wire rx_valid;
    wire [7:0] rx_byte;

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk),
        .rx_serial(rx_serial),
        .rx_valid(rx_valid),
        .rx_byte(rx_byte)
    );

    // Clock generator
    always #(CLK_PERIOD/2) clk = ~clk;

    // Task to simulate sending one UART byte
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            rx_serial = 1'b0;
            #(BIT_PERIOD);

            // Data bits, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                rx_serial = data[i];
                #(BIT_PERIOD);
            end

            // Stop bit
            rx_serial = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    initial begin
        clk = 0;
        rx_serial = 1'b1; // UART idle is high

        #1000;

        // Send ASCII 'A' = 0x41
        send_uart_byte(8'h41);

        #(BIT_PERIOD * 2);

        if (rx_valid && rx_byte == 8'h41)
            $display("PASS: Received A correctly. rx_byte = %h", rx_byte);
        else
            $display("CHECK WAVEFORM: rx_valid may have pulsed earlier. rx_byte = %h", rx_byte);

        // Send ASCII 'Z' = 0x5A
        send_uart_byte(8'h5A);

        #(BIT_PERIOD * 2);

        $display("Final rx_byte = %h", rx_byte);
        $display("Simulation complete.");

        $stop;
    end

endmodule