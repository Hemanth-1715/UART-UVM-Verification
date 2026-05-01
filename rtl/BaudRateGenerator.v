module BaudRateGenerator #(
    parameter CLOCK_RATE = 100000000,
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    output reg rxClk = 0,
    output reg txClk = 0
);
    // Fixed: Subtract 1 to account for 0-based counting
    parameter MAX_RATE_RX = (CLOCK_RATE / (2 * BAUD_RATE * 16)) - 1;
    parameter MAX_RATE_TX = (CLOCK_RATE / (2 * BAUD_RATE)) - 1;

    parameter RX_CNT_WIDTH = $clog2(MAX_RATE_RX + 1);
    parameter TX_CNT_WIDTH = $clog2(MAX_RATE_TX + 1);

    reg [RX_CNT_WIDTH - 1:0] rxCounter = 0;
    reg [TX_CNT_WIDTH - 1:0] txCounter = 0;

    always @(posedge clk) begin
        // RX Clock Divider
        if (rxCounter >= MAX_RATE_RX) begin
            rxCounter <= 0;
            rxClk <= ~rxClk;
        end else begin
            rxCounter <= rxCounter + 1'b1;
        end

        // TX Clock Divider
        if (txCounter >= MAX_RATE_TX) begin
            txCounter <= 0;
            txClk <= ~txClk;
        end else begin
            txCounter <= txCounter + 1'b1;
        end
    end
endmodule