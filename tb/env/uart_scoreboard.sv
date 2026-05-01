// =============================================================================
// SCOREBOARD: uart_scoreboard
// =============================================================================
class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  uvm_tlm_analysis_fifo #(uart_seq_item) tx_fifo, rx_fifo;
  uvm_analysis_export   #(uart_seq_item) tx_export, rx_export;

  int unsigned pass_count = 0;
  int unsigned fail_count = 0;

  function new(string name = "uart_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Build the FIFOs
    tx_fifo = new("tx_fifo", this);
    rx_fifo = new("rx_fifo", this);
    
    tx_export = new("tx_export", this);
    rx_export = new("rx_export", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    tx_export.connect(tx_fifo.analysis_export);
    rx_export.connect(rx_fifo.analysis_export);
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      uart_seq_item tx_item, rx_item;

      // Blocking get from FIFOs
      tx_fifo.get(tx_item);
      rx_fifo.get(rx_item);

      // Check data integrity
      if (tx_item.data !== rx_item.rx_data) begin
        `uvm_error("SB_MISMATCH", 
          $sformatf("Data mismatch - sent: 0x%0h received: 0x%0h", 
          tx_item.data, rx_item.rx_data))
        fail_count++;
      end else begin
        `uvm_info("SB_PASS", 
          $sformatf("Data match - 0x%0h OK", tx_item.data), UVM_MEDIUM)
        pass_count++;
      end

      // Check no framing error
      if (rx_item.rx_err) begin
        `uvm_error("SB_FRAME_ERR", 
          $sformatf("Framing error on 0x%0h", rx_item.rx_data))
        fail_count++;
      end

      // Check rxDone was seen
      if (!rx_item.rx_done) begin
        `uvm_error("SB_NO_DONE", "rxDone was never seen for this transaction")
        fail_count++;
      end
    end
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info("SB_REPORT", $sformatf(
      "\n============ Scoreboard Summary ============\n PASS : %0d\n FAIL : %0d\n============================================",
      pass_count, fail_count), UVM_NONE)
    
    if (fail_count > 0)
    `uvm_error("SB_FINAL", "** TEST FAILED (Mismatches found) **")
  else if (pass_count == 0) // <--- ADD THIS CHECK
    `uvm_error("SB_FINAL", "** TEST FAILED (No data was received!) **")
  else
    `uvm_info("SB_FINAL", "** TEST PASSED **", UVM_NONE)
endfunction

endclass : uart_scoreboard