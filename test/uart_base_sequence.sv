class uart_base_sequence extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(uart_base_sequence)

  function new(string name="uart_base_sequence");
    super.new(name);
  endfunction

endclass