// =============================================================================
// ENVIRONMENT: uart_env
// =============================================================================
class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)

  uart_tx_agent  tx_agent;
  uart_rx_agent  rx_agent;
  uart_scoreboard sb;
  uart_coverage   cov;

  function new(string name = "uart_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    tx_agent = uart_tx_agent::type_id::create("tx_agent", this);
    rx_agent = uart_rx_agent::type_id::create("rx_agent", this);
    sb       = uart_scoreboard::type_id::create("sb", this);
    cov      = uart_coverage::type_id::create("cov", this);

    uvm_config_db #(uvm_active_passive_enum)::set(this, "tx_agent", "is_active", UVM_ACTIVE);
    uvm_config_db #(uvm_active_passive_enum)::set(this, "rx_agent", "is_active", UVM_ACTIVE);
  endfunction

  function void connect_phase(uvm_phase phase);
    // Monitors -> Scoreboard
    tx_agent.ap.connect(sb.tx_export);
    rx_agent.ap.connect(sb.rx_export);

    // Monitors -> Coverage
    tx_agent.ap.connect(cov.analysis_export);
    rx_agent.ap.connect(cov.analysis_export);
  endfunction

endclass : uart_env