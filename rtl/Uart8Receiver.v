`include "UartStates.vh"

module Uart8Receiver (
    input  wire       clk,
    input  wire       en,
    input  wire       in,
    output reg [7:0]  out = 0,
    output reg        done = 0,
    output reg        busy = 0,
    output reg        err = 0
);
    reg [2:0] state = `IDLE;
    reg [2:0] bitIdx = 0;
    reg [1:0] inputSw = 2'b11; // Initialize to High to prevent false starts
    reg [3:0] clockCount = 0;
    reg [7:0] receivedData = 0;

    always @(posedge clk) begin
        inputSw <= {inputSw[0], in}; // Non-blocking for stability

        if (!en) begin
            state <= `IDLE;
            busy  <= 0;
            done  <= 0;
            err   <= 0;
        end else begin
            case (state)
                `IDLE: begin
                    done <= 1'b0;
                    if (inputSw == 2'b10) begin // Falling edge (Start bit)
                        busy <= 1'b1;
                        clockCount <= 0;
                        state <= `START_BIT;
                    end
                end

                `START_BIT: begin
                    if (clockCount == 4'd7) begin // Sample middle of start bit
                        if (inputSw[0] == 1'b0) begin
                            clockCount <= 0;
                            bitIdx <= 0;
                            state <= `DATA_BITS;
                        end else begin
                            state <= `IDLE; // False start
                        end
                    end else begin
                        clockCount <= clockCount + 1'b1;
                    end
                end

                `DATA_BITS: begin
                    if (clockCount == 4'd15) begin
                        clockCount <= 0;
                        receivedData[bitIdx] <= inputSw[0];
                        if (bitIdx == 3'd7) begin
                            state <= `STOP_BIT;
                        end else begin
                            bitIdx <= bitIdx + 1'b1;
                        end
                    end else begin
                        clockCount <= clockCount + 1'b1;
                    end
                end

                `STOP_BIT: begin
                    if (clockCount == 4'd15) begin
                        out   <= receivedData;
                        done  <= 1'b1;
                        busy  <= 1'b0;
                        state <= `IDLE;
                    end else begin
                        clockCount <= clockCount + 1'b1;
                    end
                end

                default: state <= `IDLE;
            endcase
        end
    end
endmodule