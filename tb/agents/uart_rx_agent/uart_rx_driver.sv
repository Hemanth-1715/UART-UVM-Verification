// =============================================================================
// RX DRIVER
// =============================================================================
class uart_rx_driver extends uvm_driver #(uart_seq_item);
  `uvm_component_utils(uart_rx_driver)

  virtual uart_if vif;

  function new(string name = "uart_rx_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "uart_rx_driver: vif not found")
  endfunction

  task run_phase(uvm_phase phase);
    vif.rx_cb.rxEn <= 1'b0;
    vif.rx_cb.rx   <= 1'b1;
    
    repeat(5) @(vif.rx_cb);
    vif.rx_cb.rxEn <= 1'b1;
    @(vif.rx_cb);

    // In loopback mode rx is wired to tx in tb_top — no further driving needed
    forever begin
      uart_seq_item item;
      seq_item_port.get_next_item(item);
      seq_item_port.item_done();
    end
  endtask
endclass : uart_rx_driver
