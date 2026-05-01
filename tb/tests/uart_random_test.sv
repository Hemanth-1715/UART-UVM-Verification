// --- Random Test ---
class uart_random_test extends uvm_test;
  `uvm_component_utils(uart_random_test)

  uart_env      env;
  int unsigned  num_transactions = 1000;

  function new(string name = "uart_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = uart_env::type_id::create("env", this);
    void'($value$plusargs("num_tx=%0d", num_transactions));
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), $sformatf("=== uart_random_test START: %0d txns ===", num_transactions), UVM_NONE)
    
    for (int i = 0; i < num_transactions; i++) begin
      uart_base_seq seq = uart_base_seq::type_id::create($sformatf("seq%0d", i));
      seq.start(env.tx_agent.seqr);
      #100000;
    end
    
    #500000;
    `uvm_info(get_type_name(), "=== uart_random_test END ===", UVM_NONE)
    phase.drop_objection(this);
  endtask
endclass : uart_random_test