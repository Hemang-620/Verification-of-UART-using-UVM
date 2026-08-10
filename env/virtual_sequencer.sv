class virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(virtual_sequencer)

  apb_sequencer  apb_seqr;
  uart_sequencer uart_seqr;

  uart_cfg uart_cfg_h;
  uart_reg_block ral_h;
  function new(string name="virtual_sequencer",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

endclass