// =============================================================================
// RX AGENT
// =============================================================================
class uart_rx_agent extends uvm_agent;
  `uvm_component_utils(uart_rx_agent)

  uart_rx_driver                 drv;
  uvm_sequencer #(uart_seq_item) seqr;
  uart_rx_monitor                mon;
  uvm_analysis_port #(uart_seq_item) ap;

  function new(string name = "uart_rx_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap  = new("ap", this);
    mon = uart_rx_monitor::type_id::create("mon", this);
    
    if (get_is_active() == UVM_ACTIVE) begin
      drv  = uart_rx_driver::type_id::create("drv", this);
      seqr = uvm_sequencer #(uart_seq_item)::type_id::create("seqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    mon.ap.connect(ap);
    if (get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass : uart_rx_agent