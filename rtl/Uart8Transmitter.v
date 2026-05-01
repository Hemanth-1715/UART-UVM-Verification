`include "UartStates.vh"

module Uart8Transmitter (
    input  wire       clk,
    input  wire       en,
    input  wire       start,
    input  wire [7:0] in,
    output reg        out = 1'b1,  // Default to High (Idle)
    output reg        done = 1'b0,
    output reg        busy = 1'b0
);
    reg [2:0] state = `IDLE;
    reg [7:0] data  = 8'b0;
    reg [2:0] bitIdx = 3'b0;

    always @(posedge clk) begin
        if (!en) begin
            state <= `IDLE;
            out   <= 1'b1;
            busy  <= 1'b0;
            done  <= 1'b0;
        end else begin
            case (state)
                `IDLE: begin
                    out    <= 1'b1;
                    done   <= 1'b0;
                    busy   <= 1'b0;
                    bitIdx <= 3'b0;
                    if (start) begin
                        data  <= in;
                        state <= `START_BIT;
                        busy  <= 1'b1;
                    end
                end

                `START_BIT: begin
                    out   <= 1'b0; // Start bit is Low
                    state <= `DATA_BITS;
                end

                `DATA_BITS: begin
                    out <= data[bitIdx];
                    if (bitIdx == 3'd7) begin
                        bitIdx <= 3'b0;
                        state  <= `STOP_BIT;
                    end else begin
                        bitIdx <= bitIdx + 1'b1;
                    end
                end

                `STOP_BIT: begin
                    out   <= 1'b1; // Stop bit is High
                    done  <= 1'b1;
                    state <= `IDLE;
                end

                default: state <= `IDLE;
            endcase
        end
    end
endmodule