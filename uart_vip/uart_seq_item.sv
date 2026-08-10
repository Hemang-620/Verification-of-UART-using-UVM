class uart_seq_item extends uvm_sequence_item;

  rand bit [7:0] data;
  rand bit [1:0] wlen;

  rand bit parity_en;
  rand bit even_parity;

  rand bit stop2;

  // -----------------------------
  // Fields sampled by Monitor
  // -----------------------------
  bit parity_bit;
  bit stop_bit1;
  bit stop_bit2;

  constraint valid_wlen_c {
    wlen inside {[0:3]};
  }

  `uvm_object_utils_begin(uart_seq_item)

    `uvm_field_int(data        , UVM_ALL_ON)
    `uvm_field_int(wlen        , UVM_ALL_ON)
    `uvm_field_int(parity_en   , UVM_ALL_ON)
    `uvm_field_int(even_parity , UVM_ALL_ON)
    `uvm_field_int(stop2       , UVM_ALL_ON)

    `uvm_field_int(parity_bit  , UVM_ALL_ON)
    `uvm_field_int(stop_bit1   , UVM_ALL_ON)
    `uvm_field_int(stop_bit2   , UVM_ALL_ON)

  `uvm_object_utils_end

  function new(string name = "uart_seq_item");
    super.new(name);
  endfunction

endclass