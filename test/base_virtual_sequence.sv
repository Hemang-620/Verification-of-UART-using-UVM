class base_virtual_sequence extends uvm_sequence;

  `uvm_object_utils(base_virtual_sequence)
  `uvm_declare_p_sequencer(virtual_sequencer)

  function new(string name="base_virtual_sequence");
    super.new(name);
  endfunction

endclass