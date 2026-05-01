// =============================================================================
// TX MONITOR
// =============================================================================
class uart_tx_monitor extends uvm_monitor;
  `uvm_component_utils(uart_tx_monitor)

  uvm_analysis_port #(uart_seq_item) ap;
  virtual uart_if vif;

  function new(string name = "uart_tx_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "uart_tx_monitor: vif not found")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      uart_seq_item item;
      @(posedge vif.mon_cb.txStart);
      item         = uart_seq_item::type_id::create("tx_mon");
      item.data    = vif.mon_cb.in;
      item.txStart = 1'b1;
      
      `uvm_info(get_type_name(), $sformatf("TX captured: 0x%0h", item.data), UVM_HIGH)
      ap.write(item);
    end
  endtask
endclass : uart_tx_monitor