import uvm_pkg::*;
`include "uvm_macros.svh"

`include "uart_if.sv"

`include "uart_seq_item.sv"
`include "uart_seqs.sv"

`include "uart_tx_agent_pkg.sv"
`include "uart_rx_agent_pkg.sv"

`include "uart_scoreboard.sv"
`include "uart_coverage.sv"

`include "uart_env.sv"
`include "uart_tests.sv"

module tb_top;
  parameter CLOCK_RATE = 16_000_000;
  parameter BAUD_RATE  = 100_000;

  logic clk = 0;
  always #5 clk = ~clk;

  uart_if dut_if (.clk(clk));

 
  Uart8 #(.CLOCK_RATE(CLOCK_RATE), .BAUD_RATE(BAUD_RATE)) dut (
    .clk     (clk),
    .rx      (dut_if.tx), // Loopback
    .rxEn    (dut_if.rxEn),
    .out     (dut_if.out),
    .rxDone  (dut_if.rxDone),
    .rxBusy  (dut_if.rxBusy),
    .rxErr   (dut_if.rxErr),
    .tx      (dut_if.tx),
    .txEn    (dut_if.txEn),
    .txStart (dut_if.txStart),
    .in      (dut_if.in),
    .txDone  (dut_if.txDone),
    .txBusy  (dut_if.txBusy)
  );

  initial begin
    dut_if.txEn    = 1'b0;
    dut_if.rxEn    = 1'b0; 
    dut_if.txStart = 1'b0;
    
    #100; 
    dut_if.txEn    = 1'b1;
    dut_if.rxEn    = 1'b1; 
  end
  initial begin
    uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.*", "vif", dut_if);
    
    // --- RUN YOUR CUSTOM TEST HERE ---
    run_test("uart_random_test"); 
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end
endmodule : tb_top