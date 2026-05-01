// =============================================================================
// SEQUENCE ITEM: uart_seq_item
// =============================================================================
class uart_seq_item extends uvm_sequence_item;

  // Rand Fields
  rand logic [7:0] data;
  rand logic       txStart;

  // Non-Rand Fields (Response/Status)
  logic [7:0] rx_data;
  logic       rx_done;
  logic       rx_err;

  // UVM Automation Macros
  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(data,    UVM_ALL_ON)
    `uvm_field_int(rx_data, UVM_ALL_ON)
    `uvm_field_int(rx_done, UVM_ALL_ON)
    `uvm_field_int(rx_err,  UVM_ALL_ON)
  `uvm_object_utils_end

  // Constraints
  constraint valid_start_c { 
    txStart == 1'b1; 
  }

  constraint data_dist_c {
    data dist {
      8'h00          := 5,
      8'hFF          := 5,
      8'hAA          := 5,
      8'h55          := 5,
      [8'h01:8'hFE]  := 80
    };
  }

  // Constructor
  function new(string name = "uart_seq_item");
    super.new(name);
  endfunction

  // String Conversion
  function string convert2string();
    return $sformatf("TX=0x%0h | RX=0x%0h done=%0b err=%0b",
                     data, rx_data, rx_done, rx_err);
  endfunction

endclass : uart_seq_item