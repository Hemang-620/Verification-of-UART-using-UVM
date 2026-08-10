class env_cfg extends uvm_object;

  `uvm_object_utils(env_cfg)

  apb_cfg  apb_cfg_h;

  uart_cfg uart_cfg_h;

  uart_reg_block ral_h;

  uart_adapter adapter_h;

  `include "../test/uart_reg_defs.svh"

  bit has_scoreboard = 1;

  bit has_coverage = 1;


  function new(string name="env_cfg");
    super.new(name);
  endfunction

endclass