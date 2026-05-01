// =============================================================================
// COVERAGE COLLECTOR: uart_coverage
// =============================================================================
class uart_coverage extends uvm_subscriber #(uart_seq_item);
  `uvm_component_utils(uart_coverage)

  uart_seq_item current_item;

  // Covergroup for Transmitted Data
  covergroup tx_cg;
    cp_data: coverpoint current_item.data {
      bins zero     = {8'h00};
      bins ones     = {8'hFF};
      bins alt_10   = {8'hAA};
      bins alt_01   = {8'h55};
      bins lsb_only = {8'h01};
      bins msb_only = {8'h80};
      bins rest[8]  = {[8'h02:8'hFE]};
    }
  endgroup

  // Covergroup for Received Data and Errors
  covergroup rx_cg;
    cp_data: coverpoint current_item.rx_data {
      bins zero     = {8'h00};
      bins ones     = {8'hFF};
      bins rest[16] = {[8'h01:8'hFE]};
    }
    cp_err: coverpoint current_item.rx_err {
      bins ok  = {1'b0};
      bins err = {1'b1};
    }
  endgroup

  // Constructor
  function new(string name = "uart_coverage", uvm_component parent = null);
    super.new(name, parent);
    tx_cg = new();
    rx_cg = new();
  endfunction

  // Write function called by analysis ports
  function void write(uart_seq_item t);
    current_item = t;
    if (t.txStart) tx_cg.sample();
    if (t.rx_done) rx_cg.sample();
  endfunction

  // Report phase to display final coverage metrics
  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf(
      "TX functional coverage = %.1f%% | RX functional coverage = %.1f%%",
      tx_cg.get_coverage(), rx_cg.get_coverage()), UVM_NONE)
  endfunction

endclass : uart_coverage