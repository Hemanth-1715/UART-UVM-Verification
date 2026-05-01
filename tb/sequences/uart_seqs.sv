// =============================================================================
// SEQUENCES
// =============================================================================

// --- Base: single random byte ---
class uart_base_seq extends uvm_sequence #(uart_seq_item);
  `uvm_object_utils(uart_base_seq)

  function new(string name = "uart_base_seq"); 
    super.new(name); 
  endfunction

  virtual task body();
    uart_seq_item item = uart_seq_item::type_id::create("item");
    start_item(item);
    if (!item.randomize()) begin
      `uvm_fatal("RAND", "Randomisation failed")
    end
    `uvm_info(get_type_name(), $sformatf("Sending: %s", item.convert2string()), UVM_MEDIUM)
    finish_item(item);
  endtask
endclass : uart_base_seq

// --- Directed: corner-case bytes ---
class uart_directed_seq extends uvm_sequence #(uart_seq_item);
  `uvm_object_utils(uart_directed_seq)

  function new(string name = "uart_directed_seq"); 
    super.new(name); 
  endfunction

task body();
    uart_seq_item item = uart_seq_item::type_id::create("item");
    
    start_item(item); 
    
    // --- YOUR CUSTOM INPUT HERE ---
    item.data = 8'hF6; 
    item.txStart = 1'b1;
    // ------------------------------
    
    `uvm_info(get_type_name(), $sformatf("Directed send: 0x%0h", item.data), UVM_MEDIUM)
    
    finish_item(item); 
  endtask
endclass : uart_directed_seq

// --- Reset: interrupt mid-transaction ---
class uart_reset_seq extends uvm_sequence #(uart_seq_item);
  `uvm_object_utils(uart_reset_seq)

  function new(string name = "uart_reset_seq"); 
    super.new(name); 
  endfunction

  virtual task body();
    // Pre-reset
    begin
      uart_seq_item item = uart_seq_item::type_id::create("pre");
      start_item(item);
      if (!item.randomize()) `uvm_fatal("RAND", "fail")
      finish_item(item);
    end

    // Interrupted byte
    begin
      uart_seq_item item = uart_seq_item::type_id::create("mid");
      start_item(item);
      item.data    = 8'hBE; 
      item.txStart = 1;
      finish_item(item);
    end

    // Recovery byte
    begin
      uart_seq_item item = uart_seq_item::type_id::create("post");
      start_item(item);
      item.data    = 8'hEF; 
      item.txStart = 1;
      finish_item(item);
    end
  endtask
endclass : uart_reset_seq