// =============================================================================
// RX MONITOR
// =============================================================================
class uart_rx_monitor extends uvm_monitor;
  `uvm_component_utils(uart_rx_monitor)

  uvm_analysis_port #(uart_seq_item) ap;
  virtual uart_if vif;


  function new(string name = "uart_rx_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "uart_rx_monitor: vif not found")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      uart_seq_item item;
      @(posedge vif.mon_cb.rxDone);
      
      item         = uart_seq_item::type_id::create("rx_mon");
      item.rx_data = vif.mon_cb.out;
      item.rx_done = 1'b1;
      item.rx_err  = vif.mon_cb.rxErr;
      
      `uvm_info(get_type_name(), 
                $sformatf("RX captured: 0x%0h err=%0b", item.rx_data, item.rx_err), 
                UVM_HIGH)
      ap.write(item);
    end
  endtask
endclass : uart_rx_monitor