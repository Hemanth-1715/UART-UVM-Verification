// =============================================================================
// TX DRIVER
// =============================================================================
class uart_tx_driver extends uvm_driver #(uart_seq_item);
  `uvm_component_utils(uart_tx_driver)

  virtual uart_if vif;

  function new(string name = "uart_tx_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "uart_tx_driver: vif not found in config DB")
  endfunction

  task run_phase(uvm_phase phase);
    // Reset signals
    vif.tx_cb.txEn    <= 1'b0;
    vif.tx_cb.txStart <= 1'b0;
    vif.tx_cb.in      <= 8'h00;
    
    repeat(10) @(vif.tx_cb);
    vif.tx_cb.txEn    <= 1'b1;
    //@(vif.tx_cb);

    forever begin
      uart_seq_item item;
      seq_item_port.get_next_item(item);
      drive_item(item);
      seq_item_port.item_done();
    end
  endtask

task drive_item(uart_seq_item item);
    `uvm_info(get_type_name(), $sformatf("Driving data: 0x%0h", item.data), UVM_HIGH)
    
    // 1. Put data on the bus and raise Start flag
    vif.tx_cb.in <= item.data;
    vif.tx_cb.txStart <= 1'b1;
    
    // 2. Hold it so the hardware sees it
  repeat(400) @(vif.tx_cb); 
    
    // 3. Drop the flag
    vif.tx_cb.txStart <= 1'b0;

    // 4. Wait for the hardware to finish
    fork
      begin : wait_done
        @(posedge vif.tx_cb.txDone);
      end
      begin : timeout
        repeat(5000) @(vif.tx_cb); // 5000 is plenty of time
        `uvm_error("TX_TMO", $sformatf("txDone timeout for data=0x%0h", item.data))
      end
    join_any
    disable fork;
endtask
endclass : uart_tx_driver