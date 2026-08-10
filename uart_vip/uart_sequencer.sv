class uart_sequencer extends uvm_sequencer #(uart_seq_item);

  `uvm_component_utils(uart_sequencer)

  // Configuration handle
  uart_cfg cfg_h;

  function new(string name="uart_sequencer",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db#(uart_cfg)::get(this,"","uart_cfg",cfg_h))
      `uvm_fatal(get_type_name(),"Unable to get uart_cfg")

  endfunction

endclass