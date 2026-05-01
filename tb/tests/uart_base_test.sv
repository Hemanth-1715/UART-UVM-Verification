// --- Base Test ---
class uart_base_test extends uvm_test;
  `uvm_component_utils(uart_base_test)

  uart_env env;

  function new(string name = "uart_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = uart_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    uart_base_seq seq = uart_base_seq::type_id::create("seq");
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "=== uart_base_test START ===", UVM_NONE)
    
    seq.start(env.tx_agent.seqr);
    
    #500000;
    `uvm_info(get_type_name(), "=== uart_base_test END ===", UVM_NONE)
    phase.drop_objection(this);
  endtask
endclass : uart_base_test